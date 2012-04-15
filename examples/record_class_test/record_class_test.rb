#Test of returning result set composed of instances of user class.

require 'kirbybase'

class Foobar
    attr_accessor(:recno, :name, :country, :role, :speed, :range,
     :began_service, :still_flying, :alpha, :beta)
     
    def Foobar.kb_create(recno, name, country, role, speed, range,
     began_service, still_flying)
        name ||= 'No Name!'
        speed ||= 0
        began_service ||= Date.today
        Foobar.new do |x|
            x.recno = recno
            x.name = name
            x.country = country
            x.role = role
            x.speed = speed
            x.range = range
            x.began_service = began_service
            x.still_flying = still_flying
        end
    end
    
    def initialize(&block)
        instance_eval(&block)
    end
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

# Insert a record using an instance of Foobar.
foo = Foobar.new do |x|
    x.name = 'Spitfire'
    x.country = 'Great Britain'
    x.role = 'Fighter'
    x.speed = 333
    x.range = 454
    x.began_service = Date.new(1936, 1, 1)
    x.still_flying = true
    x.alpha = "This variable won't be stored in KirbyBase."
    x.beta = 'Neither will this one.'
end
plane_tbl.insert(foo)

# Notice how select returns instances of Foobar, since it was defined as the
# record class.
recs = plane_tbl.select
puts "Example using #kb_create"
puts recs[0].class

# Now we are going to change a couple of fields of the Spitfire's Foobar
# object and update the Spitfire record in the Plane table with the updated 
# Foobar object.
recs[0].speed = 344
recs[0].range = 555
plane_tbl.update(recs[0]) {|r| r.name == 'Spitfire'}

# Here's proof that the table was updated.
p plane_tbl.select {|r| r.name == 'Spitfire'}
