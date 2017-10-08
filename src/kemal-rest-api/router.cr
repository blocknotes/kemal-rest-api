require "kemal"

module KemalRestApi
  class JSONresponse
    def initialize(@response : JSON::Any | Nil)
    end
  end

  struct Resource
    def generate_routes!
      @resources.each do |resource|
        resource.actions.each do |action|
          path = ""
          block = ->(env : HTTP::Server::Context) {}
          case action.method
          when ActionMethod::CREATE
            path = "/#{resource.plural}"
            block = ->(env : HTTP::Server::Context) do
              # TODO: let pass only valid fields
              ret = resource.model.create @option_json ? env.params.json.to_json : env.params.body.to_h
              env.response.content_type = "application/json"
              env.response.headers["Connection"] = "close"
              if ret && ret > 0
                env.response.status_code = 201
                {"message": "ok", "id": ret.to_s}.to_json
              else
                env.response.status_code = 400
              end
            end
          when ActionMethod::READ
            path = "/#{resource.plural}/:id"
            block = ->(env : HTTP::Server::Context) do
              id = env.params.url["id"].to_i
              ret = resource.model.read id
              env.response.status_code = ret ? 200 : 404
              env.response.content_type = "application/json"
              env.response.headers["Connection"] = "close"
              ret.to_json
            end
          when ActionMethod::UPDATE
            path = "/#{resource.plural}/:id"
            block = ->(env : HTTP::Server::Context) do
              id = env.params.url["id"].to_i
              # TODO: let pass only valid fields
              ret = resource.model.update id, @option_json ? env.params.json.to_json : env.params.body.to_h
              env.response.content_type = "application/json"
              env.response.headers["Connection"] = "close"
              if ret.nil?
                env.response.status_code = 404
              elsif ret == 0
                env.response.status_code = 400
              else
                env.response.status_code = 200
                {"message": "ok"}.to_json
              end
            end
          when ActionMethod::DELETE
            path = "/#{resource.plural}/:id"
            block = ->(env : HTTP::Server::Context) do
              id = env.params.url["id"].to_i
              ret = resource.model.delete id
              env.response.status_code = ret ? 200 : 404
              env.response.content_type = "application/json"
              env.response.headers["Connection"] = "close"
              if ret
                env.response.status_code = 200
                {"message": "ok"}.to_json
              else
                env.response.status_code = 404
              end
            end
          when ActionMethod::LIST
            path = "/#{resource.plural}"
            block = ->(env : HTTP::Server::Context) do
              ret = resource.model.list.to_json
              env.response.status_code = 200
              env.response.content_type = "application/json"
              env.response.headers["Connection"] = "close"
              ret
            end
          end
          unless resource.prefix.empty?
            path = '/' + resource.prefix + path
          end
          unless path.empty?
            case action.type
            when ActionType::GET
              get "#{path}" do |env|
                begin
                  block.call env
                rescue ex : Exception
                  {"error": ex.message}.to_json
                end
              end
            when ActionType::POST
              post "#{path}" do |env|
                begin
                  block.call env
                rescue ex : Exception
                  {"error": ex.message}.to_json
                end
              end
            when ActionType::PUT
              put "#{path}" do |env|
                begin
                  block.call env
                rescue ex : Exception
                  {"error": ex.message}.to_json
                end
              end
            when ActionType::PATCH
              patch "#{path}" do |env|
                begin
                  block.call env
                rescue ex : Exception
                  {"error": ex.message}.to_json
                end
              end
            when ActionType::DELETE
              delete "#{path}" do |env|
                begin
                  block.call env
                rescue ex : Exception
                  {"error": ex.message}.to_json
                end
              end
            end
            puts "#{action.type} #{path}" if DEBUG
          end
        end
      end
    end
  end
end
