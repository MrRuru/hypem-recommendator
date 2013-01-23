module Crawlable
  
  def self.extended(base)
    base.instance_eval do 
      has_attributes :crawl_dates_serialized, # Array of crawl date by depth
                     :children_synced_at # Last children sync date
    end
  end

  def is_crawlable_with(opts)
    crawler = opts[:crawler]
    children_syncer = opts[:children_syncer]
    default_depth = opts[:default_depth]
    expiration = opts[:expiration]
    
    define_method :crawled? do |depth|
      !!crawl_dates[depth] && ( crawl_dates[depth] > ( Time.now - expiration ) )      
    end


    # TODO : make syncable handle this (?) => need to find a way to inject the namespace in base.extend()
    define_method :children_synced? do
      !!children_synced_at && ( Time.parse(children_synced_at) > (Time.now - expiration))
    end

    define_method :sync_children! do |opts = {}|
      Resque.enqueue(children_syncer, {"id" => self.id}.merge(opts))
    end
    # END


    define_method :crawl! do |opts = {}|
      depth ||= default_depth
      Resque.enqueue(crawler, {:depth => default_depth}.merge(opts).merge({:id => self.id}))
    end
    
    # Setting a date propagates down the depth if more recent
    define_method :set_crawled_at do |depth, time = Time.now|
      old_crawled_dates = self.crawl_dates
      (0..depth).each do |i|
        unless old_crawled_dates[i] && ( old_crawled_dates[i] > time )
          old_crawled_dates[i] = time
        end
      end
      self.crawl_dates = old_crawled_dates
    end
    

    # Default value for crawl date array, and JSON serialization
    define_method :crawl_dates do
      if self.crawl_dates_serialized
        JSON.parse(self.crawl_dates_serialized).map{|t| Time.parse t}
      else
        []
      end
    end
    
    define_method :crawl_dates= do |value|    
      self.crawl_dates_serialized = value.to_json
    end
    
  end

end