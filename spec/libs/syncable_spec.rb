shared_examples "a syncable" do
    
  describe "#synced?" do
    
    it "should return false for unsynced data" do  
      syncable.synced?.should be_false
    end

    it "should return true for synced data" do        
      syncable.synced_at = Time.now        
      syncable.synced?.should be_true
    end
    
    it "should return false for synced but outdated songs" do
      syncable.synced_at = (Time.now - expiration - 1.second)  
      syncable.synced?.should be_false
    end
    
  end

  describe "#sync!" do
    
    it "should launch a job" do
      syncable.sync!
      syncer.should have_queue_size_of(1)
      syncer.should have_queued({"id" => syncable.id})
    end
    
  end    
        
end