class Syncer
  include Resque::Plugins::UniqueJob

  # Time to wait between song syncings, to not charge the hypem
  SLEEP_FOR_SONGS = 1

  # Time to wait after a 403 response, sign of too many requests
  SLEEP_AFTER_403 = 10

  def self.raise_error(type, message)
    logger.error(message)
    raise type, message
  end

  @queue = :syncing

  def self.logger
    @logger ||= Logger.new('log/syncer.log')
  end
      

  def self.perform(args = {})
    
    opts = args.symbolize_keys
    
    unless opts[:type] && opts[:id]
      raise_error(ArgumentError, "Type and id must be defined")
    end

    type = opts[:type].to_sym
    id = opts[:id]
    
    if opts[:callback]
      callback_opts = opts[:callback].symbolize_keys
      callback_type = callback_opts[:type]
      callback_args = callback_opts[:args].symbolize_keys
      callback = Proc.new {
        Resque.enqueue(callback_type, callback_args)
      }      
    end


    unless [:song, :user].include?(type)
      raise_error(ArgumentError, "Type must be 'user' or 'song', not '#{type}'")
    end
      

    if type == :song
            
      logger.info "Syncing song #{id}"
      
      song = Song.new(id)

      begin
        song.hypem.get
        
        begin
          # Handling 403 HTTP Forbidden responses with sleeping a bit and re-enqueuing the job
          # Since there is only one song queue, it will be occupied during the sleep
          user_ids = song.hypem.favorites.get.users.map{|user|user.name}
        rescue => e
          # The other exceptions are forwarded
          if e.message.match /Net::HTTPForbidden/

            logger.warn "403 when fetching song #{id}, sleeping a bit in the queue"

            sleep(SLEEP_AFTER_403)
            Resque.enqueue(Syncer, args)
            return
          else
            throw e
          end
        end
        
      rescue => e
        raise_error ArgumentError, "Error syncing song #{id} : #{e}"
      end
      
      song.artist = song.hypem.artist
      song.title = song.hypem.title
      song.favorites.sadd(user_ids) unless user_ids.blank?
      song.synced_at = Time.now
      
      sleep(SLEEP_FOR_SONGS)
    
    elsif type == :user
      
      logger.info "Syncing user #{id}"

      user = User.new(id)

      begin
        song_ids = user.hypem.loved_playlist.get.tracks.map{|song|song.media_id}
      rescue => e
        raise_error ArgumentError, "Error syncing user #{id} : #{e}"
      end

      user.playlist.sadd(song_ids)
      user.synced_at = Time.now
    end
    
    # Enqueuing the callback if there is one
    if callback
      callback.call
    end
      
  end
  
end