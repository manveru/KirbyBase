#Simple test of KirbyBase.

require 'kirbybase'
require 'date'

def print_divider(text)
    puts
    puts text.center(75, '-')
    puts
end

#-------------------- Initialize KirbyBase Instance ------------------------
# To run local, single-user, uncomment next line.
db = KirbyBase.new 

# To run as a client in a multi-user environment, uncomment next line.
# Also, make sure kbserver.rb is running.
#db = KirbyBase.new do |d|
#    d.connect_type = :client
#    d.host = 'localhost'
#    d.port = 44444
#end

#----------------------- Drop Table Example --------------------------------
# If table exists, delete it.
db.drop_table(:plane) if db.table_exists?(:plane)

#----------------------- Create Table Example ------------------------------
# Create a table.
plane_tbl = db.create_table(:plane, :name, :String, :country, :String,
 :role, :String, :speed, :Integer, :range, :Integer, :began_service, :Date,
 :still_flying, :Boolean) { |obj| obj.encrypt = false }

#----------------------- Insert Record Examples ----------------------------
# Four different ways to insert records in KirbyBase.

# 1) Insert a record using an array for the input values.
plane_tbl.insert('FW-190', 'Germany', 'Fighter', 399, 499,
 Date.new(1942,12,1), false)

# 2) Insert a record using a hash for the input values.
plane_tbl.insert(:name => 'P-51', :country => 'USA',
 :role => 'Fighter', :speed => 403, :range => 1201,
 :began_service => Date.new(1943,6,24), :still_flying => true)

# 3) Insert a record using a Struct for the input values.
InputRec = Struct.new(:name, :country, :role, :speed, :range,
 :began_service, :still_flying)
rec = InputRec.new('P-47', 'USA', 'Fighter', 365, 888, Date.new(1943,3,12),
 false)
plane_tbl.insert(rec)

# 4) Insert a record using a code block for the input values.
plane_tbl.insert { |r|
    r.name = 'B-17'
    r.country = 'USA'
    r.role = 'Bomber'
    r.speed = 315
    r.range = r.speed * 3
    r.began_service = Date.new(1937, 5, 1)
    r.still_flying = true
}

# If a table is already existing and you need to get a reference to it so
# that you can insert, select, etc., just do a get_table.
plane_tbl_another_reference = db.get_table(:plane)

# Then, you can use it just like you have been using the reference you got
# when you created the table.
plane_tbl_another_reference.insert('Typhoon', 'Great Britain',
 'Fighter-Bomber', 389, 690, Date.new(1944,11,20), false)

# Insert a bunch more records so we can have some "select" fun below.
plane_tbl.insert('Spitfire', 'Great Britain', 'Fighter', 345, 540,
 Date.new(1939,2,18), true)
plane_tbl.insert('Oscar', 'Japan', 'Fighter', 361, 777,
 Date.new(1943,12,31), false)
plane_tbl.insert('ME-109', 'Germany', 'Fighter', 366, 514,
 Date.new(1936,7,7),true)
plane_tbl.insert('JU-88', 'Germany', 'Bomber', 289, 999,
 Date.new(1937,1,19), false)
plane_tbl.insert('P-39', 'USA', 'Fighter', nil, nil,
 nil, false)
plane_tbl.insert('Zero', 'Japan', 'Fighter', 377, 912,
 Date.new(1937,5,15), true)
plane_tbl.insert('B-25', 'USA', '', 320, 1340, Date.new(1940,4,4), true)

#--------------------- Update Examples -------------------------------------
# Four different ways to update existing data in KirbyBase.  In all three
# instances, you still need a code block attached to the update method in
# order to select records that will be updated.

# 1) Update record using a Hash, Struct, or an Array.
plane_tbl.update(:speed => 405, :range => 1210) { |r| r.name == 'P-51' }

# 2) Update record using a Hash, Struct, or an Array, via the set
#    command.
plane_tbl.update {|r| r.name == 'P-51'}.set(:speed => 405, :range => 1210)

# 3) Update record by treating table as if it were a Hash and the keys were
#    recno's.
plane_tbl[2] = {:speed => 405, :range => 1210}

# 4) Update record using a code block, via the set command.  Notice how you
#    have access to the current record's values within the block.
plane_tbl.update {|r| r.name == 'P-51'}.set {|r|
    r.speed = r.speed+7
    r.range = r.range-2
}

#--------------------- Delete Examples -------------------------------------
# Delete 'FW-190' record.
plane_tbl.delete { |r| r.name == 'FW-190' }

#---------------------- Select Example 0 -----------------------------------
print_divider('Select Example 0')
# Select all records, including all fields in result set.
plane_tbl.select.each { |r|
    puts(('%s ' * r.members.size) % r.to_a)
}

#-------------------------- Select Example 1 -------------------------------
print_divider('Select Example 1')
# Select all Japanese planes. Include just name and speed in the result.
plane_tbl.select(:name, :speed) { |r| r.country == 'Japan' }.each { |r|
    puts '%s %s' % [r.name, r.speed]
}

#-------------------------- Select Example 2 -------------------------------
print_divider('Select Example 2')
# Select all US planes with a speed greater than 350mph. Include just name
# and speed in result set.
plane_tbl.select(:name, :speed) { |r|
    r.country == 'USA' and r.speed > 350
}.each { |r| puts '%s %s' % [r.name, r.speed] }

#-------------------------- Select Example 3 -------------------------------
print_divider('Select Example 3')
# Select all Axis fighters.
plane_tbl.select { |r|
    (r.country == 'Germany' or r.country == 'Japan') and r.role == 'Fighter'
}.each { |r| puts r }

#-------------------------- Select Example 4 -------------------------------
print_divider('Select Example 4')
# Same query as above, but let's use regular expressions instead of an 'or'.
plane_tbl.select { |r|
    r.country =~ /Germany|Japan/ and r.role == 'Fighter'
}.each { |r| puts r }

#-------------------------- Select Example 5 -------------------------------
print_divider('Select Example 5')
# Select all Bombers (but not Fighter-Bombers) and return only their name
# and country.  This is also an example of how to get a reference to an
# existing table as opposed to already having a reference to one via the
# table_create method.
match_role = /^Bomber/
plane_tbl2 = db.get_table(:plane)
plane_tbl2.select(:name, :country) { |r| r.role =~ match_role }.each { |r|
    puts '%s %s' % r.to_a
}

#-------------------------- Select Example 6 -------------------------------
print_divider('Select Example 6')
# Select all planes.  Include just name, country, and speed in result set.
# Sort result set by country (ascending) then name (ascending).
plane_tbl.select(:name, :country, :speed).sort(:country,
 :name).each { |r| puts "%s %s %d" % r.to_a }

#-------------------------- Select Example 7 -------------------------------
print_divider('Select Example 7')
# Select all planes.  Include just name, country, and speed in result set.
# Return result set as a nicely formatted report, sorted by
# country (ascending) then speed (descending).
puts plane_tbl.select(:name, :country, :speed).sort(+:country,
 -:speed).to_report

#-------------------------- Select Example 8 -------------------------------
print_divider('Select Example 8')
# Select planes that are included in nameArray.
nameArray = ['P-51', 'Spitfire', 'Zero']
plane_tbl.select { |r| nameArray.include?(r.name) }.each { |r| puts r }

#-------------------------- Select Example 9 -------------------------------
print_divider('Select Example 9')
# You can select a record as if the table is a hash and it's keys are the
# recno's.
# Select the record that has a recno of 5.
puts plane_tbl[5].name

#-------------------------- Select Example 10 -------------------------------
print_divider('Select Example 10')
# You can even have a select within the code block of another select.  Here
# we are selecting all records that are from the same country as the Zero.
puts plane_tbl.select { |r|
    r.country == plane_tbl.select { |x| x.name == 'Zero' }.first.country
}

#-------------------------- Select Example 11 -------------------------------
print_divider('Select Example 11')
# Select all planes.
plane_tbl.select.each { |r| puts r }

#-------------------------- Select Example 12 -------------------------------
print_divider('Select Example 12')
# Select all planes with a speed of nil.

#**************** Note:  This example also demonstrates the change from
# nil to kb_nil for KirbyBase's internal representation of a nil value.  You
# should only encounter this different if you have to check for nil in your
# query, as this example does.  Other than that, everything else should
# be transparent, since KirbyBase converts a kb_nil back into a nil when it
# returns a query's result set.
#***************
plane_tbl.select { |r| r.speed.kb_nil? }.each { |r| puts r }

#-------------------------- Select Example 13 -------------------------------
print_divider('Select Example 13')
# Same thing, but in a slightly different way.

#**************** Note:  This example also demonstrates the change from
# nil to kb_nil for KirbyBase's internal representation of a nil value.  You
# should only encounter this different if you have to check for nil in your
# query, as this example does.  Other than that, everything else should
# be transparent, since KirbyBase converts a kb_nil back into a nil when it
# returns a query's result set.
#***************
plane_tbl.select { |r| r.speed == kb_nil }.each { |r| puts r }

#-------------------------- Misc. Methods Examples -------------------------
print_divider('Misc. Methods Examples')
puts 'Total # of records in table: %d' % plane_tbl.total_recs
puts
puts 'Fields for plane.tbl:'
plane_tbl.field_names.zip(plane_tbl.field_types).each { |r|
    print r[0].to_s.ljust(15), r[1].to_s, "\n"
}
