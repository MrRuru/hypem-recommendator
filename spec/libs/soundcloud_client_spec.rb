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


  let(:user_id){123456}

  describe "#user" do
    let(:user_id){123456}

    it "should fetch the user" do
      @api.should_receive("get").with("/users/#{user_id}")

      client.user(user_id)
    end
  end

  describe "#user_favorites" do
    it "should fetch the user favorites" do
      @api.should_receive("get").with("/users/#{user_id}/favorites", {:limit => default_limit, :offset => 0})

      client.user_favorites(user_id)
    end


    it "should handle pages properly" do
      @api.should_receive("get").with("/users/#{user_id}/favorites", {:limit => 200, :offset => 0})
      @api.should_receive("get").with("/users/#{user_id}/favorites", {:limit => 200, :offset => 200})
      @api.should_receive("get").with("/users/#{user_id}/favorites", {:limit => 100, :offset => 400})

      client.user_favorites(user_id, :limit => 500)
    end
  end


  let(:track_id){123456}

  describe "#track" do

    it "should fetch the track" do
      @api.should_receive("get").with("/tracks/#{track_id}")

      client.track(track_id)
    end
  
  end

  describe "#track_favoriters" do

    it "should fetch the track favoriters" do
      @api.should_receive("get").with("/tracks/#{track_id}/favoriters", {:limit => default_limit, :offset => 0})

      client.track_favoriters(track_id)
    end

    it "should handle pages properly" do
      @api.should_receive("get").with("/tracks/#{track_id}/favoriters", {:limit => 200, :offset => 0})
      @api.should_receive("get").with("/tracks/#{track_id}/favoriters", {:limit => 100, :offset => 200})

      client.track_favoriters(track_id, :limit => 300)
    end
  end

end
