var app = angular.module('partsdb');
app.controller('modulesController',function($scope,partservice){
    $scope.message="";
    $scope.rowCollection=[];
    partservice.getModules().then(function(response){
        $scope.rowCollection=response.data.modules;
        $scope.dispCollection = [].concat($scope.rowCollection);
        $scope.predicates= ['artnr','description'];
        $scope.selectedPredicate = $scope.predicates[0];
    },function(e){
        alert(e);
    });
});
