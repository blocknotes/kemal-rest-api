# --------------------------------------------------------------------------- #
# kemal-rest-api basic example
# --------------------------------------------------------------------------- #
require "db"
require "mysql"
require "kemal"
require "../src/*"

DB_NAME = "test"
DB_CONNECTION = "mysql://root@localhost/#{DB_NAME}"

def create_table1
  table = "items"
  DB.open DB_CONNECTION do |db|
    if db.scalar( "SELECT COUNT(*) FROM information_schema.tables WHERE TABLE_SCHEMA = '#{DB_NAME}' AND TABLE_NAME = '#{table}'" ) == 0
      puts "> Create table #{table}"
      db.exec "CREATE TABLE #{table}( id INTEGER PRIMARY KEY AUTO_INCREMENT, name VARCHAR(255), age INTEGER )"
    end
  end
  table
end

struct MyModel < KemalRestApi::Adapters::CrystalDbModel
  def initialize
    super DB_CONNECTION, create_table1
  end
end

## Simple:
# KemalRestApi::Resource.new MyModel.new

## Change some options:
KemalRestApi::Resource.new MyModel.new, KemalRestApi::ALL_ACTIONS, singular: "item"

## Setup only specific routes:
# KemalRestApi::Resource.new MyModel.new, {
#   KemalRestApi::ActionMethod::READ => KemalRestApi::ActionType::GET,
#   KemalRestApi::ActionMethod::LIST => KemalRestApi::ActionType::GET,
#   KemalRestApi::ActionMethod::UPDATE => KemalRestApi::ActionType::PATCH,
# }, singular: "test"

module WebApp
  # Routes
  get "/" do |env|
    env.response.content_type = "text/plain"
    "Just a test..."
  end

  KemalRestApi.generate_routes!

  # Starts Kemal
  Kemal.run
end
