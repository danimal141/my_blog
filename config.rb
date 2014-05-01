Time.zone = 'Tokyo'

activate :blog do |blog|
  blog.prefix = 'posts'
  blog.layout = 'posts'
  blog.default_extension = '.md'

  blog.paginate = true
  blog.per_page = 8
  blog.page_link = "page/{num}"
end

page '/feed.xml', layout: false
page '/sitemap.xml', layout: false

set :css_dir, 'stylesheets'
set :js_dir, 'javascripts'
set :images_dir, 'images'
set :slim, { pretty: true, sort_attrs: false, format: :html5 }
set :markdown_engine, :redcarpet
set :markdown, fenced_code_blocks: true, smartypants: true

activate :directory_indexes
activate :livereload
# activate :syntax
activate :disqus do |d|
  d.shortname = 'danimal141'
end
activate :s3_sync do |s3_sync|
  s3_sync.bucket                     = 'danimal141.net'
  s3_sync.region                     = 'ap-northeast-1'
  s3_sync.aws_access_key_id          = ENV['AWS_ACCESS_KEY_ID'] || File.read("#{ENV['HOME']}/.danimal141/aws_access_key").strip
  s3_sync.aws_secret_access_key      = ENV['AWS_SECRET_ACCESS_KEY'] || File.read("#{ENV['HOME']}/.danimal141/aws_secret_key").strip
  s3_sync.delete                     = false
  s3_sync.after_build                = false
  s3_sync.prefer_gzip                = true
  s3_sync.path_style                 = true
  s3_sync.reduced_redundancy_storage = false
  s3_sync.acl                        = 'public-read'
  s3_sync.encryption                 = false
end

configure :development do
  activate :google_analytics do |ga|
    ga.tracking_id = false
  end
end

configure :build do
  activate :minify_css
  activate :minify_javascript
  #activate :asset_hash
  activate :minify_html, remove_quotes: false, remove_intertag_spaces: true
  activate :google_analytics do |ga|
    ga.tracking_id = 'UA-50475820-1'
  end
end
