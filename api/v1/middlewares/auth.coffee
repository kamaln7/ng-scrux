User = require '../../../database/models/User'

auth = (req, res, next) ->
  if not req.headers.username? or not req.headers.token?
    res.status 400
    .end()
  else
    User.auth req.headers.username, req.headers.token, res
    .then -> next()
    .catch User.invalidCredentials, (e) ->
      res.status 403
      .json {
        errors: [e.message]
      }
    .catch (e) ->
      res.status 500
      .end()

module.exports = auth