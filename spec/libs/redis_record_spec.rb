require 'spec_helper'

describe RedisRecord do
  
  describe "#new" do
    RedisRecord.new('id').id.should == 'id'    
  end
  
end