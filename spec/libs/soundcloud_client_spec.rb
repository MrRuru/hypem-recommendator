require 'spec_helper'

describe SoundcloudClient do

  let(:client){ SoundcloudClient.new }

  before(:each) do
    # A mock for the actual souncloud api client
    @api = mock("new soundcloud api")
    Soundcloud.stub(:new).and_return(@api)
  end

  describe "#api" do

    it "should create an api wrapper if not existing" do
      Soundcloud.should_receive(:new)
      api = client.api
      api.should == @api
    end

    it "should check the expiration date if existing for each access" do
      client.api
      @api.should_receive(:expired?)
      client.api
    end

    it "should refresh itself if expired" do
      client.api
      @api.stub(:expired?).and_return(true)
      Soundcloud.should_receive(:new)
      client.api        
    end

  end


  describe "actions" do

  end


end
