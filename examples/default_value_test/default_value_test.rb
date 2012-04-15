# This script is an example of how to specify a default value for a column.
#
require 'kirbybase'

db = KirbyBase.new

# If table exists, delete it.
db.drop_table(:address_book) if db.table_exists?(:address_book)

# Create a table.  Notice how we specify a default value for :category.
address_book_tbl = db.create_table(:address_book,
 :firstname, :String, :lastname, :String, :street_address, :String,
 :city, :String, :phone, :String, 
 :category, {:DataType=>:String, :Default=>'Super Hero'})

# Insert a record.  Notice that I am not passing a value for :category.  
# KirbyBase will insert the default value, 'Super Hero', in that field.
address_book_tbl.insert(:firstname=>'Bruce', :lastname=>'Wayne', 
 :street_address=>'1234 Bat Cave', :city=>'Gotham City',
 :phone=>'111-111-1111')

# Insert another record.  Here we supply the value for :category, so
# KirbyBase will use it instead of the default.
address_book_tbl.insert(:firstname=>'Bugs', :lastname=>'Bunny', 
 :street_address=>'1234 Rabbit Hole', :city=>'The Forest',
 :phone=>'222-222-2222', :category=>'Cartoon Character')
 
# Insert another record.  Here we explicitly supply nil as the value for
# category.  KirbyBase will not override this with the default value 
# because we explicitly specified nil as the value.
address_book_tbl.insert(:firstname=>'Super', :lastname=>'Man',
 :street_address=>'1234 Fortress of Solitude', :city=>'Metropolis',
 :phone=>'333-333-3333', :category=>nil) 

# Now lets change the default value for :category to 'President'.
address_book_tbl.change_column_default_value(:category, 'President')

# And let's add another record without supplying a value for :category.
address_book_tbl.insert(:firstname=>'George', :lastname=>'Bush',
 :street_address=>'1600 Pennsylvania Ave', :city=>'Washington', 
 :phone=>'333-333-3333')

# Now, let's remove the default value for :category
address_book_tbl.change_column_default_value(:category, nil)

# And add another record.  We won't specify a value for :category and,
# KirbyBase will not use a default value, because we removed it.
address_book_tbl.insert(:firstname=>'Silver', :lastname=>'Surfer', 
 :street_address=>'1234 Galaxy Way', :city=>'Any City', 
 :phone=>'444-444-4444')

# Now lets print the table out and you will see how all of the defaults
# worked.
puts address_book_tbl.select.to_report
