require 'spec_helper'

describe Syncer do
  
  # let(:id) {random_string}
  let(:id){ "1mahm" }
  let(:bad_id){ "badid" }
  let(:type) {"song"}
  
  describe "with an unsynced songs" do

    let(:artist){random_string}
    let(:title){random_string}
    let(:user_names){random_array}

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

      @song.hypem.favorites.stub(:users).and_return([])
      @song.hypem.favorites.should_receive(:users)

      @song.hypem.stub(:artist).and_return(random_string)
      @song.hypem.stub(:title).and_return(random_string)

      Syncer.perform({:type => type, :id => id})
    end
      
      
    it "should process the hypem data" do      
      @song.stub_chain(:hypem, :get)
      @song.stub_chain(:hypem, :artist).and_return(artist)
      @song.stub_chain(:hypem, :title).and_return(title)
        
      @song
        .stub_chain(:hypem, :favorites, :get, :users, :map)
        .and_return( user_names )

      Syncer.perform({:type => type, :id => id})
      
      @song.artist.should == artist      
      @song.title.should == title
      @song.synced_at.should_not be_nil
      @song.synced?.should be_true

      @song.favorites.smembers.should =~ user_names
    end
        
  end
  

  # describe "with a synced song" do
  # 
  # end
  # 
  # 
  
  describe "callbacks" do
    
    let(:callback_type) { Crawler }
    let(:callback_args) { { :type => type, :id => id, :depth => 1 } }
    
    it "should run the callback after successful execution" do

      # Fetching the last request date, so the timestamp in the request match,
      # and VCR doesn't try to fetch a new episode
      # When fixture needing to be recorded, using current time
      if VCR::Cassette.new("track").serializable_hash.values.first.empty?
        @last_request_time = Time.now
      else
        @last_request_time = VCR::Cassette.new("track").serializable_hash.values.first.last["recorded_at"]
      end
      
      Timecop.freeze(@last_request_time) do

        VCR.use_cassette("track") do
          Syncer.perform({:type => type, :id => id, :callback => {:type => callback_type, :args => callback_args}})
        end
        
      end
      
      Crawler.should have_queue_size_of(1)
      Crawler.should have_queued(callback_args)
    end
    
    # Maybe to spec only for crawler / recommander
    it "should forward its callback to children on failed execution" do
      pending "add specs"
    end
  end
  

  describe "unique queues" do
    pending "add spec"

    describe "song syncing" do
      it "should sleep after syncing a song" do
        
        pending "add spec"
        
      end
    end
  end
  
  

  describe "error cases" do
  
    it "should throw an error when no type or id" do
      bad_type = random_string
      bad_type.should_not == "song"
      bad_type.should_not == "user"
      
      lambda{ Syncer.perform({:type => bad_type, "id" => id}) }.should raise_error(ArgumentError, "Type must be 'user' or 'song', not '#{bad_type}'")
      lambda{ Syncer.perform({:type => type}) }.should raise_error(ArgumentError, /Type and id must be defined/)
      lambda{ Syncer.perform({:id => id}) }.should raise_error(ArgumentError, /Type and id must be defined/)
    end
    
    # Note that in that case we need a cassette with a 403 response from the hypem favorites fetch.
    # If the cassette .yml goes missing, it can be tested on a good one with replacing these :
    #   response:
    #     status:
    #       code: 200
    #       message: OK
    # with these :
    #   response:
    #     status:
    #       code: 403
    #       message: Forbidden

    it "should handle hype machine authorization errors" do
      
      # Fetching the last request date, so the timestamp in the request match,
      # and VCR doesn't try to fetch a new episode
      # When fixture needing to be recorded, using current time
      if VCR::Cassette.new("refused_request").serializable_hash.values.first.empty?
        @last_request_time = Time.now
      else
        @last_request_time = VCR::Cassette.new("refused_request").serializable_hash.values.first.last["recorded_at"]
      end

      # There should be a 10 seconds sleep when being forbidden to access a favorites page
      Syncer.stub!(:sleep)
      Syncer.should_receive(:sleep).with(10)
      
      Timecop.freeze(@last_request_time) do

        VCR.use_cassette("refused_request") do
          Syncer.perform({:type => type, :id => id})
        end
        
      end
      
      # The job should be re-enqueued at the end of the sleep      
      Syncer.should have_queue_size_of(1)
      Syncer.should have_queued({:type => type, :id => id})
      
    end
    
    it "should handle bad requests" do
      
      # Fetching the last request date, so the timestamp in the request match,
      # and VCR doesn't try to fetch a new episode
      # When fixture needing to be recorded, using current time
      if VCR::Cassette.new("bad_request").serializable_hash.values.first.empty?
        @last_request_time = Time.now
      else
        @last_request_time = VCR::Cassette.new("bad_request").serializable_hash.values.first.last["recorded_at"]
      end
      
      Timecop.freeze(@last_request_time) do

        VCR.use_cassette("bad_request") do
          lambda{ Syncer.perform({:type => type, :id => bad_id}) }.should raise_error(ArgumentError, /Error syncing song #{bad_id}/)
        end
        
      end
      
    end
    
  end

end
