require 'fileutils'
require 'securerandom'
require 'json'

class Comment

  def initialize(url, email, name, comment)
    @url = url; @email = email; @name = name; @comment = comment
  end

  def self.list(url)
    url = URI.unescape(url)
    dir = File.join(JekyllCommentsAPI::CONFIG["jekyll_dir"], '_comments', url_to_dir(url))
    comments = (Dir.entries(dir).collect{|path|
      next if %W{. ..}.include?(path)
      JSON.parse(File.read(File.join(dir, path)))
    }.compact if File.directory?(dir)) || []
    comments.sort{ |a, b| Time.parse(a['date']) <=> Time.parse(b['date']) }
  end

  def save
    filename = SecureRandom.uuid + ".json"
    write_to_disk(filename)
  end

  def to_json(options = nil)
    {
      :email => @email,
      :name => @name,
      :comment => @comment,
      :date => Time.now
    }.to_json
  end

  private

  def write_to_disk(filename)
    dir = File.join(JekyllCommentsAPI::CONFIG["jekyll_dir"], '_comments', url_to_dir(@url))
    path = File.join(dir, filename)
    FileUtils.mkdir_p(dir) unless File.directory?(dir)
    File.open(path, 'w') {|f| f.puts self.to_json }
  end

  def self.url_to_dir(url)
    # for some reason, my urls are coming in as http:/www so the second / is optional
    url.gsub(/http\:\/\/?(www\.)?/, '').gsub(/[^A-Za-z0-9\-_]+/, '-').squeeze('-')
  end

  def url_to_dir(url)
    self.class.url_to_dir(url)
  end

end