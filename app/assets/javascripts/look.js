function queryController($scope, $http) {
//    $scope.qs = $scope.query.text;
    $scope.list = [];
    $scope.query = '';//"Hello";
//    $scope.res = '';
    $scope.repos = null;
    $scope.skills = null;
//    $scope.n = '';
    $scope.submit = function () {
        if (this.query) {
            var queryString = this.query;
            $scope.list.push(this.query);
            this.query = '';
            $http.get('/skillify.json?uname=' + queryString).then(function (res) {
                if (res["status"] == 200) {
//                    $scope.res="Found !!";
                    var tempData = res["data"];
                    var tempUserInfo = tempData["user"];
                    $scope.name = tempUserInfo["name"];
                    $scope.imgSrc = tempUserInfo["gravatar_id"];
//                    $scope.moreInfo = "";
                    $scope.email = '';
                    $scope.loc = '';
                    $scope.bull = '';
                    $scope.bullPresent = false;
                    $scope.emailPresent = false;
                    $scope.locPresent = false;
                    var bullPresent = 0;
                    if (tempUserInfo["email"] != null) {
                        $scope.emailPresent = true;
                        $scope.email = tempUserInfo["email"];
                        bullPresent++;
                    }
                    if (tempUserInfo["location"] != null) {
                        $scope.locPresent = true;
                        $scope.loc = tempUserInfo["location"];
                        bullPresent++;
                    }
                    if (bullPresent >= 2) {
                        $scope.bullPresent = true;
//                        $scope.bull = '&bull;'
                    }

                    $scope.repos = tempData["top_repos"];
                    $scope.skills = tempData["skills"];
                }
            });
        }
    }
}