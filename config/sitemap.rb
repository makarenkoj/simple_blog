require 'aws-sdk-s3'

class R2Adapter
  def initialize(bucket, options = {})
    @bucket = bucket
    @options = options
  end

  def write(location, raw_data)
    SitemapGenerator::FileAdapter.new.write(location, raw_data)

    client = Aws::S3::Client.new(access_key_id: @options[:aws_access_key_id],
                                 secret_access_key: @options[:aws_secret_access_key],
                                 region: @options[:aws_region],
                                 endpoint: @options[:endpoint]
                                )

    mime_type = location.path.to_s.end_with?('.gz') ? 'application/x-gzip' : 'application/xml'

    File.open(location.path, 'rb') do |file|
      client.put_object(bucket: @bucket,
                        key: location.path_in_public,
                        body: file,
                        content_type: mime_type
                        )
    end
  end
end

bucket_name = ENV.fetch('R2_BUCKET_NAME')
sitemaps_host = ENV.fetch('R2_PUB_DEV_URL', 'https://pub-b5117945ddf24c73be1b37aa13e64f80.r2.dev')
default_host = ENV.fetch('DEFAULT_HOST', 'helpbooost.com')
host_url = "https://#{default_host}"

options = { host: default_host, protocol: 'https' }
Rails.application.routes.default_url_options = options
Rails.application.default_url_options = options
ActionController::Base.default_url_options = options

if defined?(ActiveStorage::Current)
  ActiveStorage::Current.url_options = options
end

SitemapGenerator::Sitemap.default_host = host_url
SitemapGenerator::Sitemap.sitemaps_host = sitemaps_host
SitemapGenerator::Sitemap.public_path = 'tmp/'
SitemapGenerator::Sitemap.sitemaps_path = 'sitemaps/'

SitemapGenerator::Sitemap.adapter = R2Adapter.new(bucket_name,
                                                  aws_access_key_id: ENV.fetch('R2_ACCESS_KEY_ID'),
                                                  aws_secret_access_key: ENV.fetch('R2_SECRET_ACCESS_KEY'),
                                                  aws_region: 'auto',
                                                  endpoint: ENV.fetch('R2_ENDPOINT')
                                                  )

SitemapGenerator::Sitemap.create(compress: true, include_root: false) do
  [:uk, :en, :it].each do |locale|
    add root_url(locale: locale, host: host_url), changefreq: 'daily', priority: 1.0

    Post.find_each do |post|
      add post_url(post, locale: locale, host: host_url), lastmod: post.updated_at, changefreq: 'weekly'
    end

    Category.find_each do |category|
      add category_url(category, locale: locale, host: host_url), changefreq: 'weekly'
    end
  end
end
