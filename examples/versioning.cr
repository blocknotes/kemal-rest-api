require "kemal"
require "../src/*"

class MyModel < KemalRestApi::Model
  def prepare_params(env : HTTP::Server::Context, *, json = true) : Hash(String, String)
    Hash(String, String).new
  end

  def create(args : Hash(String, String) | String)
    rand(100)
  end

  def read(id : Int)
    {"title": "Item #{rand(100)}", "num": "#{rand(100)}"}
  end

  def update(id : Int, args : Hash(String, String) | String)
    1
  end

  def delete(id : Int)
    1
  end

  def list
    items = [] of Hash(String, String)
    3.times do
      items.push({"title" => "Item #{rand(100)}", "num" => "#{rand(100)}"}.to_h)
    end
    items
  end
end

module WebApp
  res = KemalRestApi::Resource.new MyModel.new, KemalRestApi::ALL_ACTIONS, prefix: "api", singular: "item"
  res.generate_routes!
  Kemal.run
end
