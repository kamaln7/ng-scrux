thinky = require "#{__dirname}/../init"
r = thinky.r
Todo = require "#{__dirname}/Todo"
bcrypt = require "#{__dirname}/../../util/bcrypt"

User = thinky.createModel 'users', {
  id: String
  username: String
  password: String
  tokens: [String]
  createdAt: {_type: Date, default: r.now()}
}

User.ensureIndex 'username'
User.hasMany Todo, 'todos', 'id', 'userId'

# Logic
User.hashPassword = (password) ->
  bcrypt.hashAsync(password, null, null).then (password) =>
    password

User.isUnique = (username) ->
  User
  .filter(r.row('username').eq(username))
  .count()
  .execute().then (count) ->
    throw new User.usernameNotUnique() if count isnt 0

User.register = (username, password) ->
  user = new User {
    username: username
  }

  User
  .hashPassword password
  .then (password) ->
    user.password = password
  .then ->
    User.isUnique username
  .then ->
    user.save()

# Exceptions
class User.usernameNotUnique extends Error then constructor: -> super

module.exports = User