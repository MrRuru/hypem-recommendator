class Api::SongsController < ApiController

  respond_to :json
  
  def show
    song_id = params[:id]
    @song = Song.new(song_id)
    @song.to_json
  end
  
  def recommendations
    song_id = params[:id]
    @song = Song.new(song_id)
    @recommendations = @song.recommended_songs.first(5)
  end
  
end