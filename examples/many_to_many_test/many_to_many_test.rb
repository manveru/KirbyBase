# This script demonstrates how you could do many-to-many relationships in 
# KirbyBase.

require 'kirbybase'

db = KirbyBase.new

# Delete tables if they already exist.
db.drop_table(:author) if db.table_exists?(:author)
db.drop_table(:book) if db.table_exists?(:book)
db.drop_table(:book_author) if db.table_exists?(:book_author)

# Create author table.  Notice how we are creating a one-to-many link to
# the book_author table.
author_tbl = db.create_table(:author,
 :author_id, :Integer, :name, :String,
 :books, {:DataType=>:ResultSet, 
          :Link_many=>[:author_id, :book_author, :author_id]}
)

# Create book table.  Notice how we are creating a one-to-many link to
# the book_author table.
book_tbl = db.create_table(:book,
 :book_id, :Integer, :title, :String,
 :authors, {:DataType=>:ResultSet, 
            :Link_many=>[:book_id, :book_author, :book_id]}
)

# Create join table that will connect author table and book table.
book_author_tbl = db.create_table(:book_author, :book_id, :Integer,
 :author_id, :Integer)

# Insert some author records.
author_tbl.insert(1, 'Jules Verne', nil)
author_tbl.insert(2, 'Margaret Weis', nil)
author_tbl.insert(3, 'Tracy Hickman', nil)

# Insert some book records.
book_tbl.insert(1, 'Voyage to the Bottom of the Sea', nil)
book_tbl.insert(2, 'From the Earth to the Moon', nil)
book_tbl.insert(3, 'Dragons of Winter Night', nil)
book_tbl.insert(4, 'The Nightmare Lands', nil)

# Insert some records into the book_author table that will link the book
# table to the author table.
book_author_tbl.insert(1, 1)
book_author_tbl.insert(2, 1)
book_author_tbl.insert(3, 2)
book_author_tbl.insert(3, 3)
book_author_tbl.insert(4, 2)
book_author_tbl.insert(4, 3)


# Show all book titles written by Jules Verne.
author_tbl.select { |r| r.name == 'Jules Verne' 
 }.first.books.each { |b| 
    puts book_tbl.select { |r| r.book_id == b.book_id }.first.title
}
puts

# Show the authors of "The Nightmare Lands".
book_tbl.select { |r| r.title == 'The Nightmare Lands' 
 }.first.authors.each { |a| 
    puts author_tbl.select { |r| r.author_id == a.author_id }.first.name
}    
