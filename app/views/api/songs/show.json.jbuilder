json.song do
  json.partial! "api/songs/song", song: @song

  json.last_update Time.parse(@song.synced_at)
end