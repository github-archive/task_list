#= require task_lists

module "TaskList events",
  setup: ->
    window.linkActivated = false

    @container = $ '<div>', class: 'js-task-list-container'

    @list = $ '<ul>', class: 'task-list'
    @item = $ '<li>', class: 'task-list-item'
    @checkbox = $ '<input>',
      type: 'checkbox'
      class: 'task-list-item-checkbox'
      disabled: true
      checked: false

    @field = $ '<textarea>', class: 'js-task-list-field', "- [ ] text"

    @item.append @checkbox
    @list.append @item
    @container.append @list

    @container.append @field

    $('#qunit-fixture').append(@container).pageUpdate()

  teardown: ->
    $(document).off 'tasklist:enabled'
    $(document).off 'tasklist:disabled'
    $(document).off 'tasklist:change'

asyncTest "triggers a tasklist:change event on task list item changes", ->
  expect 1

  @field.on 'tasklist:change', (event, index, checked) ->
    ok true

  setTimeout ->
    start()
  , 20

  @checkbox.click()

asyncTest "enables task list items when a .js-task-list-field is present", ->
  expect 1

  $(document).on 'tasklist:enabled', (event) ->
    ok true

  @container.pageUpdate()
  setTimeout ->
    start()
  , 20

asyncTest "doesn't enable task list items when a .js-task-list-field is absent", ->
  expect 0

  $(document).on 'tasklist:enabled', (event) ->
    ok true

  @field.remove()

  @container.pageUpdate()
  setTimeout ->
    start()
  , 20

asyncTest "disables task list items when changing source", ->
  expect 1

  $(document).on 'tasklist:disabled', (event) ->
    ok true

  setTimeout ->
    start()
  , 20

  @checkbox.click()
