CarrierWave.configure do |config|
  if Jets.env.development? || Jets.env.test?
    config.storage = :file
  else
    config.fog_credentials = {
      provider: 'AWS',
      region: 'us-east-1',
      aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
      aws_session_token: ENV['AWS_SESSION_TOKEN']
    }
    config.fog_directory = ENV['PUBLIC_ASSETS_BUCKET']
    config.storage = :fog
  end
end
