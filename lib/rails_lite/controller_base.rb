require 'erb'
require 'active_support/inflector'
require_relative 'params'
require_relative 'session'


class ControllerBase
  attr_reader :params, :req, :res
 
  def initialize(req, res, route_params = {})
    @req = req
    @res = res
    @already_built_response = false
    @params = Params.new(@req)
  end

  # populate the response with content
  # set the responses content type to the given type
  # later raise an error on double render
  def render_content(content, type)
    if already_built_response?
      raise "error"
    else
      @res.body = content
      @res.content_type = type
      @already_built_response = true
    end
  end

  # helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # set the response status code and header
  # redirect creates a new response object and sets attributes
  # for its status code and header
  def redirect_to(url)
    if already_built_response?
      raise "error"
    else
      @res.status = 302
      @res.header['location'] = url
      @already_built_response = true
    end
  end
  
  # binding grabs all the templates instance variables
  def render(template_name)
    template_fname =
      File.join("views", self.class.name.underscore,       "#{template_name}.html.erb")
      
    render_content(
      ERB.new(File.read(template_fname)).result(binding),
      "text/html"
    )
  end
  
  def session
    @session ||= Session.new(@req)
  end

  # called from the router. 
  def invoke_action(name)
  end
end
