require "kemal"

module KemalRestApi
  class Resource
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
              ret = resource.model.create resource.model.prepare_params(env, json: @option_json)
              env.response.content_type = "application/json"
              env.response.headers["Connection"] = "close"
              if ret && ret > 0
                env.response.status_code = 201
                {"status": "ok", "id": ret.to_s}.to_json
              else
                env.response.status_code = 400
                {"status": "error", "message": "bad_request"}.to_json
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
              ret = resource.model.update id, resource.model.prepare_params(env, json: @option_json)
              env.response.content_type = "application/json"
              env.response.headers["Connection"] = "close"
              if ret.nil?
                env.response.status_code = 404
                {"status": "error", "message": "not_found"}.to_json
              elsif ret == 0
                env.response.status_code = 400
                {"status": "error", "message": "bad_request"}.to_json
              else
                env.response.status_code = 200
                {"status": "ok"}.to_json
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
                {"status": "ok"}.to_json
              else
                env.response.status_code = 404
                {"status": "error", "message": "not_found"}.to_json
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
                  {"status": "error", "message": ex.message}.to_json
                end
              end
            when ActionType::POST
              post "#{path}" do |env|
                begin
                  block.call env
                rescue ex : Exception
                  {"status": "error", "message": ex.message}.to_json
                end
              end
            when ActionType::PUT
              put "#{path}" do |env|
                begin
                  block.call env
                rescue ex : Exception
                  {"status": "error", "message": ex.message}.to_json
                end
              end
            when ActionType::PATCH
              patch "#{path}" do |env|
                begin
                  block.call env
                rescue ex : Exception
                  {"status": "error", "message": ex.message}.to_json
                end
              end
            when ActionType::DELETE
              delete "#{path}" do |env|
                begin
                  block.call env
                rescue ex : Exception
                  {"status": "error", "message": ex.message}.to_json
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
