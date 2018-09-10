class CreateFacebookGroupAccounts < ActiveRecord::Migration[5.1]
  def change
    create_table :facebook_group_accounts do |t|
      t.string :name
      t.boolean :active

      t.timestamps
    end
  end
end
