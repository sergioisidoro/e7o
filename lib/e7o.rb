module E7o
  class Configuration < OpenStruct
    def setup_defaults
      self.redis_host = 'redis://localhost:6379'
      self.enabled = false
      self.threaded = false
    end
  end 

  def self.configure
    @config = Configuration.new
    @config.setup_defaults
    yield(@config) if block_given?
    @config
  end

  def self.config
    @config || configure
  end
end

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

require 'e7o/middleware'
require 'e7o/summary'
require 'e7o/railtie' if defined?(Rails)
