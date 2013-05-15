class User < ActiveRecord::Base
  attr_accessible :bio, :blog, :company, :email, :followers, :following, :git_id, :gravatar_id, :html_url, :location, :name, :public_gists, :public_repos, :username
  has_many :skills, :dependent => :destroy
  validates :username, :presence => true
  validates :name, :presence => true
end
