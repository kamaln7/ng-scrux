express = require 'express'
fs = require '../../util/fsAsync'
path = require 'path'

router = express.Router()

controllersPath = "#{__dirname}/controllers"
files = fs.readdirSync(controllersPath)

for file in files
  controller = require path.join controllersPath, file

  router.use controller.prefix, controller.router
  console.log "Loaded controller: #{file.replace /\.coffee$/, ''}"

module.exports = router