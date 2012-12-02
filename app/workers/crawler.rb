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
    
    # Core logic
    # if unsynced
      # run sync with self (and self's callback) as callback
    # else 
      # if every children is crawled
        # set crawl status
        # run callback
      # else
        # run crawl on out-of-date children
        # with self (and self's callback) as a callback
      # end
    # end
    
    # Force logic : beware infite loops
    
    if self.object.crawled?(depth)
      self.callback.call
      return
    end
    
    if unsynced?
      self.object.sync!(:callback => self.to_callback, :force => self.force)
      return
      
    else
      if depth == 0 || children.map{|child|child.crawled?(depth-1)}.sum
        self.object.crawled_at[depth] = Time.now #crawled_at[0] should == synced_at
        self.callback.call
        return
      else
        uncrawled_children.each do |child|
          child.crawl!(:callback => self.to_callback, :force => self.force, :depth => depth - 1)
        end
        return
      end
    end

    # TODO : crawl status array, depending on depth
  end

end