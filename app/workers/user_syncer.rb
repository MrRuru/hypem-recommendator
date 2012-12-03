class UserSyncer < Syncer

  @queue = :syncing

  def type
    "user"
  end

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
  end
  
  # Fetch or not?
  def perform?
    !user.synced?
  end

end
