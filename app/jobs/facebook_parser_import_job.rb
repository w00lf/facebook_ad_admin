class FacebookParserImportJob < ApplicationJob
  queue_as :default

  def perform
    logger = Logger.new(File.new(Rails.root.join('log', 'parser.log'), 'a+'))
    parse_day = Time.current - 1.day
    logger.info("Started parsing of account, target date - #{parse_day}")
    index = 0
    FacebookAccount.joins(:facebook_group_account).where(active: true, facebook_group_accounts: { active: true }).find_each do |facebook_account|
      FacebookAccountStatsRetrieveJob.set(wait: (index * 20).seconds).perform_later(parse_day.to_i, facebook_account.id)
      index += 1
      logger.info("Setted job for account id - #{facebook_account.api_identificator}")
    end
    logger.info("Finished setting jobs")
  end
end
