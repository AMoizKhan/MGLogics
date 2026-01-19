# app/models/store.rb
class Store < ApplicationRecord
  has_many :source_sync_mappings, 
           class_name: 'ProductSyncMapping', 
           foreign_key: 'source_store_id'
  has_many :target_sync_mappings, 
           class_name: 'ProductSyncMapping', 
           foreign_key: 'target_store_id'
  
  validates :shop_domain, presence: true, uniqueness: true
  validates :access_token, presence: true
  
  def self.excluding_current(current_shop_domain)
    where.not(shop_domain: current_shop_domain).where(is_active: true)
  end
  
  def shopify_session
    ShopifyAPI::Auth::Session.new(
      shop: shop_domain,
      access_token: access_token
    )
  end
end

# app/models/product_sync_mapping.rb
class ProductSyncMapping < ApplicationRecord
  belongs_to :source_store, class_name: 'Store'
  belongs_to :target_store, class_name: 'Store'
  has_many :sync_logs
  
  validates :source_product_id, presence: true
  validates :target_product_id, presence: true
  
  before_create :generate_default_sync_settings
  
  def sync_product_changes(product_data)
    ProductSyncJob.perform_later(id, product_data)
  end
  
  private
  
  def generate_default_sync_settings
    self.sync_settings ||= {
      title: true,
      description: true,
      price: true,
      inventory: true,
      images: true
    }
  end
end

# app/models/sync_log.rb
class SyncLog < ApplicationRecord
  belongs_to :product_sync_mapping
  
  enum status: { pending: 'pending', success: 'success', failed: 'failed' }
end