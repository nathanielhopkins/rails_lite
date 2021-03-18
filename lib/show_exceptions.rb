require 'erb'

class ShowExceptions
  attr_reader :app, :response

  def initialize(app)
    @app = app
    @response = Rack::Response.new 
  end

  def call(env)
    begin
      @app.call(env)
    rescue => exception
      render_exception(exception)
    end
  end

  private
  
  def render_exception(e)
    dir_path = File.dirname(__FILE__)
    template_fname = File.join(dir_path, "templates", "rescue.html.erb")
    template = File.read(template_fname) 
    body = ERB.new(template).result(binding)
    
    ['500', {'Content-type' => 'text/html'}, body]
  end

end
