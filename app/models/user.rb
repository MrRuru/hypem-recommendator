# A hype machine song : storing its details and its playlist
class User < RedisRecord

  EXPIRE_AFTER = 1.week
  DEFAULT_CRAWL_DEPTH = 3 # Enough to get one-level recommendations for each song

  # TODO : async sync! on playlist accessing, handling expiration

  has_attributes :synced_at,
                 :crawled_at, 
                 :crawl_depth, 
                 :recommended_at, 
                 :recommendations

  has_associated :playlist

  def song_ids
    playlist.exists ? playlist.smembers : []
  end

  def songs
    song_ids.map{|song_id|Song.new(song_id)}
  end
  
  def hypem
    @hypem ||= Hypem.user(@id)
  end

  # Jobs builders
  def synced?
    !!synced_at && ( Time.parse(synced_at) > (Time.now - EXPIRE_AFTER))
  end
  
  def sync!
    Resque.enqueue(Syncer, "user", self.id)
  end
  
  def crawled?(depth = DEFAULT_CRAWL_DEPTH)
    crawled_at && ( Time.parse(crawled_at) > Time.now - EXPIRE_AFTER ) && (crawl_depth >= depth )
  end
  
  def crawl!(depth = DEFAULT_CRAWL_DEPTH, force = false)
    Resque.enqueue(Crawler, "user", self.id, depth, force)
  end

  def build_recommendations!
    Resque.enqueue(Recommender, "user", self.id)
  end

end