# frozen_string_literal: false

class SitemapJob < ApplicationJob
  rate '1 day'
  iam_policy({
               action: ['s3:PutObject', 's3:PutObjectAcl'],
               effect: 'Allow',
               resource: "#{ENV['PUBLIC_ASSETS_BUCKET_ARN']}/sitemap*"
             })
  def build
    return unless Jets.env.production?

    SitemapGenerator::Sitemap.default_host = ENV['FRONT_END_BASE_URL']
    SitemapGenerator::Sitemap.include_root = false
    SitemapGenerator::Sitemap.adapter = SitemapGenerator::WaveAdapter.new
    SitemapGenerator::Sitemap.create do
      Listing.publically_viewable.find_each do |listing|
        changefreq = listing.sold? ? :never : :weekly
        priority = listing.sold? ? 0.5 : 0.8
        add "/listings/#{listing.id}", lastmod: listing.updated_at, changefreq: changefreq, priority: priority
      end
    end
    SitemapGenerator::Sitemap.ping_search_engines
  end
end
