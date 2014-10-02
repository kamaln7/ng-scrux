thinky = require "#{__dirname}/../init"

Todo = thinky.createModel 'todos', {
  id: String
  content: String
  done: Boolean
  userId: String
  createdAt: {_type: Date, default: r.now()}
  updatedAt: {_type: Date, default: r.now()}
}

module.exports = Todo
