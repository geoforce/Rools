require File.dirname(__FILE__) + '/../spec_helper'
require 'rools'

# to support csv test
class Hour
end
class Customer
end

describe "Empty RuleSet" do
  before(:each) do
    @ruleset = Rools::RuleSet.new
  end
  
  after(:each) do
    @ruleset = nil
  end
  
  it "should not contain any rules" do
    @ruleset.get_rules.size == 0
  end

  it "should not contain any facts" do
    @ruleset.get_facts.size == 0
  end
  
  it "responds to assert" do
    @ruleset.should respond_to(:assert)
  end
 
  it "can assert with one or more parameters" do
    obj1 = "heya"
    obj2 = 2
    #@ruleset.should_receive(:assert).with(obj1, obj2).and_return(Rools::RuleSet::PASS)
    status = @ruleset.assert(obj1, obj2)
    status.should equal(Rools::RuleSet::PASS)
  end
  
  it "responds to evaluate" do
    @ruleset.should respond_to(:evaluate)
  end
  
  it "has null metrics" do
    @ruleset.status == Rools::RuleSet::UNDETERMINED
    @ruleset.num_executed == 0
    @ruleset.num_evaluated == 0
  end
  
  it "can accept new facts programmatically and delete all facts" do
    obj1 = "heya"
    obj2 = 2
    @ruleset.fact( obj1 )
    @ruleset.fact( obj2 )
    
    @ruleset.get_facts.should have(2).facts
    @ruleset.delete_facts
    @ruleset.get_facts.should have(0).facts
  end
  
  it "can accept more than one fact of the same type, they get associated in the same fact type" do
    @ruleset.fact( "heya" )
    @ruleset.fact( "hello" )
    @ruleset.get_facts.should have(1).facts
  end
  
  it "can accept fact stements in a rule set" do
    @ruleset = Rools::RuleSet.new do
		facts 'Countries' do
			["China", "USSR", "France", "Great Britain", "USA"]
		end
	end
    @ruleset.get_facts.should have(1).fact
  end
  
  it "can load an xml file" do
    @ruleset.load_xml( "test/data/hello.xml")
    @ruleset.get_rules.should have(2).rule
  end
  
  it "should generate an RuleLoadingError if loading a bad xml file" do
    lambda {
      @ruleset.load_xml( "test/data/bad_hello.xml")
    }.should raise_error( Rools::RuleLoadingError)
  end
  
   it "can load an xml string" do
    
  str ="<rule-set name='hello'>
    	<facts name='Chars'>['a','b','c']</facts>
    	<rule name='Hello'>
    	  <parameter>String</parameter>
    	  <consequence>puts 'Hello, Rools!'</consequence>
    	</rule>
    </rule-set>"

     @ruleset.load_xml_rules_as_string( str )
     @ruleset.get_rules.should have(1).rule
  end
  
  it "can load an rb file" do
    @ruleset.load_rb( "test/data/hello.rb")
    @ruleset.get_rules.should have(1).rule
  end
  
  it "should generate an RuleLoadingError if loading a bad ruby file" do
    lambda {
      @ruleset.load_rb( "test/data/bad_hello.rb")
    }.should raise_error( Rools::RuleLoadingError)
  end
  
  it "can load an rb rule string" do

  str = "rule 'Hello' do
  	  parameter String
  	  consequence { puts 'Hello, Rools!' }
    end"

    @ruleset.load_rb_rules_as_string( str )
    @ruleset.get_rules.should have(1).rule
  end
  
  it "can load a csv file" do
    @ruleset.load_csv( "test/data/greetings.csv")
    @ruleset.get_rules.should have(4).rules
  end
  
  it "can be initialized with an .xml file" do
    @ruleset = Rools::RuleSet.new( "test/data/hello.xml")
  end
  
  it "can be initialized with an .rb file" do
    @ruleset = Rools::RuleSet.new( "test/data/hello.rb")
  end
  
  it "can be initialized with an .rules file, equivalent to .rb" do
    @ruleset = Rools::RuleSet.new( "test/data/hello.rules")
  end
  
  it "can be initialized with a .csv file" do
    @ruleset = Rools::RuleSet.new( "test/data/rules301.csv")
  end

  it "or will generate an error for other extensions" do
    lambda {
      @ruleset = Rools::RuleSet.new( "test/data/greetings.xls")
    }.should raise_error( Rools::RuleLoadingError)
  end
  
  it "can stop rule evaluation" do
    ruleset = Rools::RuleSet.new do
		rule 'Hello' do
			parameter String
			consequence { stop("Stop it") }
		end
	end
	status = ruleset.assert "Hey"
	status.should eql(Rools::RuleSet::PASS)
  end
  
  it "can fail rule evaluation" do
    ruleset = Rools::RuleSet.new do
		rule 'Hello' do
			parameter String
			consequence { fail("fail it") }
		end
	end
	status = ruleset.assert "Hey"
	status.should eql(Rools::RuleSet::FAIL)
  end
  
  it "rules do not get evaluated if the rule parameter does not match the asserted object" do
    ruleset = Rools::RuleSet.new do
		rule 'Hello' do
			parameter String
			consequence { fail("fail it") }
		end
	end
	status = ruleset.assert 10
	status.should eql(Rools::RuleSet::PASS)
	ruleset.num_evaluated.should be(0)
  end
end