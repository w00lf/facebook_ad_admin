class AddApiIdentificatorToFacebookAccounts < ActiveRecord::Migration[5.1]
  def change
    remove_column :facebook_accounts, :api_id, :string
    add_column :facebook_accounts, :api_identificator, :string
  end
end
