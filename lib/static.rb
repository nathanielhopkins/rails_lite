require 'rack'

class Static
  attr_reader :app, :req, :res
  
  def initialize(app)
    @app = app
    @res = Rack::Response.new
  end

  def call(env)
    dir_path = root_path
    @res["Content-Type"] = env[1]["Content-Type"]
    
    @req = Rack::Request.new(env)
    #somehow find file from request and set to variable 'content'
    body = File.read(content)
    @res.write(body)
    @res.finish
  end

  private
  def root_path
    dir_name = File.dirname(__FILE__)
    root = File.dirname(dir_name)
    dir_path = File.join(root, "public")
  end
end
