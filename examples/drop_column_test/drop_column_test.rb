#Test of drop_column method.

require 'kirbybase'

db = KirbyBase.new

# If table exists, delete it.
db.drop_table(:plane) if db.table_exists?(:plane)

# Create a table.
plane_tbl = db.create_table(:plane, :name, :String, :speed, :Integer,
 :service_date, :Date, :still_flying, :Boolean)

# Insert a bunch more records so we can have some "select" fun below.
plane_tbl.insert('Spitfire', 345, Date.new(1939,2,18), true)
plane_tbl.insert('Oscar', 361, Date.new(1943,12,31), false)
plane_tbl.insert('ME-109', 366, Date.new(1936,7,7),true)
plane_tbl.insert('JU-88', 289, Date.new(1937,1,19), false)
plane_tbl.insert('P-39', nil, nil, false)
plane_tbl.insert('Zero', 377, Date.new(1937,5,15), true)

plane_tbl.drop_column(:speed)

puts plane_tbl.select.to_report
