module Api
  module V1
    class FacebookParseResultsController < ActionController::Base
      before_action :token_auth

      def index
        return head :unauthorized

        @parse_results = ParseResult
                          .select(:api_identificator, :parsed_data, :report_date)
                          .joins(:facebook_account)
                          .where(status: "ok")
                          .where
                          .not(parsed_data: nil)
                          .search(params[:q])
                          .result
                          .page(params[:page])
                          .per(params[:per_page])
        render json: @parse_results.to_json
      end

      private

      def token_auth
        authenticate_with_http_token do |token, _options|
          Settings.api.token == token || unauthorized
        end
      end

      def unauthorized
        headers['WWW-Authenticate'] = 'Token realm="Application"'
        head :unauthorized
      end
    end
  end
end
