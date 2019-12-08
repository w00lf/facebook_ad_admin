class FacebookHideAllCommentsJob < ApplicationJob
  queue_as :default

  def perform
    logger = Logger.new(File.new(Rails.root.join('log', 'hide_comments.log'), 'a+'))
    logger.info('Started hidding all comment')
    index = 0
    FacebookAccount.joins(:facebook_group_account).where(active: true, facebook_group_accounts: { active: true }).find_each do |facebook_account|
      FacebookAccountHideCommentsJob.set(wait: (index * 30).seconds).perform_later(facebook_account.id)
      index += 1
      logger.info("Setted FacebookAccountHideCommentsJob for #{facebook_account.id}")
    end
    logger.info('Finished setting jobs')
  end
end
