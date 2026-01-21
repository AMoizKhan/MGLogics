# class HomeController < AuthenticatedController
#   def index
#     @shop = current_shop
#     @current_store = Store.find_by(shopify_domain: @shop.domain)
    
#     # If store not in database, add it
#     unless @current_store
#       @current_store = Store.create!(
#         shopify_domain: @shop.domain,
#         shopify_token: @shop.token,
#         name: @shop.name
#       )
#     end
    
#     # Update token if needed
#     @current_store.update(shopify_token: @shop.token) if @current_store.shopify_token != @shop.token
    
#     render :index
#   end
# end
class HomeController < AuthenticatedController
  def index
    @shop = current_shop
    @current_store = Store.find_by(shopify_domain: @shop.domain)
    
    unless @current_store
      @current_store = Store.create!(
        shopify_domain: @shop.domain,
        shopify_token: @shop.token,
        name: @shop.name
      )
    end
    
    @current_store.update(shopify_token: @shop.token) if @current_store.shopify_token != @shop.token
    
    render :index
  end
end