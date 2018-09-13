ActiveAdmin.register BinomCampaign do
  permit_params :binom_identificator,
                :facebook_campaign_identificator,
                :name,
                :facebook_account_id
end
