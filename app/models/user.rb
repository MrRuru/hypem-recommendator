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
    :crawler => UserCrawler
  )

  has_associated :playlist

  def song_ids
    playlist.exists ? playlist.smembers : []
  end

  def songs
    song_ids.map{|song_id|Song.new(song_id)}
  end
  
end