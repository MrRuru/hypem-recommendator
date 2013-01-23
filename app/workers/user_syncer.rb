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
    logger.info "Syncing user #{id}"

    # Fetching the data from soundcloud
    sc_data = SoundcloudClient.new.user(id)

    # Setting it on the user
    user.set_attributes(sc_data)
    # user.name = sc_data[:name]
    # user.url = sc_data[:url]
    # user.favorites_count = sc_data[:favorites_count]

    # Updating the synced_at timestamp
    user.synced_at = Time.now

    # Sleeping a bit to not overcharge the queue
    Kernel.sleep(SLEEP_FOR_USERS)    
  end
  
  # Fetch or not?
  def perform?
    !user.synced?
  end

end
