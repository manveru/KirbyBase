# This script demonstrates how to use crosstab functionality of a
# KirbyBase result set.  A KirbyBase result set automatically has an
# equivalent transposed array whereby all of the values of a column are
# available.  I call this a crosstab, but I am probably using this term
# incorrectly.  Perhaps the examples below will help explain what I am
# talking about.

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

# If tables exists, delete it.
db.drop_table(:order) if db.table_exists?(:order)
db.drop_table(:order_item) if db.table_exists?(:order_item)

# Create an order item table.  This is the child table to the order table.
# Make sure you create the child table BEFORE you create the parent table
# so that KirbyBase can take advantage of any indexes that you have defined.
order_item_tbl = db.create_table(:order_item,
 :item_id, :Integer,
 :order_id, :Integer,
 :descr, :String,
 :qty, :Integer,
 :price, :Float,
 :total, {:DataType=>:Float, :Calculated=>'qty*price'}
)

# Create an order table.  We are telling KirbyBase that the items field is
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
order_item_tbl.insert(1,345,'Steel',30,19.99,nil)
order_item_tbl.insert(2,345,'Glass',5,4.15,nil)
order_item_tbl.insert(5,454,'Floppies',750000,0.5,nil)
order_item_tbl.insert(3,17,'Wheels',200,2500.0,nil)
order_item_tbl.insert(4,17,'Wings',25,1000000.0,nil)


# Print all orders.  Under each order print all items in that order.  Notice
# that we are able to print the total for each order because we have access
# to the entire order_items.total column of the result set.  We don't have
# to loop through all of the order item result set records to add up the
# total for each order.
puts "\nPrint all orders:\n"
order_tbl.select.each do |r|
    puts "\nid: %3d  customer: %-10s  total charge: %11.2f" % [r.order_id,
     r.customer, r.items.total.inject { |sum, n| sum + n }]

    r.items.each do |i|
        puts "\titem:  %-10s %6d * %10.2f = %11.2f" % [i.descr,
         i.qty, i.price, i.total]
    end
end
puts '-' * 70;puts

# You can even use the ability to access an entire column of values in your
# select statements.  In this example, we only want to select those orders
# whose total charges exceeds $100,000.  We can do this because we have
# access to the entire total column of the child table, order items.
puts "Print only orders whose total charge exceeds $100,000:\n"
order_tbl.select { |r| r.items.total.inject { |sum, n| sum+n } > 100000
 }.each do |r|
    puts "\nid: %3d  customer: %-10s  total charge: %11.2f" % [r.order_id,
     r.customer, r.items.total.inject { |sum, n| sum + n }]

    r.items.each do |i|
        puts "\titem:  %-10s %6d * %10.2f = %11.2f" % [i.descr,
         i.qty, i.price, i.total]
    end
end
