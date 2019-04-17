require 'e7o/middleware'
require 'e7o/railtie' if defined?(Rails)

module I18n
  module E7oKeyRegistry
    def lookup(locale, key, scope = [], options = {})
      separator = options[:separator] || I18n.default_separator
      flat_key = I18n.normalize_keys(locale, key, scope, separator).join(separator)

      RequestStore.store[:e7o_counter] ||= {}
      RequestStore.store[:e7o_counter][flat_key] ||= 0
      RequestStore.store[:e7o_counter][flat_key] += 1

      super
    end
  end
end

I18n::Backend::Simple.send :include, I18n::E7oKeyRegistry
