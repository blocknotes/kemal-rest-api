module KemalRestApi
  struct Action
    property :method
    property :type

    def initialize( @method : ActionMethod, @type : ActionType )
    end
  end
end
