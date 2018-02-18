require "./spec_helper"

module NoDbSpec
  class NoDbModel < KemalRestApi::Model
    def prepare_params(env : HTTP::Server::Context, *, json = true) : Hash(String, String)
      Hash(String, String).new
    end

    def create(args : Hash(String, String))
      args ? 8 : nil
    end

    def read(id : Int | String)
      if id.to_i > 10
        nil
      else
        {"title": "Item #{rand(100)}", "num": "#{rand(100)}"}
      end
    end

    def update(id : Int | String, args : Hash(String, String))
      id_ = id.to_i
      if id_ > 10
        nil
      elsif id_ > 5
        1
      else
        0
      end
    end

    def delete(id : Int | String)
      id_ = id.to_i
      if id_ > 10
        nil
      elsif id_ > 5
        1
      else
        0
      end
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
      Kemal::RouteHandler::INSTANCE.routes = Radix::Tree(Kemal::Route).new
      res = KemalRestApi::Resource.new NoDbModel.new, KemalRestApi::ALL_ACTIONS, singular: "item"
      res.generate_routes!
    end

    Spec.after_each do
      res.reset!
    end

    context "success responses" do
      it "should create an item" do
        post "/items", headers: HTTP::Headers{"Accept" => "application/json"}
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
        (json["title"]?.to_s.size > 0).should eq(true)
        (json["num"]?.to_s.size > 0).should eq(true)
        (json["invalid_key"]?.to_s.size > 0).should eq(false)
      end

      it "should update an item" do
        put "/items/8", headers: HTTP::Headers{"Accept" => "application/json"}
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
        json.size.should eq(3)
      end
    end

    context "not_found responses" do
      it "should not read an item" do
        get "/items/12", headers: HTTP::Headers{"Accept" => "application/json"}
        response.status_code.should eq(404)
        response.headers["Content-Type"]?.should eq("application/json")
      end

      it "should not update an item" do
        put "/items/12", headers: HTTP::Headers{"Accept" => "application/json"}
        response.status_code.should eq(404)
        response.headers["Content-Type"]?.should eq("application/json")
      end

      it "should not delete an item" do
        delete "/items/12", headers: HTTP::Headers{"Accept" => "application/json"}
        response.status_code.should eq(404)
        response.headers["Content-Type"]?.should eq("application/json")
      end
    end

    # context "with invalid responses" do
    # ...
    # end
  end
end
