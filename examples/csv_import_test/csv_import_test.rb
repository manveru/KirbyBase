#Test of CSV file import.

require 'kirbybase'
require 'date'

db = KirbyBase.new

# To run as a client in a multi-user environment, uncomment next line.
# Also, make sure kbserver.rb is running.
#db = KirbyBase.new do |d|
#    d.connect_type = :client
#    d.host = 'localhost'
#    d.port = 44444
#end

# If table exists, delete it.
db.drop_table(:plane) if db.table_exists?(:plane)

# Create a table.
plane_tbl = db.create_table(:plane, :name, :String, :country, :String,
 :role, :String, :speed, :Integer, :range, :Integer, :began_service, :Date,
 :still_flying, :Boolean)

# Import csv file.
puts 'Records imported: %d' % plane_tbl.import_csv('plane.csv')

puts

# Now, lets show that the csv file did, in fact, get imported.
puts plane_tbl.select(:name, :country, :role, :speed, :range).sort(:name
 ).to_report
