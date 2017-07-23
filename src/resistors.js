var app = angular.module('partsdb');
app.controller('resistorsController',function($scope,$http,partservice){
    $scope.message="";
    $scope.rowCollection=[];
    $http({
        method: 'GET',
        url: 'data/myresistors.json'
    }).then(function(response){
        $scope.rowCollection=response.data;
        $scope.dispCollection = [].concat($scope.rowCollection);
    },function(e){
        alert(e);
    });
});
