class UserRepo < ActiveRecord::Base
  attr_accessible :repos, :username
end
