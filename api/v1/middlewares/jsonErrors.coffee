jsonErrors = (req, res, next) ->
  res.jsonErrors = (status, errors) ->
    res.status status
    .json {
      errors: errors
    }
  next()

module.exports = jsonErrors