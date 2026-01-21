class ProductSync < ApplicationRecord
  belongs_to :source_store, class_name: 'Store'
  belongs_to :target_store, class_name: 'Store'
  
  validates :source_product_id, uniqueness: { scope: [:source_store_id, :target_store_id] }
  
  before_save :update_product_titles
  
  def sync_product!
    SyncProductJob.perform_later(self.id)
  end
  
  private
  
  def update_product_titles
    if source_store && source_product_id && source_product_title.nil?
      product = source_store.fetch_product(source_product_id)
      self.source_product_title = product['title'] if product
    end
  end
end