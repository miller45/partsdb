var app = angular.module('partsdb', ['ngRoute','smart-table']);
app.controller('appCtrl', ['$scope',
  function($scope) {
    $scope.greeting = { text: 'Hello' };
}]);

app.config(['$routeProvider',
    function($routeProvider) {
        $routeProvider.
        when('/parts', {
            templateUrl: 'partials/parts.html',
            controller: 'partsController'
        }).
        when('/parts/:partId', {
            templateUrl: 'partials/part-detail.html',
            controller: 'partsDetailsController'
        }).
        when('/resistors', {
            templateUrl: 'partials/resistors.html',
            controller: 'resistorsController'
        }).
        when('/about',{
            templateUrl: 'partials/about.html',
            controller: 'aboutController'
        });

    }]);