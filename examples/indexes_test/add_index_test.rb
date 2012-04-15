# This script is an example of how to add an index to an existing table.
#
require 'kirbybase'

db = KirbyBase.new

# If table exists, delete it.
db.drop_table(:address_book) if db.table_exists?(:address_book)

address_book_tbl = db.create_table(:address_book,
 :firstname, :String, :lastname, :String, :street_address, :String,
 :city, :String, :phone, :String, :category, :String)

# Insert some contact info records.
address_book_tbl.insert('Bruce', 'Wayne', '1234 Bat Cave', 'Gotham City',
 '111-111-1111', 'Super Hero')
address_book_tbl.insert('Bugs', 'Bunny', '1234 Rabbit Hole', 'The Forest',
 '222-222-2222', 'Cartoon Character')
address_book_tbl.insert('George', 'Bush', '1600 Pennsylvania Ave',
 'Washington', '333-333-3333', 'President')
address_book_tbl.insert('Silver', 'Surfer', '1234 Galaxy Way',
 'Any City', '444-444-4444', 'Super Hero')

# Select all super heros without using the index.
address_book_tbl.select { |r| r.category == 'Super Hero' }.each { |r|
    puts '%s %s %s' % [r.firstname, r.lastname, r.phone]
}
puts;puts

address_book_tbl.add_index(:category)

# Now, do the same query, but use the category index.  These
# select_by_index methods are automatically created by KirbyBase when you
# specify that a column be indexed.
address_book_tbl.select_by_category_index { |r|
 r.category == 'Super Hero' }.each { |r|
    puts '%s %s %s' % [r.firstname, r.lastname, r.phone]
}
puts;puts

address_book_tbl.add_index(:firstname, :lastname)

# Select Bugs Bunny using the firstname+lastname index.
address_book_tbl.select_by_firstname_lastname_index { |r|
    r.firstname == 'Bugs' and r.lastname == 'Bunny'
}.each { |r| puts '%s %s %s' % [r.firstname, r.lastname, r.phone] }
