class UserCrawler < Crawler
  
  @queue = :crawling

  def object
    @user ||= User.new(id)
  end

  # def process_crawl
  #   logger.info "Crawling user #{id} at depth #{depth} #{'(forcing)' if force}"
  # 
  #   unless user.synced?
  #     logger.info "User #{id} was not synced : syncing it"
  #     user.sync!
  #     return
  #   end
  # 
  #   logger.info "Crawling user #{id} songs : #{user.song_ids}"
  # 
  #   user.songs.each do |song|
  #     song.crawl!(depth - 1, force) if force || !song.crawled?(depth - 1)
  #   end
  # 
  #   user.crawled_at = Time.now
  #   user.crawl_depth = depth
  # end

end