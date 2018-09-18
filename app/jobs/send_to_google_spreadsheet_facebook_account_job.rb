class SendToGoogleSpreadsheetFacebookAccountJob
  include Sidekiq::Worker

  def perform(date_unix, facebook_account_id, rows, column_headers)
    date = Time.at(date_unix)
    facebook_account  = FacebookAccount.find(facebook_account_id)
    session = GoogleDrive::Session.from_config(Rails.root.join('config', 'config.json').to_s)
    logger = Logger.new(File.new(Rails.root.join('tmp', 'google_spreadsheet.log'), 'a+'))
    file_name = "Report Facebook Advertisment Report, #{date.strftime("%B")}"
    spreadsheet = session.spreadsheet_by_title(file_name)
    just_created = false
    unless spreadsheet
      just_created = true
      spreadsheet = session.create_spreadsheet(file_name)
    end
    logger.info("Trying to write in spreadsheet")
    result_hash = {
      facebook_account.facebook_group_account.name => rows
    }
    result_hash.each.with_index(1) do |group, group_index|
      group_name, group_rows = group
      worksheet = spreadsheet.worksheet_by_title(group_name)
      worksheet = spreadsheet.add_worksheet(group_name, 1000, 100) unless worksheet
      first_empty_row = (1..1000).find { |row_number| worksheet[row_number,1].blank? }
      result_rows = first_empty_row == 1 ? ([column_headers] + group_rows) : group_rows
      result_rows.each.with_index(first_empty_row) do |row, i|
        row.each.with_index(1) do |attr, j|
          worksheet[i, j] = attr
        end
      end
      worksheet.save
      worksheet.reload
    end
    spreadsheet.worksheets[0].delete if just_created
    logger.info("Finished parsing")
  end
end