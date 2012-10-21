class Syncer
  include Resque::Plugins::UniqueJob

  @queue = :syncing

  def self.logger
    @logger ||= Logger.new('log/syncer.log')
  end
      

  def self.perform(type, id)
    
    if type == "song"
      
      logger.info "Syncing song #{id}"
      
      song = Song.new(id)

      begin
        song.hypem.get
        user_ids = song.hypem.favorites.get.users.map{|user|user.name}
      rescue => e
        logger.error "Error syncing song #{id} : #{e}"
        return
      end
      
      song.artist = song.hypem.artist
      song.title = song.hypem.title
      song.favorites.sadd(user_ids)
      song.synced_at = Time.now
    
    elsif type == "user"
      
      logger.info "Syncing user #{id}"

      user = User.new(id)

      begin
        song_ids = user.hypem.loved_playlist.get.tracks.map{|song|song.media_id}
      rescue => e
        logger.error "Error syncing user #{id} : #{e}"
        return
      end

      user.playlist.sadd(song_ids)
      user.synced_at = Time.now
    end
      
  end
  
end