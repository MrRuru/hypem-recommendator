class UserSyncer < Syncer

  @queue = :syncing

  def type
    "user"
  end

  # To not overcharge the API
  SLEEP_FOR_USERS = 15

  # Song model accessor
  def user
    User.new(id)
  end

  # Performer
  def fetch_from_hypem
    logger.info "Syncing user #{id}"
  
    hypem = Hypem.user(@id)
    song_ids = hypem.loved_playlist.get.tracks.map{|song|song.media_id}
  
    user.playlist.sadd(song_ids)
    user.synced_at = Time.now

    # Sleeping a bit to not overcharge the queue
    Kernel.sleep(SLEEP_FOR_USERS)    
  end
  
  # Fetch or not?
  def perform?
    !user.synced?
  end

end
