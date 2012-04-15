# This script is an example of how to rename a table.
#
require 'kirbybase'

db = KirbyBase.new

# If tables exist, delete them.
db.drop_table(:address_book) if db.table_exists?(:address_book)
db.drop_table(:contact_list) if db.table_exists?(:contact_list)

address_book_tbl = db.create_table(:address_book,
 :firstname, :String, :lastname, :String, :street_address, :String,
 :city, :String, :phone, :String, :category, :String
)

# Insert some contact info records.
address_book_tbl.insert('Bruce', 'Wayne', '1234 Bat Cave', 'Gotham City',
 '111-111-1111', 'Super Hero')
address_book_tbl.insert('Bugs', 'Bunny', '1234 Rabbit Hole', 'The Forest',
 '222-222-2222', 'Cartoon Character')
address_book_tbl.insert('George', 'Bush', '1600 Pennsylvania Ave',
 'Washington', '333-333-3333', 'President')
address_book_tbl.insert('Silver', 'Surfer', '1234 Galaxy Way',
 'Any City', '444-444-4444', 'Super Hero')

address_book_tbl.select { |r| r.category == 'Super Hero' }.each { |r|
    puts '%s %s %s' % [r.firstname, r.lastname, r.phone]
}
puts;puts

contact_list_tbl = db.rename_table(:address_book, :contact_list)

contact_list_tbl.select { |r| r.category == 'Super Hero' }.each { |r|
    puts '%s %s %s' % [r.firstname, r.lastname, r.phone]
}
puts;puts

p db.tables
