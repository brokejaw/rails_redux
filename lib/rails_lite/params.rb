require 'uri'

class Params
  attr_accessor :params
  # use your initialize to merge params from
  # 1. query string
  # 2. post body
  # 3. route params
  def initialize(req, route_params = {})
    @params = {}
    
    @params.merge!(route_params)
    if req.query_string
      @params.merge!(parse_www_encoded_form(req.query_string))
    end
    if req.body
      @params.merge!(parse_www_encoded_form(req.body))
    end
    
    @permitted = []
  end

  def [](key)
    @params[key]
  end

  def permit(*keys)
    keys.each do |key|
      @permitted << key
    end
  end

  def require(key)
  end

  def permitted?(key)
    @permitted.include?(key)
  end

  def to_s
    @params.to_json.to_s
  end

  class AttributeNotFoundError < ArgumentError; end;

  private

  def parse_www_encoded_form(www_encoded_form)
    decoded_params = URI.decode_www_form(www_encoded_form)
    
    decoded_params.each do |arr|
      
      @params[arr[0]] = arr[1]
    end
    
    @params
    # set parsed params with: @params[key] = value
  end
  
  # user[address][street] should return ['user', 'address', 'street']
  def parse_key(key)
    
  end
end
