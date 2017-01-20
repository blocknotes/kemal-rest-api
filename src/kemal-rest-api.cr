require "kemal"
require "./kemal-rest-api/*"
require "./kemal-rest-api/adapters/*"

module KemalRestApi
  DEBUG = false

  ALL_ACTIONS = {} of ActionMethod => ActionType

  error 400 do |env|
    env.response.content_type = "application/json"
    { "message": "Bad Request" }.to_json
  end

  error 401 do |env|
    env.response.content_type = "application/json"
    { "message": "Unauthorized" }.to_json
  end

  error 404 do |env|
    env.response.content_type = "application/json"
    { "message": "Not Found" }.to_json
  end

  error 500 do |env|
    env.response.content_type = "application/json"
    { "message": "Internal Server Error" }.to_json
  end
end
