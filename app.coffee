config = require './config'

db = require './database/init'
r  = db.r

express = require 'express'
bodyParser = require 'body-parser'
expressValidator = require 'express-validator'
morgan = require 'morgan'

app = express()
app.use morgan('dev')
app.use bodyParser.urlencoded({ extended: false })
app.use bodyParser.json()
app.use expressValidator()

apiV1 = require './api/v1/app'
app.use '/api/v1', apiV1
console.log 'Loaded API v1'

app.use express.static 'frontend/v1'
console.log 'Loaded Frontend v1'

app.listen config.http.port, config.http.host, ->
  console.log "ng-scrux listening on #{config.http.host}:#{config.http.port}"