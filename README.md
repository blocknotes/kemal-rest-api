# kemal-rest-api [![Build Status](https://travis-ci.org/blocknotes/kemal-rest-api.svg?branch=master)](https://travis-ci.org/blocknotes/kemal-rest-api)

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
require "db"       # dependency required to use CrystalDbModel
require "sqlite3"  # dependency required to use CrystalDbModel - alternatives: crystal-mysql, crystal-pg
require "kemal"
require "kemal-rest-api"

struct MyModel < KemalRestApi::Adapters::CrystalDbModel
  def initialize
    super "sqlite3:./db.sqlite3", "my_table"
  end
end

KemalRestApi::Resource.new MyModel.new, nil, singular: "item"

module WebApp
  KemalRestApi.generate_routes!
  Kemal.run
end

## Generated routes:
# POST /items
# GET /items/:id
# PUT /items/:id
# DELETE /items/:id
# GET /items
```

## KemalRestApi::Resource options

- *singular*: singular name of the model
- *plural*: plural name of the model

## More examples

See [examples](https://github.com/blocknotes/kemal-rest-api/tree/master/examples) folder.

## Notes

*crystal-db* shard is required only if `KemalRestApi::Adapters::CrystalDbModel` is used.

## Contributors

- [Mattia Roccoberton](http://blocknot.es) - creator, maintainer, Crystal fan :)
