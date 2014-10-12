thinky = require "#{__dirname}/../init"
r = thinky.r

Todo = thinky.createModel 'todos', {
  id: String
  content: String
  done: {_type: Boolean, default: false}
  userId: String
  createdAt: {_type: Date, default: r.now()}
  updatedAt: {_type: Date, default: r.now()}
}

Todo.pre 'save', (next) ->
  @updatedAt = new Date()
  next()

# Logic

Todo.ofUser = (user) ->
  @filter r.row('userId').eq user.id

module.exports = Todo
