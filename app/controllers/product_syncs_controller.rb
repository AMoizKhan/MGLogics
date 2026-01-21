class ProductSyncsController < AuthenticatedController
  before_action :set_current_shop
  
  def index
    @product_syncs = ProductSync.where(source_store: @current_shop)
                                 .or(ProductSync.where(target_store: @current_shop))
                                 .includes(:source_store, :target_store)
    
    syncs_data = @product_syncs.map do |sync|
      {
        id: sync.id,
        source_product_title: sync.source_product_title,
        target_store_name: sync.target_store.name,
        target_product_title: sync.target_product_title,
        active: sync.active,
        sync_title_description: sync.sync_title_description,
        sync_price: sync.sync_price,
        sync_inventory: sync.sync_inventory,
        last_synced_at: sync.last_synced_at
      }
    end
    
    render json: syncs_data
  end
  
  def update
    product_sync = ProductSync.find(params[:id])
    product_sync.update!(product_sync_params)
    product_sync.sync_product! if product_sync.active?
    
    render json: { success: true }
  end
  
  def destroy
    product_sync = ProductSync.find(params[:id])
    
    # Delete the product from target store
    if params[:delete_from_target] == 'true'
      begin
        response = HTTParty.delete(
          "https://#{product_sync.target_store.shopify_domain}/admin/api/2024-01/products/#{product_sync.target_product_id}.json",
          headers: {
            'X-Shopify-Access-Token' => product_sync.target_store.shopify_token
          }
        )
      rescue => e
        # Product might already be deleted
      end
    end
    
    product_sync.destroy
    render json: { success: true }
  end
  
  private
  
  def set_current_shop
    @current_shop = Store.find_by(shopify_domain: current_shopify_domain)
  end
  
  def product_sync_params
    params.require(:product_sync).permit(
      :sync_inventory, :sync_price, :sync_title_description, :active
    )
  end
end