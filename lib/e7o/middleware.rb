require 'redis'

module E7o
  class Middleware
    def initialize(app)
      if e7o_enabled
        @redis_connection ||= Redis.new url: E7o.config.redis_host
      else
        @redis_connection ||= nil
      end
      @app = app
    end

    def call(env)

      res = @app.call(env)
      if RequestStore.store[:e7o_counter] && e7o_enabled
        data = RequestStore.store[:e7o_counter]
        if E7o.config.threaded
          Thread.new do
            update_store(data)
            Thread.exit
          end
        else
          update_store(data)
        end
      end
      res
    end

    private

    def update_store(data)
      begin
        @redis_connection.multi do |multi|
          data.map do |key, count|
            multi.incrby(key, count)
          end
        end
      rescue Exception => e
        # Broad exception rescue because we do not want to compromise request
        puts "Could not update i18n counter #{e}"
      end
    end

    def e7o_enabled
      E7o.config.enabled
    end
  end
end
