class ProductsController < AuthenticatedController
  before_action :set_current_shop
  
  def index
    products = @current_shop.fetch_products(limit: 100)
    formatted_products = products.map do |product|
      {
        id: product['id'],
        title: product['title'],
        handle: product['handle'],
        product_type: product['product_type'],
        vendor: product['vendor'],
        created_at: product['created_at'],
        published_at: product['published_at'],
        status: product['status'],
        images: product['images']&.first&.dig('src')
      }
    end
    
    render json: { products: formatted_products }
  end
  
  def create
    target_store = Store.find(params[:target_store_id])
    
    params[:product_ids].each do |product_id|
      # Fetch complete product details from source store
      source_product = @current_shop.fetch_product(product_id)
      
      # Prepare product data for target store
      product_data = {
        product: {
          title: source_product['title'],
          body_html: source_product['body_html'],
          vendor: source_product['vendor'],
          product_type: source_product['product_type'],
          tags: source_product['tags'],
          variants: source_product['variants'].map do |variant|
            {
              price: variant['price'],
              sku: variant['sku'],
              inventory_quantity: variant['inventory_quantity'],
              inventory_management: 'shopify'
            }
          end,
          images: source_product['images'].map do |image|
            {
              src: image['src'],
              alt: image['alt'] || source_product['title']
            }
          end
        }
      }
      
      # Create product in target store
      response = HTTParty.post(
        "https://#{target_store.shopify_domain}/admin/api/2024-01/products.json",
        headers: {
          'X-Shopify-Access-Token' => target_store.shopify_token,
          'Content-Type' => 'application/json'
        },
        body: product_data.to_json
      )
      
      if response.success?
        target_product = JSON.parse(response.body)['product']
        
        # Create sync record
        ProductSync.create!(
          source_store: @current_shop,
          target_store: target_store,
          source_product_id: product_id,
          target_product_id: target_product['id'],
          sync_inventory: true,
          sync_price: true,
          sync_title_description: true,
          active: true
        )
      end
    end
    
    render json: { success: true, message: 'Products synced successfully' }
  end
  
  private
  
  def set_current_shop
    @current_shop = Store.find_by(shopify_domain: current_shopify_domain)
  end
end