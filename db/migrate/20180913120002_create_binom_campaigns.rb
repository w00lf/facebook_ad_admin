class CreateBinomCampaigns < ActiveRecord::Migration[5.1]
  def change
    create_table :binom_campaigns do |t|
      t.string :binom_identificator
      t.string :facebook_campaign_identificator
      t.string :name
      t.references :facebook_account, foreign_key: { delete: :cascade }

      t.timestamps
    end
  end
end
