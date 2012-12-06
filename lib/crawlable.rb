module Crawlable
  
  def self.extended(base)
    base.instance_eval do 
      has_attributes :crawled_at
      has_attributes :crawled_depth
    end
  end

  def is_crawlable_with(opts)
    crawler = opts[:crawler]
    default_depth = opts[:default_depth]
    expiration = opts[:expiration]
    
    define_method :crawled? do |depth|
      if depth == 0
        true
      else
        !!crawled_at && ( Time.parse(crawled_at) > Time.now - expiration ) && (crawl_depth.to_i >= depth )      
      end
    end
    
    define_method :crawl! do |opts = {}|
      depth ||= default_depth
      Resque.enqueue(crawler, {:depth => default_depth}.merge(opts).merge({:id => self.id}))
    end
  end

end