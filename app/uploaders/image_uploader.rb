class ImageUploader < CarrierWave::Uploader::Base
  include CarrierWaveDirect::Uploader unless Jets.env.development? || Jets.env.test?
  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  # include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  # storage :file
  # storage :fog

  # ENV['FRONT_END_PUBLIC_PATH'] should be set only in local envs
  def store_dir
    "#{ENV['FRONT_END_PUBLIC_PATH']}uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url(*args)
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  def url
    return unless present?

    if ENV['PUBLIC_ASSETS_URL']
      "#{ENV['PUBLIC_ASSETS_URL']}/#{path}"
    else
      # need to add the slash in the front for nextjs
      "/#{super.gsub(ENV['FRONT_END_PUBLIC_PATH'], '')}"
    end
  end

  # Process files as they are uploaded:
  # process scale: [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  # version :thumb do
  #   process resize_to_fit: [50, 50]
  # end

  # Add an allowlist of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_allowlist
    %w[jpg jpeg png webp heic]
  end

  def content_type_allowlist
    %r{image/}
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end
end