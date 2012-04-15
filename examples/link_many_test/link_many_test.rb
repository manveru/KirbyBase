# This script demonstrates how to link a field in the table to a subset
# of records from another table (i.e. a "one to many" link in database
# lingo).

# In this example, we have an order table and an order_item table.  Each
# record in the order table represents a customer order.  The order_item
# table holds the detail items for each order. We create a one-to-many link
# between the order table and the order_item table by providing extra
# information about the order.items field when we create the order table.

require 'kirbybase'

db = KirbyBase.new

# To run as a client in a multi-user environment, uncomment next line.
# Also, make sure kbserver.rb is running.
#db = KirbyBase.new do |d|
#    d.connect_type = :client
#    d.host = 'localhost'
#    d.port = 44444
#end

# If table exists, delete it.
db.drop_table(:order) if db.table_exists?(:order)
db.drop_table(:order_item) if db.table_exists?(:order_item)

# Create an order item table.  This is the child table to the order table.
# Create child table before creating parent table so that KirbyBase can
# take advantage of any indexes.
order_item_tbl = db.create_table(:order_item,
 :item_id, :Integer,
 :order_id, :Integer,
 :descr, :String,
 :qty, :Integer,
 :price, :Float
)

# Create a table.  We are telling KirbyBase that the items field is
# to be linked to the order_item table by comparing the order.order_id
# field to the order_item.order_id field.  By specifying :Link_many, we are
# telling KirbyBase to make this a one-to-many link.  The result of this is
# that when you do a select, the items field of the order table is going to
# hold a reference to a ResultSet (i.e. Array) holding all order_item
# records whose order_id field match the order_id field in the order record.
order_tbl = db.create_table(:order,
 :order_id, :Integer,
 :customer, :String,
 :items, {:DataType=> :ResultSet, :Link_many=> [:order_id, :order_item,
 :order_id]}
)

# Insert some order records.
order_tbl.insert({:order_id=>345, :customer=>'Ford'})
order_tbl.insert({:order_id=>454, :customer=>'Microsoft'})
order_tbl.insert({:order_id=>17, :customer=>'Boeing'})

# Insert some order item records.
order_item_tbl.insert(1,345,'Steel',30,19.99)
order_item_tbl.insert(2,345,'Glass',5,4.15)
order_item_tbl.insert(5,454,'Floppies',750000,0.5)
order_item_tbl.insert(3,17,'Wheels',200,2500.0)
order_item_tbl.insert(4,17,'Wings',25,1000000.0)

# Print all orders.  Under each order print all items in that order.
order_tbl.select.each do |r|
    puts '%3d %s' % [r.order_id, r.customer]
    r.items.each { |i|
        puts "\t%d %15s %6d %10.2f" % [i.item_id, i.descr, i.qty, i.price]
    }
end
