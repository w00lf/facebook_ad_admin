class ReadFacebookCreationSpreadsheetJob < ApplicationJob
  queue_as :default

  READY_STATUS = 'ready'

  def perform(file_name:, config_file:)
    session = GoogleDrive::Session.from_config(config_file) # Rails.root.join('config', 'config.json').to_s
    logger = Logger.new(File.new(Rails.root.join('tmp', 'read_facebook_creation_spreadsheet.log'), 'a+'))
    spreadsheet = session.spreadsheet_by_title(file_name)
    worksheet = spreadsheet.worksheets[0]
    headers = worksheet.rows[0].map(&:strip)
    worksheet.rows.each.with_index(1) do |row, i|
      begin
        attributes = headers.zip(row).to_h
        logger.info("Got attributes: #{attributes}")
        # Skip headers and not ready rows
        next if i == 1 || attributes['Status'] != READY_STATUS
        import_result = ImportResult.create(status: 'in_progress')
        account_id = attributes['Account id']
        facebook_account = FacebookAccount.find_by!(api_identificator: account_id)
        import_result.update(facebook_account: facebook_account)
        serialize_attribute_and_create_entries(facebook_account, attributes)
        import_result.update(status: 'ok')
        worksheet[i, column_index(headers, 'Status')] = "done"
      rescue => e
        not_found_account_error(import_result, account_id)
        worksheet[i, column_index(headers, 'Status')] = e.message
      end
    end
    worksheet.save
  end

  private

  def ad_account(facebook_account)
    account_id = facebook_account.api_identificator
    session = FacebookAds::Session.new(access_token: facebook_account.api_token)
    FacebookAds::AdAccount.get("act_#{account_id}", %w[name id currency account_status], session)
  end

  def serialize_attribute_and_create_entries(facebook_account, attributes)
    campaign = find_or_create_campaign(facebook_account, attributes)
    adset = find_or_create_adset(facebook_account, attributes,  campaign)
    image_hash = create_image(facebook_account, attributes.fetch('Image')).first.hash
    adcreative = create_adcreative(facebook_account, attributes.merge('Image hash' => image_hash))
    create_ad(facebook_account, attributes, adset, adcreative)
  end

  def find_or_create_campaign(facebook_account, attributes)
    existing = ad_account(facebook_account).campaigns(fields: ['name']).find {|n| n.name == attributes.fetch('Campaign Name') }
    return existing if existing
    create_campaign(facebook_account, attributes)
  end

  def create_campaign(facebook_account, attributes)
    parsed_attributes = FacebookCreation::CampaignSerializer.new(attributes).as_json
    FacebookCreation::CampaignService.call(facebook_account, parsed_attributes)
  end

  def find_or_create_adset(facebook_account, attributes, campaign)
    existing = ad_account(facebook_account).adsets(fields: ['name']).find {|n| n.name == attributes.fetch('Ad Set Name') }
    return existing if existing
    create_adset(facebook_account, attributes, campaign)
  end

  def create_adset(facebook_account, attributes, campaign)
    parsed_attributes = FacebookCreation::AdsetSerializer.new(facebook_account: facebook_account,
                                                              adset_attributes: attributes).as_json
    FacebookCreation::AdsetService.call(facebook_account, parsed_attributes.merge(campaign_id: campaign.id))
  end

  def create_adcreative(facebook_account, attributes)
    parsed_attributes = FacebookCreation::AdcreativeSerializer.new(facebook_account, attributes).as_json
    FacebookCreation::AdcreativeService.call(facebook_account, parsed_attributes)
  end

  def create_image(facebook_account, url)
    FacebookCreation::ImageService.call(facebook_account, url)
  end

  def create_ad(facebook_account, attributes, adset, adcreative)
    parsed_attributes = {
      name: attributes.fetch('Ad Name'),
      status: 'ACTIVE',
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
