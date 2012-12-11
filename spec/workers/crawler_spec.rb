require 'spec_helper'

describe Crawler do
  
  let(:id){random_string}
  let(:callback){ {:type => "SongCrawler", :args => {:id => "some_id", :depth => 4}} }
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
      
      # Setting up the data
      crawled_user = Object.new
      uncrawled_user = Object.new
      
      crawled_user.stub!(:crawled?).and_return(true)
      uncrawled_user.stub!(:crawled?).and_return(false)
      
      @song.stub!(:users).and_return([crawled_user, uncrawled_user])
      
      # Launch uncrawled with itself (and its callback) as callback at lower depth
      crawled_user.should_not_receive(:crawl!)
      uncrawled_user.should_receive(:crawl!).with({:depth => (depth - 1), :callback => crawler.to_callback})
      
      # Do not launch its callback
      crawler.callback.should_not_receive(:call)
      
      crawler.perform
      
      # Do not set its flag
      @song.crawled?(depth).should be_false      
      
    end
    
    it "should set its flag and call the callback if depth is 0" do

      # Setting up the data
      crawler.depth = 0
                  
      # Call its callback
      crawler.callback.should_receive(:call)
      
      crawler.perform
      
      # Set its flag
      @song.crawled?(crawler.depth).should be_true  
      
    end
    
  end
  
  describe "with an uncrawled object with crawled children" do
        
    it "should set its flag and call its callback" do
      # Setting up the data
      @song.synced_at = Time.now      
      @song.synced?.should be_true
      @song.crawled?(depth).should be_false
      
      users = []
      
      3.times do
        crawled_user = Object.new
        crawled_user.stub!(:crawled?).and_return(true)
        users << crawled_user
      end
      
      @song.stub!(:users).and_return(users)

      # Call its callback
      crawler.callback.should_receive(:call)
      
      crawler.perform
      
      # Set its flag
      @song.crawled?(depth).should be_true  
    end
    
  end

  describe "with a crawled object" do
    
    it "should not update its flag but call its callback" do
      
      # Setting up the data
      @song.stub!(:synced?).and_return(true)
      @song.stub!(:crawled?).and_return(true)
      
      # Call its callback
      crawler.callback.should_receive(:call)

      # Don't set its flag
      @song.should_not_receive(:set_crawled_at)

      crawler.perform
      
    end
    
  end
    
end