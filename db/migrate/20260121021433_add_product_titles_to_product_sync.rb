class AddProductTitlesToProductSync < ActiveRecord::Migration[8.1]
  def change
    add_column :product_syncs, :source_product_title, :string
    add_column :product_syncs, :target_product_title, :string
  end
end
