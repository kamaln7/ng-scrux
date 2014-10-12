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
  .withFields 'id', 'content'
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
      .json _.pick todo, 'id', 'content'
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
  req.checkBody('content', 'Content must be at least 3 characters long').isLength(3)

  errors = req.validationErrors()
  if errors
    res.jsonErrors 400, errors
  else
    {content} = req.body
    {id} = req.params

    Todo.ofUser res.locals.user
    .filter r.row('id').eq id
    .update {
      content: content
    }
    .run()
    .then (todo) ->
      res
      .json {
        id: id
        content: content
      }
    .catch (e) -> res.silentJsonException e

module.exports =
  prefix: '/todos'
  router: router