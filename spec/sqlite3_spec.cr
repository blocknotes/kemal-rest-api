require "./spec_helper"

require "db"
require "sqlite3"

module SQLite3Spec
  SQLITE3_DB_FILE       = "./test.sqlite3"
  SQLITE3_DB_CONNECTION = "sqlite3:#{SQLITE3_DB_FILE}"
  SQLITE3_DB_TABLE      = "Test"

  struct Sqlite3Model < KemalRestApi::Adapters::CrystalDbModel
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
      # res.set_options(json: false)
      res.generate_routes!
    end

    Spec.after_each do
      res.reset!
    end

    context "success responses" do
      it "should create an item (using json params)" do
        post "/items", headers: HTTP::Headers{"Accept" => "application/json", "Content-Type" => "application/json"}, body: %({"name":"Boh","age":123})
        response.status_code.should eq(201)
        response.headers["Content-Type"]?.should eq("application/json")
        json = JSON.parse response.body
        json["status"]?.should eq(MSG_OK)
        (json["id"]?.to_s.size > 0).should eq(true)
      end

      # it "should create an item (using formdata)" do
      #   post "/items", headers: HTTP::Headers{"Accept" => "application/json", "Content-Type" => "application/x-www-form-urlencoded"}, body: "name=Boh&age=123"
      #   response.status_code.should eq(201)
      #   response.headers["Content-Type"]?.should eq("application/json")
      #   json = JSON.parse response.body
      #   json["status"]?.should eq(MSG_OK)
      #   (json["id"]?.to_s.size > 0).should eq(true)
      # end

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
        put "/items/8", headers: HTTP::Headers{"Accept" => "application/json", "Content-Type" => "application/json"}, body: %({"name":"Yle","age":32})
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

    res.reset!
  end
end
