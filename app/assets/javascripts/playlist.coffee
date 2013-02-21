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
            id: '40289362'
          },
          {
            title: "Sir Sly - Gold"
            artist: "Sir Sly"
            id: '63392244'
          },
          {
            title: "Ratatat - Loud Pipes"
            artist: "Fatlicious!"
            id: '29462796'
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