require 'spec_helper'

describe SongSyncer do
  
  # let(:id) {random_string}
  let(:id){ "1mahm" }
  let(:bad_id){ "badid" }
  let(:type) {"song"}
    
  # Calling a spec associated to a stored cassette : fetch it or timefreeze it if present
  def timed_vcr_cassette(cassette_name, &block)
    if VCR::Cassette.new(cassette_name).serializable_hash.values.first.empty?
      @last_request_time = Time.now
    else
      @last_request_time = VCR::Cassette.new(cassette_name).serializable_hash.values.first.last["recorded_at"]
    end
    
    Timecop.freeze(@last_request_time) do
      VCR.use_cassette(cassette_name) do
        yield
      end      
    end
  end
    
  describe "with an unsynced songs" do

    let(:artist){random_string}
    let(:title){random_string}
    let(:user_names){random_array}

    before(:each) do
      # Control what's happening to the song in the syncer
      @song = Song.new(id)
      Song.stub(:new).and_return(@song)
      
      # @syncer = SongSyncer.new({:id => id})
      # SongSyncer.stub(:new).and_return(@syncer)
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

      SongSyncer.perform({:id => id})
    end
      
      
    it "should process the hypem data" do      
      @song.stub_chain(:hypem, :get)
      @song.stub_chain(:hypem, :artist).and_return(artist)
      @song.stub_chain(:hypem, :title).and_return(title)
        
      @song
        .stub_chain(:hypem, :favorites, :get, :users, :map)
        .and_return( user_names )

      SongSyncer.perform({:id => id})
      
      @song.artist.should == artist      
      @song.title.should == title
      @song.synced_at.should_not be_nil
      @song.synced?.should be_true

      @song.favorites.smembers.should =~ user_names
    end        
  end
  
  
  describe "already synced data" do
    
    it "should not try to sync the data" do
      song = Song.new(id)
      song.synced_at = Time.now
      song.synced?.should be_true
      
      syncer = SongSyncer.new({:id => id})
      SongSyncer.stub(:new).and_return(syncer)

      syncer.should_not_receive (:fetch_from_hypem)
      
      SongSyncer.perform({:id => id})
    end
    
    it "should force the syncing if told to" do
      pending "todo"
    end
    
    it "should forward the forced syncing flag" do        
      pending "todo on crawler and/or recommander maybe (?)"
    end
    
    it "should forward directly to the attached callback" do
      pending "todo"      
    end

  end

  describe "callbacks" do
    
    let(:callback_type) { Crawler }
    let(:callback_args) { { :type => type, :id => id, :depth => 1 } }
    
    it "should run the callback after successful execution" do
      timed_vcr_cassette("track") do
        SongSyncer.perform({:id => id, :callback => {:type => callback_type, :args => callback_args}})
      end
      
      Crawler.should have_queue_size_of(1)
      Crawler.should have_queued(callback_args)
    end
    
    # Maybe to spec only for crawler / recommander
    it "should forward its callback to children on failed execution" do
      pending "maybe only for crawler and/or recommander"      
    end
  end
  

  describe "unique queues" do

    it "should use unique queues" do
      SongSyncer.should include Resque::Plugins::UniqueJob
    end
    
    describe "song syncing" do
      it "should sleep after syncing a song" do
        Kernel.stub!(:sleep)
        Kernel.should_receive(:sleep).with(1)

        timed_vcr_cassette("track") do
          SongSyncer.perform({:id => id})
        end
      end
    end
  end
  
  

  describe "error cases" do
  
    it "should throw an error when no id" do      
      lambda{ SongSyncer.perform({}) }.should raise_error(ArgumentError, /ID must be defined/)
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
      # There should be a 10 seconds sleep when being forbidden to access a favorites page
      syncer = SongSyncer.new({:id => id})
      syncer.should_receive :sleep_and_reenqueue!

      timed_vcr_cassette("refused_request") do
        syncer.perform
      end
    end    
    
    it "should handle bad requests" do      
      timed_vcr_cassette("bad_request") do
        lambda{ SongSyncer.perform({:id => bad_id}) }.should raise_error(ArgumentError, /Error syncing song #{bad_id}/)
      end      
    end
    
  end

  describe "#sleep_and_reenqueue!" do
    it "should fetch the correct arguments" do
      syncer = SongSyncer.new({:id => id})
      syncer.send(:arguments).should == {:id => id}
      
      syncer = SongSyncer.new({:id => id, :force_syncing => true})
      syncer.send(:arguments).should == {:id => id, :force_syncing => true}      
    end

    it "should work" do
      syncer = SongSyncer.new({:id => id})

      Kernel.stub!(:sleep)
      Kernel.should_receive(:sleep).with(10)
      
      syncer.send(:sleep_and_reenqueue!)
      SongSyncer.should have_queue_size_of(1)
      SongSyncer.should have_queued({:id => id})
    end
    
  end

end
