require 'json'

class Session
  # find the cookie for this app
  # deserialize the cookie into a hash
  def initialize(req)
    # @cookies = JSON.parse(req.cookies['_rails_lite_app'] ||= "{}")
    if req.cookies["_rails_lite_app"]
      @cookies = JSON.parse(req.cookies['_rails_lite_app'])
    else
      @cookies = {}
    end
  end

  def [](key)
    @cookies[key]
  end

  def []=(key, val)
    @cookies[key] = val
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_session(res)
    res.set_cookie(
      '_rails_lite_app', 
      { path: '/', value: @cookies.to_json}
    )
  end
end
