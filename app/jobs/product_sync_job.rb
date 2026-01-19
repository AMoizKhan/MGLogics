# app/jobs/product_sync_job.rb
class ProductSyncJob < ApplicationJob
  queue_as :default
  retry_on StandardError, attempts: 3, wait: :exponentially_longer
  
  def perform(mapping_id, product_data = nil)
    mapping = ProductSyncMapping.find(mapping_id)
    
    if product_data.nil?
      # Initial sync - fetch from source
      product_data = fetch_product_from_store(
        mapping.source_store, 
        mapping.source_product_id
      )
    end
    
    # Transform and sync
    sync_data = transform_product_data(product_data, mapping.sync_settings)
    sync_product_to_target(mapping, sync_data)
    
    log_sync(mapping, 'success')
  rescue => e
    log_sync(mapping, 'failed', e.message)
    raise e
  end
  
  private
  
  def fetch_product_from_store(store, product_id)
    client = ShopifyAPI::Clients::Rest.new(session: store.shopify_session)
    response = client.get(path: "products/#{product_id}")
    response.body['product']
  end
  
  def transform_product_data(product_data, sync_settings)
    # Remove Shopify-specific IDs
    transformed = product_data.except('id', 'admin_graphql_api_id')
    
    # Apply sync settings
    unless sync_settings['title']
      transformed.delete('title')
    end
    
    unless sync_settings['description']
      transformed.delete('body_html')
    end
    
    # Transform variants
    if transformed['variants']
      transformed['variants'] = transformed['variants'].map do |variant|
        variant_data = variant.except('id', 'product_id', 'admin_graphql_api_id')
        
        unless sync_settings['price']
          variant_data.delete('price')
        end
        
        unless sync_settings['inventory']
          variant_data.delete('inventory_quantity')
          variant_data.delete('inventory_management')
        end
        
        variant_data
      end
    end
    
    transformed
  end
  
  def sync_product_to_target(mapping, product_data)
    client = ShopifyAPI::Clients::Rest.new(session: mapping.target_store.shopify_session)
    
    if mapping.target_product_id.present?
      # Update existing product
      client.put(
        path: "products/#{mapping.target_product_id}",
        body: { product: product_data }
      )
    else
      # Create new product
      response = client.post(
        path: 'products',
        body: { product: product_data }
      )
      
      # Update mapping with new product ID
      new_product_id = response.body['product']['id']
      mapping.update!(target_product_id: new_product_id)
    end
  end
  
  def log_sync(mapping, status, error_message = nil)
    mapping.sync_logs.create!(
      action: 'sync',
      status: status,
      error_message: error_message,
      metadata: { timestamp: Time.current }
    )
  end
end

# app/jobs/webhook_processing_job.rb
class WebhookProcessingJob < ApplicationJob
  queue_as :webhooks
  
  def perform(mapping_id, product_data)
    ProductSyncJob.perform_now(mapping_id, product_data)
  end
end