class ImageUploader < CarrierWave::Uploader::Base
  BUCKET = Aws::S3::Resource.new.bucket(ENV['PUBLIC_ASSETS_BUCKET']) if ENV['PUBLIC_ASSETS_BUCKET']

  # ENV['FRONT_END_PUBLIC_PATH'] should be set only in local envs
  def store_dir
    "#{ENV['FRONT_END_PUBLIC_PATH']}#{store_prefix}"
  end

  def store_prefix
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
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
    existing_url(filename) || local_url(filename) || s3_url(filename)
  end

  def presigned_put_urls(filenames)
    filenames.map { |filename| presigned_put_url(filename) }
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

  private

  # returns nil unless 'filename' is a url to an existing file on disk or S3
  def existing_url(filename)
    if ENV['PUBLIC_ASSETS_URL']
      return unless filename.start_with?(ENV['PUBLIC_ASSETS_URL'])
    else
      return unless filename.start_with?("/#{store_prefix}")
    end

    { url: nil, identifier: filename.split(store_prefix).last }
  end

  # returns a path inside the frontend's /public directory if using local storage
  def local_url(filename)
    return if ENV['PUBLIC_ASSETS_BUCKET']

    { url: "#{store_prefix}/#{filename}", identifier: filename }
  end

  # returns a presigned s3 url for uploading an object
  def s3_url(filename)
    return unless ENV['PUBLIC_ASSETS_BUCKET']

    new_identifier = "#{SecureRandom.uuid}/#{filename}"
    object = BUCKET.object("#{store_dir}/#{new_identifier}")
    { url: object.presigned_url(:put, acl: 'public-read'), identifier: new_identifier }
  end
end
