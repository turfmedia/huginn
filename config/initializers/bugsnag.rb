Bugsnag.configure do |config|
  if Rails.env.test? || Rails.env.development?
    #Do not use Bugsnag
  else
    config.api_key = "97d2a9b6a14f0f17d35c2b675f02d8cc"
  end
end
