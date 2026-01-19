# db/migrate/20240101000001_create_stores.rb
class CreateStores < ActiveRecord::Migration[7.0]
  def change
    create_table :stores do |t|
      t.string :shop_domain, null: false, index: { unique: true }
      t.text :access_token, null: false
      t.boolean :is_active, default: true
      t.timestamps
    end
  end
end

# db/migrate/20240101000002_create_product_sync_mappings.rb
class CreateProductSyncMappings < ActiveRecord::Migration[7.0]
  def change
    create_table :product_sync_mappings do |t|
      t.references :source_store, foreign_key: { to_table: :stores }
      t.references :target_store, foreign_key: { to_table: :stores }
      t.bigint :source_product_id, null: false
      t.bigint :target_product_id, null: false
      t.jsonb :variant_mappings
      t.jsonb :sync_settings, default: {
        title: true,
        description: true,
        price: true,
        inventory: true,
        images: true
      }
      t.boolean :sync_enabled, default: true
      t.timestamps
      
      t.index [:source_store_id, :source_product_id, :target_store_id], 
              unique: true, 
              name: 'idx_unique_product_mapping'
    end
  end
end

# db/migrate/20240101000003_create_sync_logs.rb
class CreateSyncLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :sync_logs do |t|
      t.references :product_sync_mapping, foreign_key: true
      t.string :action
      t.string :status
      t.text :error_message
      t.jsonb :metadata
      t.timestamps
    end
  end
end