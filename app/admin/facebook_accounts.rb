ActiveAdmin.register FacebookAccount do
  permit_params :active, :name, :api_identificator, :api_token, :api_secret, :facebook_group_account_id

  index do
    id_column
    column :active
    column :name
    column 'Account_id', :api_identificator
    column :api_token do |obj|
      truncate(obj.api_token)
    end
    column :api_secret
    column :facebook_group_account
    actions
  end
end
