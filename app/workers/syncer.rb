class Syncer < BaseWorker

  @queue = :syncing

  # Time to wait after a 403 response, sign of too many requests
  SLEEP_AFTER_403 = 1000

  # Performing logic
  def perform

    # Fetch the data from hypem
    if perform? || self.force

      begin
        fetch_from_soundcloud
      rescue => e
        # Re-enqueue self when 403 response
        if e.message.match /403/
          sleep_and_reenqueue!
          return
        else
          raise_error ArgumentError, "Error syncing #{type} #{id} : #{e}"
        end
      end

    end
            
    # Call its callback if present and everything went fine
    if callback
      callback.call
    end

  end        

  protected

  # Re-enqueuing on bad response
  def sleep_and_reenqueue!
    logger.warn "403 when fetching #{type} #{id}, sleeping a bit in the queue"

    Kernel.sleep(SLEEP_AFTER_403)

    Resque.enqueue(self.class, self.opts)
  end
  
  # Actual hypem fetching, defined in subclasses
  def fetch_from_soundcloud
    throw "Cannot fetch untyped data. Please precise wether a song or a user should be fetched"
  end
  
  
end