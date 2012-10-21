json.song do
  json.partial! "api/songs/song", song: @song
  json.last_update Time.parse(@song.recommendations_built_at)
  json.recommendations @recommendations do |recommendation|
    json.partial! "api/songs/song", song: recommendation
  end
end