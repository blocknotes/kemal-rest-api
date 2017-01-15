# kemal-rest-api

A Crystal library to create REST API with Kemal

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  kemal-rest-api:
    github: blocknotes/kemal-rest-api
```

## Usage

```ruby
require "db"
require "sqlite3"
require "kemal"
require "kemal-rest-api"

struct MyModel < KemalRestApi::Adapters::CrystalDbModel
  def initialize
    super DB_CONNECTION, create_table1
  end
end

KemalRestApi::Resource.new MyModel.new

module WebApp
  KemalRestApi.generate_routes!
  Kemal.run
end
```

## More examples

See [examples](https://github.com/blocknotes/kemal-rest-api/tree/master/examples) folder.

## Contributors

- [Mattia Roccoberton](http://blocknot.es) - creator, maintainer, Crystal fan :)
