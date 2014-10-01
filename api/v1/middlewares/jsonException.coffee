jsonException = (req, res, next) ->
  res.jsonException = (status, e) ->
    res.jsonErrors status, [e.message]
  next()

module.exports = jsonException