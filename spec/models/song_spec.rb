require 'spec_helper'

describe Song do

  let(:id) {random_string}
  let(:artist) {"Dj Awesome"}
  let(:title) {"Hypermegamix"}


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
        @song.synced_at = Time.now - Song::EXPIRE_AFTER - 1.second

        @song.synced?.should be_false
      end
      
    end

    describe "#sync!" do
      
      it "should launch a job" do
        @song.sync!
        Syncer.should have_queue_size_of(1)
        Syncer.should have_queued({"type" => "song", "id" => @song.id})
      end
      
    end    

  end
    
end
