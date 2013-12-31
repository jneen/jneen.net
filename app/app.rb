load File.join(File.dirname(__FILE__), 'models.rb')
load File.join(File.dirname(__FILE__), 'support.rb')

class BlagApp < Sinatra::Application
  configure :development do
    require 'sinatra/reloader'
    register Sinatra::Reloader
  end

  ROOT = Pathname.new(__FILE__).dirname.parent

  STARTED_AT = Time.now

  def self.logger
    @logger ||= Logger.new('log/blag.log')
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
  end

  configure do
    set :root, ROOT
    set :views, ROOT.join('templates')
    set :haml, {:format => :html5, :escape_html => false}

    enable :logging
  end

  get '/' do
    @posts = BlogPost.latest(5)
    haml :index
  end

  get '/posts/:name' do |name|
    @post = BlogPost.find(name)
    haml :post
  end

  get '/pages/:name' do |name|
    @page = Page.find(name)
    haml :page
  end

  get %r(/archive(/(\d+))?) do |_, pageno|
    @pageno = pageno.to_i
    @posts = BlogPost.page(@pageno)
    halt 404 if @posts.empty?
    @has_next = BlogPost.page(@pageno + 1).any?
    haml :archive
  end

  get '/rss' do
    @posts = BlogPost.latest(10)

    content_type 'application/rss+xml'
    haml :rss, :layout => false, :format => :xhtml
  end
end
