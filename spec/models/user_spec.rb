require 'spec_helper'

describe User do

  let(:id) {random_string}
  # let(:artist) {"Dj Awesome"}
  # let(:title) {"Hypermegamix"}

  before :each do
    REDIS.flushall
    ResqueSpec.reset!
  end

  
  describe "#syncing" do
    
    it_behaves_like "a syncable" do
      let(:syncable){ User.new(id) }
      
      let(:expiration){ 1.week }
      let(:syncer){ UserSyncer }
    end

  end
  
    
  describe "crawling" do
    
    it_behaves_like "a crawlable" do
      let(:crawlable){ User.new(id) }

      let(:expiration){ 1.week }
      let(:crawler){ UserCrawler }
      let(:default_depth){ 3 }
    end      
    
  end  
    
end
