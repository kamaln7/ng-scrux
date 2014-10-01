express = require 'express'
router = express.Router()

User = require '../../../database/models/User'
auth = require '../middlewares/auth'
jsonException = require '../middlewares/jsonException'
jsonErrors = require '../middlewares/jsonErrors'

router.post '/register', (req, res) ->
  req.checkBody('username', 'Username must be at least 4 characters long').isLength(4)
  req.checkBody('password', 'Password must be at least 8 characters long').isLength(8)

  errors = req.validationErrors()
  if errors
    res.jsonErrors 400, errors
  else
    {username, password} = req.body

    User.register(username, password).then (user) ->
      res.status 201
      .json {
        token: user.tokens[0]
      }
    .catch User.usernameNotUnique, (e) -> res.jsonException e, 400
    .catch (e) -> res.silentJsonException e

router.post '/login', (req, res) ->
  req.checkBody('username', 'You must supply a username').notEmpty()
  req.checkBody('password', 'You must supply a password').notEmpty()

  errors = req.validationErrors()
  if errors
    res.jsonErrors 400, errors
  else
    {username, password} = req.body

    User.login(username, password).then (user) ->
      res.json {
        token: user.token
      }
    .catch User.invalidCredentials, (e) -> res.jsonException 403, e
    .catch (e) -> res.silentJsonException e

router.get '/logout', auth, (req, res) ->
  User.logout res.locals.user.username, res.locals.token
  .then ->
    res.end()
  .catch User.invalidCredentials, (e) -> res.jsonException 403, e
  .catch (e) -> res.silentJsonException e

module.exports =
  prefix: '/users'
  router: router