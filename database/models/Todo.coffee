thinky = require "#{__dirname}/../init"
r = thinky.r

Todo = thinky.createModel 'todos', {
  id: String
  content: String
  done: Boolean
  userId: String
  createdAt: {_type: Date, default: r.now()}
  updatedAt: {_type: Date, default: r.now()}
}

Todo.pre 'save', (next) ->
  @updatedAt = new Date()
  next()

module.exports = Todo
