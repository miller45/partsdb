var app = angular.module('partsdb');
app.controller('resistorsController',function($scope,partservice){
    $scope.message="";
    $scope.rowCollection=[];
    partservice.getResistors().then(function(response){
        $scope.rowCollection=response.data;
        $scope.dispCollection = [].concat($scope.rowCollection);
    },function(e){
        alert(e);
    });
});
