function PlayerCtrl($scope){
  

  $scope.currentTrack = {
    title: "Zeds Dead - No Prayers",
    artist: "Thissongissick.com"
  };

  $scope.previousTracks = [{
    title: "Ratatat - Loud Pipes",
    artist: "Fatlicious!"
  }];

  $scope.nextTracks = [{
    title: "Sir Sly - Gold",
    artist: "Sir Sly"
  }];



  $scope.nextTrack = function(){
    return $scope.nextTracks[0];
  };

  $scope.previousTrack = function(){
    return $scope.previousTracks[0];
  };

  $scope.playPrevious = function(){
    $scope.nextTracks.unshift($scope.currentTrack);
    $scope.currentTrack = $scope.previousTracks.shift();
  };

  $scope.playNext = function(){
    $scope.previousTracks.unshift($scope.currentTrack);
    $scope.currentTrack = $scope.nextTracks.shift();
  };



}
