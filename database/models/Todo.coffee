thinky = require "#{__dirname}/../init"

Todo = thinky.createModel 'todos', {
  id: String
  content: String
  done: Boolean
  userId: String
}

module.exports = Todo