# This controller is handling user inputs

MixerApp.PlayerCtrl = ($scope) ->

  # Bootstrapping the playlist, maybe to put in another place
  MixerApp.Playlist.bootstrap()

  $scope.index = 1

  $scope.currentTrack = -> 
    MixerApp.Playlist.get($scope.index)

  $scope.previousTrack = -> 
    MixerApp.Playlist.get($scope.index - 1)

  $scope.nextTrack = -> 
    MixerApp.Playlist.get($scope.index + 1)

  $scope.playPreviousTrack = ->
    $scope.index = $scope.index - 1

  $scope.playNextTrack = ->
    $scope.index = $scope.index + 1
