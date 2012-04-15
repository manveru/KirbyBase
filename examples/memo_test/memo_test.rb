# This script is an example of how you can use KirbyBase's new Memo field
# type.

require 'kirbybase'

db = KirbyBase.new { |d| d.memo_blob_path = './memos' }

#db = KirbyBase.new(:client, 'localhost', 44444)    


# If table exists, delete it.
db.drop_table(:plane) if db.table_exists?(:plane)

# Create a table.
plane_tbl = db.create_table(:plane, :name, :String, :country, :String, 
 :speed, :Integer, :range, :Integer, :descr, :Memo)

# Create a long string field with embedded newlines for the memo contents.
memo_string = <<END_OF_STRING
The P-51 Mustang was the premier Allied fighter aircraft of World War II.
It's performance and long range allowed it to escort Allied strategic
bombers on raids deep inside Germany.
END_OF_STRING

# Create an instance of KBMemo for the memo field.
memo = KBMemo.new(db, 'P-51.txt', memo_string)

# Insert the new record, including the memo field.
plane_tbl.insert('P-51', 'USA', 403, 1201, memo)
 
# Insert another record. 
memo_string = <<END_OF_STRING
The FW-190 was a World War II German fighter.  It was used primarily as an
interceptor against Allied strategic bombers.
END_OF_STRING

memo = KBMemo.new(db, 'FW-190.txt', memo_string)
plane_tbl.insert('FW-190', 'Germany', 399, 499, memo)

# Select all records, print name, country, speed and range on first line.
# Then, print contents of memo field below.
plane_tbl.select.each { |r|
    puts "Name: %s  Country: %s  Speed: %d  Range: %d\n\n" % [r.name, 
     r.country, r.speed, r.range]
    puts r.descr.contents
    puts "\n" + "-" * 75 + "\n\n"
}


puts "\n\nNow we will change the memo for the P-51:\n\n"

# Grab the P-51's record.
rec = plane_tbl.select { |r| r.name == 'P-51' }.first

# Grab the contents of the memo field and add a line to it.
memo = rec.descr
memo.contents += "This last line should show up if the memo was changed.\n"

# Now, update the record with the changed contents of the memo field.
plane_tbl.update {|r| r.name == 'P-51'}.set(:descr => memo)

# Do another select to show that the memo field indeed changed.
puts plane_tbl.select { |r| r.name == 'P-51' }.first.descr.contents


puts "\n\nNow we will change every record's memo field:\n\n"

plane_tbl.update_all { |r|
    r.descr.contents += "I have added a line to the %s memo.\n\n" % r.name
}

# Do another select to show that the memo field for each record has
# indeed changed.
plane_tbl.select.each { |r| puts r.descr.contents }
