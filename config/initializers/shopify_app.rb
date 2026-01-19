# config/initializers/shopify_app.rb
require 'shopify_api'

ShopifyAPI::Context.setup(
  api_key: ENV['SHOPIFY_API_KEY'],
  api_secret_key: ENV['SHOPIFY_API_SECRET'],
  host: ENV['HOST'],
  scope: ENV['SCOPES'] || 'read_products,write_products,read_inventory,write_inventory',
  is_embedded: true,
  is_private: false,
  api_version: '2024-01',
  session_storage: ShopifyAPI::Auth::FileSessionStorage.new, # Or use ActiveRecord
  logger: Rails.logger
)

# config/initializers/shopify_session_repository.rb
module ShopifyApp
  class SessionRepository
    class << self
      def store_session(session)
        store = Store.find_or_initialize_by(shop_domain: session.shop)
        store.access_token = session.access_token
        store.save!
        store
      end
      
      def load_session(id)
        store = Store.find_by(shop_domain: id)
        return unless store
        
        ShopifyAPI::Auth::Session.new(
          shop: store.shop_domain,
          access_token: store.access_token
        )
      end
    end
  end
end