require 'spec_helper'

describe Crawler do
  
  let(:id){random_string}
  let(:callback){ {:type => Recommender, :args => {:id => "some_id"}} }
  let(:depth){3}
  
  let(:crawler){SongCrawler.new(:id => id, :depth => depth, :callback => callback)}


  before(:each) do
    @song = Song.new(id)
    Song.stub(:new).and_return(@song)
  end
  
  describe "with an unsynced object" do

    it "should sync the object" do

      # Checking the status
      @song.synced?.should be_false
      @song.crawled?(depth).should be_false

      # Launch a sync with itself (and its callback) as a callback
      @song.stub!(:sync)
      @song.should_receive(:sync!).with(:callback => crawler.to_callback)
            
      # Do not launch its callback
      crawler.callback.should_not_receive(:call)
    
      crawler.perform
      
      # Its flag should not be set
      @song.crawled?(depth).should be_false
                
    end
    
  end
  
  describe "with a synced but uncrawled object" do
    
    before(:each) do

      # Setting up and checking the data
      @song.synced_at = Time.now      
      @song.synced?.should be_true
      @song.crawled?(depth).should be_false
      
      
      
    end
    
    it "should crawl uncrawled children with a lower depth" do
      
      let(depth){0}

      # Check statuses
      
      # Launch uncrawled with itself (and its callback) as callback at lower depth
      
      # Do not launch its callback
      
      # Do not set its flag
      
      pending
      
    end
    
    it "should set its flag and call the callback if depth is 0" do

      # Set its flag
      
      # Call its callback
      
      pending
      
    end
    
  end
  
  describe "with an uncrawled object with crawled children" do
    
    it "should set its flag and call its callback" do
      # Set its flag
      
      # Call its callback
      
      pending
      
    end
    
  end

  describe "with a crawled object" do
    
    it "should not update its flag but call its callback" do
      
      # Set its flag
      
      pending
      
    end
    
  end
    
end