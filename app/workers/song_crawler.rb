class SongCrawler < Crawler

  @queue = :crawling

  def song
    @song ||= Song.new(id)
  end

  def children
    song.users
  end
  
  alias :object :song


  # def process_crawl
  #   logger.info "Crawling song #{id} at depth #{depth} #{'(forcing)' if force}"
  # 
  #   unless song.synced?
  #     logger.info "Song #{id} was not synced : syncing it"
  #     song.sync!
  #     return
  #   end
  #     
  #   logger.info "Crawling song #{id} users : #{song.user_ids}"
  #   
  #   song.users.each do |user|
  #     user.crawl!(depth - 1, force) if force || !user.crawled?(depth - 1)
  #   end
  # 
  #   song.crawled_at = Time.now
  #   song.crawl_depth = depth
  # end

end