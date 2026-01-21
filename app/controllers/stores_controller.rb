class StoresController < AuthenticatedController
  def index
    stores = Store.where.not(shopify_domain: current_shopify_domain)
                  .map do |store|
                    {
                      id: store.id,
                      name: store.name,
                      shopify_domain: store.shopify_domain,
                      created_at: store.created_at
                    }
                  end
    
    render json: stores
  end
end