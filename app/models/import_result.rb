class ImportResult < ApplicationRecord
  belongs_to :facebook_account, optional: true
end
