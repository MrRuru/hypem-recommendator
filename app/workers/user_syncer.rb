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
  def fetch_from_soundcloud
    logger.info "Syncing user #{@id}"
  
    user.sync_from_soundcloud!
    user.synced_at = Time.now

    # Sleeping a bit to not overcharge the queue
    Kernel.sleep(SLEEP_FOR_USERS)    
  end
  
  # Fetch or not?
  def perform?
    !user.synced?
  end

end
