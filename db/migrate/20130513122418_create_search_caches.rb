class CreateSearchCaches < ActiveRecord::Migration
  def change
    create_table :search_caches do |t|
      t.string :key
      t.text :response

      t.timestamps
    end
  end
end
