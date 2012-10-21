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

    unless @song.recommended_songs.empty?
      @recommendations = @song.recommended_songs.first(5)
    else
      response.status = "503"
      render :json => {:status => "Recommandations for #{song_id} being processed"}      
    end
  end
  
end