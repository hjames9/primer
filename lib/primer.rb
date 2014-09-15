require 'active_record'

class ActiveRecord::ConnectionAdapters::AbstractAdapter
  module PrimaryKey
    def add_primary_key(table_name, columns)
      column_exists?(table_name, :id, nil, {})
      remove_column table_name, :id if column_exists?(table_name, :id, nil, {})
      execute "alter table #{table_name} add primary key(#{Array(columns).join(', ')})"
    end

    def remove_primary_key(table_name)
      execute "alter table #{table_name} drop constraint #{table_name}_pkey"
    end

    def undo_add_primary_key(table_name, columns)
      drop_primary_key table_name,
      Array(columns).each do |c|
        change c, :string, :null => true, :default => nil
      end
      add_default_primary_key table_name
    end

    def add_default_primary_key(table_name)
      integer :id unless column_exists?(table_name, :id, nil, {})
      change :id, :primary_key
    end

    def supports_primary_key?
      true
    end
  end
  module CheckConstraint
    def add_check_constraint(table_name, constraint_name, expression, *rest)
      for index in 0 ... rest.size
        expression = expression.sub('?', rest[index].to_s);
      end
      execute "alter table #{table_name} add constraint #{constraint_name} check(#{expression})"
    end

    def remove_check_constraint(table_name, constraint_name)
      execute "alter table #{table_name} drop constraint #{constraint_name}"
    end
  end
end

class ActiveRecord::ConnectionAdapters::AbstractAdapter
  include PrimaryKey
  include CheckConstraint
end

module CommandRecorder
  def add_primary_key(*args)
    record(:add_primary_key, args);
  end

  def remove_primary_key(*args)
    record(:remove_primary_key, args);
  end

  def invert_add_primary_key(args)
    table_name = args.first
    [:remove_primary_key, [table_name]]
  end

  def add_check_constraint(*args)
    record(:add_check_constraint, args);
  end

  def remove_check_constraint(*args)
    record(:remove_check_constraint, args);
  end

  def invert_add_check_constraint(args)
    table_name = args.first
    constraint_name = args.second
    [:remove_check_constraint, [table_name, constraint_name]]
  end
end

class ActiveRecord::Migration::CommandRecorder
  include CommandRecorder
end
