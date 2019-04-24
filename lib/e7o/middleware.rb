require 'redis'

module E7o
  class Middleware
    def initialize(app)
      @redis_connection ||= Redis.new url: E7o.config.redis_host
      @app = app
    end

    def call(env)
      res = @app.call(env)
      if RequestStore.store[:e7o_counter] && e7o_enabled
        begin
          @redis_connection.multi do |multi|
            RequestStore.store[:e7o_counter].map do |key, count|
              multi.incrby(key, count)
            end
          end
        rescue Exception => e
          # Broad exception rescue because we do not want to compromise request
          puts "Could not update i18n counter #{e}"
        end
      end
      res
    end

    private

    def e7o_enabled
      E7o.config.enabled
    end

  end
end
