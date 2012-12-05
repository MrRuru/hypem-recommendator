module Crawlable

    has_attributes :crawled_at,
                   :crawl_depth
  
    def crawlable(&block)
      opts = args.extract_options!
      
      [:expiration, :default_depth, :crawler].each do |required_option|        
        throw "#{required_option} option required" unless opts[:required_option]
      end
      
      define_method(:crawled?) do |depth = opts[:default_depth]|
        crawled_at && ( Time.parse(crawled_at) > Time.now - opts[:expiration] ) && (crawl_depth.to_i >= depth )
      end
      
      define_method(:crawl!) do |depth = opts[:default_depth]|
        Resque.enqueue(opts[:crawler], {:id => self.id, :depth => depth})
      end
    end
  
end