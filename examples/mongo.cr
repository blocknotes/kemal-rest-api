require "mongo"
require "kemal"
require "../src/*"

class MongoHelper
  DB_NAME       = "test"
  DB_COLLECTION = "coll"
  DB_CONNECTION = "mongodb://localhost/#{DB_NAME}"

  def get_client
    Mongo::Client.new(DB_CONNECTION)
  end

  def get_database
    client = get_client
    client[DB_NAME]
  end

  def get_collection
    db = get_database
    db[DB_COLLECTION]
  end

  def with_database
    # db.collection_names.includes?( DB_COLLECTION ) ? db[DB_COLLECTION] : get_collection
    db = get_database
    begin
      yield db
    ensure
      # db.drop
    end
  end

  def with_collection
    with_database do |db|
      col = db[DB_COLLECTION]
      yield col
    end
  end
end

class MongoModel < KemalRestApi::Model
  DB_NAME       = "test"
  DB_COLLECTION = "coll"
  DB_CONNECTION = "mongodb://localhost/#{DB_NAME}"

  @mongodb = MongoHelper.new

  def prepare_params(env : HTTP::Server::Context, *, json = true) : Hash(String, String)
    data = Hash(String, String).new
    args = json ? env.params.json.to_json : env.params.body.to_h
    if (args_ = args).class == Hash(String, String)
      data = args.as(Hash(String, String))
    else
      data = Hash(String, String).new
      JSON.parse(args.as(String)).each do |k, v|
        data[k.to_s] = v.to_s
      end
    end
    data
  end

  def create(data : Hash(String, String))
    ret = 0
    @mongodb.with_collection do |coll|
      coll.insert(data)
      if (err = coll.last_error)
        ret = err["nInserted"].as(Int)
      end
    end
    ret
  end

  def read(id : Int | String)
    @mongodb.with_collection do |coll|
      coll.find_one({"_id" => BSON::ObjectId.new(id)})
    end
  end

  def update(id : Int | String, data : Hash(String, String))
    ret = 0
    @mongodb.with_collection do |coll|
      coll.update({"_id" => BSON::ObjectId.new(id)}, {"$set" => data})
      if (err = coll.last_error)
        ret = err["nModified"].as(Int)
      end
    end
    ret
  end

  def delete(id : Int | String)
    ret = false
    @mongodb.with_collection do |coll|
      doc = coll.find_one({"_id" => BSON::ObjectId.new(id)})
      if doc
        #  TODO: remove find_one to use only remove?
        coll.remove({"_id" => BSON::ObjectId.new(id)})
        ret = true
      end
    end
    ret
  end

  def list
    results = [] of Hash(String, String)
    @mongodb.with_collection do |coll|
      coll.find(BSON.new) do |doc|
        hash = Hash(String, String).new
        doc.each_pair do |k, v|
          hash[k] = v.value.to_s
        end
        results << hash
      end
    end
    results
  end

  # def db_connect
  #   require "mongo"
  #   client = Mongo::Client.new "mongodb://localhost"
  #   db = client["test"]
  #   collection = db["coll"]
  #   collection.find({} of String => String) do |doc| p doc; end
  #
  #   # client = Mongo::Client.new DB_CONNECTION
  #   # db = client[DB_NAME]
  #   # collection = db[DB_COLLECTION]
  #   # collection.insert({"name" => "James Bond", "age" => 37})
  #   @mongodb.with_collection do |coll|
  #     # p coll.count
  #     coll.insert({"name" => "James Blond", "age" => 123})
  #   end
  # end
end

module WebApp
  res = KemalRestApi::Resource.new MongoModel.new, KemalRestApi::ALL_ACTIONS, singular: "item"
  res.generate_routes!
  Kemal.run
end
