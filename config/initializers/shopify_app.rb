# # config/initializers/shopify_app.rb
# require 'shopify_api'

# ShopifyAPI::Context.setup(
#   api_key: ENV['SHOPIFY_API_KEY'],
#   api_secret_key: ENV['SHOPIFY_API_SECRET'],
#   host: ENV['HOST'],
#   scope: ENV['SCOPES'] || 'read_products,write_products,read_inventory,write_inventory',
#   is_embedded: true,
#   is_private: false,
#   api_version: '2024-01',
#   session_storage: ShopifyAPI::Auth::ActiveRecordStore, # Or use ActiveRecord
#   logger: Rails.logger
# )

# # config/initializers/shopify_session_repository.rb
# module ShopifyApp
#   class SessionRepository
#     class << self
#       def store_session(session)
#         store = Store.find_or_initialize_by(shop_domain: session.shop)
#         store.access_token = session.access_token
#         store.save!
#         store
#       end
      
#       def load_session(id)
#         store = Store.find_by(shop_domain: id)
#         return unless store
        
#         ShopifyAPI::Auth::Session.new(
#           shop: store.shop_domain,
#           access_token: store.access_token
#         )
#       end
#     end
#   end
# end
# config/initializers/shopify_app.rb
require 'shopify_api'

# Custom session store using your Store model
class ActiveRecordSessionStore
  # Store a Shopify session
  def store(session)
    store = Store.find_or_initialize_by(shop_domain: session.shop)
    store.access_token = session.access_token
    store.save!
    store
  end

  # Retrieve a Shopify session by shop domain
  def retrieve(shop_domain)
    store = Store.find_by(shop_domain: shop_domain)
    return unless store

    ShopifyAPI::Auth::Session.new(
      id: shop_domain,
      shop: store.shop_domain,
      access_token: store.access_token,
      api_version: '2024-01'
    )
  end

  # Delete a session
  def delete(shop_domain)
    store = Store.find_by(shop_domain: shop_domain)
    store&.destroy
  end
end

# # Setup ShopifyAPI context
# ShopifyAPI::Context.setup(
#   api_key: ENV.fetch('SHOPIFY_API_KEY'),
#   api_secret_key: ENV.fetch('SHOPIFY_API_SECRET'),
#   host_name: ENV.fetch('HOST'),                    # e.g., 'localhost:3000' or ngrok URL
#   scope: ENV.fetch('SCOPES', 'read_products,write_products,read_inventory,write_inventory').split(','),
#   is_embedded_app: true,
#   api_version: '2024-01',
#   session_storage: ActiveRecordSessionStore.new,
#   logger: Rails.logger
# )
