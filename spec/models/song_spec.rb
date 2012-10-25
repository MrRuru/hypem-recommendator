require 'spec_helper'

describe Song do

  before :each do
    REDIS.flushall
    ResqueSpec.reset!
    @song = FactoryGirl.build_stubbed(:song)
  end

  
  describe "#syncing" do
    
    it "#sync?" do
      @song.synced?.should be_false
    end
  
    it "#sync!" do
      @song.sync!
      Syncer.should have_queue_size_of(1)
      Syncer.should have_queued({"type" => "song", "id" => @song.id})
    end

  end
    
end
