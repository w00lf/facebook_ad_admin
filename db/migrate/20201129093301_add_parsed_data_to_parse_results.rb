class AddParsedDataToParseResults < ActiveRecord::Migration[5.1]
  def change
    add_column :parse_results, :parsed_data, :jsonb
  end
end
