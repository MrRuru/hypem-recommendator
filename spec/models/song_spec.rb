require 'spec_helper'

describe Song do

  let(:id) {random_string}
  # let(:artist) {"Dj Awesome"}
  # let(:title) {"Hypermegamix"}

  before :each do
    REDIS.flushall
    ResqueSpec.reset!
  end

  
  describe "#syncing" do
    
    it_behaves_like "a syncable" do
      let(:syncable){ Song.new(id) }
      
      let(:expiration){ 1.day }
      let(:syncer){ SongSyncer }
    end

  end
  
    
  describe "crawling" do
    
    it_behaves_like "a crawlable" do
      let(:crawlable){ Song.new(id) }

      let(:expiration){ 1.day }
      let(:crawler){ SongCrawler }
      let(:default_depth){ 2 }
    end      
    
  end  
    
end
