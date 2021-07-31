CarrierWave.configure do |config|
  if Jets.env.development? || Jets.env.test?
    config.storage = :file
  else
    config.fog_credentials = {
      provider: 'AWS',
      region: 'us-east-1'
      # these values should only be set for local testing staging/prod will use IAM roles
      # aws_access_key_id: '',
      # aws_secret_access_key: '',
    }
    config.fog_directory = ENV['PUBLIC_ASSETS_BUCKET']
  end
end
