# This script is an example of how to use indexes in KirbyBase.  Indexes
# allow for faster queries on large datasets.
#
# To use indexes, you must first specify which fields are to be indexed.
# You do this at table creation time.  Both single and compound indexes can
# be created.  Then, when performing a select query, you simply use the
# automatically created select_by_?????_index method, where ????? is
# replaced by the name(s) of the indexed field(s).  That's it.  Everything
# else concerning building and maintaing indexes is done by KirbyBase.
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
db.drop_table(:address_book) if db.table_exists?(:address_book)

# Here we are creating a table to hold contact info.  We are going to create
# two indexes.  One index is going to be a compound index containing the
# firstname and lastname fields.  Notice how we group the firstname and
# lastname fields into one index by specifying :Index=>1 for both of them.
# This just tells KirbyBase that the two fields should be combined into one
# compound index because they both are using the same index number.  The
# second index is going to be a single index containing the category field.
# Since we want it to be a separate index, we simply use the next available
# number, 2, as the value of it's :Index key.
address_book_tbl = db.create_table(:address_book,
 :firstname, {:DataType=>:String, :Index=>1},
 :lastname, {:DataType=>:String, :Index=>1},
 :street_address, :String,
 :city, :String,
 :phone, :String,
 :category, {:DataType=>:String, :Index=>2},
 :age, {:DataType=>:Integer, :Index=>3}
)

# Insert some contact info records.
address_book_tbl.insert('Bruce', 'Wayne', '1234 Bat Cave', 'Gotham City',
 '111-111-1111', 'Super Hero', 39)
address_book_tbl.insert('Bugs', 'Bunny', '1234 Rabbit Hole', 'The Forest',
 '222-222-2222', 'Cartoon Character', 12)
address_book_tbl.insert('George', 'Bush', '1600 Pennsylvania Ave',
 'Washington', '333-333-3333', 'President', 2)
address_book_tbl.insert('Silver', 'Surfer', '1234 Galaxy Way',
 'Any City', '444-444-4444', 'Super Hero', 199)
address_book_tbl.insert('John', 'Doe', '1234 Robin Lane', 'Detroit',
 '999-999-9999', nil, 54)
address_book_tbl.insert(nil, 'NoFirstName', 'Nowhere Road', 'Notown',
 '000-000-0000', 'Nothing', nil)

# Select all super heros without using the index.
address_book_tbl.select { |r| r.category == 'Super Hero' }.each { |r|
    puts '%s %s %s' % [r.firstname, r.lastname, r.phone]
}
puts;puts
# Now, do the same query, but use the category index.  These
# select_by_index methods are automatically created by KirbyBase, based on
# the indexes you specified at table creation.
address_book_tbl.select_by_category_index { |r|
 r.category == 'Super Hero' }.each { |r|
    puts '%s %s %s' % [r.firstname, r.lastname, r.phone]
}
puts;puts
# Select Bugs Bunny using the firstname+lastname index.
address_book_tbl.select_by_firstname_lastname_index { |r|
    r.firstname == 'Bugs' and r.lastname == 'Bunny'
}.each { |r| puts '%s %s %s' % [r.firstname, r.lastname, r.phone] }

puts;puts
# Select the guy with no first name using the firstname+lastname index.
address_book_tbl.select_by_firstname_lastname_index { |r|
    r.lastname == 'NoFirstName'
}.each { |r| puts '%s %s %s' % [r.firstname, r.lastname, r.phone] }

puts;puts
# Select the guy with no first name using the firstname+lastname index.
# This time we will explicitly say firstname should be nil
address_book_tbl.select_by_firstname_lastname_index { |r|
    r.firstname.nil? and r.lastname == 'NoFirstName'
}.each { |r| puts '%s %s %s' % [r.firstname, r.lastname, r.phone] }

puts;puts
address_book_tbl.select_by_age_index { |r| r.age > 30 }.each { |r|
 puts '%s %s %d' % [r.firstname, r.lastname, r.age] }
 
puts;puts
p address_book_tbl.field_indexes
