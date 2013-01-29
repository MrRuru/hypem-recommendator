# A hype machine song : storing its details and the users who favorited it 
class Song < RedisRecord

  # Syncing
  extend Syncable
  is_syncable_with(
    :expiration => 1.day, 
    :syncer => SongSyncer
  )

  # Crawling
  extend Crawlable
  is_crawlable_with(
    :expiration => 1.day,
    :default_depth => 2, # Enough to get one-level recommendations
    :crawler => SongCrawler,
    :children_syncer => SongFavoritersSyncer
  )
  
  # Attributes
  has_attributes :uploader_id,
                 :title,
                 :url,
                 :artwork_url,
                 :favoriters_count

  has_associated :favoriters


  def user_ids
    favoriters.exists ? favoriters.smembers : []
  end
  
  def users
    user_ids.map{|user_id|User.new(user_id)}
  end

  def uploader
    self.uploader_id ? User.new(self.uploader_id) : nil
  end

end