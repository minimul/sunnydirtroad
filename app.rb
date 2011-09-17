require 'rubygems'
require 'sqlite3'
require 'logger'
require 'rack-flash'
enable :sessions
use Rack::Flash

configure do 
  LOGGER = Logger.new('sinatra.log')
  DB = SQLite3::Database.new("dirtroad.db")
  DB.results_as_hash = true
  ADMIN_USERNAME  = 'dirtuser'
  ADMIN_PASSWD    = 'dirtpass'
end

helpers do
  include Rack::Utils
  alias_method :h, :escape_html

  def logger
    LOGGER
  end

  def page_title
    'Rent Berenstain Bear books'
  end

  def protected!
    response['WWW-Authenticate'] = %(Basic realm="SunnyDirtRoad Administration") and \
    throw(:halt, [401, "Not authorized\n"]) and \
    return unless authorized?
  end

  def authorized?
    return false unless ADMIN_USERNAME && ADMIN_PASSWD
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == [ADMIN_USERNAME, ADMIN_PASSWD]
  end

end

get '/' do
  @analytics = true
  @page_title = page_title
  erb :index
end

post '/' do
  @page_title = page_title
  DB.execute("INSERT INTO emails VALUES (NULL,?,datetime('now'),?)",params[:email],request.ip)
  flash[:notice] = 'Ok, got it. Will keep you updated on the progress of SunnyDirtRoad.'
  redirect '/'
end

get '/check/responses' do
  protected!
  @page_title = 'Check responses'
  @data = DB.execute("SELECT * FROM emails")
  erb :check_responses
end
