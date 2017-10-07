require "./spec_helper"

require "db"
require "sqlite3"

DB_CONNECTION = "sqlite3:./test.sqlite3"

def create_table1
  table = "Test"
  DB.open DB_CONNECTION do |db|
    if db.scalar("SELECT COUNT(*) FROM sqlite_master WHERE type='table' AND name='#{table}'") == 0
      puts "> Create table #{table}"
      db.exec "CREATE TABLE #{table}( id INTEGER PRIMARY KEY, name STRING, age INTEGER )"
    end
  end
  table
end

struct Sqlite3Model < KemalRestApi::Adapters::CrystalDbModel
  def initialize
    super DB_CONNECTION, create_table1
  end
end

module CrystalDbSpec
  # , prefix: "api"
  KemalRestApi::Resource.new Sqlite3Model.new, KemalRestApi::ALL_ACTIONS, singular: "item"
  KemalRestApi.generate_routes!

  MSG_NOT_FOUND = "Not Found"
  MSG_OK        = "ok"

  describe KemalRestApi do
    context "success responses" do
      # it "should create an item" do
      #   post "/test" do |env|
      #     env.params.json.to_json
      #   end
      #   json_body = {"name": "Test", "age": 123}
      #   post("/test", headers: HTTP::Headers{"Content-Type" => "application/json"}, body: json_body.to_json)
      #   response.body.should eq(json_body.to_json)
      # end

      # it "should create an item" do
      #   # post("/items", headers: HTTP::Headers{"Accept" => "application/json"}, body: "name=Mat&age=39")
      #   # HTTP::Client.post "http://localhost:3000/items", nil, "name=Mat&age=39"
      #   post "/items", nil, "name=Mat&age=39"
      #   response.status_code.should eq(201)
      #   response.headers["Content-Type"]?.should eq("application/json")
      #   json = JSON.parse response.body
      #   json["message"]?.should eq(MSG_OK)
      #   (json["id"]?.to_s.size > 0).should eq(true)
      # end
    end
  end

  KemalRestApi::Resource.reset!
end
