class SitemapJob < ApplicationJob
  queue_as :default

  def perform
    # system("bin/rails sitemap:refresh")
    SitemapGenerator::Interpreter.run(verbose: true)
  end
end
