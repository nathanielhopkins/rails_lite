require 'active_support'
require 'active_support/core_ext'
require 'erb'
require_relative './session'
require_relative './flash'

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
    raw_path = "views/#{controller_name}/file_name"
    dir = File.dirname(raw_path)
    template_file = template_name.to_s + ".html.erb"
    path = File.join(dir, template_file)
    template = File.read(path)
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
    send(name)
    render(name) if !self.already_built_response?
  end

  private

  def prepare_render_or_redirect
    raise "Cannot double render/redirect" if already_built_response?
    @already_built_response = true
    self.session.store_session(@res)
    flash.store_flash(@res)
  end
end

