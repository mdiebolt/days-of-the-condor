activate :syntax

set :markdown_engine, :redcarpet
set :markdown, :fenced_code_blocks => true, :smartypants => true

activate :livereload
activate :blog do |blog|
  blog.summary_length = 500
  blog.paginate = true
  blog.per_page = 5
end

set :css_dir, "stylesheets"
set :js_dir, "javascripts"
set :images_dir, "images"

configure :build do
  activate :minify_css
  activate :minify_javascript
end
