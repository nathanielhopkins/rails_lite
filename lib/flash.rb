require 'json'

class Flash
  attr_reader :now

  def initialize(req)
    cookie = req.cookies['_rails_lite_app_flash']

    @now = cookie ? JSON.parse(cookie) : {}
    @flash = {}
  end

  def [](key)
    @flash[key.to_s] || @now[key.to_s]
  end

  def []=(key, value)
    @flash[key] = value
  end

  def store_flash(res)
    res.set_cookie(
      '_rails_lite_app_flash', 
      { path: '/', value: @flash.to_json}
    )
  end
end
