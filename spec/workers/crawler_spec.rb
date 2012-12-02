require 'spec_helper'

describe Crawler do
  
  describe "with synced data" do
    
    it "should forward the crawl one level down" do
      pending
    end
    
    it "should stop at level 0" do
      pending      
    end
    
  end
  
  
  describe "with unsynced data" do
    
    it "should send the data to be synced" do
      pending    
    end
    
    it "should set a callback to itself" do
      pending
    end
      
    it "should not set the crawled? flag until actually done" do
      pending      
    end
      
  end
  
  
  describe "forcing and callbacks" do
    
    it "should force the syncing when the force flag is set" do
      pending      
    end

    it "should forward the force flag to children crawls" do
      pending      
    end
    
    it "should forward its callback to children crawls" do
      pending      
    end

  end
    
end