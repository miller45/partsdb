var app = angular.module('partsdb');
app.controller('partsController',function($scope,partservice){
    $scope.message="";
    $scope.rowCollection=[];
    partservice.getParts().then(function(response){
        $scope.rowCollection=response.data.parts;
        $scope.dispCollection = [].concat($scope.rowCollection);
		$scope.predicates= ['batch','artnr','description','class','value1','value2'];		 
		$scope.selectedPredicate = $scope.predicates[0];
    },function(e){
        alert(e);
    });
});
