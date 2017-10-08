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
end
