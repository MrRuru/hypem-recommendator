require 'spec_helper'

describe SongSyncer do
  
  pending "redo for soundcloud"

  # # let(:id) {random_string}
  # let(:id){ "1mahm" }
  # let(:bad_id){ "badid" }
  # let(:type) {"song"}
  # let(:callback_type) { "SongCrawler" }
  # let(:callback_args) { { :id => id, :depth => 1 } }    
  #   
  # # Calling a spec associated to a stored cassette : fetch it or timefreeze it if present
  # def timed_vcr_cassette(cassette_name, &block)
  #   if VCR::Cassette.new(cassette_name).serializable_hash.values.first.empty?
  #     @last_request_time = Time.now
  #   else
  #     @last_request_time = VCR::Cassette.new(cassette_name).serializable_hash.values.first.last["recorded_at"]
  #   end
  #   
  #   Timecop.freeze(@last_request_time) do
  #     VCR.use_cassette(cassette_name) do
  #       yield
  #     end      
  #   end
  # end
  #   
  # describe "with an unsynced songs" do
  #     
  #   it "should sync with hypem data" do      
  #     @song = Song.new(id)
  #     Song.stub(:new).and_return(@song)
  # 
  #     timed_vcr_cassette("track") do
  #       SongSyncer.perform({:id => id})
  #     end
  #     
  #     @song.artist.should == "Soko"      
  #     @song.title.should == "I'll Kill Her (Hannes Fischer Remix)"
  #     @song.synced_at.to_s.should == "2012-11-15 01:45:12 +0100"
  # 
  #     @song.favorites.smembers.should =~ ["ElectricEclectic", "JVArgas", "JanaVGK", "Kamuy", "Piiiem", "StrangeMachine", "amygo", "artorius", "bws81", "cheriths", "evgenia", "hotshowers", "itsbhaji", "missvu", "mrtz", "sdubbs", "tangowithlions", "tobi_dragon", "travelling", "zuccakathi"]
  #   end        
  # end
  # 
  # 
  # describe "already synced data" do
  #   
  #   it "should not try to sync the data" do
  #     synced_song = Song.new(id)
  #     synced_song.synced_at = Time.now
  #     synced_song.synced?.should be_true
  #     
  #     syncer = SongSyncer.new({:id => id})
  #     SongSyncer.stub(:new).and_return(syncer)
  # 
  #     syncer.should_not_receive (:fetch_from_hypem)
  #     
  #     SongSyncer.perform({:id => id})
  #   end
  #   
  #   it "should force the syncing if told to" do
  #     synced_song = Song.new(id)
  #     synced_song.synced_at = Time.now
  #     synced_song.synced?.should be_true
  #     
  #     syncer = SongSyncer.new({:id => id, :force => true})
  #     SongSyncer.stub(:new).and_return(syncer)
  # 
  #     syncer.stub!(:fetch_from_hypem)
  #     syncer.should_receive (:fetch_from_hypem)
  #     
  #     SongSyncer.perform({:id => id, :force => true})
  #   end
  #   
  #   it "should still call the attached callback" do
  #     synced_song = Song.new(id)
  #     synced_song.synced_at = Time.now
  #     synced_song.synced?.should be_true
  # 
  #     syncer = SongSyncer.new({:id => id, :callback => {:type => callback_type, :args => callback_args}})
  #     SongSyncer.stub(:new).and_return(syncer)
  #     
  #     syncer.callback.should_not be_nil
  #     syncer.callback.should_receive(:call)
  #     
  #     SongSyncer.perform({:id => id, :callback => {:type => callback_type, :args => callback_args}})
  #   end
  # 
  # end
  # 
  # describe "callbacks" do
  #   
  #   it "should run the callback after successful execution" do
  #     timed_vcr_cassette("track") do
  #       SongSyncer.perform({:id => id, :callback => {:type => callback_type, :args => callback_args}})
  #     end
  #     
  #     Crawler.should have_queue_size_of(1)
  #     Crawler.should have_queued(callback_args)
  #   end
  # 
  # end
  # 
  # 
  # describe "unique queues" do
  # 
  #   it "should use unique queues" do
  #     SongSyncer.should include Resque::Plugins::UniqueJob
  #   end
  #   
  #   describe "song syncing" do
  #     it "should sleep after syncing a song" do
  #       Kernel.stub!(:sleep)
  #       Kernel.should_receive(:sleep).with(15)
  # 
  #       timed_vcr_cassette("track") do
  #         SongSyncer.perform({:id => id})
  #       end
  #     end
  #   end
  # end
  # 
  # 
  # 
  # describe "error cases" do
  # 
  #   it "should throw an error when no id" do      
  #     lambda{ SongSyncer.perform({}) }.should raise_error(ArgumentError, /ID must be defined/)
  #   end
  #   
  #   # Note that in that case we need a cassette with a 403 response from the hypem favorites fetch.
  #   # If the cassette .yml goes missing, it can be tested on a good one with replacing these :
  #   #   response:
  #   #     status:
  #   #       code: 200
  #   #       message: OK
  #   # with these :
  #   #   response:
  #   #     status:
  #   #       code: 403
  #   #       message: Forbidden
  # 
  #   it "should handle hype machine authorization errors" do
  #     # There should be a 10 seconds sleep when being forbidden to access a favorites page
  #     syncer = SongSyncer.new({:id => id})
  #     syncer.should_receive :sleep_and_reenqueue!
  # 
  #     timed_vcr_cassette("refused_request") do
  #       syncer.perform
  #     end
  #   end    
  #   
  #   it "should handle bad requests" do      
  #     timed_vcr_cassette("bad_request") do
  #       lambda{ SongSyncer.perform({:id => bad_id}) }.should raise_error(ArgumentError, /Error syncing song #{bad_id}/)
  #     end      
  #   end
  #   
  # end
  # 
  # describe "#sleep_and_reenqueue!" do
  #   it "should fetch the correct arguments" do
  #     syncer = SongSyncer.new({:id => id})
  #     syncer.send(:opts).should == {:id => id}
  #     
  #     syncer = SongSyncer.new({:id => id, :force => true})
  #     syncer.send(:opts).should == {:id => id, :force => true}      
  # 
  #     syncer = SongSyncer.new({:id => id, :callback => {:type => callback_type, :args => callback_args}})
  #     syncer.send(:opts).should == {:id => id, :callback => {:type => callback_type, :args => callback_args}}  
  #   end
  # 
  #   it "should work" do
  #     syncer = SongSyncer.new({:id => id})
  # 
  #     Kernel.stub!(:sleep)
  #     Kernel.should_receive(:sleep).with(1000)
  #     
  #     syncer.send(:sleep_and_reenqueue!)
  #     SongSyncer.should have_queue_size_of(1)
  #     SongSyncer.should have_queued({:id => id})
  #   end
  #   
  # end

end
