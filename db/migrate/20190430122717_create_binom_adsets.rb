class CreateBinomAdsets < ActiveRecord::Migration[5.1]
  def change
    create_table :binom_adsets do |t|
      t.string :facebook_adset_identificator
      t.string :name
      t.references :facebook_account, foreign_key: true

      t.timestamps
    end
  end
end
