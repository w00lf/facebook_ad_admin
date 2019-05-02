ActiveAdmin.register BinomAdset do
  permit_params :facebook_adset_identificator,
                :name,
                :facebook_account_id

  filter :created_at
  filter :name_cont
  filter :facebook_account_name_cont
end
