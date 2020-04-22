class AddDailyLimitAndDailyLimitUpdatedAtToFacebookAccounts < ActiveRecord::Migration[5.1]
  def change
    add_column :facebook_accounts, :daily_limit, :string
    add_column :facebook_accounts, :daily_limit_updated_at, :datetime
  end
end
