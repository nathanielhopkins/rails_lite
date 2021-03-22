require 'rack'

class Static
  attr_reader :app, :res

  def initialize(app)
    @app = app
    @res = Rack::Response.new
    @MIME_TYPES = {
    '.txt' => 'text/plain',
    '.jpg' => 'image/jpeg',
    '.zip' => 'application/zip'
    }
  end

  def call(env)
    if env["PATH_INFO"].index("/public/")  
      serve(env)
    else
      @app.call(env)
    end
  end

  
  private
  def serve(env)
    content = file_path(env)
    if File.exist?(content)
      body = File.read(content)
      @res.write(body)
      mime_type(content)
    else
      @res.status = 404
      @res.write("File not found")
    end
    @res.finish
  end

  def file_path(env)
    dir_name = File.dirname(__FILE__)
    root = File.dirname(dir_name)
    file_path = env["PATH_INFO"]
    content = File.join(root, file_path)
  end

  def mime_type(file_name)
    ext = File.extname(file_name)
    content_type = @MIME_TYPES[ext]
    @res["Content-Type"] = content_type
  end
end
