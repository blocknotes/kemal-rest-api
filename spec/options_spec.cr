# ## NOTE: disabled - problems with kemal / spec-kemal: "Duplicate trail found"

# require "./spec_helper"

# struct NoDbModel < KemalRestApi::Model
#   def create(args : Hash(String, String))
#     rand(100)
#   end

#   def read(id : Int)
#     {"title": "Item #{rand(100)}", "num": "#{rand(100)}"}
#   end

#   def update(id : Int, args : Hash(String, String))
#     1
#   end

#   def delete(id : Int)
#     1
#   end

#   def list
#     items = [] of Hash(String, String)
#     3.times do
#       items.push({"title" => "Item #{rand(100)}", "num" => "#{rand(100)}"}.to_h)
#     end
#     items
#   end
# end

# module OptionsSpec
#   res = KemalRestApi::Resource.new NoDbModel.new, KemalRestApi::ALL_ACTIONS, prefix: "api/v1", singular: "item", plural: "objects"
#   res.generate_routes!

#   MSG_NOT_FOUND = "Not Found"
#   MSG_OK        = "ok"

#   describe KemalRestApi do
#     context "success responses with prefix" do
#       it "should list 3 items" do
#         get "/api/v1/objects", headers: HTTP::Headers{"Accept" => "application/json"}
#         response.status_code.should eq(200)
#         response.headers["Content-Type"]?.should eq("application/json")
#         json = JSON.parse response.body
#         json.size.should eq(3)
#       end
#     end
#   end

#   res.reset!
# end
