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
      @response.status = '500'
      @response['Content-type'] = 'text/html'
      @response.body << "RuntimeError"
      return @response.finish
  end

end
