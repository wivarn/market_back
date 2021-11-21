# frozen_string_literal: false

class SitemapJob < ApplicationJob
  rate '1 day'
  iam_policy({
               action: ['s3:PutObject', 's3:PutObjectAcl'],
               effect: 'Allow',
               resource: "#{ENV['PUBLIC_ASSETS_BUCKET_ARN']}/sitemap.txt"
             })
  def build
    return unless Jets.env.production?

    sitemap = ''
    Listing.publically_viewable.find_each do |listing|
      sitemap << "#{ENV['FRONT_END_BASE_URL']}/listings/#{listing.id}\n"
    end
    s3_client.put_object(acl: 'public-read', body: sitemap, bucket: ENV['PUBLIC_ASSETS_BUCKET'], key: 'sitemap.txt')
  end

  private

  def s3_client
    @s3_client ||= Aws::S3::Client.new
  end
end
