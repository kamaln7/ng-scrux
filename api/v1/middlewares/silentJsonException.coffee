silentJsonException = (req, res, next) ->
  res.silentJsonException = (e) ->
    console.error e, e.stack
    res.status 500
    .end()
  next()

module.exports = silentJsonException