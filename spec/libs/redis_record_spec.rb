require 'spec_helper'

describe RedisRecord do
  
  class TestRecord < RedisRecord
    
    has_attributes :test_attribute
    has_associated :test_associated

  end

  let(:random_string_array) {Array.new(rand(10) + 1).map{random_string}}
    
  let(:id) {random_string}
  let(:attribute_value) {random_string}
  let(:associated_value) {random_string_array}
  
  before :each do
    REDIS.flushall
    @record = TestRecord.new(id)
  end
  
  describe "#new" do
    
    it "should save a valid id and key" do
      @record.id.should == id
      @record.key.should == "test_record:#{id}"
    end
    
    it "should not be persisted on initialization" do
      REDIS.exists(@record.key).should == false
    end
    
  end

  describe "persistance" do

    it "should save attribute in hash and persist only then" do
      @record.test_attribute = attribute_value
      REDIS.exists(@record.key).should == true
      @record.test_attribute.should == attribute_value
    end
  
    it "should save associated in different field as set" do
      @record.test_associated.sadd associated_value
      REDIS.exists(@record.key).should == false
      REDIS.exists("#{@record.key}:test_associated").should == true
      @record.test_associated.smembers.should =~ associated_value.sort      
    end
  
  end  
end