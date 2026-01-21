class SyncProductJob < ApplicationJob
  queue_as :default
  
  def perform(product_sync_id)
    product_sync = ProductSync.find(product_sync_id)
    
    # Get source store product data
    source_product = fetch_product_from_store(
      product_sync.source_store, 
      product_sync.source_product_id
    )
    
    # Sync to target store
    if product_sync.target_product_id
      # Update existing product in target store
      update_product_in_store(
        product_sync.target_store,
        product_sync.target_product_id,
        source_product,
        product_sync
      )
    else
      # Create new product in target store
      target_product_id = create_product_in_store(
        product_sync.target_store,
        source_product,
        product_sync
      )
      product_sync.update!(target_product_id: target_product_id)
    end
    
    product_sync.update!(last_synced_at: Time.current)
  end
  
  private
  
  def fetch_product_from_store(store, product_id)
    response = HTTParty.get(
      "https://#{store.shopify_domain}/admin/api/2024-01/products/#{product_id}.json",
      headers: {
        'X-Shopify-Access-Token' => store.shopify_token,
        'Content-Type' => 'application/json'
      }
    )
    
    raise "Failed to fetch product: #{response.code}" unless response.success?
    JSON.parse(response.body)['product']
  end
  
  def create_product_in_store(store, source_product, product_sync)
    product_data = prepare_product_data(source_product, product_sync)
    
    response = HTTParty.post(
      "https://#{store.shopify_domain}/admin/api/2024-01/products.json",
      headers: {
        'X-Shopify-Access-Token' => store.shopify_token,
        'Content-Type' => 'application/json'
      },
      body: { product: product_data }.to_json
    )
    
    raise "Failed to create product: #{response.code}" unless response.success?
    JSON.parse(response.body)['product']['id']
  end
  
  def update_product_in_store(store, product_id, source_product, product_sync)
    product_data = prepare_product_data(source_product, product_sync)
    
    response = HTTParty.put(
      "https://#{store.shopify_domain}/admin/api/2024-01/products/#{product_id}.json",
      headers: {
        'X-Shopify-Access-Token' => store.shopify_token,
        'Content-Type' => 'application/json'
      },
      body: { product: product_data }.to_json
    )
    
    raise "Failed to update product: #{response.code}" unless response.success?
  end
  
  def prepare_product_data(source_product, product_sync)
    product_data = {}
    
    if product_sync.sync_title_description
      product_data[:title] = source_product['title']
      product_data[:body_html] = source_product['body_html']
      product_data[:product_type] = source_product['product_type']
      product_data[:vendor] = source_product['vendor']
      product_data[:tags] = source_product['tags']
    end
    
    # Handle variants with price and inventory sync
    if source_product['variants'] && (product_sync.sync_price || product_sync.sync_inventory)
      product_data[:variants] = source_product['variants'].map do |variant|
        variant_data = {
          sku: variant['sku'],
          inventory_management: 'shopify'
        }
        
        variant_data[:price] = variant['price'] if product_sync.sync_price
        variant_data[:inventory_quantity] = variant['inventory_quantity'] if product_sync.sync_inventory
        
        variant_data
      end
    end
    
    # Handle images
    if source_product['images'] && product_sync.sync_title_description
      product_data[:images] = source_product['images'].map do |image|
        {
          src: image['src'],
          alt: image['alt']
        }
      end
    end
    
    product_data
  end
end