require 'spec_helper'

describe Syncer do
  
  let(:id) {random_string}
  let(:type) {"song"}

  describe "with an unsynced songs" do

    let(:song) {}

    before(:each) do
      # Control what's happening to the song in the syncer
      @song = Song.new(id)
      Song.stub(:new).and_return(@song)
    end
      

    it "should try to sync with hypem" do
      @song.stub(:hypem).and_return(Object.new)

      @song.hypem.should_receive(:get)
      
      @song.hypem.stub(:favorites).and_return(Object.new)
      @song.hypem.should_receive(:favorites)

      @song.hypem.favorites.stub(:get).and_return(@song.hypem.favorites)
      @song.hypem.favorites.should_receive(:get)

      @song.hypem.favorites.stub(:users).and_return(Object.new)
      @song.hypem.favorites.should_receive(:users)

      Syncer.perform({:type => type, :id => id})
    end
      
      
    it "should process the hypem data" do
      @song.stub_chain(:hypem, :get).and_return("foobar")
      @song.stub_chain(:hypem, :favorites, :get,  :users).and_return("foobarbar")

      Syncer.perform({:type => type, :id => id})
      
      @song.artist.should == "artist"
    end
        
    
    
  end
  

  # describe "with a synced song" do
  # 
  # end
  # 
  # 
  # 
  # describe "callbacks" do
  # 
  #   
  # end
  # 
  # 
  # 

  describe "error cases" do
  
    it "should throw an error when no type or id" do
      bad_type = random_string
      bad_type.should_not == "song"
      bad_type.should_not == "user"
      
      lambda{ Syncer.perform({:type => bad_type, :id => id}) }.should raise_error(ArgumentError, "Type must be 'user' or 'song', not '#{bad_type}'")
      lambda{ Syncer.perform({:type => type}) }.should raise_error(ArgumentError, /Type and id must be defined/)
      lambda{ Syncer.perform({:id => id}) }.should raise_error(ArgumentError, /Type and id must be defined/)
    end
    
    it "should handle hype machine exceptions" do
      
    end
    
  end

end
