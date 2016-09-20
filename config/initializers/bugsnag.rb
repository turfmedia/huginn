Bugsnag.configure do |config|
  if Rails.env.test? || Rails.env.development?
    #Do not use Bugsnag
  else
    config.api_key = "189a29fedef5e347d2eb37ea4bdc531f"
  end
end
