# A hype machine song : storing its details and its playlist
class User < RedisRecord

  # Syncing
  extend Syncable
  is_syncable_with(
    :expiration => 1.week, 
    :syncer => UserSyncer
  )

  # Crawling
  extend Crawlable
  is_crawlable_with(
    :expiration => 1.week,
    :default_depth => 3, # Enough to get one-level recommendations for each song
    :crawler => UserCrawler,
    :children_syncer => UserFavoritesSyncer
  )

  # Attributes
  has_attributes :name,
                 :url,
                 :favorites_count

  has_associated :favorites


  def song_ids
    favorites.exists ? favorites.smembers : []
  end

  def songs
    song_ids.map{|song_id|Song.new(song_id)}
  end

end