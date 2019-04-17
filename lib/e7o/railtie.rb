require 'request_store'

module E7o
  class Railtie < ::Rails::Railtie
    initializer 'E7o.configure_rails_initialization' do |app|
      app.middleware.use RequestStore::Middleware
      app.middleware.insert_after RequestStore::Middleware, E7o::Middleware
    end
  end
end
