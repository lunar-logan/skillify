function queryController($scope, $http) {
//    $scope.qs = $scope.query.text;
    $scope.list = [];
    $scope.query = "Hello";
    $scope.res = '';
    $scope.repos = null;
    $scope.submit = function () {
        if (this.query) {
            queryString = this.query;
            $scope.list.push(this.query);
            this.query = '';
            $http.get('/skillify.json?uname=' + queryString).then(function (res) {
                if (res["status"] == 200) {
//                    $scope.res="Found !!";
                    var tempAllRepos = res["data"];
                    $scope.repos = tempAllRepos["top_repos"];
                }
            });
        }
    }
}