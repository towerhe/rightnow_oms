class Product < ActiveRecord::Base
  has_ancestry
  acts_as_cartable
  acts_as_api

  api_accessible :default do |t|
    t.add :id
    t.add :name
    t.add :price
    t.add :group
    t.add :children
    t.add :ancestry
  end
end
