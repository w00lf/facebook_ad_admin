class AddAccountStatusAndDisableReasonToFacebookAccounts < ActiveRecord::Migration[5.1]
  def change
    add_column :facebook_accounts, :account_status, :string
    add_column :facebook_accounts, :disable_reason, :string
  end
end
