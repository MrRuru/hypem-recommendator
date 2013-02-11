class SongSyncer < Syncer
  
  @queue = :syncing
  
  def type
    "song"
  end
  
  # Time to wait between song syncings, to not charge the hypem
  SLEEP_FOR_SONGS = 15

  private

  # Song model accessor
  def song
    Song.new(id)
  end

  # Performer
  def fetch_from_soundcloud
    logger.info "Syncing song #{id}"

    # Fetching the data from souncloud
    sc_data = SoundcloudClient.new.track(id)

    # Assigning it to the song
    song.set_attributes(sc_data)

    # If no uploader set, sync it and callback to itself
    unless song.uploader.synced?
      song.uploader.sync!(:callback => self.to_callback)
      return
    end
    # Else continue

    # Updating the synced_at timestamp
    song.synced_at = Time.now

    # Sleeping a bit to not overcharge the queue
    Kernel.sleep(SLEEP_FOR_SONGS)    
  end
  
  # Checking if fetching must be done
  def perform?
    !song.synced?
  end
          
end