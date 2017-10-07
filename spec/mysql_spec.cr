# ## NOTE: disabled - problems with kemal / spec-kemal: "Duplicate trail found"

# require "./spec_helper"

# require "db"
# require "mysql"

# DB_NAME       = "test"
# DB_TABLE      = "items"
# DB_CONNECTION = "mysql://root@localhost/#{DB_NAME}"

# def create_table1
#   DB.open DB_CONNECTION do |db|
#     if db.scalar("SELECT COUNT(*) FROM information_schema.tables WHERE TABLE_SCHEMA = '#{DB_NAME}' AND TABLE_NAME = '#{DB_TABLE}'") == 0
#       puts "> Create table #{DB_TABLE}"
#       db.exec "CREATE TABLE #{DB_TABLE}( id INTEGER PRIMARY KEY AUTO_INCREMENT, name VARCHAR(255), age INTEGER )"
#     else
#       db.exec "TRUNCATE #{DB_TABLE}"
#     end
#   end
#   DB_TABLE
# end

# def insert_some_data
#   DB.open DB_CONNECTION do |db|
#     10.times do
#       db.exec "INSERT INTO #{DB_TABLE} VALUES( NULL, \"Yle#{Random.rand(9)}\", #{Random.rand(100)} )"
#     end
#   end
# end

# struct MySQLModel < KemalRestApi::Adapters::CrystalDbModel
#   def initialize
#     super DB_CONNECTION, create_table1
#   end
# end

# module CrystalDbSpec
#   res = KemalRestApi::Resource.new MySQLModel.new, KemalRestApi::ALL_ACTIONS, singular: "item"
#   res.generate_routes!
#   insert_some_data

#   MSG_NOT_FOUND = "Not Found"
#   MSG_OK        = "ok"

#   describe KemalRestApi do
#     # Spec.before_each do
#     #   # KemalRestApi.generate_routes!
#     # end

#     context "success responses" do
#       it "should create an item" do
#         post "/items", headers: HTTP::Headers{"Accept" => "application/json", "Content-Type" => "application/x-www-form-urlencoded"}, body: "name=Mat&age=39"
#         response.status_code.should eq(201)
#         response.headers["Content-Type"]?.should eq("application/json")
#         json = JSON.parse response.body
#         json["message"]?.should eq(MSG_OK)
#         (json["id"]?.to_s.size > 0).should eq(true)
#       end

#       it "should read an item" do
#         get "/items/8", headers: HTTP::Headers{"Accept" => "application/json"}
#         response.status_code.should eq(200)
#         response.headers["Content-Type"]?.should eq("application/json")
#         json = JSON.parse response.body
#         (json["id"]?.to_s.size > 0).should eq(true)
#         (json["name"]?.to_s.size > 0).should eq(true)
#         (json["age"]?.to_s.size > 0).should eq(true)
#       end

#       it "should update an item" do
#         put "/items/8", headers: HTTP::Headers{"Accept" => "application/json", "Content-Type" => "application/x-www-form-urlencoded"}, body: "name=Mat&age=39"
#         response.status_code.should eq(200)
#         response.headers["Content-Type"]?.should eq("application/json")
#         json = JSON.parse response.body
#         json["message"]?.should eq(MSG_OK)
#       end

#       it "should delete an item" do
#         delete "/items/8", headers: HTTP::Headers{"Accept" => "application/json"}
#         response.status_code.should eq(200)
#         response.headers["Content-Type"]?.should eq("application/json")
#         json = JSON.parse response.body
#         json["message"]?.should eq(MSG_OK)
#       end

#       it "should list 3 items" do
#         get "/items", headers: HTTP::Headers{"Accept" => "application/json"}
#         response.status_code.should eq(200)
#         response.headers["Content-Type"]?.should eq("application/json")
#         json = JSON.parse response.body
#         (json.size > 0).should eq(true)
#       end
#     end
#   end

#   res.reset!
# end
