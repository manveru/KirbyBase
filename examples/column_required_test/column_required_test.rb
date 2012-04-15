# This script is an example of how to specify that a value is required for a
# column.
#
require 'kirbybase'

db = KirbyBase.new

# If table exists, delete it.
db.drop_table(:address_book) if db.table_exists?(:address_book)

# Create a table.  Notice how we specify a default value for :category.
address_book_tbl = db.create_table(:address_book,
 :firstname, :String, :lastname, :String, :street_address, :String,
 :city, :String, :phone, :String, 
 :category, {:DataType=>:String, :Required=>true})

begin
    # Insert a record.  Notice that I am passing nil for :category.  This
    # will cause KirbyBase to raise an exception.
    address_book_tbl.insert('Bruce', 'Wayne', '1234 Bat Cave',
     'Gotham City', '111-111-1111', nil)
rescue StandardError => e
    puts e
    puts;puts
end

begin
    # Same thing should happen if I don't even specify a value for
    # :category.
    address_book_tbl.insert(:firstname=>'Bruce', :lastname=>'Wayne', 
     :street_addres=>'1234 Bat Cave', :city=>'Gotham City', 
     :phone=>'111-111-1111')
rescue StandardError => e
    puts e
    puts;puts
end

# Now, let's turn off the required flag for :category.
address_book_tbl.change_column_required(:category, false)

# And we will attempt to add the record again.
address_book_tbl.insert('Bruce', 'Wayne', '1234 Bat Cave',
 'Gotham City', '111-111-1111', nil)

