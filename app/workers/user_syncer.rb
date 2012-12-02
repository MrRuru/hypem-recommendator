class UserSyncer < Syncer

  @queue = :syncing

  # Constructor
  def initialize(args)
    self.type = :user
    super
  end

  # Song model accessor
  def user
    User.new(id)
  end

  # Performer
  def fetch_from_hypem
    logger.info "Syncing user #{id}"
  
    song_ids = user.hypem.loved_playlist.get.tracks.map{|song|song.media_id}
  
    user.playlist.sadd(song_ids)
    user.synced_at = Time.now
  end
  
  # Fetch or not?
  def perform?
    !user.synced?
  end

end
