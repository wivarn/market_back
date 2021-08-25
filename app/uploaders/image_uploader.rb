class ImageUploader < CarrierWave::Uploader::Base
  BUCKET = Aws::S3::Resource.new.bucket(ENV['PUBLIC_ASSETS_BUCKET']) unless Jets.env.development? || Jets.env.test?

  # ENV['FRONT_END_PUBLIC_PATH'] should be set only in local envs
  def store_dir
    "#{ENV['FRONT_END_PUBLIC_PATH']}uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def key
    path.delete_prefix(store_dir)
  end

  def url
    return unless present?

    if ENV['PUBLIC_ASSETS_URL']
      "#{ENV['PUBLIC_ASSETS_URL']}/#{path}"
    else
      # need to add the slash in the front for nextjs
      "/#{super.gsub(ENV['FRONT_END_PUBLIC_PATH'], '')}"
    end
  end

  def presigned_put_url(filename)
    key = "#{SecureRandom.uuid}/#{filename}"
    object = BUCKET.object("#{store_dir}/#{key}")
    { url: object.presigned_url(:put, acl: 'public-read'), key: key }
  end

  def remove_from_s3(key)
    BUCKET.object("#{store_dir}#{key}").delete
  end

  # Add an allowlist of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_allowlist
    %w[jpg jpeg png webp heic]
  end

  def content_type_allowlist
    %r{image/}
  end
end
