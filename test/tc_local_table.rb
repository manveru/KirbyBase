$:.unshift File.join(File.dirname(__FILE__), "..", "lib")

require "test/unit"
require "kirbybase"
require "base_test"

class TestTableLocal < Test::Unit::TestCase

	include BaseTest

    def test_table_name
		tbl = @db.create_table(:empty) { |t| t.encrypt = @encrypted }
        assert_equal(:empty, tbl.name)
    end

    def test_table_filename
		tbl = @db.create_table(:empty) { |t| t.encrypt = @encrypted }
        assert_equal(table_fname('empty'), tbl.filename)
    end

    def test_table_field_names
		tbl = @db.create_table(:empty, :one, :String, :two, :Integer) { |t|
         t.encrypt = @encrypted }
        assert_equal([:recno, :one, :two], tbl.field_names)
    end

    def test_table_field_types
		tbl = @db.create_table(:empty, :one, :String, :two, :Integer) { |t|
         t.encrypt = @encrypted }
        assert_equal([:Integer, :String, :Integer], tbl.field_types)
    end

    def test_table_field_indexes
		tbl = @db.create_table(:empty, :one, {:DataType=>:String,
         :Index=>1}, :two, {:DataType=>:Integer, :Index=>2}, :three,
         {:DataType=>:Integer, :Index=>1}, :four, :String) { |t|
         t.encrypt = @encrypted }
        assert_equal([nil, 'Index->1', 'Index->2', 'Index->1', nil],
         tbl.field_indexes)
    end

    def test_table_field_defaults_001
		tbl = @db.create_table(:empty, :one, {:DataType=>:String,
         :Default=>'one'}, :two, :Integer, :three, {:DataType=>:Integer,
         :Default=>3}) { |t| t.encrypt = @encrypted }
        assert_equal([nil, 'one', nil, 3], tbl.field_defaults)
    end

    def test_table_field_defaults_002
		assert_raise(RuntimeError) { @db.create_table(:empty, :one,
         {:DataType=>:String, :Default=>'one'}, :two, :Integer, :three,
         {:DataType=>:Integer, :Default=>'3'}) { |t|
         t.encrypt = @encrypted } }
    end

    def test_table_field_requireds_001
		tbl = @db.create_table(:empty, :one, {:DataType=>:String,
         :Required=>true}) { |t| t.encrypt = @encrypted }
        assert_equal([false, true], tbl.field_requireds)
    end

    def test_table_field_requireds_002
		assert_raise(RuntimeError) { @db.create_table(:empty, :one,
         {:DataType=>:String, :Required=>'true'}) { |t|
         t.encrypt = @encrypted } }
    end

	def test_pack_table
		num_records = 50
		tbl = @db.create_table(:count, :number, :Integer) { |t|
         t.encrypt = @encrypted }

		num_records.times { |i| tbl.insert(i) }
		(1..num_records).step(2) do |i|
			tbl.delete { |r| r.number == i }
		end

		assert_equal(num_records / 2, tbl.pack)
	end

    def test_insert_001
        tbl = @db.create_table(:plane, :name, :String, :speed, :Integer
         ) { |t| t.encrypt = @encrypted }

        assert_equal(1, tbl.insert('Spitfire', 500)) 
    end

    def test_insert_002
        tbl = @db.create_table(:plane, :name, :String, :speed, :Integer
         ) { |t| t.encrypt = @encrypted }
        tbl.insert('Spitfire', 500)

        assert_equal([1, 'Spitfire', 500], tbl[1].to_a) 
    end

    def test_insert_003
        tbl = @db.create_table(:plane, :name, :String, :speed, :Integer
         ) { |t| t.encrypt = @encrypted }
        tbl.insert(:name => 'Spitfire', :speed => 500)

        assert_equal([1, 'Spitfire', 500], tbl[1].to_a) 
    end

    def test_insert_004
        tbl = @db.create_table(:plane, :name, :String, :speed, :Integer
         ) { |t| t.encrypt = @encrypted }
        tbl.insert { |r| r.name = 'Spitfire'; r.speed = 500 }

        assert_equal([1, 'Spitfire', 500], tbl[1].to_a) 
    end

    def test_insert_005
        tbl = @db.create_table(:plane, :name, :String, :speed, :Integer
         ) { |t| t.encrypt = @encrypted }
        tbl.insert('Spitfire', nil)

        assert_equal([1, 'Spitfire', nil], tbl[1].to_a) 
    end

    def test_insert_006
        tbl = @db.create_table(:plane, :name, :String,
         :speed, {:DataType=>:Integer, :Default=>300}) { |t|
         t.encrypt = @encrypted }
        tbl.insert('Spitfire', nil)

        assert_equal([1, 'Spitfire', nil], tbl[1].to_a) 
    end

    def test_insert_007
        tbl = @db.create_table(:plane, :name, :String,
         :speed, {:DataType=>:Integer, :Default=>300, :Required=>true}
         ) { |t| t.encrypt = @encrypted }
        tbl.insert(:name => 'Spitfire')

        assert_equal([1, 'Spitfire', 300], tbl[1].to_a) 
    end

    def test_insert_008
        tbl = @db.create_table(:plane, :name, :String,
         :speed, {:DataType=>:Integer, :Default=>300}) { |t|
         t.encrypt = @encrypted }
        tbl.insert('Spitfire', 500)

        assert_equal([1, 'Spitfire', 500], tbl[1].to_a) 
    end

    def test_insert_010
        tbl = @db.create_table(:plane, :name, {:DataType=>:String,
         :Required=>true}, :speed, :Integer) { |t| t.encrypt = @encrypted }

        assert_raise(ArgumentError) { tbl.insert(nil, 500) }
    end

    def test_insert_011
        tbl = @db.create_table(:plane, :name, {:DataType=>:String,
         :Required=>true}, :speed, :Integer) { |t| t.encrypt = @encrypted }

        assert_raise(ArgumentError) { tbl.insert(:speed => 500) }
    end

    def test_insert_012
        tbl = @db.create_table(:plane, :name, {:DataType=>:String,
         :Required=>true}, :speed, :Integer) { |t| t.encrypt = @encrypted }

        assert_raise(ArgumentError) { tbl.insert { |r| r.speed = 500 } }
    end

    def test_update_001
        tbl = @db.create_table(:plane, :name, :String, :speed, :Integer
         ) { |t| t.encrypt = @encrypted }
        tbl.insert('Spitfire', 500)
        tbl.update(:speed => 495) { |r| r.recno == 1 }

        assert_equal([1, 'Spitfire', 495], tbl[1].to_a) 
    end

    def test_update_002
        tbl = @db.create_table(:test, :name, :String) { |t|
         t.encrypt = @encrypted }
        tbl.insert('me')
        tbl.update_all { |r| r.name = r.name.upcase }
        assert_equal('ME', tbl.select[0].name)
    end

    def test_update_003
        tbl = @db.create_table(:test, :name, :String) { |t|
         t.encrypt = @encrypted }
        tbl.insert('you')
        tbl.update{ true }.set { |r| r.name = r.name.upcase }
        assert_equal('YOU', tbl.select[0].name)
    end

    def test_update_004
        tbl = @db.create_table(:plane, :name, :String, :speed, :Integer
         ) { |t| t.encrypt = @encrypted }
        tbl.insert('Spitfire', 500)
        tbl[1] = {:speed => 495}

        assert_equal([1, 'Spitfire', 495], tbl[1].to_a) 
    end

    def test_update_005
        tbl = @db.create_table(:plane, :name, :String, :speed, :Integer
         ) { |t| t.encrypt = @encrypted }
        tbl.insert('Spitfire', 500)
        assert_raise(RuntimeError) { tbl.update(:recno => 5) { |r|
         r.recno == 1 } }
    end

    def test_update_006
        tbl = @db.create_table(:plane, :name, :String, :speed, :Integer
         ) { |t| t.encrypt = @encrypted }
        tbl.insert('Spitfire', 500)
        assert_raise(RuntimeError) { tbl.update { |r| r.recno == 1
         }.set { |r| r.recno = 5 } }
    end

    def test_update_007
        tbl = @db.create_table(:plane, :name, :String,
         :speed, {:DataType=>:Integer, :Default=>300, :Required=>true}
         ) { |t| t.encrypt = @encrypted }
        tbl.insert(:name => 'Spitfire')

        assert_raise(ArgumentError) { tbl.update(:speed => nil) { |r|
         r.recno == 1 } }
    end

    def test_update_010
        tbl = @db.create_table(:plane, :name, {:DataType=>:String,
         :Required=>true}, :speed, :Integer) { |t| t.encrypt = @encrypted }
        tbl.insert('Spitfire', 500)

        assert_raise(ArgumentError) { tbl.update(:name => nil) { |r|
         r.recno == 1 } }
    end

    def test_delete_001
        tbl = @db.create_table(:plane, :name, :String, :speed, :Integer
         ) { |t| t.encrypt = @encrypted }
        tbl.insert('Spitfire', 500)
        tbl.delete { |r| r.recno == 1 }

        assert_equal([], tbl[1].to_a) 
    end

    def test_delete_002
        tbl = @db.create_table(:plane, :name, :String, :speed, :Integer
         ) { |t| t.encrypt = @encrypted }
        tbl.insert('Spitfire', 500)
        tbl.delete { |r| r.name == 'Spitfire' }

        assert_equal([], tbl[1].to_a) 
    end

    def test_delete_003
        tbl = @db.create_table(:plane, :name, :String, :speed, :Integer
         ) { |t| t.encrypt = @encrypted }
        tbl.insert('Spitfire', 500)
        tbl.insert('P-51', 600)
        tbl.delete { |r| r.recno == 1 }

        assert_equal(1, tbl.select.size) 
    end

    def test_clear_001
        tbl = @db.create_table(:plane, :name, :String, :speed, :Integer
         ) { |t| t.encrypt = @encrypted }
        tbl.insert('Spitfire', 500)
        tbl.insert('P-51', 600)
        tbl.clear

        assert_equal(0, tbl.select.size) 
    end

    def test_clear_002
        tbl = @db.create_table(:plane, :name, :String, :speed, :Integer
         ) { |t| t.encrypt = @encrypted }
        tbl.insert('Spitfire', 500)
        tbl.insert('P-51', 600)
        tbl.clear(true)

        assert_equal(0, tbl.last_rec_no) 
    end

    def test_clear_003
        tbl = @db.create_table(:plane, :name, :String, :speed, :Integer
         ) { |t| t.encrypt = @encrypted }
        tbl.insert('Spitfire', 500)
        tbl.insert('P-51', 600)

        assert_equal(2, tbl.delete_all) 
    end

    def test_add_column_001
		tbl = @db.create_table(:empty, :one, :String, :two, :Integer
         ) { |t| t.encrypt = @encrypted }
        assert_raise(RuntimeError) { tbl.add_column(:one, :String) }
    end

    def test_add_column_002
		tbl = @db.create_table(:empty, :one, :String, :two, :Integer
         ) { |t| t.encrypt = @encrypted }
        tbl.add_column(:three, :Boolean)

        assert_equal([:recno, :one, :two, :three], tbl.field_names)
    end

    def test_add_column_003
		tbl = @db.create_table(:empty, :one, :String) { |t|
         t.encrypt = @encrypted }
        tbl.add_column(:two, {:DataType => :Boolean, :Index => 1})

        assert_equal([nil, nil, 'Index->1'], tbl.field_indexes)
    end

    def test_add_column_004
		tbl = @db.create_table(:empty, :one, :String) { |t|
         t.encrypt = @encrypted }
        tbl.add_column(:two, {:DataType => :Integer, :Index => 1})
        tbl.insert('bob', 3)
        tbl.insert('sue', 5)
        
        assert_equal([2, 'sue', 5], 
         tbl.select_by_two_index { |r| r.two > 4}.first.to_a)
    end

    def test_add_column_005
		tbl = @db.create_table(:empty, :one, :String, :three, :Integer
         ) { |t| t.encrypt = @encrypted }
        tbl.add_column(:two, :Boolean, :one)

        assert_equal([:recno, :one, :two, :three], tbl.field_names)
    end
    
    def test_drop_column_001
        tbl = @db.create_table(:empty, :one, :String, :two, :Integer
         ) { |t| t.encrypt = @encrypted }
        tbl.drop_column(:one)
            
        assert_equal([:recno, :two], tbl.field_names)
    end

    def test_drop_column_002
        tbl = @db.create_table(:empty, :one, :String, :two, :Integer
         ) { |t| t.encrypt = @encrypted }
        tbl.drop_column(:two)
            
        assert_raise(RuntimeError) { tbl.drop_column(:three) }
    end

    def test_drop_column_003
        tbl = @db.create_table(:empty, :one, {:DataType => :String, 
         :Index => 1}, :two, :Integer) { |t| t.encrypt = @encrypted }
        tbl.drop_column(:one)
            
        assert_raise(NoMethodError) { tbl.select_by_one_index { true } }
    end
    
    def test_rename_column_001
        tbl = @db.create_table(:empty, :one, :String) { |t|
         t.encrypt = @encrypted }
        tbl.rename_column(:one, :two)
        assert_equal([:recno, :two], tbl.field_names)
    end

    def test_rename_column_002
        tbl = @db.create_table(:empty, :one, {:DataType => :String,
         :Index => 1}) { |t| t.encrypt = @encrypted }
        tbl.insert('one')
        tbl.rename_column(:one, :two)
        assert_equal(1, tbl.select_by_two_index {|r| r.two = 'one'}.size)
    end

    def test_rename_column_003
        tbl = @db.create_table(:empty, :one, :String) { |t|
         t.encrypt = @encrypted }
        tbl.rename_column(:one, :two)
        assert_equal([:recno, :two], tbl.field_names)
    end

    def test_rename_column_004
        tbl = @db.create_table(:empty, :one, :String) { |t|
         t.encrypt = @encrypted }
        assert_raise(RuntimeError) {tbl.rename_column(:one, :recno)}
    end

    def test_change_column_type_001
        tbl = @db.create_table(:empty, :one, :String) { |t|
         t.encrypt = @encrypted }
        tbl.change_column_type(:one, :Integer)
        
        assert_equal([:Integer, :Integer], tbl.field_types)
    end
    
    def test_change_column_type_002
        tbl = @db.create_table(:empty, :one, :String) { |t|
         t.encrypt = @encrypted }

        assert_raise(RuntimeError) {tbl.change_column_type(:one, :integer)} 
    end
    
    def test_change_column_type_003
        tbl = @db.create_table(:empty, :one, { :DataType => :String,
         :Required => true}) { |t| t.encrypt = @encrypted }
        tbl.change_column_type(:one, :Integer)
        
        assert_equal([[:Integer, :Integer], [false, true]], 
         [tbl.field_types, tbl.field_requireds])
    end
    
    def test_calculated_field_001
        tbl = @db.create_table(:empty, :one, :Integer, :two, :Integer,
         :three, { :DataType => :Integer, :Calculated => 'one + two' }
         ) { |t| t.encrypt = @encrypted }
        tbl.insert(1, 2, nil)
        
        assert_equal(3, tbl[1].three) 
    end

    def test_calculated_field_002
        tbl = @db.create_table(:empty, :one, :Integer, :two, :Integer,
         :three, { :DataType => :Integer, :Calculated => 'one + two' }
         ) { |t| t.encrypt = @encrypted }
        
        assert_raise(ArgumentError) { tbl.insert(1, 2, 3) } 
    end

    def test_column_required_001
        tbl = @db.create_table(:empty, :one, :String, :two, 
         {:DataType => :String, :Required => true}) { |t|
         t.encrypt = @encrypted }
         
        assert_raise(ArgumentError) { tbl.insert('one', nil) } 
    end

    def test_column_required_002
        tbl = @db.create_table(:empty, :one, :String, :two, 
         {:DataType => :String, :Required => true}) { |t|
         t.encrypt = @encrypted }
         
        assert_raise(ArgumentError) { tbl.insert(:one => 'one') } 
    end

    def test_column_required_003
        tbl = @db.create_table(:empty, :one, :String, :two, 
         {:DataType => :String, :Required => false}) { |t|
         t.encrypt = @encrypted }
        tbl.insert(:one => 'one') 
        
        assert_equal([1, 'one', nil], tbl[1].to_a) 
    end

    def test_column_required_004
        tbl = @db.create_table(:empty, :one, :String, :two, 
         {:DataType => :String, :Required => true, :Default => 'bob'}
         ) { |t| t.encrypt = @encrypted }
        tbl.insert(:one => 'one') 
        
        assert_equal([1, 'one', 'bob'], tbl[1].to_a) 
    end

    def test_column_required_005
        tbl = @db.create_table(:empty, :one, :String, :two, 
         {:DataType => :String, :Required => true}) { |t|
         t.encrypt = @encrypted }
        tbl.insert('one', 'two') 
        
        assert_raise(ArgumentError) {
         tbl.update('one', nil) { |r| r.recno == 1 } } 
    end

    def test_column_required_006
        tbl = @db.create_table(:empty, :one, :String, :two, 
         {:DataType => :String, :Required => true}) { |t|
         t.encrypt = @encrypted }
        tbl.insert('one', 'two') 
        
        assert_raise(ArgumentError) {
         tbl.update(:two => nil) { |r| r.recno == 1 } } 
    end

    def test_column_required_007
        tbl = @db.create_table(:empty, :one, :String, :two, 
         {:DataType => :String, :Required => true, :Default => 'three'}
         ) { |t| t.encrypt = @encrypted }
         
        assert_raise(ArgumentError) { tbl.insert('one', nil) } 
    end

    def test_change_column_required_001
        tbl = @db.create_table(:empty, :one, :String, :two, :String
         ) { |t| t.encrypt = @encrypted }
        tbl.change_column_required(:two, true)
        
        assert_raise(ArgumentError) { tbl.insert(:one => 'one') } 
    end

    def test_change_column_required_002
        tbl = @db.create_table(:empty, :one, :String, :two, 
         {:DataType => :String, :Required => true}) { |t|
         t.encrypt = @encrypted }
        tbl.change_column_required(:two, false)
        
        assert_equal(1, tbl.insert(:one => 'one')) 
    end

    def test_column_default_001
        tbl = @db.create_table(:empty, :one, :String, :two, 
         {:DataType => :String, :Default => 'two'}) { |t|
         t.encrypt = @encrypted }
        tbl.insert('one', nil)
        assert_equal([1, 'one', nil], tbl[1].to_a) 
    end

    def test_column_default_002
        tbl = @db.create_table(:empty, :one, :String, :two, 
         {:DataType => :String, :Default => 'two'}) { |t|
         t.encrypt = @encrypted }
        tbl.insert('one', 'not two')

        assert_equal([1, 'one', 'not two'], tbl[1].to_a) 
    end

    def test_column_default_003
        tbl = @db.create_table(:empty, :one, :String, :two, 
         {:DataType => :String, :Default => 'two'}) { |t|
         t.encrypt = @encrypted }
        tbl.insert(:one => 'one')

        assert_equal([1, 'one', 'two'], tbl[1].to_a) 
    end

    def test_column_default_004
        tbl = @db.create_table(:empty, :one, :String, :two, 
         {:DataType => :String, :Default => 'two'}) { |t|
         t.encrypt = @encrypted }
        tbl.insert(Struct.new(:one, :two).new('one'))

        assert_equal([1, 'one', nil], tbl[1].to_a) 
    end

    def test_column_default_005
        tbl = @db.create_table(:empty, :one, :String, :two, 
         {:DataType => :String, :Default => 'two', :Required => true}) { |t|
         t.encrypt = @encrypted }

        assert_raise(ArgumentError) { tbl.insert('one', nil) } 
    end

    def test_change_column_default_value_001
        tbl = @db.create_table(:empty, :one, :String, :two, :String
         ) { |t| t.encrypt = @encrypted }
        tbl.change_column_default_value(:two, 'two')
        tbl.insert(:one => 'one')
        
        assert_equal([1, 'one', 'two'], tbl[1].to_a)        
    end

    def test_change_column_default_value_002
        tbl = @db.create_table(:empty, :one, :String, :two, 
         {:DataType => :String, :Default => 'two'}) { |t|
         t.encrypt = @encrypted }
        tbl.change_column_default_value(:two, nil)
        tbl.insert(:one => 'one')
        
        assert_equal([1, 'one', nil], tbl[1].to_a)        
    end
    
    def test_index_001
        tbl = @db.create_table(:empty, :one, {:DataType => :String,
         :Index => 1}) { |t| t.encrypt = @encrypted }
        tbl.insert('one')
        tbl.insert('two')
        
        assert_equal(1, tbl.select_by_one_index {|r| r.one == 'one'}.size)
    end
    
    def test_index_002
        tbl = @db.create_table(:empty, :one, {:DataType => :String,
         :Index => 1}, :two, :String, :three, 
         {:DataType => :Integer, :Index => 1}) { |t|
         t.encrypt = @encrypted }
        tbl.insert('one', 'two', 3)
        tbl.insert('four', 'five', 6)
        
        assert_equal(1, tbl.select_by_one_three_index {|r| 
         r.one == 'four' and r.three == 6}.size)
    end
    
    def test_index_003
        assert_raise(RuntimeError) {@db.create_table(:empty, :one, 
         {:DataType => :YAML, :Index => 1}) { |t| t.encrypt = @encrypted }}
    end

    def test_add_index_001
        tbl = @db.create_table(:empty, :first, :String, :last, :String
         ) { |t| t.encrypt = @encrypted }
        tbl.insert('John', 'Doe')
        tbl.add_index(:first, :last)
        
        assert_equal(1, tbl.select_by_first_last_index {|r| 
         r.first == 'John' and r.last == 'Doe'}.size)
    end

    def test_add_index_002
        tbl = @db.create_table(:empty, :first, :String, :last, :String
         ) { |t| t.encrypt = @encrypted }
        tbl.insert('John', 'Doe')
        assert_raise(RuntimeError) { tbl.add_index(:recno, :first) }
    end

    def test_drop_index_001
        tbl = @db.create_table(:empty, :one, {:DataType => :String,
         :Index => 1}) { |t| t.encrypt = @encrypted }
        tbl.insert('one')
        tbl.insert('two')
        tbl.drop_index(:one)

        assert_equal([nil, nil], tbl.field_indexes)
    end

    def test_drop_index_002
        tbl = @db.create_table(:empty, :one, {:DataType => :String,
         :Index => 1}) { |t| t.encrypt = @encrypted }
        tbl.insert('one')
        tbl.insert('two')
        tbl.drop_index(:one)

        assert_raise(NoMethodError) { tbl.select_by_one_index { |r|
         r.one == 'one' } }
    end

    def test_link_many_001
        parent_tbl = @db.create_table(:parent, :one, :String, :two,
         {:DataType => :ResultSet, :Link_many => [:one, :child, :three]}
         ) { |t| t.encrypt = @encrypted }
        child_tbl = @db.create_table(:child, :three, :String) { |t|
         t.encrypt = @encrypted }
        parent_tbl.insert(:one => 'bob')
        child_tbl.insert('bob')
        child_tbl.insert('bob')
        child_tbl.insert('sue')

        assert_equal(2, parent_tbl.select[0].two.size)
    end

    def test_link_many_002
        assert_raise(RuntimeError) { @db.create_table(:parent, :one,
         :String, :two, {:DataType => :String, :Link_many =>
         [:one, :child, :three]}) { |t| t.encrypt = @encrypted } }
    end

    def test_lookup_field_001
        person_tbl = @db.create_table(:person, :person_id, {:DataType =>
         :String, :Key => true}, :name, :String) { |t|
         t.encrypt = @encrypted }
        emp_tbl = @db.create_table(:emp, :person, :person) { |t|
         t.encrypt = @encrypted }
        person_tbl.insert('1', 'John Doe')
        emp_tbl.insert(:person => '1')

        assert_equal('John Doe', emp_tbl.select[0].person.name)
    end

    def test_lookup_field_002
        person_tbl = @db.create_table(:person, :person_id, :String,
         :name, :String) { |t| t.encrypt = @encrypted }
        emp_tbl = @db.create_table(:emp, :person, {:DataType => :String,
         :Lookup => [:person, :person_id]}) { |t| t.encrypt = @encrypted }
        person_tbl.insert('1', 'John Doe')
        emp_tbl.insert(:person => '1')

        assert_equal('John Doe', emp_tbl.select[0].person.name)
    end

    def test_lookup_field_003
        emp_tbl = @db.create_table(:emp, :person, {:DataType => :String,
         :Lookup => [:person, :person_id]}) { |t| t.encrypt = @encrypted }
        person_tbl = @db.create_table(:person, :person_id, :String,
         :name, :String) { |t| t.encrypt = @encrypted }
        person_tbl.insert('1', 'John Doe')
        emp_tbl.insert(:person => '1')

        assert_equal('John Doe', emp_tbl.select[0].person.name)
    end

    def test_lookup_field_004
        emp_tbl = @db.create_table(:emp, :person, {:DataType => :String,
         :Lookup => [:person, :incorrect_field_name]}) { |t|
         t.encrypt = @encrypted }
        person_tbl = @db.create_table(:person, :person_id, :String,
         :name, :String) { |t| t.encrypt = @encrypted }
        person_tbl.insert('1', 'John Doe')
        emp_tbl.insert(:person => '1')

        assert_raise(NoMethodError) { emp_tbl.select[0].person.name }
    end

    def test_lookup_field_005
        person_tbl = @db.create_table(:person, :person_id, :String,
         :name, :String) { |t| t.encrypt = @encrypted }
        emp_tbl = @db.create_table(:emp, :person, {:DataType => :String,
         :Lookup => [:incorrect_table_name, :person_id]}) { |t|
         t.encrypt = @encrypted }
        person_tbl.insert('1', 'John Doe')
        emp_tbl.insert(:person => '1')

        assert_raise(RuntimeError) { emp_tbl.select[0].person.name }
    end

    def test_memo_001
        tbl = @db.create_table(:empty, :one, :Memo) { |t|
         t.encrypt = @encrypted }
        tbl.insert(KBMemo.new(@db, 'test.txt', 'This is a test.'))

        assert_equal('This is a test.', tbl[1].one.contents)
    end

    def test_memo_002
        tbl = @db.create_table(:empty, :one, :Memo) { |t|
         t.encrypt = @encrypted }
        tbl.insert(KBMemo.new(@db, 'test.txt', 'This is a test.'))
        tbl.update { |r| r.recno == 1}.set { |r|
         r.one.contents += '  And so is this.' }

        assert_equal('This is a test.  And so is this.',
         tbl[1].one.contents)
    end

    class Foobar
        attr_accessor(:recno, :one)
     
        def Foobar.kb_create(recno, one)
            Foobar.new do |x|
                x.recno = recno
                x.one = one
            end
        end
    
        def initialize(&block)
            instance_eval(&block)
        end
    end 

    def test_record_class_001
        tbl = @db.create_table(:empty, :one, :String) {|t|
         t.record_class = Foobar
         t.encrypt = @encrypted
        }
        tbl.insert('one')
        assert_equal(Foobar, tbl[1].class)
    end

    def test_yaml_001
        tbl = @db.create_table(:empty, :two, :String, :one, :YAML) { |t|
         t.encrypt = @encrypted }
        tbl.insert(:one => ['one', 2])

        assert_equal(['one', 2], tbl[1].one)
    end

    def test_yaml_002
        tbl = @db.create_table(:empty, :two, :String, :one, :YAML) { |t|
         t.encrypt = @encrypted }
        tbl.insert(:one => ['one', 2])
        tbl.update(:one => ['two', 3]) { |r| r.recno == 1 }
        assert_equal(['two', 3], tbl[1].one)
    end
    
    def test_nil_values_001
        tbl = @db.create_table(:nil_tests, :nil_value, :Integer,
         :conditional, :Integer)
        tbl.insert(nil, 100)
         
        recs = []
         
        assert_nothing_raised {rec = tbl.select {|r| r.nil_value > 100}}
        assert_equal 0, recs.length
        
        assert_nothing_raised {recs = tbl.select {|r| r.nil_value > 100 and 
         r.conditional > 100}}
        assert_equal 0, recs.length

        assert_nothing_raised {recs = tbl.select {|r| r.nil_value > 100 or 
         r.conditional > 100}}
        assert_equal 0, recs.length

        assert_nothing_raised {recs = tbl.select {|r| r.nil_value > 100 and 
         r.conditional == 100}}
        assert_equal 0, recs.length

        assert_nothing_raised {recs = tbl.select {|r| r.nil_value > 100 or 
         r.conditional == 100}}
        assert_equal 1, recs.length

        assert_nothing_raised {recs = tbl.select {|r| r.nil_value.kb_nil?}}
        assert_equal 1, recs.length

        assert_nothing_raised {recs = tbl.select {|r| r.nil_value == kb_nil}}
        assert_equal 1, recs.length
    end
end

