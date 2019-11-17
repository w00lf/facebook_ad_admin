page = FacebookAds::Page.get("250515082286181", ad_account_1.session)
ad_account_1.adsets.first.ads.first.adcreatives.first
# "380138442712881_471120650281326"
page_post_id = ad_account_1.adsets.first.ads.first.adcreatives.first.effective_object_story_id
page_post = FacebookAds::PagePost.get("380138442712881_471120650281326", ad_account_1.session)
[80] pry(main)> comment = page_post.comments.first
=> #<FacebookAds::Comment {:created_time=>Fri, 18 Oct 2019 03:09:46 +0000, :message=>"Link forwards to SCAM page! Report!", :id=>"471120650281326_471482563578468"}>

[81] pry(main)> accounts = FacebookAds::User.get('me', ad_account_1.session).accounts.first
=> #<FacebookAds::Page {:access_token=>"EAAGJIA9vnZCcBAEqKJZB7ticKM6oFynkVlb2VhfQZA0YNbe6H4QPwl5xjecYqPyjMeX8wPzaOmuHWDATkZANLutmche1mpjyb94ZBA87eWKQf3IVZCfNrQD40nbc2RTqiRLZBeDkvFhUIG0JfZBclrdmSSaAR3zAl5mUoagg5BijdUQ8aQpXplUA", :category=>"Cause", :category_list=>[#<FacebookAds::PageCategory {:id=>"2606", :name=>"Cause"}>], :name=>"Blogz Timez", :id=>"380138442712881", :tasks=>["ANALYZE", "ADVERTISE", "MODERATE", "CREATE_CONTENT", "MANAGE"]}>

[83] pry(main)> FacebookAds::Comment.get("471120650281326_471482563578468", access_token: "EAAGJIA9vnZCcBAEqKJZB7ticKM6oFynkVlb2VhfQZA0YNbe6H4QPwl5xjecYqPyjMeX8wPzaOmuHWDATkZANLutmche1mpjyb94ZBA87eWKQf3IVZCfNrQD40nbc2RTqiRLZBeDkvFhUIG0JfZBclrdmSSaAR3zAl5mUoagg5BijdUQ8aQpXplUA")
=> #<FacebookAds::Comment {:id=>"471120650281326_471482563578468"}>

[86] pry(main)> k.is_hidden = true
=> true
[88] pry(main)> k.save
=> 2019-11-17 18:46:30 +0300


account = FacebookAds::User.get('me', ad_account_1.session).accounts.first
page_access_token = account.access_token
page_post_id = ad_account_1.adsets.first.ads.first.adcreatives.first.effective_object_story_id
page_post = FacebookAds::PagePost.get(page_post_id, ad_account_1.session)
comments = page_post.comments.to_a
batch = FacebookAds::Batch.with_batch do
  comments.each.with_index(1) do |comment, i|
    break if i > max_comments

    puts(comment, comment.id)
    comment_object = FacebookAds::Comment.get(comment.id, access_token: page_access_token)
    comment_object.is_hidden = true
    comment_object.save
  end
end
batch.execute

1124403291049525_1348060405350478