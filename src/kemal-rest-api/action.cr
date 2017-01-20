module KemalRestApi
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

  struct Action
    property :method
    property :type

    def initialize( @method : ActionMethod, @type : ActionType )
    end
  end
end
