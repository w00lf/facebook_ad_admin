class BinomServer < ApplicationRecord
  validates :api_key, presence: true
  validates :url, presence: true

  def name
    url
  end
end
