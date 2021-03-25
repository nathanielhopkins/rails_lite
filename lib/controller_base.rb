require 'active_support'
require 'active_support/core_ext'
require 'erb'
require_relative './session'
require_relative './flash'
require 'rack'
require 'securerandom'

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res, route_params = {})
    @req = req
    @res = res
    @params = req.params.merge!(route_params)
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end
  
  # Set the response status code and header
  def redirect_to(url)
    prepare_render_or_redirect

    res['Location'] = url
    res.status = 302

    nil
  end
  
  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    prepare_render_or_redirect

    res['Content-Type'] = content_type
    res.write(content)

    nil
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    controller_name = self.class.name.underscore
    dir_path = File.dirname(__FILE__)
    root_path = File.dirname(dir_path)
    template_fname = File.join(root_path, "views", controller_name, "#{template_name.to_s}.html.erb")
    template = File.read(template_fname) 
    content = ERB.new(template).result(binding)
    render_content(content, 'text/html')
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(@req)
  end

  def flash
    @flash ||= Flash.new(@req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    if protect_from_forgery?
      check_authenticity_token unless @req.request_method == 'GET'
    end
    send(name)
    render(name) if !self.already_built_response?
  end

  # CSRF
  def form_authenticity_token
    token = @params['authenticity_token'] ?  @params['authenticity_token'] : SecureRandom.base64(16)
    @res.set_cookie('authenticity_token', token) if res.headers['Set-Cookie'].nil?
    cookie_str = res.headers['Set-Cookie']
    cookie = Rack::Utils.parse_query(cookie_str)
    cookie['authenticity_token']
  end

  def check_authenticity_token
    controller_token = form_authenticity_token
    request_cookie_str = @req.env["HTTP_COOKIE"]
    request_cookie = Rack::Utils.parse_query(request_cookie_str)
    request_token = request_cookie['authenticity_token']

    raise 'Invalid authenticity token' unless controller_token == request_token
  end

  def self.protect_from_forgery
    @@protect_from_forgery = true
  end

  private

  def prepare_render_or_redirect
    raise "Cannot double render/redirect" if already_built_response?
    @already_built_response = true
    self.session.store_session(@res)
    flash.store_flash(@res)
  end

  def protect_from_forgery?
    @@protect_from_forgery
  end
end

