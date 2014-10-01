fs = require 'fs'
Promise = require 'bluebird'

fsAsync = Promise.promisifyAll fs

module.exports = fsAsync