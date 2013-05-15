class CreateTopSkillRepos < ActiveRecord::Migration
  def change
    create_table :top_skill_repos do |t|
      t.string :skill
      t.text :repo_content

      t.timestamps
    end
  end
end
