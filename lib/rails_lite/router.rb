class Route
  attr_reader :pattern, :http_method, :controller_class, :action_name
  
  def initialize(pattern, http_method, controller_class, action_name)
    @pattern = pattern                   # eg /users/new
    @http_method = http_method           # eg GET
    @controller_class = controller_class # eg UsersController
    @action_name = action_name           # eg #index
  end

  # checks if pattern matches path and method matches request method
  def matches?(req) #this calls our http methods in 
    http_method == req.request_method.downcase.to_sym && !!(pattern =~ req.path)
  end

  # use pattern to pull out route params (save for later?)
  # instantiate controller and call controller action
  def run(req, res)
    match_data = @pattern.match(req.path)

    route_params = {}
    match_data.names.each do |name|
      route_params[name] = match_data[name]
    end

    @controller_class
      .new(req, res, route_params)
      .invoke_action(action_name)
  end
end

class Router
  attr_reader :routes

  def initialize
    @routes = []
  end
  
  def add_route(pattern, method, controller_class, action_name)
    @routes << Route.new(
      pattern, 
      method, 
      controller_class, 
      action_name
    )
  end
  
  def draw(&proc)
    instance_eval(&proc)
  end

  [:get, :post, :put, :delete].each do |http_method|
    define_method(http_method) do |pattern, controller_class, action_name|
      add_route(pattern, http_method, controller_class, action_name)
    end
  end
  
  # same as
  # def get
  # => add_route()

  # should return the route that matches this request
  def match(req)
    routes.find { |route| route.matches?(req) }
  end

  # either throw 404 or call run on a matched route
  def run(req, res)
    matched_route = match(req)
    
    if matched_route.nil?
      res.status = 404
    else
      matched_route.run(req, res)
    end
  end
end

