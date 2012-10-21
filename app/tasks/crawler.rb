class Crawler
  include Resque::Plugins::UniqueJob

  @queue = :crawling
  
  def self.logger
    @logger ||= Logger.new('log/crawler.log')
  end

  def self.perform(type, id, depth, force)
    
    return if depth <= 0
    
    if type == "song"
      crawl_song(id, depth, force)
    elsif type == "user"
      crawl_user(id, depth, force)
    end
  end
  
  private

  def self.crawl_song(id, depth, force)
    logger.info "Crawling song #{id} at depth #{depth} #{'(forcing)' if force}"

    song = Song.new(id)

    unless song.synced?
      logger.info "Song #{id} was not synced : syncing it"
      song.sync!
      return
    end
      
    logger.info "Crawling song #{id} users : #{song.user_ids}"
    
    song.users.each do |user|
      user.crawl!(depth - 1, force) if force || !user.crawled?(depth - 1)
    end

    song.crawled_at = Time.now
    song.crawl_depth = depth
  end
  
  def self.crawl_user(id, depth, force)
    logger.info "Crawling user #{id} at depth #{depth} #{'(forcing)' if force}"

    user = User.new(id)
    
    unless user.synced?
      logger.info "User #{id} was not synced : syncing it"
      user.sync!
      return
    end

    logger.info "Crawling user #{id} songs : #{user.song_ids}"

    user.songs.each do |song|
      song.crawl!(depth - 1, force) if force || !song.crawled?(depth - 1)
    end

    user.crawled_at = Time.now
    user.crawl_depth = depth
  end
end