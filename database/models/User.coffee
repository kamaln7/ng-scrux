thinky = require "#{__dirname}/../init"
r = thinky.r
Todo = require "#{__dirname}/Todo"
bcrypt = require "#{__dirname}/../../util/bcrypt"
uuid = require 'node-uuid'
_ = require 'lodash'

User = thinky.createModel 'users', {
  id: String
  username: String
  password: String
  tokens: [String]
  createdAt: {_type: Date, default: r.now()}
  updatedAt: {_type: Date, default: r.now()}
}

User.ensureIndex 'username'
User.hasMany Todo, 'todos', 'id', 'userId'

# Logic
User.hashPassword = (password) ->
  bcrypt.hashAsync(password, null, null).then (password) =>
    password

User.isUnique = (username) ->
  User
  .filter r.row('username').eq username
  .count()
  .execute().then (count) ->
    throw new User.usernameNotUnique() if count isnt 0

User.register = (username, password) ->
  user = new User {
    username: username
    tokens: [@generateToken()]
  }

  User
  .hashPassword password
  .then (password) ->
    user.password = password
  .then ->
    User.isUnique username
  .then ->
    user.save()

User.generateToken = -> uuid.v4()

User.login = (username, password) ->
  token = User.generateToken()

  User
  .filter r.row('username').eq username
  .run().then (users) ->
    throw new User.invalidCredentials unless users.length
    @user = users[0]

    bcrypt.compareAsync password, @user.password
  .then (match) ->
    throw new User.invalidCredentials unless match
  .then (users) ->
    @user.tokens.push token
    @user.save()
  .then ->
    {
      user: @user
      token: token
    }

User.logout = (username, token) ->
  # I should do this the ReSQL way http://stackoverflow.com/questions/20612739/rethinkdb-removing-item-from-array-in-one-table-by-value-from-another-table
  User
  .filter r.row('username').eq username
  .run().then (users) ->
    return unless users.length
    user = users[0]

    user.tokens = _.without user.tokens, token
    user.save()

User.auth = (username, token, res) ->
  User
  .filter r.row('username').eq username
  .filter (user) ->
    user('tokens').contains token
  .run().then (users) ->
    throw new User.invalidCredentials unless users.length
    res.locals.token = token
    user = res.locals.user = users[0]

# Exceptions
class User.usernameNotUnique extends Error then constructor: ->
  super
  @message = 'Username already exists'
class User.invalidCredentials extends Error then constructor: ->
  super
  @message = 'Invalid credentials'

module.exports = User
