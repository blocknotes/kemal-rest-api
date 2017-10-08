require "./spec_helper"

require "db"
require "mysql"

module MySQLSpec
  MYSQL_DB_NAME       = "test"
  MYSQL_DB_TABLE      = "items"
  MYSQL_DB_URL        = "mysql://root@localhost/"
  MYSQL_DB_CONNECTION = "#{MYSQL_DB_URL}#{MYSQL_DB_NAME}"

  class MySQLModel < KemalRestApi::Adapters::CrystalDbModel
    def initialize
      super MYSQL_DB_CONNECTION, prepare
      # Insert some data
      DB.open MYSQL_DB_CONNECTION do |db|
        10.times do
          db.exec "INSERT INTO #{MYSQL_DB_TABLE} VALUES( NULL, \"Yle#{Random.rand(9)}\", #{Random.rand(100)} )"
        end
      end
    end

    def prepare
      prepare_db
      prepare_table
    end

    def prepare_db
      DB.open MYSQL_DB_URL do |db|
        if db.scalar("SELECT COUNT(*) FROM information_schema.tables WHERE TABLE_SCHEMA = '#{MYSQL_DB_NAME}'") == 0
          db.exec "CREATE DATABASE #{MYSQL_DB_NAME}"
        end
      end
    end

    def prepare_table
      DB.open MYSQL_DB_CONNECTION do |db|
        if db.scalar("SELECT COUNT(*) FROM information_schema.tables WHERE TABLE_SCHEMA = '#{MYSQL_DB_NAME}' AND TABLE_NAME = '#{MYSQL_DB_TABLE}'") == 0
          puts "> Create table #{MYSQL_DB_TABLE}"
          db.exec "CREATE TABLE #{MYSQL_DB_TABLE}( id INTEGER PRIMARY KEY AUTO_INCREMENT, name VARCHAR(255), age INTEGER )"
        else
          db.exec "TRUNCATE #{MYSQL_DB_TABLE}"
        end
      end
      MYSQL_DB_TABLE
    end
  end

  res = KemalRestApi::Resource.new MySQLModel.new

  describe KemalRestApi do
    Spec.before_each do
      Kemal::RouteHandler::INSTANCE.http_routes = Radix::Tree(Kemal::Route).new
      res = KemalRestApi::Resource.new MySQLModel.new, KemalRestApi::ALL_ACTIONS, singular: "item"
      res.generate_routes!
    end

    Spec.after_each do
      res.reset!
    end

    context "success responses" do
      it "should create an item" do
        # post "/items", headers: HTTP::Headers{"Accept" => "application/json", "Content-Type" => "application/x-www-form-urlencoded"}, body: "name=Boh&age=123"
        post "/items", headers: HTTP::Headers{"Accept" => "application/json", "Content-Type" => "application/json"}, body: {"name": "Boh", "age": 123}.to_json
        response.status_code.should eq(201)
        response.headers["Content-Type"]?.should eq("application/json")
        json = JSON.parse response.body
        json["status"]?.should eq(MSG_OK)
        (json["id"]?.to_s.size > 0).should eq(true)
      end

      it "should read an item" do
        get "/items/8", headers: HTTP::Headers{"Accept" => "application/json"}
        response.status_code.should eq(200)
        response.headers["Content-Type"]?.should eq("application/json")
        json = JSON.parse response.body
        (json["id"]?.to_s.size > 0).should eq(true)
        (json["name"]?.to_s.size > 0).should eq(true)
        (json["age"]?.to_s.size > 0).should eq(true)
      end

      it "should update an item" do
        # put "/items/8", headers: HTTP::Headers{"Accept" => "application/json", "Content-Type" => "application/x-www-form-urlencoded"}, body: "name=Boh&age=124"
        put "/items/8", headers: HTTP::Headers{"Accept" => "application/json", "Content-Type" => "application/json"}, body: {"name": "Yle", "age": 32}.to_json
        response.status_code.should eq(200)
        response.headers["Content-Type"]?.should eq("application/json")
        json = JSON.parse response.body
        json["status"]?.should eq(MSG_OK)
      end

      it "should delete an item" do
        delete "/items/8", headers: HTTP::Headers{"Accept" => "application/json"}
        response.status_code.should eq(200)
        response.headers["Content-Type"]?.should eq("application/json")
        json = JSON.parse response.body
        json["status"]?.should eq(MSG_OK)
      end

      it "should list 3 items" do
        get "/items", headers: HTTP::Headers{"Accept" => "application/json"}
        response.status_code.should eq(200)
        response.headers["Content-Type"]?.should eq("application/json")
        json = JSON.parse response.body
        (json.size > 0).should eq(true)
      end
    end

    context "not_found responses" do
      it "should not read an item" do
        get "/items/12", headers: HTTP::Headers{"Accept" => "application/json"}
        response.status_code.should eq(404)
        response.headers["Content-Type"]?.should eq("application/json")
        # json = JSON.parse response.body
        # json["status"]?.should eq(MSG_NOT_FOUND)
      end

      it "should not update an item" do
        put "/items/12", headers: HTTP::Headers{"Accept" => "application/json"}
        response.status_code.should eq(404)
        response.headers["Content-Type"]?.should eq("application/json")
        # json = JSON.parse response.body
        # json["status"]?.should eq(MSG_NOT_FOUND)
      end

      it "should not delete an item" do
        delete "/items/12", headers: HTTP::Headers{"Accept" => "application/json"}
        response.status_code.should eq(404)
        response.headers["Content-Type"]?.should eq("application/json")
        # json = JSON.parse response.body
        # json["status"]?.should eq(MSG_NOT_FOUND)
      end
    end

    context "with invalid responses" do
      it "should not create an item with empty data" do
        post "/items"
        response.status_code.should eq(400)
        response.headers["Content-Type"]?.should eq("application/json")
        json = JSON.parse response.body
        json["status"]?.should eq(MSG_ERROR)
      end
    end
  end

  res.reset!
end
