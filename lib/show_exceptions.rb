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
    # does not pass simple specs provided, but does successfully render errors view
    dir_path = File.dirname(__FILE__)
    template_fname = File.join(dir_path, "templates", "rescue.html.erb")
    template = File.read(template_fname) 
    body = ERB.new(template).result(binding)
  
    @response.status = 500
    @response['Content-Type'] = 'text/html'
    @response.write(body)

    @response.finish
  end

  def error_source_file(e)
    stack_trace_top = e.backtrace.first.split(':')
    stack_trace_top(e)[0]
  end

  def stack_trace_top(e)
    e.backtrace[0].split(':')
  end

  def extract_formatted_source(e)
    source_file_name = error_source_file(e)
    source_line_num = source_line_num(e)
    source_lines = extract_source(source_file_name)
    format_source(source_lines, source_line_num)
  end

  def source_line_num(e)
    stack_trace_top(e)[1].to_i
  end

  def formatted_source(file, source_line_num)
    source_lines = extract_source(file)
    format_source(source_lines, source_line_num)
  end

  def extract_source(file)
    source_file = File.open(file, 'r')
    source_file.readlines
  end

  def format_source(source_lines, source_line_num)
    start = [0, source_line_num - 3].max
    lines = source_lines[start..(start + 5)]
    Hash[*(start+1..(lines.count + start)).zip(lines).flatten]
  end
end
