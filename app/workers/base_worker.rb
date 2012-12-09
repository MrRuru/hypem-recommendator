class BaseWorker
  include Resque::Plugins::UniqueJob

  attr_accessor :logger, :id, :callback, :force, :opts

  # Constructor
  def initialize(args)
    # Saving the arguments for re-enqueuing
    self.opts = args.symbolize_keys

    # Setting up the logger
    self.logger = Logger.new('log/syncer.log')

    # Validating attributes
    unless opts[:id]
      raise_error(ArgumentError, "ID must be defined")
    end

    self.id = opts[:id]
    
    # Setting up callback
    if opts[:callback]
      callback_opts = opts[:callback].symbolize_keys
      callback_type = callback_opts[:type].constantize
      callback_args = callback_opts[:args].symbolize_keys
      self.callback = Proc.new {
        Resque.enqueue(callback_type, callback_args)
      }      
    end
    
    # Setting up the forced syncing flag
    self.force = !!opts[:force]
  end
  
  # Core logic
  def self.perform(args = {})
    new(args).perform
  end

  # Error logger/raiser
  def raise_error(type, message)
    self.logger.error(message)
    raise type, message
  end
  
  # Conversion to callback hash
  def to_callback
    {:type => self.class.to_s, :args => self.opts}
  end
  
  def perform
    throw "please define this in subclasses!"
  end
  
end  
  