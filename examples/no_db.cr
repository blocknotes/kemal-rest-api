require "kemal"
require "../src/*"

struct MyModel < KemalRestApi::Model
  # create: it should return the id of the created row or nil on error
  def create( args : Hash(String, String) )
    ( rand > 0.5 ) ? rand( 100 ) : nil
  end
  # read: it should return an Hash( String, String ) or nil if not found
  def read( id : Int )
    ( rand > 0.5 ) ? { "title": "Item #{rand(100)}", "num": "#{rand(100)}" } : nil
  end
  # update: it should return the affected rows or nil on error
  def update( id : Int, args : Hash(String, String) )
    ( rand > 0.5 ) ? ( ( rand > 0.5 ) ? 1 : 0 ) : nil
  end
  # delete: it should return the affected rows or nil on error
  def delete( id : Int )
    ( rand > 0.5 ) ? ( ( rand > 0.5 ) ? 1 : 0 ) : nil
  end
  # list: it should return an Array of Hashes
  def list
    items = [] of Hash(String, String)
    rand( 5 ).times do
      items.push( { "title" => "Item #{rand(100)}", "num" => "#{rand(100)}" }.to_h )
    end
    items
  end
end

KemalRestApi::Resource.new MyModel.new, nil, singular: "item"

module WebApp
  KemalRestApi.generate_routes!
  Kemal.run
end
