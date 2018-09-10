class FacebookGroupAccount < ApplicationRecord
  validates :name, presence: true
end
