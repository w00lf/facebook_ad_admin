class AddBelongsToBinomServerToBinomAdsetsAndBinomCampaigns < ActiveRecord::Migration[5.1]
  def change
    add_reference :binom_campaigns, :binom_server, foreign_key: true
    add_reference :binom_adsets, :binom_server, foreign_key: true
  end
end
