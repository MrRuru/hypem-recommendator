class Syncer
  include Resque::Plugins::UniqueJob

  @queue = :syncing

  # Time to wait after a 403 response, sign of too many requests
  SLEEP_AFTER_403 = 10

  attr_accessor :logger, :type, :id, :callback, :force_syncing

  # Constructor
  def initialize(args)
    opts = args.symbolize_keys
    self.logger = Logger.new('log/syncer.log')

    # Validating attributes
    unless opts[:id]
      raise_error(ArgumentError, "ID must be defined")
    end

    self.id = opts[:id]
    
    # Setting up callback
    if opts[:callback]
      callback_opts = opts[:callback].symbolize_keys
      callback_type = callback_opts[:type]
      callback_args = callback_opts[:args].symbolize_keys
      self.callback = Proc.new {
        Resque.enqueue(callback_type, callback_args)
      }      
    end
    
    # Setting up the forced syncing flag
    self.force_syncing = !!opts[:force_syncing]
  end

  # Core logic
  def self.perform(args = {})
    new(args).perform
  end

  def perform
    begin
      
      # Fetch the data from hypem
      if fetch? || self.force_syncing
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

  # Arguments accessor (for re-enqueuing)
  def arguments
    Hash[*[:id, :callback, :force_syncing]
      .select{|argument| !!self.send(argument)}
      .map{|argument| [argument, self.send(argument)]}  
      .flatten
    ]
  end

  # Error logger/raiser
  def raise_error(type, message)
    self.logger.error(message)
    raise type, message
  end
  
  # Re-enqueuing on bad response
  def sleep_and_reenqueue!
    logger.warn "403 when fetching #{type} #{id}, sleeping a bit in the queue"

    Kernel.sleep(SLEEP_AFTER_403)

    Resque.enqueue(self.class, self.arguments)
  end
  
  # Actual hypem fetching, defined in subclasses
  def fetch_from_hypem
    throw "Cannot fetch untyped data. Please precise wether a song or a user should be fetched"
  end
  
  
end