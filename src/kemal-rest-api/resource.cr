require "./action"

module KemalRestApi
  abstract struct Model
    abstract def create( args : Hash( String, String ) ): Int | Nil
    abstract def read( id : Int ): Hash( String, String ) | Nil
    abstract def update( id : Int, args : Hash( String, String ) ): Int | Nil
    abstract def delete( id : Int ): Int | Nil
    abstract def list(): Array( Hash( String, String ) )
  end

  struct Resource
    @@resources = [] of Resource
    @actions = [] of Action
    @singular : String
    @plural : String

    getter :actions, :model, :singular, :plural

    alias ActionsList = Hash( ActionMethod, ActionType )

    def initialize( @model : Model, actions : ActionsList | Nil = nil, *, singular = "", plural = "" )
      @singular = singular.strip.empty? ? typeof( model ).to_s.downcase : singular.strip
      @plural = plural.strip.empty? ? Resource.pluralize( @singular ) : plural.strip
      @@resources.push self
      setup_actions! actions
    end

    def self.pluralize( string )
      case string
      when /(s|x|z|ch)$/
        "#{string}es"
      when /(a|e|i|o|u)y$/
        "#{string}s"
      when /y$/
        "#{string[0..-2]}ies"
      when /f$/
        "#{string[0..-2]}ves"
      when /fe$/
        "#{string[0..-3]}ves"
      else
        "#{string}s"
      end
    end

    def self.resources
      @@resources
    end

    protected def setup_actions!( actions = {} of Action::Method => Action::MethodType )
      if !actions || actions.empty?
        @actions.push Action.new( ActionMethod::CREATE, ActionType::POST )
        @actions.push Action.new( ActionMethod::READ,   ActionType::GET )
        @actions.push Action.new( ActionMethod::UPDATE, ActionType::PUT )
        @actions.push Action.new( ActionMethod::DELETE, ActionType::DELETE )
        @actions.push Action.new( ActionMethod::LIST,   ActionType::GET )
      else
        actions.each do |k, v|
          @actions.push Action.new( k, v )
        end
      end
    end
  end

end
