var app = angular.module('partsdb');
app.controller('modulesController',function($scope,$http){
    $scope.message="";
    $scope.rowCollection=[];
    $http({
        method: 'GET',
        url: 'data/modules.json'
    }).then(function(response){
        $scope.rowCollection=response.data.modules;
        $scope.dispCollection = [].concat($scope.rowCollection);
        $scope.predicates= ['artnr','description'];
        $scope.selectedPredicate = $scope.predicates[0];
    },function(e){
        alert(e);
    });
});
