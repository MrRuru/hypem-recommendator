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
  
    # Check that we are synced. Transfer to syncer if not the case
    if !self.object.synced?
      self.object.sync!(:callback => self.to_callback)
      return
    end


    # Check that our children are synced. Transfer to the syncer if not the case
    if !self.object.children_synced?
      self.object.sync_children!(:callback => self.to_callback)
      return
    end


    # Then check if we are crawled for this depth. If yes, then we can skip this next step
    # and directly forward to our callback.
    if !self.object.crawled?(depth)

      # Now there are 3 possible cases :
      # - the depth is 0 : there are no children to crawl, so we can safely set our crawl timestamp and continue
      # - all our children are crawled for depth - 1 : it means that we are crawled for depth and that we can also set our timestamp and continue
      # - some of our children are still uncrawled for depth - 1 : we call them with ourself as the callback and EXIT
      uncrawled_children = (depth > 0) ? self.children.select{|child| !child.crawled?(depth-1)} : []

      if !uncrawled_children.empty?
        uncrawled_children.each do |child|
          child.crawl! :callback => self.to_callback, :depth => (depth - 1)
        end

        return # exit this all task, we will be back since we included ourselves as a callback
      
      else
        # Set our timestamp
        self.object.set_crawled_at(depth)
      end

    end
           
    # Everything went ok (either already crawled, or children already ok) : forward to the callback
    if self.callback
      self.callback.call   
    end
  end        

end