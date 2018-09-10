ActiveAdmin.register FacebookAccount do
  permit_params :active, :name, :api_identificator, :api_token, :api_secret, :facebook_group_account_id
end
