CarrierWave.configure do |config|
  config.storage = :file
  config.store_dir = "tmp/carrierwave/#{Jets.env}"
end
