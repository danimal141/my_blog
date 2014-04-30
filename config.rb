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

configure :development do
  activate :google_analytics do |ga|
    ga.tracking_id = false
  end
end

configure :build do
  activate :minify_css
  activate :minify_javascript
  activate :asset_hash
  activate :minify_html, remove_quotes: false, remove_intertag_spaces: true
  activate :google_analytics do |ga|
    ga.tracking_id = 'UA-50475820-1'
  end
end
