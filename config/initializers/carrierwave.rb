CarrierWave.configure do |config|
  if Jets.env.development? || Jets.env.test?
    config.storage = :file
  else
    config.fog_credentials = {
      provider: 'AWS',
      region: 'us-east-1',
      # need to replaces these
      aws_access_key_id: ENV['PUBLIC_ASSETS_ACCESS_ID'],
      aws_secret_access_key: ENV['PUBLIC_ASSETS_SECRET_ACCESS_KEY']
    }
    config.fog_directory = ENV['PUBLIC_ASSETS_BUCKET']
    config.max_file_size = 50.megabytes
  end
end
