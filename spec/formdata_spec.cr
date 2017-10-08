require "./spec_helper"

require "db"
require "sqlite3"

module FormDataSpec
  SQLITE3_DB_FILE       = "./test.sqlite3"
  SQLITE3_DB_CONNECTION = "sqlite3:#{SQLITE3_DB_FILE}"
  SQLITE3_DB_TABLE      = "Test"

  class Sqlite3Model < KemalRestApi::Adapters::CrystalDbModel
    def initialize
      super SQLITE3_DB_CONNECTION, create_table
      # Insert some data
      DB.open SQLITE3_DB_CONNECTION do |db|
        10.times do
          db.exec "INSERT INTO #{SQLITE3_DB_TABLE} VALUES( NULL, \"Yle#{Random.rand(9)}\", #{Random.rand(100)} )"
        end
      end
    end

    def create_table
      DB.open SQLITE3_DB_CONNECTION do |db|
        if db.scalar("SELECT COUNT(*) FROM sqlite_master WHERE type='table' AND name='#{SQLITE3_DB_TABLE}'") == 0
          puts "> Create table #{SQLITE3_DB_TABLE}"
          db.exec "CREATE TABLE #{SQLITE3_DB_TABLE}( id INTEGER PRIMARY KEY, name STRING, age INTEGER )"
        else
          db.exec "DELETE FROM #{SQLITE3_DB_TABLE}"
        end
      end
      SQLITE3_DB_TABLE
    end
  end

  res = KemalRestApi::Resource.new Sqlite3Model.new

  describe KemalRestApi do
    Spec.before_each do
      Kemal::RouteHandler::INSTANCE.http_routes = Radix::Tree(Kemal::Route).new
      res = KemalRestApi::Resource.new Sqlite3Model.new, KemalRestApi::ALL_ACTIONS, singular: "item"
      res.set_options(json: false)
      res.generate_routes!
    end

    Spec.after_each do
      res.reset!
    end

    context "success responses" do
      it "should create an item" do
        post "/items", headers: HTTP::Headers{"Accept" => "application/json", "Content-Type" => "application/x-www-form-urlencoded"}, body: "name=Boh&age=123"
        response.status_code.should eq(201)
        response.headers["Content-Type"]?.should eq("application/json")
        json = JSON.parse response.body
        json["status"]?.should eq(MSG_OK)
        (json["id"]?.to_s.size > 0).should eq(true)
      end

      it "should update an item" do
        put "/items/8", headers: HTTP::Headers{"Accept" => "application/json", "Content-Type" => "application/x-www-form-urlencoded"}, body: "name=Boh&age=124"
        response.status_code.should eq(200)
        response.headers["Content-Type"]?.should eq("application/json")
        json = JSON.parse response.body
        json["status"]?.should eq(MSG_OK)
      end
    end
  end
end
