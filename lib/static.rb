require 'rack'

class Static
  attr_reader :app, :res

  def initialize(app)
    @app = app
    @res = Rack::Response.new
  end

  def call(env)
    content = file_path(env)
    if File.exist?(content)
      body = File.read(content)
      @res.write(body)
    else
      @res.status = 404
    end
    @res.finish
  end
  
  private
  def file_path(env)
    dir_name = File.dirname(__FILE__)
    root = File.dirname(dir_name)
    file_path = env["PATH_INFO"]
    content = File.join(root, file_path)
  end
end
