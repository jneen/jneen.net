# Activate and configure extensions
# https://middlemanapp.com/advanced/configuration/#configuring-extensions

$DEBUG = false

Haml::TempleEngine.disable_option_validator!

load File.join(File.dirname(__FILE__), 'lib/blag.rb')

activate :autoprefixer do |prefix|
  prefix.browsers = "last 2 versions"
end

# Layouts
# https://middlemanapp.com/basics/layouts/

# Per-page layout changes
page '/*.xml', layout: false
page '/*.json', layout: false
page '/*.txt', layout: false

def genproxy(path, newpath, local_vars)
  proxy "#{path}/index.html", newpath, locals: local_vars, ignore: true, layout: 'layout'
end

helpers do
  def description(arg=:absent)
    return @description if arg == :absent

    @description = arg
  end

  def title(arg=:absent)
    @title ||= []
    return @title if arg == :absent

    @title << arg
  end

  def permalink(path='')
    File.join(Site[:url], path)
  end

  def with_absolute_urls(data)
    # XXX HACK XXX
    data.gsub(/(?<=href=")[^"]+(?=")/, &method(:permalink))
  end
end

BlogPost.published.each do |post|
  genproxy post.path, "post.html", post: post
end

Page.ls.each do |page|
  genproxy page.path, "page.html", page: page
end

# homepage = Content.find('index')
# genproxy '/', 'page.html', page: Content.find('index')

next_archive_page = nil
0.upto(1000) do |pageno|
  archive_page = next_archive_page || BlogPost.page(0)
  next_archive_page = BlogPost.page(pageno + 1)

  has_next = next_archive_page.any?

  archive_locals = {
    pageno: pageno,
    posts: archive_page,
    has_next: has_next
  }

  genproxy "/blag/#{pageno}", "archive.html", archive_locals
  genproxy "/blag/index.html", "archive.html", archive_locals if pageno == 0

  break unless has_next
end
