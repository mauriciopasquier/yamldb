require File.dirname(__FILE__) + '/base'

describe YamlDb::Dump do

  before do
    silence_warnings { ActiveRecord::Base = double('ActiveRecord::Base').as_null_object }
    allow(ActiveRecord::Base).to receive(:connection).and_return(double('connection').as_null_object)
    allow(ActiveRecord::Base.connection).to receive(:tables).and_return([ 'mytable', 'schema_info', 'schema_migrations' ])
    allow(ActiveRecord::Base.connection).to receive(:columns).with('mytable').and_return([ double('a',:name => 'a', :type => :string), double('b', :name => 'b', :type => :string) ])
    allow(ActiveRecord::Base.connection).to receive(:select_one).and_return({"count"=>"2"})
    allow(ActiveRecord::Base.connection).to receive(:select_all).and_return([ { 'a' => 1, 'b' => 2 }, { 'a' => 3, 'b' => 4 } ])
    allow(YamlDb::Utils).to receive(:quote_table).with('mytable').and_return('mytable')
  end

  before(:each) do
    allow(File).to receive(:new).with('dump.yml', 'w').and_return(StringIO.new)
    @io = StringIO.new
  end

  it "should return a formatted string" do
    YamlDb::Dump.table_record_header(@io)
    @io.rewind
    expect(@io.read).to eq("  records: \n")
  end

  it "should return a yaml string that contains a table header and column names" do
    if RUBY_VERSION.split(".")[1] == "9"
      YAML::ENGINE.yamler = "syck"
    end
    allow(YamlDb::Dump).to receive(:table_column_names).with('mytable').and_return([ 'a', 'b' ])
    YamlDb::Dump.dump_table_columns(@io, 'mytable')
    @io.rewind
    expect(@io.read).to eq(<<EOYAML

--- 
mytable: 
  columns: 
  - a
  - b
EOYAML
    )
  end

  it "should return dump the records for a table in yaml to a given io stream" do
    YamlDb::Dump.dump_table_records(@io, 'mytable')
    @io.rewind
    expect(@io.read).to eq(<<EOYAML
  records: 
  - - 1
    - 2
  - - 3
    - 4
EOYAML
    )
  end

end
