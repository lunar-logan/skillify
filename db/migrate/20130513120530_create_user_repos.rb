class CreateUserRepos < ActiveRecord::Migration
  def change
    create_table :user_repos do |t|
      t.string :username
      t.text :repos

      t.timestamps
    end
  end
end
