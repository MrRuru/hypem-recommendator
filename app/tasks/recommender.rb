class Recommender
  include Resque::Plugins::UniqueJob

  @queue = :recommending
  
  def self.logger
    @logger ||= Logger.new('log/recommender.log')
  end

  def self.perform(id)
    logger.info "Getting recommendations for song #{id}"
    
    song = Song.new(id)

    unless song.crawled?
      song.crawl!
      return
    end

    recommender = SongRecommender.new

    song.users.each do |user|
      recommender.playlists.add_set(user.id, user.song_ids)
    end
    
    recommender.process!
    
    recommendations = recommender.for(id).map do |recommendation|
      recommendation.item_id
    end
    
    song.recommendations = JSON(recommendations)
    song.recommendations_built_at = Time.now
    
  end
end
