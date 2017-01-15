require "../resource"

module KemalRestApi::Adapters
  abstract struct CrystalDbModel < Model
    def initialize( @db_connection : String, @table_name : String )
    end

    def create( args : Hash( String, DB::Any ) )
      DB.open @db_connection do |db|
        if args.empty?
          return 0
        else
          v = "?" + ",?" * ( args.size - 1 )
          result = db.exec "INSERT INTO #{@table_name}( #{args.keys.join( "," )} ) VALUES( #{v} )", args.values
          return result.last_insert_id if result
        end
      end
      nil
    end

    def read( id : Int )
      DB.open @db_connection do |db|
        db.query "SELECT * FROM #{@table_name} WHERE id = ?", id do |rs|
          rs.each do
            item = {} of String => String
            rs.each_column { |col| item[col] = ( val = rs.read ) ? val.to_s : "" }
            return item
          end
        end
      end
      nil
    end

    def update( id : Int, args : Hash( String, DB::Any ) )
      DB.open @db_connection do |db|
        found = false
        db.query( "SELECT * FROM #{@table_name} WHERE id = ?", id ) { |rs| found = rs.move_next }
        if found
          if args.empty?
            return 0
          else
            fields = args.map { |k, v| "#{k} = ?" }.join( ", " )
            ret = db.exec "UPDATE #{@table_name} SET #{fields} WHERE id = #{id}", args.values
            return ret.rows_affected if ret
          end
        end
      end
      nil
    end

    def delete( id : Int )
      DB.open @db_connection do |db|
        found = false
        db.query( "SELECT * FROM #{@table_name} WHERE id = ?", id ) { |rs| found = rs.move_next }
        if found
          ret = db.exec "DELETE FROM #{@table_name} WHERE id = ?", id
          return ret.rows_affected if ret
        end
      end
      nil
    end

    def list
      items = [] of Hash( String, String )
      DB.open @db_connection do |db|
        db.query "SELECT * FROM #{@table_name}" do |rs|
          rs.each do
            item = {} of String => String
            rs.each_column { |col| item[col] = ( val = rs.read ) ? val.to_s : "" }
            items.push item
          end
        end
      end
      items
    end
  end
end
