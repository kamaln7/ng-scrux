express = require 'express'
router = express.Router()

Todo = require '../../../database/models/Todo'
auth = require '../middlewares/auth'
jsonException = require '../middlewares/jsonException'
jsonErrors = require '../middlewares/jsonErrors'
_ = require 'lodash'
r = require("#{__dirname}/../../../database/init").r

router.use auth

router.get '/', (req, res) ->
  Todo
  .ofUser res.locals.user
  .withFields 'id', 'content', 'done'
  .orderBy r.desc 'createdAt'
  .run()
  .then (todos) ->
    res.json todos
  .catch (e) -> res.silentJsonException e

router.post '/', (req, res) ->
  req.checkBody('content', 'Content must be at least 3 characters long').isLength(3)

  errors = req.validationErrors()
  if errors
    res.jsonErrors 400, errors
  else
    {content} = req.body

    todo = new Todo {
      userId: res.locals.user.id
      content: content
    }

    todo
    .save()
    .then (todo) ->
      res
      .status 201
      .json _.pick todo, 'id', 'content', 'done'
    .catch (e) -> res.silentJsonException e

router['delete'] '/:id', (req, res) ->
  Todo
  .ofUser res.locals.user
  .filter r.row('id').eq req.params.id
  .delete()
  .execute()
  .then  ->
    res
    .status 200
    .end()
  .catch (e) -> res.silentJsonException e

router.put '/:id', (req, res) ->
  req.checkBody('content', 'Content must be at least 3 characters long').optional().isLength 3
  req.checkBody('done', 'Done must be either true or false').optional().matches /^(true|false)$/i

  errors = req.validationErrors()
  if errors
    res.jsonErrors 400, errors
  else
    {id} = req.params
    toUpdate = _.pick req.body, ['content', 'done']

    Todo.ofUser res.locals.user
    .filter r.row('id').eq id
    .update toUpdate
    .run()
    .then () ->
      res
      .json _.merge {id: id}, toUpdate
    .catch (e) -> res.silentJsonException e

module.exports =
  prefix: '/todos'
  router: router