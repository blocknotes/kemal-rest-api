require "kemal"
require "./kemal-rest-api/*"
require "./kemal-rest-api/adapters/*"

module KemalRestApi
  DEBUG = true

  enum ActionMethod
    CREATE
    READ
    UPDATE
    DELETE
    LIST
  end

  enum ActionType
    GET
    POST
    PUT
    PATCH
    DELETE
  end

  before_all do |env|
    env.response.content_type = "application/json"
  end

  error 400 do
    { "message": "Bad Request" }.to_json
  end

  error 401 do
    { "message": "Unauthorized" }.to_json
  end

  error 404 do
    { "message": "Not Found" }.to_json
  end

  error 500 do
    { "message": "Internal Server Error" }.to_json
  end
end
