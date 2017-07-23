var app = angular.module('partsdb');

app.service("partservice",function(){
    this.getItems=function(){
        return [];
    }
});

app.controller('aboutController',function($scope,$http){
    $scope.message="Hello World";
});

app.controller('partsController',function($scope,$http,partservice){
    $scope.message="";
    $scope.rowCollection=[];
    $http({
        method: 'GET',
        url: 'data/parts.json'
    }).then(function(response){                
        $scope.rowCollection=response.data.parts;
        $scope.dispCollection = [].concat($scope.rowCollection);
    },function(e){
        alert(e);
    });
});

app.config(['$routeProvider',
    function($routeProvider) {
        $routeProvider.
            when('/parts', {
                templateUrl: 'partials/parts.html',
                controller: 'partsController'
            }).
            when('/parts/:partId', {
                templateUrl: 'partials/part-detail.html',
                controller: 'PhoneDetailCtrl'
            }).
            when('/about',{
                templateUrl: 'partials/about.html',
                controller: 'aboutController'
            });

    }]);