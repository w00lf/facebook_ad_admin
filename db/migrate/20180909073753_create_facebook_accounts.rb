class CreateFacebookAccounts < ActiveRecord::Migration[5.1]
  def change
    create_table :facebook_accounts do |t|
      t.string :name
      t.string :api_id
      t.string :api_token
      t.string :api_secret
      t.boolean :active
      t.references :facebook_group_account, foreign_key: { delete: :cascade }

      t.timestamps
    end
  end
end
