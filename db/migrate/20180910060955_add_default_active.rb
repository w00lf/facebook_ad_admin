class AddDefaultActive < ActiveRecord::Migration[5.1]
  def change
    change_column :facebook_accounts, :active, :boolean, default: true, null: false
    change_column :facebook_group_accounts, :active, :boolean, default: true, null: false
  end
end
