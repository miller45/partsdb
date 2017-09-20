var app = angular.module('partsdb');
app.controller('partsController',function($scope,$http,partservice){
    $scope.message="";
    $scope.rowCollection=[];
    $http({
        method: 'GET',
        url: 'data/batchinfo.json'
    }).then(function(batchResponse){
        $scope.batchinfo=batchResponse.data.batchinfo;
        $http({
            method: 'GET',
            url: 'data/parts.json'
        }).then(function(partsResponse){        
            $scope.rowCollection=partsResponse.data.parts;        
            $scope.dispCollection = [].concat($scope.rowCollection);
        },function(e){
            alert(e);
        });
    },function(e){
        alert(e);
    })
    
});
