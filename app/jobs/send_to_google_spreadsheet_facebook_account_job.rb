class SendToGoogleSpreadsheetFacebookAccountJob < ApplicationJob
  queue_as :google_spreadsheet

  def perform(date_unix, facebook_account_id, rows, column_headers)
    date = Time.at(date_unix)
    facebook_account  = FacebookAccount.find(facebook_account_id)
    session = GoogleDrive::Session.from_config(Rails.root.join('config', 'config.json').to_s)
    logger = Logger.new(File.new(Rails.root.join('tmp', 'google_spreadsheet.log'), 'a+'))
    file_name = "#{date.strftime("%B")} #{date.strftime("%y")}"

    collection = session.collection_by_url(Settings.google_drive.folder_url)
    spreadsheet = collection.file_by_title(file_name)

    just_created = false
    unless spreadsheet
      just_created = true
      spreadsheet = collection.create_spreadsheet(file_name)
    end
    logger.info("Trying to write in spreadsheet")
    result_hash = {
      facebook_account.facebook_group_account.name => rows
    }
    result_hash.each.with_index(1) do |group, group_index|
      group_name, group_rows = group
      worksheet = spreadsheet.worksheet_by_title(group_name)
      worksheet = spreadsheet.add_worksheet(group_name, 1000, 100) unless worksheet
      first_empty_row = worksheet.num_rows + 1
      logger.info("first_empty_row is #{first_empty_row}")
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
