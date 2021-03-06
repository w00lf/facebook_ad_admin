class FacebookAccountHideCommentsJob < ApplicationJob
  queue_as :hide_comments

  def perform(facebook_account_id)
    FacebookApi::HideCommentsPostService.new.call(facebook_account: FacebookAccount.find(facebook_account_id))
  end
end
