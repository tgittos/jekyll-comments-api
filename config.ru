$: << "."

require 'rack/contrib'
require 'jekyll_comments_api'

use Rack::PostBodyContentTypeParser

run JekyllCommentsAPI.new
