class CreateProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :products do |t|
      t.string :name
      t.belongs_to :user, foreign_key: true
      t.string :description
      t.decimal :price, precision: 10, scale: 2
      t.integer :in_stock
      t.integer :sku
      t.string :media

      t.timestamps
    end
    add_index :products, :name
    add_index :products, :sku, unique: true
  end
end
