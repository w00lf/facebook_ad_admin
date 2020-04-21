class CreateBinomServers < ActiveRecord::Migration[5.1]
  def change
    create_table :binom_servers do |t|
      t.string :url
      t.string :api_key

      t.timestamps
    end
  end
end
