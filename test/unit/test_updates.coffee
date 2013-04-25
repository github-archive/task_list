#= require task_lists

module "TaskList updates",
  setup: ->
    window.linkActivated = false

    @container = $ '<div>', class: 'js-task-list-container'

    @list = $ '<ul>', class: 'task-list'

    @completeItem = $ '<li>', class: 'task-list-item'
    @completeCheckbox = $ '<input>',
      type: 'checkbox'
      class: 'task-list-item-checkbox'
      disabled: true
      checked: true # yup

    @incompleteItem = $ '<li>', class: 'task-list-item'
    @incompleteCheckbox = $ '<input>',
      type: 'checkbox'
      class: 'task-list-item-checkbox'
      disabled: true
      checked: false

    @field = $ '<textarea>', class: 'js-task-list-field', text: """
      - [x] complete
      - [ ] incomplete
    """

    @changes =
      toComplete: """
      - [ ] complete
      - [ ] incomplete
      """
      toIncomplete: """
      - [x] complete
      - [x] incomplete
      """

    @completeItem.append @completeCheckbox
    @list.append @completeItem
    @completeItem.expectedIndex = 1

    @incompleteItem.append @incompleteCheckbox
    @list.append @incompleteItem
    @incompleteItem.expectedIndex = 2

    @container.append @list
    @container.append @field

    $('#qunit-fixture').append(@container).pageUpdate()

  teardown: ->
    $(document).off 'tasklist:change'

asyncTest "updates the source, marking the incomplete item as complete", ->
  expect 3

  @field.on 'tasklist:change', (event, index, checked) =>
    ok checked
    equal index, @incompleteItem.expectedIndex
    equal @field.val(), @changes.toIncomplete

  setTimeout ->
    start()
  , 20

  @incompleteCheckbox.click()

asyncTest "updates the source, marking the complete item as incomplete", ->
  expect 3

  @field.on 'tasklist:change', (event, index, checked) =>
    ok !checked
    equal index, @completeItem.expectedIndex
    equal @field.val(), @changes.toComplete

  setTimeout ->
    start()
  , 20

  @completeCheckbox.click()
