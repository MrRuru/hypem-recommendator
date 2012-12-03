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
  
    # Force logic : beware infite loops
    
    # TODO
    # Crawled status array by depth (overriding lower depths)
    # Crawled(0) = synced ; crawl!(0) = sync!

    
    # If not already crawled for this depth
    if !self.object.crawled?(depth)

      # Sync it and quit before crawling its children
      if !self.object.synced?
        
        self.object.sync!(:callback => self.to_callback)
        return
      
      else
        
        # If there remain uncrawled children ,crawl them and quit
        uncrawled_children = self.object.children.select{|child| !child.crawled?(depth-1)}

        if !uncrawled_children.empty?
          uncrawled_children.each do |child|
            child.crawl! :callback => self.to_callback, :depth => (depth - 1)
          end
          return #does it exit all of the task ??
        
        # Otherwise we can officially set the crawl on the current element
        else
          self.crawled_at[depth] = Time.now
        end
      end
    end
           
    # Everything went ok (either already crawled, or children already ok) : forward to the callback
    if self.callback
      self.callback.call   
    end
  end        

end