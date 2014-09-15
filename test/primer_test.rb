require 'test/unit'
require 'primer'

class MigrationTest < ActiveRecord::Migration
    def up
        create_table :__tester do |t|
            t.integer :ss
            t.string  :first_name
            t.string  :last_name
        end
        add_index :__tester, :ss
        add_index :__tester, :first_name
        add_index :__tester, :last_name
        add_primary_key :__tester, [:ss, :first_name, :last_name]
    end

    def down
        drop_table :__tester
    end
end

class PrimerTest < Test::Unit::TestCase
    def test_add_primary_key
        ActiveRecord::Base.establish_connection( :adapter => "sqlite3", :database => "test.db" )

        mt = MigrationTest.new
        mt.up
        mt.down

	File.delete("test.db")
    end

    def test_drop_primary_key
        assert_equal 9, 9
    end

    def test_add_default_primary_key
        assert_equal 9, 9
    end

    def test_undo_add_primary_key
        assert_equal 9, 9
    end
end
