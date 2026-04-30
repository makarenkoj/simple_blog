bucket_name = ENV.fetch('R2_BUCKET_NAME')
sitemaps_host = ENV.fetch('R2_PUB_DEV_URL', 'https://pub-b5117945ddf24c73be1b37aa13e64f80.r2.dev')
default_host = ENV.fetch('DEFAULT_HOST', 'helpbooost.com')

Rails.application.routes.default_url_options[:host] = default_host
Rails.application.routes.default_url_options[:protocol] = 'https'

SitemapGenerator::Sitemap.default_host = "https://#{default_host}"
SitemapGenerator::Sitemap.sitemaps_host = sitemaps_host
SitemapGenerator::Sitemap.public_path = 'tmp/'
SitemapGenerator::Sitemap.sitemaps_path = 'sitemaps/'

SitemapGenerator::Sitemap.adapter = SitemapGenerator::AwsSdkAdapter.new(
  bucket_name,
  aws_access_key_id: ENV.fetch('R2_ACCESS_KEY_ID'),
  aws_secret_access_key: ENV.fetch('R2_SECRET_ACCESS_KEY'),
  aws_region: 'auto',
  endpoint: ENV.fetch('R2_ENDPOINT')
)

SitemapGenerator::Sitemap.create(compress: true, include_root: false) do
  [:uk, :en, :it].each do |locale|
    add root_path(locale: locale), changefreq: 'daily', priority: 1.0

    Post.find_each do |post|
      add post_path(post, locale: locale), 
          lastmod: post.updated_at, 
          changefreq: 'weekly'
    end

    Category.find_each do |category|
      add category_path(category, locale: locale), changefreq: 'weekly'
    end
  end
end
