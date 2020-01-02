require 'i18n/tasks'

module E7o
    class Summary
        DEFAULT_LOCALE = 'en'
        
        attr :redis, :used, :unused
        
        def initialize
            @redis = Redis.new url: E7o.config.redis_host
            @_redis_keys = nil
            @all = nil
            @all_without_locale = nil
            @used = []
            @unused = []
            @_count_by_locale = {}
            @_sum_by_locale = {}
        end
        
        def gather_all_keys
            # hackish, forces initialization of I18n
            I18n.t(:foo)
            all_tranlsations = I18n.backend.send(:translations)
            @all = travers_dict_keys("", all_tranlsations).flatten.uniq
            @all_without_locale = @all.map{|x| x[3..-1]}.uniq
            @all
        end
        
        def travers_dict_keys(root, dict)
            dict.map do |key, value|
                res = []  
                if value.is_a?(Hash)
                    if root == ""
                        res += travers_dict_keys(key.to_s, value)
                    else
                        res += travers_dict_keys(root.to_s + "." + key.to_s, value) 
                    end
                    
                else
                    [root.to_s + "." + key.to_s]
                end
            end
        end
        
        module RedisCounts

        	def accessed_keys_by_locale(locale)
                redis.keys("#{locale}.*")
            end

            def accessed_keys
                @_redis_keys ||= redis.keys("*")
            end
            
          	def global_keys
          		@all_without_locale ||= @_redis_keys.map{|x| x[3..-1]}.uniq
          	end
            
            def accessed_key? locale, key
                k = add_locale_to_key(locale, key)
                accessed_keys.include?(k)
            end
            
            def accessed_key_any_locale? key
                global_keys.include?(k)
            end


            def count_by_locale locale
                @_count_by_locale[locale] ||= accessed_keys_by_locale(locale).size
            end
            
            def list_counts_by_locale
                I18n.available_locales.each.reduce({}) do |result, locale|
                    @_count_by_locale[locale] = count_by_locale(locale)
                end
                @_count_by_locale
            end
            
            def sum_all
                I18n.available_locales.each.reduce(0) { |sum, locale| sum += sum_by_locale(locale) }
            end
            
            def sum_by_locale locale
                @_sum_by_locale[locale] ||= accessed_keys_by_locale(locale).reduce(0) {|sum, key| sum += redis.get(key).to_i }
            end
        end
        
        include RedisCounts
        
        module NativeKeys
            def translation_used?(k)
                I18n.available_locales.detect do |locale|
                    accessed_key?(locale, "#{locale}.#{k}")
                end
            end
            
            def native_keys locale = DEFAULT_LOCALE
                local_locale(locale).select_keys do |k,v|
                    yield k
                end
            end
            
            def list_native_keys locale = DEFAULT_LOCALE
                keys = []
                native_keys(locale) { |k| keys << k}
                keys
            end
            
        end
        
        include NativeKeys
        
        def call
        	gather_all_keys

            @all_without_locale.each do |key|
                if translation_used?(key)
                    @used << key
                else
                    @unused << key
                end
            end
            self
        end
        
        private
        def strip_locale_from_key locale, key
            key.sub("#{locale}.", '')
        end
        
        def add_locale_to_key locale, key
            key =~ /^#{locale}\.*/ ? key : "#{locale}.#{key}"
        end
    end
end
