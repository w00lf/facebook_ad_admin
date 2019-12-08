module FacebookApi
  class HideCommentsPostService < FacebookAPIBaseRepresenter
    attr_accessor :logger

    def call(facebook_account:, max_comments: 10000, logger: Logger.new(STDOUT))
      @logger = logger
      ad_account = ::FacebookAccountApiRepresentation.new(facebook_account: facebook_account, date: Time.now, logger: logger)
      account = with_exception_control { FacebookAds::User.get('me', ad_account.session).accounts.first }
      page_access_token = account.access_token
      ad_account.adcreatives.map(&:effective_object_story_id).each do |page_post_id|
        page_post = with_exception_control { FacebookAds::PagePost.get(page_post_id, ad_account.session) }
        comments = with_exception_control { page_post.comments(filter: 'stream', limit: 500).to_a }
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
    rescue => e
      Rails.logger.error("HideCommentsPostService: error on account #{facebook_account.id}: #{e.message}")
    end

    def method_missing(method, *args); end
  end
end