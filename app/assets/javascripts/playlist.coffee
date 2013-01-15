# This module is handling the client-side loaded tracks, and the communication with the api

MixerApp.Playlist = {

  # Fetches a starting playlist from the api
  bootstrap: () ->
    @tracks = _.map [
        {
          title: "Zeds Dead - No Prayers"
          artist: "Thissongissick.com"
        },
        {
          title: "Sir Sly - Gold"
          artist: "Sir Sly"
        },
        {
          title: "Ratatat - Loud Pipes"
          artist: "Fatlicious!"
        }
      ], (obj) -> new MixerApp.Track(obj)    

  # Get the track corresponding to a specific index
  get: (index) ->
    if index < 0 || index >= @tracks.length
      {}
    else
      @tracks[index]

}