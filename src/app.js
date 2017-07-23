var app = angular.module('partsdb', ['ngRoute','smart-table']);
app.controller('appCtrl', ['$scope',
  function($scope) {
    $scope.greeting = { text: 'Hello' };
}]);
