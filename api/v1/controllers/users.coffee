express = require 'express'
router = express.Router()

User = require '../../../database/models/User'

router.post '/', (req, res) ->
  req.checkBody('username', 'Username must be at least 4 characters long').isLength(4)
  req.checkBody('password', 'Password must be at least 8 characters long').isLength(8)

  errors = req.validationErrors()
  if errors
    res.status(400).json {
      errors: errors
    }
  else
    username = req.body.username
    password = req.body.password
    User.register(username, password).then ->
      res.status(201).json {
        message: 'Registered!'
      }
    .catch (e) ->
      if e instanceof User.usernameNotUnique
        res.status(400).json {
          errors: ['Username already exists.']
        }
      else
        res.status(500)

module.exports =
  prefix: '/users'
  router: router