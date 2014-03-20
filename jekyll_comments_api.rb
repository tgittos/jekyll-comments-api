$: << "." unless $:.include?(".")

require 'sinatra/base'
require 'yaml'
require 'lib/comment'
require 'json'

class JekyllCommentsAPI < Sinatra::Base

  configure do
    CONFIG = YAML.load_file("./config/application.yml")
    mime_type :javascript, 'application/javascript'
  end

  get '/embed.js' do
    erb :"embed.js", :content_type => :javascript, :locals => { :host => CONFIG["host"] }
  end

  post '/api/comment' do
    headers['Access-Control-Allow-Origin'] = "*"
    content_type :json
    comment = Comment.new(params["url"], params["email"], params["name"], params["comment"])
    comment.save
    { :count => Comment.list(params["url"]).length, :comment => comment }.to_json
  end

  get '/api/comments/*' do
    headers['Access-Control-Allow-Origin'] = "*"
    content_type :json
    url = params[:splat].first + "//" + params[:splat][1..-1].join('/')
    comments = Comment.list(url)
    { :count => comments.length, :comments => comments }.to_json
  end

end
