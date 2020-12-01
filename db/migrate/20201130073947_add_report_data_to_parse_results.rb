class AddReportDataToParseResults < ActiveRecord::Migration[5.1]
  def change
    add_column :parse_results, :report_date, :date, index: true
  end
end
