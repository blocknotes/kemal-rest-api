require "./spec_helper"

module OptionsSpec
  class NoDbModel < KemalRestApi::Model
    def prepare_params(env : HTTP::Server::Context, *, json = true) : Hash(String, String)
      Hash(String, String).new
    end

    def create(args : Hash(String, String))
      rand(100)
    end

    def read(id : Int | String)
      {"title": "Item #{rand(100)}", "num": "#{rand(100)}"}
    end

    def update(id : Int | String, args : Hash(String, String))
      1
    end

    def delete(id : Int | String)
      1
    end

    def list
      items = [] of Hash(String, String)
      3.times do
        items.push({"title" => "Item #{rand(100)}", "num" => "#{rand(100)}"}.to_h)
      end
      items
    end
  end

  res = KemalRestApi::Resource.new NoDbModel.new

  describe KemalRestApi do
    Spec.before_each do
      Kemal::RouteHandler::INSTANCE.http_routes = Radix::Tree(Kemal::Route).new
      res = KemalRestApi::Resource.new NoDbModel.new, KemalRestApi::ALL_ACTIONS, prefix: "api/v1", singular: "item", plural: "objects"
      res.generate_routes!
    end

    Spec.after_each do
      res.reset!
    end

    context "success responses with prefix" do
      it "should list 3 items" do
        get "/api/v1/objects", headers: HTTP::Headers{"Accept" => "application/json"}
        response.status_code.should eq(200)
        response.headers["Content-Type"]?.should eq("application/json")
        json = JSON.parse response.body
        json.size.should eq(3)
      end
    end
  end
end
