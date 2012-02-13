class CreateCartableModels < ActiveRecord::Migration
  def up
    create_table :cartable_models do |t|
      t.string :name_column
      t.decimal :price_column, precision: 10, scale: 2
    end
  end

  def down
    drop_table :cartable_models
  end
end
