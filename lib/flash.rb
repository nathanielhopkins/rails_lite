require 'json'

class Flash
  attr_reader :flash
  def initialize(req)
    if req.cookies["_rails_lite_app_flash"]
      @flash = JSON.parse(req.cookies['_rails_lite_app_flash'])
    else
      @flash = {}
    end
  end

  def [](key)
    @flash[key]
  end

  def []=(key, value)
    @flash[key] = value
  end

  def store_flash(res)
  end
end
