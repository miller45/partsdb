var app = angular.module('partsdb');

app.service("partservice", function($http) {
    this.getModules = function() {
        return $http({
            method: 'GET',
            url: 'data/modules.json'
        });
    };

    this.getParts = function() {
        return $http({
            method: 'GET',
            url: 'data/parts.json'
        });
    };

    this.getResistors = function() {
        return $http({
            method: 'GET',
            url: 'data/myresistors.json'
        });
    };

});

