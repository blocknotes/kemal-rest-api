require "kemal"
require "../src/*"

class MyModel < KemalRestApi::Model
  def prepare_params(env : HTTP::Server::Context, *, json = true) : Hash(String, String)
    Hash(String, String).new
  end

  # create: it should return the id of the created row or nil on error
  def create(args : Hash(String, String))
    (rand > 0.5) ? rand(100) : nil
  end

  # read: it should return an Hash( String, String ) or nil if not found
  def read(id : Int | String)
    (rand > 0.5) ? {"title": "Item #{rand(100)}", "num": "#{rand(100)}"} : nil
  end

  # update: it should return the affected rows or nil on error
  def update(id : Int | String, args : Hash(String, String))
    (rand > 0.5) ? ((rand > 0.5) ? 1 : 0) : nil
  end

  # delete: it should return the affected rows or nil on error
  def delete(id : Int | String)
    (rand > 0.5) ? ((rand > 0.5) ? 1 : 0) : nil
  end

  # list: it should return an Array of Hashes
  def list
    items = [] of Hash(String, String)
    rand(5).times do
      items.push({"title" => "Item #{rand(100)}", "num" => "#{rand(100)}"}.to_h)
    end
    items
  end
end

module WebApp
  res = KemalRestApi::Resource.new MyModel.new, KemalRestApi::ALL_ACTIONS, singular: "item"
  res.generate_routes!
  Kemal.run
end
