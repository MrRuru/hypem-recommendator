require 'spec_helper'

describe Song do

  let(:id) {random_string}
  let(:artist) {"Dj Awesome"}
  let(:title) {"Hypermegamix"}
  let(:expiration) {1.day}


  before :each do
    REDIS.flushall
    ResqueSpec.reset!
    
    @song = Song.new(id)
  end

  
  describe "#syncing" do
    
    describe "#synced?" do
      
      it "should return false for unsynced songs" do  
        @song.synced?.should be_false
      end

      it "should return true for synced songs" do
        @song.artist = artist
        @song.title = title
        @song.synced_at = Time.now
        
        @song.synced?.should be_true
      end
      
      it "should return false for synced but outdated songs" do
        @song.artist = artist
        @song.title = title
        @song.synced_at = Time.now - expiration- 1.second

        @song.synced?.should be_false
      end
      
    end

    describe "#sync!" do
      
      it "should launch a job" do
        @song.sync!
        SongSyncer.should have_queue_size_of(1)
        SongSyncer.should have_queued({"id" => @song.id})
      end
      
    end    

  end
    
  describe "crawling" do
    
    describe "#crawl!" do

      it "should launch a job" do
      
        pending
      
      end
      
      it "should handle the default depth" do
        
      end

    end
    
    describe "#crawled?" do
  
      it "should check the syncing status for depth 0" do
        
        pending
        
      end
      
      it "should check the crawl date existence and expiration" do
        
        pending
        
      end
      
      it "should propagate down - if better - but not up" do
        
        pending
        
      end      
      
    end
    
  end  
    
end
