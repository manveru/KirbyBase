# This script demonstrates how to link a field in the table to an entire
# record from another table (sometimes called a "lookup table").  This
# script is different from 'lookup_field_test.rb' because it shows how to
# use the "lookup_key" table attribute to make it easier to define a
# Lookup field.

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
# indexes.  Also, we want to create the lookup table first so that we can
# define a lookup key.  We do this by adding a :Key entry to the field type
# has and assigning true to it's value.
person_tbl = db.create_table(:person,
 :person_id, {:DataType=>:String, :Key=>true},
 :name, :String,
 :phone, :String
)

# Insert some person records.
person_tbl.insert('000-13-5031', 'John Smith', '512.555.1234')
person_tbl.insert('010-10-9999', 'Jane Doe', '313.724.4230')

# Create a table.  We are telling KirbyBase that the manager field is
# to be linked to the person table.  Notice that in this example, since we
# want the manager field in this table to be linked to the person_id in the
# person table, which is that table's lookup key field, all we have to
# specify here is the name of the lookup table, :person.
department_tbl = db.create_table(:department,
 :dept_id, :Integer,
 :dept_name, :String,
 :manager, {:DataType=>:String, :Lookup=>:person})

# Insert some department records.
department_tbl.insert(345, 'Payroll', '000-13-5031')
department_tbl.insert(442, 'Accounting', '010-10-9999')

# Print department info.  Notice how we also print info from the linked
# person record.
department_tbl.select.each do |r|
    puts "\n%s %s %s %s %s" % [r.dept_id, r.dept_name,
     r.manager.person_id, r.manager.name, r.manager.phone]
end
