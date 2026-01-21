class Store < ApplicationRecord
  has_many :source_syncs, class_name: 'ProductSync', foreign_key: 'source_store_id'
  has_many :target_syncs, class_name: 'ProductSync', foreign_key: 'target_store_id'
  
  validates :shopify_domain, presence: true, uniqueness: true
  validates :shopify_token, presence: true
  
  def fetch_store_info
    response = HTTParty.get(
      "https://#{shopify_domain}/admin/api/2024-01/shop.json",
      headers: {
        'X-Shopify-Access-Token' => shopify_token,
        'Content-Type' => 'application/json'
      }
    )
    
    return nil unless response.success?
    JSON.parse(response.body)['shop']
  end
  
  def fetch_products(limit: 50)
    response = HTTParty.get(
      "https://#{shopify_domain}/admin/api/2024-01/products.json",
      headers: {
        'X-Shopify-Access-Token' => shopify_token,
        'Content-Type' => 'application/json'
      },
      query: { limit: limit }
    )
    
    return [] unless response.success?
    JSON.parse(response.body)['products']
  end
  
  def fetch_product(product_id)
    response = HTTParty.get(
      "https://#{shopify_domain}/admin/api/2024-01/products/#{product_id}.json",
      headers: {
        'X-Shopify-Access-Token' => shopify_token,
        'Content-Type' => 'application/json'
      }
    )
    
    return nil unless response.success?
    JSON.parse(response.body)['product']
  end
end