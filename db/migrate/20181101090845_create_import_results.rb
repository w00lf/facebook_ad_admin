class CreateImportResults < ActiveRecord::Migration[5.1]
  def change
    create_table :import_results do |t|
      t.text :error_type
      t.text :error_text
      t.belongs_to :facebook_account, foreign_key: { on_delete: :cascade }, index: true
      t.text :status

      t.timestamps
    end
  end
end
