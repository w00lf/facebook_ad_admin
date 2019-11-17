module FacebookApi
  class HideCommentsPostService < FacebookAPIBaseRepresenter
    def call(facebook_account:, max_comments: 10000, logger: Logger.new(STDOUT))
      ad_account = ::FacebookAccountApiRepresentation.new(facebook_account: facebook_account, date: Time.now, logger: Logger.new(STDOUT))
      account = with_exception_control { FacebookAds::User.get('me', ad_account.session).accounts.first }
      page_access_token = account.access_token
      page_post_id = with_exception_control { ad_account.adcreatives(fields: %i[id effective_object_story_id]).first.effective_object_story_id }
      page_post = with_exception_control { FacebookAds::PagePost.get(page_post_id, ad_account.session) }
      comments = with_exception_control { page_post.comments.to_a }
      batch = FacebookAds::Batch.with_batch do
        comments.each.with_index(1) do |comment, i|
          break if i > max_comments

          puts(comment.message, comment.id)
          comment_object = with_exception_control { FacebookAds::Comment.get(comment.id, access_token: page_access_token) }
          comment_object.is_hidden = true
          comment_object.save
        end
      end
      with_exception_control { batch.execute }
    end
  end
end