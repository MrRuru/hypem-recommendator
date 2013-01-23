class UserFavoritesSyncer < Syncer

  @queue = :syncing
  
  def type
    "user_favorites"
  end

  # Time to wait between song syncings, to not charge the api
  SLEEP_FOR_USER_FAVORITES = 15

  private

  # Song model accessor
  def user
    User.new(id)
  end

  # Performer
  def fetch_from_soundcloud
    logger.info "Syncing user #{id} favorites"

    # Fetching the data from souncloud
    sc_data = SoundcloudClient.new.user_favorites(id)

    # For each, creating the user and setting its synced_at timestamp
    sc_data.each do |song_sc_data|
      song = Song.new(song_sc_data[:id])
      song.set_attributes(song_sc_data)

      throw "HANDLE THE UPLOADER"

      song.synced_at = Time.now
    end

    # Saving the favorites
    throw "TODO"

    # Setting the children_synced_at timestamp
    user.children_synced_at = Time.now

    # Sleeping a bit to not overcharge the queue
    Kernel.sleep(SLEEP_FOR_USER_FAVORITES)    
  end
  
  # Checking if fetching must be done
  def perform?
    !user.children_synced?
  end
          

end