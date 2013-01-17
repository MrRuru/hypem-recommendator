require 'spec_helper'

describe SoundcloudClient do

  let(:client){ SoundcloudClient.new }
  let(:default_limit){ SoundcloudClient::DEFAULT_LIMIT }

  before(:each) do
    # A mock for the actual souncloud api client
    @api = mock(Soundcloud).as_null_object
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


  describe "#user" do
    let(:user_id){123456}

    it "should fetch the user and its favorites" do
      @api.should_receive("get").with("/users/#{user_id}")
      @api.should_receive("get").with("/users/#{user_id}/favorites", {:limit => default_limit, :offset => 0})

      client.user(user_id)
    end


    it "should handle pages properly" do
      @api.should_receive("get").with("/users/#{user_id}")
      @api.should_receive("get").with("/users/#{user_id}/favorites", {:limit => 200, :offset => 0})
      @api.should_receive("get").with("/users/#{user_id}/favorites", {:limit => 200, :offset => 200})
      @api.should_receive("get").with("/users/#{user_id}/favorites", {:limit => 100, :offset => 400})

      client.user(user_id, :limit => 500)
    end
  end

  describe "#track" do
    let(:track_id){123456}

    it "should fetch the track and its favoriters" do
      @api.should_receive("get").with("/tracks/#{track_id}")
      @api.should_receive("get").with("/tracks/#{track_id}/favoriters", {:limit => default_limit, :offset => 0})

      client.track(track_id)
    end


    it "should handle pages properly" do
      @api.should_receive("get").with("/tracks/#{track_id}")
      @api.should_receive("get").with("/tracks/#{track_id}/favoriters", {:limit => 200, :offset => 0})
      @api.should_receive("get").with("/tracks/#{track_id}/favoriters", {:limit => 100, :offset => 200})

      client.track(track_id, :limit => 300)
    end
  end

end
