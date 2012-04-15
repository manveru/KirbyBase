#Test of returning result set composed of instances of user class.  This
#example differs from the first in that there is no kb_create method, so
#KirbyBase will default to create a new instance of the record's custom
#class and setting each instance attribute to each field's value.

require 'kirbybase'

class Foobar
    attr_accessor(:recno, :name, :country, :role, :speed, :range,
     :began_service, :still_flying)
end 
        
# To run local, single-user, uncomment next line.
db = KirbyBase.new 

# If table exists, delete it.
db.drop_table(:plane) if db.table_exists?(:plane)

# Create a table.  Notice how you set record_class equal to your class.
plane_tbl = db.create_table do |t|
    t.name = :plane
    t.field_defs = [:name, :String, :country, :String, :role, :String, 
     :speed, :Integer, :range, :Integer, :began_service, :Date, 
     :still_flying, :Boolean]
    t.encrypt = false
    t.record_class = Foobar
end 

plane_tbl = db.get_table(:plane)

# Insert a record.
plane_tbl.insert('Spitfire','Great Britain','Fighter',333,454,
 Date.new(1936, 1, 1),true)

# Notice how select returns instances of Foobar, even there is no 
# kb_create method.
recs = plane_tbl.select
p recs.first
