class Syncer < BaseWorker
  @queue = :syncing

  # Time to wait after a 403 response, sign of too many requests
  SLEEP_AFTER_403 = 10

  # Performing logic
  def perform
    begin
      
      # Fetch the data from hypem
      if perform? || self.force
        fetch_from_hypem
      end
      
      # Call its callback if present
      if callback
        callback.call
      end

    # Handle 403 errors
    rescue => e
      # Re-enqueue self when 403 response
      if e.message.match /Net::HTTPForbidden/
        sleep_and_reenqueue!
        return
      else
        raise_error ArgumentError, "Error syncing #{type} #{id} : #{e}"
      end
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
  def fetch_from_hypem
    throw "Cannot fetch untyped data. Please precise wether a song or a user should be fetched"
  end
  
  
end