class FetchFacebookBmDailyLimitJob < ApplicationJob
  queue_as :cpa_rip

  STATS_URL = 'https://cpa.rip/check-bm/'.freeze
  DEFAULT_HEADERS = {
   'Connection' => 'keep-alive',
   'Pragma' => 'no-cache',
   'Cache-Control' => 'no-cache',
   'Origin' => 'https://cpa.rip',
   'Upgrade-Insecure-Requests' => '1',
   'Content-Type' => 'application/x-www-form-urlencoded',
   'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.163 Safari/537.36',
   'Sec-Fetch-Dest' => 'document',
   'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9',
   'Sec-Fetch-Site' => 'same-origin',
   'Sec-Fetch-Mode' => 'navigate',
   'Sec-Fetch-User' => '?1',
   'Referer' => 'https://cpa.rip/check-bm/',
   'Accept-Language' => 'en-US,en;q=0.9,ru;q=0.8,zh-CN;q=0.7,zh;q=0.6'
  #  'Cookie' => 'PHPSESSID=dbb6ef4fdcd149319afec55fe812bcc1; _ym_uid=15874773011060117768; _ym_d=1587477301; _ga=GA1.2.1851610923.1587477301; _gid=GA1.2.714116224.1587477301; _ym_isad=1; bp-activity-oldestpage=1; _ym_visorc_44245349=w; _gat_gtag_UA_122461507_1=1'
  }

  # .business
  def perform(facebook_account_ids)
    facebook_account_ids.each_slice(5) do |group|
      facebook_accounts = group.map do |id|
                            ::FacebookAccountApiRepresentation.new(facebook_account: FacebookAccount.find(id))
                          end
      bm_ids = facebook_accounts.map { |account| account.business.id }
      response = Faraday.post(STATS_URL, URI.encode_www_form([['id', bm_ids.join(', ')]]), DEFAULT_HEADERS)
      html = Nokogiri::HTML(response.body)
      facebook_accounts.each do |account|
        account.facebook_account.update!(daily_limit: daily_limit(html, account.business.id), daily_limit_updated_at: Time.current)
      end
    end
  end

  # <tr>
  #   <td>2410968839029246</td>
  #   <td><img width="50" height="50"
  #       data-src="https://scontent.fhen1-1.fna.fbcdn.net/v/t1.30497-1/cp0/c15.0.50.50a/p50x50/83577589_556345944958992_2558068442594803712_n.png?_nc_cat=1&_nc_sid=f72489&_nc_eui2=AeGZNYhYgtN2Y-81g1HmwPMQGOCLk4j0HdgY4IuTiPQd2Ag2mpZxVAZ4guKet0iophA&_nc_ohc=HEUtKw44260AX-9WKff&_nc_ht=scontent.fhen1-1.fna&oh=e0af9a6280d70a7212808b726dac7c1c&oe=5EC4793C"
  #       class="lazyload" src="data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw=="><noscript><img
  #         src="https://scontent.fhen1-1.fna.fbcdn.net/v/t1.30497-1/cp0/c15.0.50.50a/p50x50/83577589_556345944958992_2558068442594803712_n.png?_nc_cat=1&_nc_sid=f72489&_nc_eui2=AeGZNYhYgtN2Y-81g1HmwPMQGOCLk4j0HdgY4IuTiPQd2Ag2mpZxVAZ4guKet0iophA&_nc_ohc=HEUtKw44260AX-9WKff&_nc_ht=scontent.fhen1-1.fna&oh=e0af9a6280d70a7212808b726dac7c1c&oe=5EC4793C"
  #         width="50" height="50"></noscript> 2410968839029246 (Reese's Marketing)</td>
  #   <td style="color:red;">BAN</td>
  #   <td style="color:green;">250</td>
  #   <td style="color:green;">-</td>
  #   <td style="color:green;">-</td>
  # </tr>
  def daily_limit(html, bm_id)
    bm_row = html
              .xpath("//tr/td[text() = '#{bm_id}']")
              .first
    return 'no data' unless bm_row

    bm_row.ancestors
          .first
          .children
          .xpath('//td')[3]
          .text
  end
end
