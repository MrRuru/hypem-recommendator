# This module is handling the client-side loaded tracks, and the communication with the api

Mixer.Playlist = {

  tracks: []

  # Fetches a starting playlist from the api
  bootstrap: (callback) ->

    # Simulating an api call
    setTimeout ( () =>
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
        ], (obj) -> new Mixer.Track(obj)

        typeof callback == 'function' && callback() ),
      1000

  # Get the track corresponding to a specific index
  get: (index) ->
    if index < 0 || index >= @tracks.length
      {}
    else
      @tracks[index]

}