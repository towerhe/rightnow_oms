module RightnowOms
  class Cart < ActiveRecord::Base
    acts_as_api

    belongs_to :shopper

    api_accessible :default do |t|
      t.add :session_id
      t.add :state
    end

    validates :session_id, presence: true
  end
end
