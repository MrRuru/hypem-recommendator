# A hype machine song : storing its details and the users who favorited it 
class Song < RedisRecord

  # Syncing
  extend Syncable
  
  is_syncable_with(
    :expiration => 1.day, 
    :syncer => SongSyncer
  )


  extend Crawlable
  is_crawlable_with(
    :expiration => 1.day,
    :default_depth => 2, # Enough to get one-level recommendations
    :crawler => SongCrawler
  )
  
  # Attributes
  has_attributes :recommended_at, 
                 :recommendations,
                 :recommendations_built_at,
                 :artist,
                 :title

  has_associated :favorites

  def recommended_songs
    recommendations ? JSON.parse(recommendations).map{|song_id| Song.new(song_id)} : []
  end

  def user_ids
    favorites.exists ? favorites.smembers : []
  end
  
  def users
    user_ids.map{|user_id|User.new(user_id)}
  end

  def recommendations_exist?
    !!recommendations
  end
  
  def recommendations_expired?
    recommendations_built_at && ( Time.parse(recommendations_built_at) > Time.now - EXPIRE_AFTER )
  end
  
  def build_recommendations!
    Resque.enqueue(Recommender, self.id)
  end
  
end