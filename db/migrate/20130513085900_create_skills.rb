class CreateSkills < ActiveRecord::Migration
  def change
    create_table :skills do |t|
      t.integer :user_id
      t.string :skill
      t.float :standing

      t.timestamps
    end
  end
end
