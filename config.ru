require 'rubygems'
require 'sinatra'

root_dir = File.dirname(__FILE__)

set :environment,ENV['RACK_ENV'].to_sym
set :root,root_dir

disable :run


log = File.new('sinatra.log','a')
$stdout.reopen(log)
$stderr.reopen(log)

require 'app'
run Sinatra::Application
