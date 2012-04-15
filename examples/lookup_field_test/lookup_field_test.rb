# This script demonstrates how to link a field in the table to an entire
# record from another table (i.e. a "one to one" relationship in database
# lingo).

# In the example below, we have a department table.  For each department
# record, the manager field is actually a reference to a record from the
# person table. This allows us to reference the linked person record
# through the manager field.

require 'kirbybase'

db = KirbyBase.new

# To run as a client in a multi-user environment, uncomment next line.
# Also, make sure kbserver.rb is running.
#db = KirbyBase.new do |d|
#    d.connect_type = :client
#    d.host = 'localhost'
#    d.port = 44444
#end

# If tables exists, delete them.
db.drop_table(:department) if db.table_exists?(:department)
db.drop_table(:person) if db.table_exists?(:person)

# Create a person table. Create lookup table first before the table that
# uses the lookup table, so that KirbyBase can take advantage of any
# indexes.
person_tbl = db.create_table(:person,
 :person_id, :String,
 :name, :String,
 :phone, :String
)

# Insert some person records.
person_tbl.insert('000-13-5031', 'John Smith', '512.555.1234')
person_tbl.insert('010-10-9999', 'Jane Doe', '313.724.4230')

# Create a table.  We are telling KirbyBase that the manager field is
# to be linked to the person table.
department_tbl = db.create_table(:department,
 :dept_id, :Integer,
 :dept_name, :String,
 :manager, {:DataType=>:String, :Lookup=>[:person, :person_id]})

# Insert some department records.
department_tbl.insert(345, 'Payroll', '000-13-5031')
department_tbl.insert(442, 'Accounting', '010-10-9999')

# Print department info.  Notice how we also print info from the linked
# person record.
department_tbl.select.each do |r|
    puts "\n%s %s %s %s %s" % [r.dept_id, r.dept_name,
     r.manager.person_id, r.manager.name, r.manager.phone]
end
