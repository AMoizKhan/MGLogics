# app/controllers/auth_controller.rb
class AuthController < ApplicationController
  def callback
    session = ShopifyAPI::Auth::Oauth::validate_auth_callback(
      cookies: cookies,
      auth_query: ShopifyAPI::Auth::Oauth::AuthQuery.new(params.permit!.to_h)
    )
    
    store = Store.find_or_initialize_by(shop_domain: session.shop)
    store.access_token = session.access_token
    store.is_active = true
    store.save!
    
    # Register webhooks
    register_webhooks(session)
    
    redirect_to root_path
  rescue ShopifyAPI::Errors::InvalidOAuthError => e
    Rails.logger.error("OAuth error: #{e.message}")
    redirect_to login_path, alert: "Authentication failed"
  end
  
  private
  
  def register_webhooks(session)
    webhooks = [
      { topic: 'PRODUCTS_UPDATE', address: "#{ENV['HOST']}/webhooks/products_update" },
      { topic: 'PRODUCTS_CREATE', address: "#{ENV['HOST']}/webhooks/products_create" },
      { topic: 'INVENTORY_LEVELS_UPDATE', address: "#{ENV['HOST']}/webhooks/inventory_update" }
    ]
    
    client = ShopifyAPI::Clients::Rest.new(session: session)
    
    webhooks.each do |webhook|
      begin
        client.post(
          path: 'webhooks',
          body: { webhook: webhook }
        )
      rescue => e
        Rails.logger.error("Failed to register webhook #{webhook[:topic]}: #{e.message}")
      end
    end
  end
end