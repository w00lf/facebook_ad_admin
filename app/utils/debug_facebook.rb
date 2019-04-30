FacebookAds.configure do |config|
  # Logger for debugger
  config.logger = ::Logger.new(STDOUT).tap { |d| d.level = Logger::DEBUG }

  # Log Http request & response to logger
  config.log_api_bodies = true
end