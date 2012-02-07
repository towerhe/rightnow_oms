class Product < ActiveRecord::Base
  has_ancestry

  acts_as_api

  api_accessible :default do |t|
    t.add :id
    t.add :name
    t.add :price
    t.add :has_children?, as: :hasChildren
    t.add :group
  end

  def has_children?
    return false if self.children.empty?

    true
  end
end
