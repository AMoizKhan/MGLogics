# app/controllers/webhooks_controller.rb
class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :verify_webhook
  
  def products_update
    product_data = JSON.parse(request.body.read)
    shop_domain = request.headers['HTTP_X_SHOPIFY_SHOP_DOMAIN']
    
    # Find all sync mappings for this product
    mappings = ProductSyncMapping
      .joins(:source_store)
      .where(stores: { shop_domain: shop_domain })
      .where(source_product_id: product_data['id'])
      .where(sync_enabled: true)
    
    mappings.each do |mapping|
      WebhookProcessingJob.perform_later(mapping.id, product_data)
    end
    
    head :ok
  end
  
  def products_create
    # Similar to products_update
    head :ok
  end
  
  def inventory_update
    inventory_data = JSON.parse(request.body.read)
    shop_domain = request.headers['HTTP_X_SHOPIFY_SHOP_DOMAIN']
    
    # Handle inventory sync
    InventorySyncJob.perform_later(shop_domain, inventory_data)
    
    head :ok
  end
  
  private
  
  def verify_webhook
    data = request.body.read
    request.body.rewind
    
    hmac = request.headers['HTTP_X_SHOPIFY_HMAC_SHA256']
    digest = OpenSSL::Digest.new('sha256')
    calculated_hmac = Base64.strict_encode64(
      OpenSSL::HMAC.digest(digest, ENV['SHOPIFY_API_SECRET'], data)
    )
    
    head :unauthorized unless ActiveSupport::SecurityUtils.secure_compare(calculated_hmac, hmac)
  end
end