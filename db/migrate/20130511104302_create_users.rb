class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username
      t.string :name
      t.string :git_id
      t.string :gravatar_id
      t.string :html_url
      t.string :email
      t.string :location
      t.string :company
      t.string :blog
      t.string :bio
      t.integer :public_repos
      t.integer :public_gists
      t.integer :followers
      t.integer :following

      t.timestamps
    end
  end
end
