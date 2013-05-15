class Skill < ActiveRecord::Base
  attr_accessible :skill, :standing, :user_id
  belongs_to :user
end
