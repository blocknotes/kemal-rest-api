require "kemal"
require "../src/*"

struct MyModel < KemalRestApi::Model
  def create(args : Hash(String, String))
    (rand > 0.5) ? rand(100) : nil
  end

  def read(id : Int)
    (rand > 0.5) ? {"title": "Item #{rand(100)}", "num": "#{rand(100)}"} : nil
  end

  def update(id : Int, args : Hash(String, String))
    (rand > 0.5) ? ((rand > 0.5) ? 1 : 0) : nil
  end

  def delete(id : Int)
    (rand > 0.5) ? ((rand > 0.5) ? 1 : 0) : nil
  end

  def list
    items = [] of Hash(String, String)
    rand(5).times do
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
