# This script is an example of how to drop an index from an existing table.
#
require 'kirbybase'

db = KirbyBase.new

# If table exists, delete it.
db.drop_table(:address_book) if db.table_exists?(:address_book)

address_book_tbl = db.create_table(:address_book,
 :firstname, {:DataType=>:String, :Index=>1},
 :lastname, {:DataType=>:String, :Index=>1},
 :street_address, :String,
 :city, :String,
 :phone, :String,
 :category, {:DataType=>:String, :Index=>2}
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

p address_book_tbl.field_indexes
puts;puts

address_book_tbl.select_by_category_index { |r|
 r.category == 'Super Hero' }.each { |r|
    puts '%s %s %s' % [r.firstname, r.lastname, r.phone]
}
puts;puts

address_book_tbl.drop_index(:category)

begin
    address_book_tbl.select_by_category_index { |r|
     r.category == 'Super Hero' }.each { |r|
        puts '%s %s %s' % [r.firstname, r.lastname, r.phone]
    }
rescue StandardError => e
    puts e
    puts;puts
end

# Select Bugs Bunny using the firstname+lastname index.
address_book_tbl.select_by_firstname_lastname_index { |r|
    r.firstname == 'Bugs' and r.lastname == 'Bunny'
}.each { |r| puts '%s %s %s' % [r.firstname, r.lastname, r.phone] }

address_book_tbl.drop_index(:firstname, :lastname)

begin
    address_book_tbl.select_by_firstname_lastname_index { |r|
        r.firstname == 'Bugs' and r.lastname == 'Bunny'
    }.each { |r| puts '%s %s %s' % [r.firstname, r.lastname, r.phone] }
rescue StandardError => e
    puts e
    puts;puts
end

p address_book_tbl.field_indexes