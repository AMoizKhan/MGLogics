# app/controllers/dashboard_controller.rb
class DashboardController < ApplicationController
  include ShopifyApp::LoginProtection
  
  before_action :login_again_if_different_shop
  before_action :set_shopify_session
  
  def index
    @shop = current_shopify_domain
    render layout: 'embedded_app'
  end
  
  private
  
  def set_shopify_session
    @session = ShopifyAPI::Utils::SessionUtils.load_current_session(
      request.headers
    )
  end
end