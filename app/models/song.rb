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
    :crawler => SongCrawler
  )
  
  # Attributes
  has_attributes :recommendations,
                 :recommendations_built_at,
                 :artist,
                 :title

  has_associated :favorites


  def user_ids
    favorites.exists ? favorites.smembers : []
  end
  
  def users
    user_ids.map{|user_id|User.new(user_id)}
  end

  def self.import_from_soundcloud(sc_data)

    # self.name = sc_data.username
    # self.url = sc_data.permalink_url
    # self.songs_count = sc_data.public_favorites_count
  end

end