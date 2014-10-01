bcrypt = require 'bcrypt-nodejs'
Promise = require 'bluebird'

bcrypt = Promise.promisifyAll bcrypt

module.exports = bcrypt