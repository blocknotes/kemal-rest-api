# kemal-rest-api [![Build Status](https://travis-ci.org/blocknotes/kemal-rest-api.svg?branch=master)](https://travis-ci.org/blocknotes/kemal-rest-api)

A Crystal library to create REST API with Kemal.

**NOTE**: this is an *alpha* version, a lot of features and security improvements need to be implemented actually

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

KemalRestApi::Resource.new MyModel.new, KemalRestApi::ALL_ACTIONS, prefix: "api", singular: "item"

module WebApp
  KemalRestApi.generate_routes!
  Kemal.run
end
```

Generated routes:

- POST /api/items
- GET /api/items/:id
- PUT /api/items/:id
- DELETE /api/items/:id
- GET /api/items

## KemalRestApi::Resource options

**plural** (String): plural name of the model, used for routes, default = *singular* pluralized

**prefix** (String): prefix for all API routes, default = ""

**singular** (String): singular name of the model, default = class model name lowercase

## More examples

See [examples](https://github.com/blocknotes/kemal-rest-api/tree/master/examples) folder.

## Notes

*crystal-db* shard is required only if `KemalRestApi::Adapters::CrystalDbModel` is used.

## Contributors

- [Mattia Roccoberton](http://blocknot.es) - creator, maintainer, Crystal fan :)
