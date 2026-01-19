# app/controllers/api/stores_controller.rb
class Api::StoresController < ApplicationController
  before_action :verify_current_shop
  
  def index
    @stores = Store.excluding_current(current_shop_domain)
    render json: {
      stores: @stores.map { |s| { id: s.id, domain: s.shop_domain } }
    }
  end
  
  private
  
  def current_shop_domain
    @current_shop_domain ||= params[:shop] || session[:shopify_domain]
  end
  
  def verify_current_shop
    head :unauthorized unless current_shop_domain
  end
end

# app/controllers/api/products_controller.rb
class Api::ProductsController < ApplicationController
  before_action :set_shopify_session
  
  def index
    client = ShopifyAPI::Clients::Rest.new(session: @session)
    response = client.get(path: 'products', query: { limit: 50 })
    
    render json: {
      products: response.body['products'].map do |product|
        {
          id: product['id'],
          title: product['title'],
          price: product['variants'].first['price'],
          image: product['image']&.dig('src')
        }
      end
    }
  end
  
  private
  
  def set_shopify_session
    @session = ShopifyAPI::Utils::SessionUtils.load_current_session(
      request.headers
    )
    head :unauthorized unless @session
  end
end

# app/controllers/api/sync_controller.rb
class Api::SyncController < ApplicationController
  before_action :set_shopify_session
  
  def create
    source_store = Store.find_by(shop_domain: @session.shop)
    target_store = Store.find(params[:target_store_id])
    
    products = params[:product_ids].map do |product_id|
      ProductSyncMapping.sync_product(source_store, target_store, product_id)
    end
    
    render json: {
      success: true,
      message: "#{products.count} products queued for sync"
    }
  end
  
  def sync_status
    mapping = ProductSyncMapping.find(params[:mapping_id])
    render json: {
      status: mapping.sync_logs.last&.status || 'pending',
      last_sync: mapping.sync_logs.last&.created_at
    }
  end
end