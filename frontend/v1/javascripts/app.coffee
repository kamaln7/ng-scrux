apiBase = '/api/v1'
app = angular.module 'scruxApp', ['ui.router', 'ngCookies', 'toaster']

.config ($stateProvider, $urlRouterProvider) ->
  $urlRouterProvider.otherwise '/login'

  # Non-auth
  $stateProvider
  .state 'users', {
    abstract: true
    template: '<ui-view/>'
    data:
      auth: false
  }
  .state 'users.login', {
    url: '/login'
    templateUrl: 'partials/users/login.html'
    controller: 'LoginCtrl'
  }
  .state 'users.logout', {
    url: '/logout'
    controller: 'LoginCtrl'
    data:
      auth: true
  }

  # Auth
  $stateProvider
  .state 'todos', {
    abstract: true
    template: '<ui-view/>'
    data:
      auth: true
  }
  .state 'todos.index', {
    url: '/todos'
    templateUrl: 'partials/todos/index.html'
    controller: 'TodosCtrl'
  }

.run ($rootScope, $state, Auth, toaster) ->
  $rootScope.$on '$stateChangeStart', (event, toState) ->
    if toState.name is 'users.login' and Auth.isLoggedIn()
      toaster.pop 'warning', 'You are already logged in.'
      $state.transitionTo 'todos.index'
      event.preventDefault()
    else if toState.data.auth and not Auth.isLoggedIn()
      toaster.pop 'error', 'Authentication required.', 'Please log in.'
      $state.transitionTo 'users.login'
      event.preventDefault()

.factory 'Auth', ($http, $cookieStore, $rootScope) ->
  user = $cookieStore.get('user') || null
  $rootScope.user = user

  if user
    $http.defaults.headers.common.username = user.username
    $http.defaults.headers.common.token = user.token

  {
    user: user
    isLoggedIn: -> @user isnt null
    login: (user, success, error) ->
      $http
      .post "#{apiBase}/users/login", user
      .success (res) =>
        @user = {
          username: user.username
          token: res.token
        }
        $cookieStore.put 'user', @user
        $http.defaults.headers.common.username = @user.username
        $http.defaults.headers.common.token = @user.token
        $rootScope.user = @user
        success()
      .error error
    logout: (success, error) ->
      $http
      .get "#{apiBase}/users/logout"
      .success =>
        @_logout()
        success()
      .error error
    _logout: ->
      @user = null
      $cookieStore.put 'user', @user
      delete $http.defaults.headers.common.username
      delete $http.defaults.headers.common.token
      $rootScope.user = @user
  }

.factory 'Todo', ($http, Auth) ->
  {
    get: (success, error) ->
      $http
      .get "#{apiBase}/todos"
      .success success
      .error error

    delete: (id, success, error) ->
      $http
      .delete "#{apiBase}/todos/#{id}"
      .success success
      .error error

    update: (id, data, success, error) ->
      $http
      .put "#{apiBase}/todos/#{id}", data
      .success success
      .error error
  }

.controller 'LoginCtrl', ($scope, $state, Auth, toaster) ->
  $scope.login = ->
    Auth.login {
      username: $scope.username
      password: $scope.password
    }, ->
      toaster.pop 'success', "You're in!", 'You have been successfully logged in.'
      $state.transitionTo 'todos.index'
    , (err) ->
      toaster.pop 'error', 'Oops!', 'Invalid credentials.'
      Auth._logout()

  $scope.logout = ->
    Auth.logout ->
      toaster.pop 'success', 'Logged out.'
      $state.transitionTo 'users.login'
    , (err) ->
      toaster.pop 'error', 'Oops!', 'An error occurred'

  if $state.current.name is 'users.logout' then $scope.logout()

.controller 'TodosCtrl', ($scope, $state, Todo, toaster) ->
  $scope.loadTodos = ->
    Todo
    .get (todos) ->
      $scope.todos = todos
    , (res, code) ->
      if code is 403
        toaster.pop 'error', 'Authentication required.', 'Please log in.'
        Auth._logout()
        $state.go 'users.login'
      else
        toaster.pop 'error', 'Oops!', 'An error occurred.'

  $scope.loadTodos()

  $scope.delete = (index) ->
    id = $scope.todos[index].id
    Todo
    .delete id
    , ->
      toaster.pop 'success', 'Todo deleted'
      $scope.loadTodos()
    , (res, code) ->
      toaster.pop 'error', 'Oops!', 'An error occurred.'
      console.log res, code

  $scope.toggle = (index) ->
    todo = $scope.todos[index]
    Todo
    .update todo.id, {
        done: not todo.done
      }
    , ->
      toaster.pop 'success', 'Todo toggled'
      $scope.loadTodos()
    , (res, code) ->
      toaster.pop 'error', 'Oops!', 'An error occurred.'
      console.log res, code