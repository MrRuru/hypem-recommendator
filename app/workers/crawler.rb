class Crawler < BaseWorker
  @queue = :crawling

  attr_accessor :depth

  # Constructor
  def initialize(args)
    super
   
    unless opts[:depth]
      raise_error(ArgumentError, "Crawl depth must be defined")
    end

    self.depth = opts[:depth]
  end
  
  # Core logic
  def perform
    process_crawl

    if self.callback
      self.callback.call
    end
  end        

  protected

  def process_crawl
    throw "please call the crawl on a user or a song"
  end

end