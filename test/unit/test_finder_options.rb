require 'test_helper'
require 'models'

class FinderOptionsTest < Test::Unit::TestCase
  include MongoMapper
  
  should "raise error if provided something other than a hash" do
    lambda { FinderOptions.new(Room) }.should raise_error(ArgumentError)
    lambda { FinderOptions.new(Room, 1) }.should raise_error(ArgumentError)
  end
  
  should "symbolize the keys of the hash provided" do
    FinderOptions.new(Room, 'offset' => 1).options.keys.map do |key|
      key.should be_instance_of(Symbol)
    end
  end
  
  context "Converting conditions to criteria" do
    should "not add _type to query if model does not have superclass that is single collection inherited" do
      FinderOptions.new(Message, :foo => 'bar').criteria.should == {
        :foo => 'bar'
      }
    end
    
    should "not add _type to nested conditions" do
      FinderOptions.new(Enter, :foo => 'bar', :age => {'$gt' => 21}).criteria.should == {
        :foo => 'bar',
        :age => {'$gt' => 21},
        :_type => 'Enter'
      }
    end
    
    %w{gt lt gte lte ne in nin mod size where exists}.each do |operator|
      should "convert #{operator} conditions" do
        FinderOptions.new(Room, :age.send(operator) => 21).criteria.should == {
          :age => {"$#{operator}" => 21}
        }
      end
    end
    
    should "automatically add _type to query if model is single collection inherited" do
      FinderOptions.new(Enter, :foo => 'bar').criteria.should == {
        :foo => 'bar',
        :_type => 'Enter'
      }
    end
    
    should "work with simple criteria" do
      FinderOptions.new(Room, :foo => 'bar').criteria.should == {
        :foo => 'bar'
      }
      
      FinderOptions.new(Room, :foo => 'bar', :baz => 'wick').criteria.should == {
        :foo => 'bar', 
        :baz => 'wick'
      }
    end
    
    should "convert id to _id" do
      id = Mongo::ObjectID.new
      FinderOptions.new(Room, :id => id).criteria.should == {:_id => id}
    end
    
    should "convert id with symbol operator to _id with modifier" do
      id = Mongo::ObjectID.new
      FinderOptions.new(Room, :id.ne => id).criteria.should == {
        :_id => {'$ne' => id}
      }
    end
    
    should "make sure that _id's are object ids" do
      id = Mongo::ObjectID.new
      FinderOptions.new(Room, :_id => id.to_s).criteria.should == {:_id => id}
    end
    
    should "work fine with _id's that are object ids" do
      id = Mongo::ObjectID.new
      FinderOptions.new(Room, :_id => id).criteria.should == {:_id => id}
    end
    
    should "make sure other object id typed keys get converted" do
      id = Mongo::ObjectID.new
      FinderOptions.new(Message, :room_id => id.to_s).criteria.should == {:room_id => id}
    end
    
    should "work fine with object ids for object id typed keys" do
      id = Mongo::ObjectID.new
      FinderOptions.new(Message, :room_id => id).criteria.should == {:room_id => id}
    end
    
    should "use $in for arrays" do
      FinderOptions.new(Room, :foo => [1,2,3]).criteria.should == {
        :foo => {'$in' => [1,2,3]}
      }
    end
    
    should "not use $in for arrays if already using array operator" do
      FinderOptions.new(Room, :foo => {'$all' => [1,2,3]}).criteria.should == {
        :foo => {'$all' => [1,2,3]}
      }

      FinderOptions.new(Room, :foo => {'$any' => [1,2,3]}).criteria.should == {
        :foo => {'$any' => [1,2,3]}
      }
    end
    
    should "work arbitrarily deep" do
      FinderOptions.new(Room, :foo => {:bar => [1,2,3]}).criteria.should == {
        :foo => {:bar => {'$in' => [1,2,3]}}
      }
      
      FinderOptions.new(Room, :foo => {:bar => {'$any' => [1,2,3]}}).criteria.should == {
        :foo => {:bar => {'$any' => [1,2,3]}}
      }
    end
  end
  
  context "ordering" do
    should "single field with ascending direction" do
      sort = [['foo', 1]]
      FinderOptions.new(Room, :order => 'foo asc').options[:sort].should == sort
      FinderOptions.new(Room, :order => 'foo ASC').options[:sort].should == sort
    end
    
    should "single field with descending direction" do
      sort = [['foo', -1]]
      FinderOptions.new(Room, :order => 'foo desc').options[:sort].should == sort
      FinderOptions.new(Room, :order => 'foo DESC').options[:sort].should == sort
    end
    
    should "convert order operators to mongo sort" do
      FinderOptions.new(Room, :order => :foo.asc).options[:sort].should == [['foo', 1]]
      FinderOptions.new(Room, :order => :foo.desc).options[:sort].should == [['foo', -1]]
    end
    
    should "convert array of order operators to mongo sort" do
      FinderOptions.new(Room, :order => [:foo.asc, :bar.desc]).options[:sort].should == [['foo', 1], ['bar', -1]]
    end
    
    should "convert field without direction to ascending" do
      sort = [['foo', 1]]
      FinderOptions.new(Room, :order => 'foo').options[:sort].should == sort
    end
    
    should "convert multiple fields with directions" do
      sort = [['foo', -1], ['bar', 1], ['baz', -1]]
      FinderOptions.new(Room, :order => 'foo desc, bar asc, baz desc').options[:sort].should == sort
    end
    
    should "convert multiple fields with some missing directions" do
      sort = [['foo', -1], ['bar', 1], ['baz', 1]]
      FinderOptions.new(Room, :order => 'foo desc, bar, baz').options[:sort].should == sort
    end
    
    should "just use sort if sort and order are present" do
      sort = [['$natural', 1]]
      FinderOptions.new(Room, :sort => sort, :order => 'foo asc').options[:sort].should == sort
    end
    
    should "convert natural in order to proper" do
      sort = [['$natural', 1]]
      FinderOptions.new(Room, :order => '$natural asc').options[:sort].should == sort
      sort = [['$natural', -1]]
      FinderOptions.new(Room, :order => '$natural desc').options[:sort].should == sort
    end
    
    should "work for natural order ascending" do
      FinderOptions.new(Room, :sort => {'$natural' => 1}).options[:sort]['$natural'].should == 1
    end
    
    should "work for natural order descending" do
      FinderOptions.new(Room, :sort => {'$natural' => -1}).options[:sort]['$natural'].should == -1
    end
  end
  
  context "skip" do
    should "default to 0" do
      FinderOptions.new(Room, {}).options[:skip].should == 0
    end
    
    should "use skip provided" do
      FinderOptions.new(Room, :skip => 2).options[:skip].should == 2
    end
    
    should "covert string to integer" do
      FinderOptions.new(Room, :skip => '2').options[:skip].should == 2
    end
    
    should "convert offset to skip" do
      FinderOptions.new(Room, :offset => 1).options[:skip].should == 1
    end
  end
  
  context "limit" do
    should "default to 0" do
      FinderOptions.new(Room, {}).options[:limit].should == 0
    end
    
    should "use limit provided" do
      FinderOptions.new(Room, :limit => 2).options[:limit].should == 2
    end
    
    should "covert string to integer" do
      FinderOptions.new(Room, :limit => '2').options[:limit].should == 2
    end
  end
  
  context "fields" do
    should "default to nil" do
      FinderOptions.new(Room, {}).options[:fields].should be(nil)
    end
    
    should "be converted to nil if empty string" do
      FinderOptions.new(Room, :fields => '').options[:fields].should be(nil)
    end
    
    should "be converted to nil if []" do
      FinderOptions.new(Room, :fields => []).options[:fields].should be(nil)
    end
    
    should "should work with array" do
      FinderOptions.new(Room, {:fields => %w(a b)}).options[:fields].should == %w(a b)
    end
    
    should "convert comma separated list to array" do
      FinderOptions.new(Room, {:fields => 'a, b'}).options[:fields].should == %w(a b)
    end
    
    should "also work as select" do
      FinderOptions.new(Room, :select => %w(a b)).options[:fields].should == %w(a b)
    end
  end
  
  context "Condition auto-detection" do
    should "know :conditions are criteria" do
      finder = FinderOptions.new(Room, :conditions => {:foo => 'bar'})
      finder.criteria.should == {:foo => 'bar'}
      finder.options.keys.should_not include(:conditions)
    end
    
    should "know fields is an option" do
      finder = FinderOptions.new(Room, :fields => ['foo'])
      finder.options[:fields].should == ['foo']
      finder.criteria.keys.should_not include(:fields)
    end
    
    # select gets converted to fields so just checking keys
    should "know select is an option" do
      finder = FinderOptions.new(Room, :select => 'foo')
      finder.options.keys.should include(:sort)
      finder.criteria.keys.should_not include(:select)
      finder.criteria.keys.should_not include(:fields)
    end
    
    should "know skip is an option" do
      finder = FinderOptions.new(Room, :skip => 10)
      finder.options[:skip].should == 10
      finder.criteria.keys.should_not include(:skip)
    end
    
    # offset gets converted to skip so just checking keys
    should "know offset is an option" do
      finder = FinderOptions.new(Room, :offset => 10)
      finder.options.keys.should include(:skip)
      finder.criteria.keys.should_not include(:skip)
      finder.criteria.keys.should_not include(:offset)
    end

    should "know limit is an option" do
      finder = FinderOptions.new(Room, :limit => 10)
      finder.options[:limit].should == 10
      finder.criteria.keys.should_not include(:limit)
    end

    should "know sort is an option" do
      finder = FinderOptions.new(Room, :sort => [['foo', 1]])
      finder.options[:sort].should == [['foo', 1]]
      finder.criteria.keys.should_not include(:sort)
    end

    # order gets converted to sort so just checking keys
    should "know order is an option" do
      finder = FinderOptions.new(Room, :order => 'foo')
      finder.options.keys.should include(:sort)
      finder.criteria.keys.should_not include(:sort)
    end
        
    should "work with full range of things" do
      finder_options = FinderOptions.new(Room, {
        :foo => 'bar',
        :baz => true,
        :sort => [['foo', 1]],
        :fields => ['foo', 'baz'],
        :limit => 10,
        :skip => 10,
      })
      
      finder_options.criteria.should == {
        :foo => 'bar',
        :baz => true,
      }
      
      finder_options.options.should == {
        :sort => [['foo', 1]],
        :fields => ['foo', 'baz'],
        :limit => 10,
        :skip => 10,
      }
    end
  end
  
end # FinderOptionsTest
