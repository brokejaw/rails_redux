require 'json'
require 'webrick'

class Session
  # find the cookie for this app
  # deserialize the cookie into a hash
  def initialize(req)
    cookie = req.cookies.find { |c| c.name == '_rails_lite_app' }
    @data = cookie.nil? ? {} : JSON.parse(cookie.value)
  end

  def [](key)
    @data[key]
  end

  def []=(key, val)
    @data[key] = val
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_session(res)
    res.cookies << WEBrick::Cookie.new('_rails_lite_app', @data.to_json)
  end
end

# 1. a new session object is created in controller_base
# 2. we search for our app cookie. if it exists we parse the data
# 3. if the cookie is not found, we create a new {}
# 4. we store the session cookie in the response's cookie method
# 5. we also provide getter/setter for the cookie