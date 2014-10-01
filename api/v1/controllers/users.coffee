express = require 'express'
router = express.Router()

User = require '../../../database/models/User'
auth = require '../middlewares/auth'

router.post '/', (req, res) ->
  req.checkBody('username', 'Username must be at least 4 characters long').isLength(4)
  req.checkBody('password', 'Password must be at least 8 characters long').isLength(8)

  errors = req.validationErrors()
  if errors
    res.status 400
    .json {
      errors: errors
    }
  else
    {username, password} = req.body

    User.register(username, password).then (user) ->
      res.status 201
      .json {
        token: user.tokens[0]
      }
    .catch User.usernameNotUnique, (e) ->
      res.status 400
      .json {
        errors: [e.message]
      }
    .catch ->
      res.status 500
      .end()

router.post '/login', (req, res) ->
  req.checkBody('username', 'You must supply a username').notEmpty()
  req.checkBody('password', 'You must supply a password').notEmpty()

  errors = req.validationErrors()
  if errors
    res.status 400
    .json {
      errors: errors
    }
  else
    {username, password} = req.body

    User.login(username, password).then (user) ->
      res.status 200
      .json {
        token: user.token
      }
    .catch User.invalidCredentials, (e) ->
      res.status 403
      .json {
        errors: [e.message]
      }
    .catch ->
      res.status 500
      .end()

router.get '/logout', auth, (req, res) ->
  User.logout res.locals.user.username, res.locals.token
  .then ->
    res.status 200
    .end()
  .catch User.invalidCredentials, (e) ->
    res.status 403
    .json {
      errors: [e.message]
    }
  .catch ->
    res.status 500
    .end()

module.exports =
  prefix: '/users'
  router: router