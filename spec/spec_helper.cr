require "spec-kemal"
require "../src/*"

MSG_ERROR     = "error"
MSG_NOT_FOUND = "Not Found"
MSG_OK        = "ok"

Spec.before_each do
  config = Kemal.config
  config.env = "test"
  config.setup
end

Spec.after_each do
  Kemal.config.clear
  Kemal::RouteHandler::INSTANCE.routes = Radix::Tree(Kemal::Route).new
  Kemal::RouteHandler::INSTANCE.cached_routes = Hash(String, Radix::Result(Kemal::Route)).new
  Kemal::WebSocketHandler::INSTANCE.routes = Radix::Tree(Kemal::WebSocket).new
end
