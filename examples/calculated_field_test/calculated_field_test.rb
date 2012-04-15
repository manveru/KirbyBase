# This example script shows how to specify calculated fields in a KirbyBase
# table.  Calculated fields are "virtual" fields.  They do not really exist
# in the table, but are calculated during a select query.  However, once
# calculated, they behave just like "real" table fields.

# In this example, we will create an expenses table that holds information
# on recent purchases.  The total_cost field is a calculated field.  We tell
# KirbyBase how to calculate it's value, i.e. by multiplying the quantity
# field by the price field.

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
db.drop_table(:expenses) if db.table_exists?(:expenses)

# Create a table.
expenses_tbl = db.create_table(:expenses,
 :transaction_date, :Date,
 :description, :String,
 :quantity, :Integer,
 :price, :Float,
 :total_cost, {:DataType=>:Float, :Calculated=>'quantity * price'}
)

# Insert a couple of expense records.
expenses_tbl.insert({:transaction_date => Date.new(2005, 9, 7),
 :description => 'Pencils', :quantity => 100, :price => 0.50})
expenses_tbl.insert({:transaction_date => Date.new(2005, 9, 8),
 :description => 'Books', :quantity => 3, :price => 45.0})

# Select all records and send the result to the screen in report format.
# Notice how the total_cost field for each record has been calculated for
# you by multiplying price times quantity.
puts "\nSelect all records:\n\n"
puts expenses_tbl.select.to_report

# And, you can even use a calculated field in your select condition.  Here
# we are only selecting records whose total cost is greater than $100.
puts "\n\nSelect only records with a total cost greater than $100:\n\n"
puts expenses_tbl.select { |r| r.total_cost > 100.00 }.to_report
