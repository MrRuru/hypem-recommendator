class SongSyncer < Syncer
  
  @queue = :syncing
  
  def type
    "song"
  end
  
  # Time to wait between song syncings, to not charge the hypem
  SLEEP_FOR_SONGS = 1

  private

  # Song model accessor
  def song
    Song.new(id)
  end

  # Performer
  def fetch_from_hypem
    logger.info "Syncing song #{id}"
   
    # Fetching the hypem data
    hypem = Hypem.track(id)
    hypem.get
    user_ids = hypem.favorites.get.users.map{|user|user.name}
    
    # Storing it
    song.artist = hypem.artist
    song.title = hypem.title
    song.favorites.sadd(user_ids) unless user_ids.blank?
    song.synced_at = Time.now                

    # Sleeping a bit to not overcharge the queue
    Kernel.sleep(SLEEP_FOR_SONGS)    
  end
  
  # Checking if fetching must be done
  def perform?
    !song.synced?
  end
          
end