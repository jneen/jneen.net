require 'pathname'
require 'yaml'

load Pathname.new(__FILE__).dirname.join('support.rb')

module PathnameExtension
  def path_without_ext(rel=nil)
    path = self
    path = path.relative_path_from(rel) if rel

    path.to_s[0...-path.extname.size]
  end
end

Pathname.send(:include, PathnameExtension)

class Content
  ROOT = Pathname.new(__FILE__).dirname.parent.join('content')
  def self.root
    ROOT
  end

  include Wrappable

  wraps :file

  VALID_EXTENSIONS = %w(
    .md
    .yml
  )

  def self.find(key)
    paths = []
    root.find do |path|
      next unless VALID_EXTENSIONS.include?(path.extname)
      next unless path.path_without_ext(root) == key

      paths << path
    end

    wrap(paths.first) if paths.any?
  end

  def self.ls(dir='')
    root.join(dir).children.select do |c|
      VALID_EXTENSIONS.include?(c.extname)
    end.sort.reverse.map(&method(:wrap))
  end

  def initialize(fname)
    super(Pathname.new(fname))
  end

  def source
    @source ||= begin
      # god damn it, just make everything UTF-8
      contents = file.open('r:UTF-8', &:read)
      contents.encode!('UTF-8', 'UTF-8', :invalid => :replace)
      contents
    end
  end

  def content
    parsed[:content]
  end

  def metadata
    parsed[:metadata]
  end

  def [](k)
    metadata[k.to_s]
  end

  def html
    Renderer.html(content, format)
  end

  def fold_split(&b)
    splut = html.split('<!--fold-->', 2)
    splut.tap(&b) if b
    splut
  end

  def format
    file.extname
  end

  def interpolate(context={})
    Renderer.interpolate(html, context)
  end

  def key
    @key ||= file.path_without_ext(ROOT)
  end

  def path
    "/#{key}"
  end

  def render(context={})
    {
      key: key,
      metadata: metadata,
      content: interpolate(context),
    }
  end

private
  # read the YAML frontmatter
  # regex stolen from Jekyll
  def parsed
    return @parsed if instance_variable_defined? :@parsed

    if source =~ /^(---\s*\n.*?\n?)^(---\s*$\n?)/m
      { metadata: YAML.load($1), content: $' }
    else
      { metadata: {}, content: source }
    end
  end
end

class BlogPost < Content
  def self.root
    super.join('posts')
  end

  def self.published
    ls.select(&:published?)
  end

  def self.latest(count, offset=0)
    range = offset..(count + offset)
    published[range] || [] # why would you return nil, ruby...?
  end

  def self.page(pageno, per_page=10)
    latest(per_page, per_page * pageno)
  end

  def published_at
    return @published_at if instance_variable_defined?(:@published_at)
    @published_at = self[:date] && Time.parse(self[:date])
  end

  def published?
    published_at && published_at < Time.now
  end

  def title
    self[:title]
  end

  def description
    self[:description] || title
  end
end

class Page < Content
  def self.root
    super.join('pages')
  end

  def title
    self[:title]
  end
end

class Links < Content
  def self.each(&b)
    find('links')['links'].each do |link|
      link['target'] ||= nil
      yield OpenStruct.new(link)
    end
  end
end

class Site < Content
  class << self
    def [](key)
      find('site')[key]
    end
  end
end

class Redirects < Content
  def self.data
    @data ||= find('redirects').metadata
  end

  def self.each(&b)
    data && data.each(&b)
  end

  def self.[](key)
    data && data[key]
  end
end

module Renderer
  extend self

  class HTML < Redcarpet::Render::HTML
    # magical smart-quotes
    include Redcarpet::Render::SmartyPants

    # syntax highlighting
    require 'rouge/plugins/redcarpet'
    include Rouge::Plugins::Redcarpet
  end

  def html(source, format)
    case format
    when '.txt', '.html'
      source
    when '.md', '.mkd'
      markdown.render(source)
    when '.yml', '.yaml'
      ''
    else
      '(( UNRECOGNIZED FORMAT ))'
    end
  end

  def interpolate(html, context={})
    Mustache.render(html, context)
  end

private
  def markdown
    @markdown ||= Redcarpet::Markdown.new(html_renderer,
      fenced_code_blocks: true
    )
  end

  def html_renderer
    @html_renderer ||= HTML.new
  end
end
