class ReadFacebookCreationSpreadsheetJob
  include Sidekiq::Worker
  READY_STATUS = 'ready'

  def perform(file_name:, config_file:)
    session = GoogleDrive::Session.from_config(config_file) # Rails.root.join('config', 'config.json').to_s
    logger = Logger.new(File.new(Rails.root.join('tmp', 'read_facebook_creation_spreadsheet.log'), 'a+'))
    spreadsheet = session.spreadsheet_by_title(file_name)
    worksheet = spreadsheet.worksheets[0]
    headers = worksheet.rows[0]
    worksheet.rows.each.with_index(1) do |row, i|
      attributes = headers.zip(row).to_h
      logger.info("Got attributes: #{attributes}")
      # Skip headers and not ready rows
      next if i == 1 || attributes['Status'] != READY_STATUS
      import_result = ImportResult.create(status: 'in_progress')
      account_id = attributes['Account id']
      facebook_account = FacebookAccount.find_by(api_identificator: account_id)
      if facebook_account.nil?
        not_found_account_error(import_result, account_id)
        worksheet[i, column_index(headers, 'Status')] = "Cannot found account with id: #{account_id}"
        next
      end
      import_result.update(facebook_account: facebook_account)
      serialize_attribute_and_create_entries(facebook_account, attributes)
    end
    worksheet[i, column_index(headers, 'Status')] = "done"
    worksheet.save
  end

  private

  def serialize_attribute_and_create_entries(facebook_account, attributes)
    campaign = create_campign(facebook_account, attributes)
    adset = create_adset(facebook_account, attributes.merge(campaign_id: campaign.id))
    adcreative = create_adcreative(facebook_account, attributes)
    create_ad(facebook_account, attributes, adset, adcreative)
  end

  def create_campign(facebook_account, attributes)
    parsed_attributes = FacebookCreation::CampaignSerializer.new(attributes).as_json
    FacebookCreation::CampaignService.call(facebook_account, parsed_attributes)
  end

  def create_adset(facebook_account, attributes)
    parsed_attributes = FacebookCreation::AdsetSerializer.new(facebook_account: facebook_account,
                                                              adset_attributes: attributes).as_json
    FacebookCreation::AdsetService.call(facebook_account, parsed_attributes)
  end

  def create_adcreative(facebook_account, attributes)
    parsed_attributes = FacebookCreation::AdcreativeSerializer.new(attributes).as_json
    FacebookCreation::AdsetService.call(facebook_account, parsed_attributes)
  end

  def create_ad(facebook_account, attributes, adset, adcreative)
    parsed_attributes = {
      name: attributes.fetch('Ad Name'),
      status: 'PAUSED',
      adset_id: adset.id,
      creative: { creative_id: adcreative.id }
    }
    FacebookCreation::AdService.call(facebook_account, parsed_attributes)
  end

  def not_found_account_error(import_result, account_id)
    import_result.update(status: 'error', error_type: 'Not found account', error_text: "Cannot find account with id: #{account_id}")
  end

  def column_index(headers, name)
    headers.index(name) + 1
  end
end
