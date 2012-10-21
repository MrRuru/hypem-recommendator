# A hype machine song : storing its details and the users who favorited it 
class Song < RedisRecord

  EXPIRE_AFTER = 1.day
  DEFAULT_CRAWL_DEPTH = 2 # Enough to get one-level recommendations
  
  # TODO : async sync! on favorites and recommendations

  has_attributes :synced_at,
                 :crawled_at, 
                 :crawl_depth, 
                 :recommended_at, 
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

  def hypem
    @hypem ||= Hypem.track(@id)
  end  

  # Jobs builders
  def synced?
    !!synced_at && ( Time.parse(synced_at) > (Time.now - EXPIRE_AFTER))
  end
  
  def sync!
    Resque.enqueue(Syncer, "song", self.id)
  end
  
  def crawled?(depth = DEFAULT_CRAWL_DEPTH)
    crawled_at && ( Time.parse(crawled_at) > Time.now - EXPIRE_AFTER ) && (crawl_depth.to_i >= depth )
  end
  
  def crawl!(depth = DEFAULT_CRAWL_DEPTH, force = false)
    Resque.enqueue(Crawler, "song", self.id, depth, force)
  end

  def build_recommendations!
    Resque.enqueue(Recommender, self.id)
  end
  
end