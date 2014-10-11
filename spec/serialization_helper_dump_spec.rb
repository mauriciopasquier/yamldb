require File.dirname(__FILE__) + '/base'

describe SerializationHelper::Dump do

  before do
    silence_warnings { ActiveRecord::Base = double('ActiveRecord::Base').as_null_object }
    allow(ActiveRecord::Base).to receive(:connection).and_return(double('connection').as_null_object)
    allow(ActiveRecord::Base.connection).to receive(:tables).and_return([ 'mytable', 'schema_info', 'schema_migrations' ])
    allow(ActiveRecord::Base.connection).to receive(:columns).with('mytable').and_return([ double('a', :name => 'a', :type => :string), double('b', :name => 'b', :type => :string) ])
    allow(ActiveRecord::Base.connection).to receive(:select_one).and_return({"count"=>"2"})
    allow(ActiveRecord::Base.connection).to receive(:select_all).and_return([ { 'a' => 1, 'b' => 2 }, { 'a' => 3, 'b' => 4 } ])
    allow(SerializationHelper::Utils).to receive(:quote_table).with('mytable').and_return('mytable')
  end

  before(:each) do
    allow(File).to receive(:new).with('dump.yml', 'w').and_return(StringIO.new)
    @io = StringIO.new
  end

  it "should return a list of column names" do
    expect(SerializationHelper::Dump.table_column_names('mytable')).to eq([ 'a', 'b' ])
  end

  it "should return a list of tables without the rails schema table" do
    expect(SerializationHelper::Dump.tables).to eq(['mytable'])
  end

  it "should return the total number of records in a table" do
    expect(SerializationHelper::Dump.table_record_count('mytable')).to eq(2)
  end

  it "should return all records from the database and return them when there is only 1 page" do
    SerializationHelper::Dump.each_table_page('mytable') do |records|
      expect(records).to eq([ { 'a' => 1, 'b' => 2 }, { 'a' => 3, 'b' => 4 } ])
    end
  end

  it "should paginate records from the database and return them" do
    allow(ActiveRecord::Base.connection).to receive(:select_all).and_return([ { 'a' => 1, 'b' => 2 } ], [ { 'a' => 3, 'b' => 4 } ])

    records = [ ]
    SerializationHelper::Dump.each_table_page('mytable', 1) do |page|
      expect(page.size).to eq(1)
      records.concat(page)
    end

    expect(records).to eq([ { 'a' => 1, 'b' => 2 }, { 'a' => 3, 'b' => 4 } ])
  end

  it "should dump a table's contents to yaml" do
    expect(SerializationHelper::Dump).to receive(:dump_table_columns)
    expect(SerializationHelper::Dump).to receive(:dump_table_records)
    SerializationHelper::Dump.dump_table(@io, 'mytable')
  end

  it "should not dump a table's contents when the record count is zero" do
    allow(SerializationHelper::Dump).to receive(:table_record_count).with('mytable').and_return(0)
    expect(SerializationHelper::Dump).to_not receive(:dump_table_columns)
    expect(SerializationHelper::Dump).to_not receive(:dump_table_records)
    SerializationHelper::Dump.dump_table(@io, 'mytable')
  end

end
