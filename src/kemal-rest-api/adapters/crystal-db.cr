require "../resource"

module KemalRestApi::Adapters
  abstract class CrystalDbModel < Model
    def initialize(@db_connection : String, @table_name : String)
    end

    def prepare_params(env : HTTP::Server::Context, *, json = true) : Hash(String, String)
      data = Hash(String, String).new
      args = json ? env.params.json.to_json : env.params.body.to_h
      if (args_ = args).class == Hash(String, String)
        data = args.as(Hash(String, String))
      else
        data = Hash(String, String).new
        JSON.parse(args.as(String)).each do |k, v|
          data[k.to_s] = v.to_s
        end
      end
      data
    end

    def create(data : Hash(String, String))
      DB.open @db_connection do |db|
        return 0 if data.empty?
        result = db.exec "INSERT INTO #{@table_name}( #{data.keys.join(",")} ) VALUES( #{(["?"] * data.size).join(",")} )", data.values
        return result.last_insert_id if result
      end
      nil
    end

    def read(id : Int)
      DB.open @db_connection do |db|
        db.query "SELECT * FROM #{@table_name} WHERE id = ?", id do |rs|
          rs.each do
            item = {} of String => String
            rs.each_column { |col| item[col] = (val = rs.read) ? val.to_s : "" }
            return item
          end
        end
      end
      nil
    end

    def update(id : Int, data : Hash(String, String))
      DB.open @db_connection do |db|
        found = false
        db.query("SELECT * FROM #{@table_name} WHERE id = ?", id) { |rs| found = rs.move_next }
        if found
          return 0 if data.empty?
          fields = data.map { |k, v| "#{k} = ?" }.join(", ")
          ret = db.exec "UPDATE #{@table_name} SET #{fields} WHERE id = #{id}", data.values
          return ret.rows_affected if ret
        end
      end
      nil
    end

    def delete(id : Int)
      DB.open @db_connection do |db|
        found = false
        db.query("SELECT * FROM #{@table_name} WHERE id = ?", id) { |rs| found = rs.move_next }
        if found
          ret = db.exec "DELETE FROM #{@table_name} WHERE id = ?", id
          return ret.rows_affected if ret
        end
      end
      nil
    end

    def list
      items = [] of Hash(String, String)
      DB.open @db_connection do |db|
        db.query "SELECT * FROM #{@table_name}" do |rs|
          rs.each do
            item = {} of String => String
            rs.each_column { |col| item[col] = (val = rs.read) ? val.to_s : "" }
            items.push item
          end
        end
      end
      items
    end
  end
end
