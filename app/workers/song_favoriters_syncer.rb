class SongFavoritersSyncer < Syncer

  @queue = :syncing
  
  def type
    "song_favoriters"
  end

  # Time to wait between song syncings, to not charge the api
  SLEEP_FOR_SONG_FAVORITERS = 15

  private

  # Song model accessor
  def song
    Song.new(id)
  end

  # Performer
  def fetch_from_soundcloud
    logger.info "Syncing song #{id} favoriters"

    # Fetching the data from souncloud
    sc_data = SoundcloudClient.new.track_favoriters(id)

    # For each, creating the user and setting its synced_at timestamp
    sc_data.each do |user_sc_data|
      user = User.new(user_sc_data[:id])
      user.set_attributes(user_sc_data)
      user.synced_at = Time.now
    end

    # Saving the favorites
    throw "TODO"

    # Setting the children_synced_at timestamp
    song.children_synced_at = Time.now

    # Sleeping a bit to not overcharge the queue
    Kernel.sleep(SLEEP_FOR_SONG_FAVORITERS)    
  end
  
  # Checking if fetching must be done
  def perform?
    !song.children_synced?
  end
          

end