# TaskList Behavior
#
#= provides tasklist:enabled
#= provides tasklist:disabled
#= provides tasklist:change
#= provides tasklist:changed
#
#= require crema/element/fire
#= require crema/events/pageupdate
#
# Enables Task List update behavior.
#
# ### Example Markup
#
#   <div class="js-task-list-container">
#     <ul class="task-list">
#       <li class="task-list-item">
#         <label>
#           <input type="checkbox" class="js-task-list-item-checkbox" disabled />
#           text
#         </label>
#       </li>
#     </ul>
#     <form>
#       <textarea class="js-task-list-field">- [ ] text</textarea>
#     </form>
#   </div>
#
# ### Specification
#
# TaskLists MUST be contained in a `(div).js-task-list-container`.
#
# TaskList Items SHOULD be an a list (`UL`/`OL`) element.
#
# Task list items MUST match `(input).task-list-item-checkbox` and MUST be
# `disabled` by default. The Item's contents SHOULD be wrapped in a `LABEL`.
#
# TaskLists MUST have a `(textarea).js-task-list-field` form element whose
# `value` attribute is the source (Markdown) to be udpated. The source MUST
# follow the syntax guidelines.
#
# TaskList updates trigger `tasklist:change` events. If the change is
# successful, `tasklist:changed` is fired. The change can be canceled.
#
# jQuery and crema are required.
#
# ### Methods
#
# `.taskList('enable')` or `.taskList()`
#
# Enables TaskList updates for the container.
#
# `.taskList('disable')`
#
# Disables TaskList updates for the container.
#
## ### Events
#
# `tasklist:enabled`
#
# Fired when the TaskList is enabled.
#
# * **Synchronicity** Sync
# * **Bubbles** Yes
# * **Cancelable** No
# * **Target** `.js-task-list-container`
#
# `tasklist:disabled`
#
# Fired when the TaskList is disabled.
#
# * **Synchronicity** Sync
# * **Bubbles** Yes
# * **Cancelable** No
# * **Target** `.js-task-list-container`
#
# `tasklist:change`
#
# Fired before the TaskList item change takes affect.
#
# * **Synchronicity** Sync
# * **Bubbles** Yes
# * **Cancelable** Yes
# * **Target** `.js-task-list-field`
#
# `tasklist:changed`
#
# Fired once the TaskList item change has taken affect.
#
# * **Synchronicity** Sync
# * **Bubbles** Yes
# * **Cancelable** No
# * **Target** `.js-task-list-field`
#
# ### NOTE
#
# Task list checkboxes are rendered as disabled by default because rendered
# user content is cached without regard for the viewer. We enable checkboxes
# on `pageUpdate` if the container has a `(textarea).js-task-list-field`.
#
# To automatically enable TaskLists, add the `js-task-list-enable` class to the
# `js-task-list-container`.

incomplete = "[ ]"
complete   = "[x]"

# Pattern used to identify all task list items.
# Useful when you need iterate over all items.
itemPattern = ///
  ^
  (?:\s*[-+*]|(?:\d+\.))? # optional list prefix
  \s*                     # optional whitespace prefix
  (                       # checkbox
    #{complete.  replace(/([\[\]])/g, "\\$1")}|
    #{incomplete.replace(/([\[\]])/g, "\\$1")}
  )
  (?=\s)                  # followed by whitespace
///

# Used to filter out code fences from the source for comparison only.
# http://rubular.com/r/x5EwZVrloI
# Modified slightly due to issues with JS
codeFencesPattern = ///
  ^`{3}           # ```
    (?:\s*\w+)?   # followed by optional language
    [\S\s]        # whitespace
  .*              # code
  [\S\s]          # whitespace
  ^`{3}$          # ```
///mg

# Used to filter out potential mismatches (items not in lists).
# http://rubular.com/r/OInl6CiePy
itemsInParasPattern = ///
  ^
  (
    #{complete.  replace(/[\[\]]/g, "\\$1")}|
    #{incomplete.replace(/[\[\]]/g, "\\$1")}
  )
  .+
  $
///g

# Given the source text, updates the appropriate task list item to match the
# given checked value.
#
# Returns the updated String text.
updateTaskListItem = (source, itemIndex, checked) ->
  clean = source.replace(/\r/g, '').replace(codeFencesPattern, '').
    replace(itemsInParasPattern, '').split("\n")
  index = 0
  result = for line in source.split("\n")
    if line in clean && line.match(itemPattern)
      index += 1
      if index == itemIndex
        line =
          if checked
            line.replace(incomplete, complete)
          else
            line.replace(complete, incomplete)
    line
  result.join("\n")

# Updates the $field value to reflect the state of $item.
# Triggers the `tasklist:change` event before the value has changed, and fires
# a `tasklist:changed` event once the value has changed.
updateTaskList = ($item) ->
  $container = $item.closest '.js-task-list-container'
  $field     = $container.find '.js-task-list-field'
  index      = 1 + $container.find('.task-list-item-checkbox').index($item)
  checked    = $item.prop 'checked'

  $field.fire 'tasklist:change', [index, checked], ->
    $field.val updateTaskListItem($field.val(), index, checked)
    $field.trigger 'change'
    $field.fire 'tasklist:changed', [index, checked]

# When the task list item checkbox is updated, submit the change
$(document).on 'change', '.task-list-item-checkbox', ->
  updateTaskList $(this)

# Enables TaskList item changes.
enableTaskList = ($container) ->
  if $container.find('.js-task-list-field').length > 0
    $container.
      find('.task-list-item').addClass('enabled').
      find('.task-list-item-checkbox').attr('disabled', null)
    $container.addClass('is-task-list-enabled').
      trigger 'tasklist:enabled'

# Enables a collection of TaskList containers.
enableTaskLists = ($containers) ->
  for container in $containers
    enableTaskList $(container)

# Disable TaskList item changes.
disableTaskList = ($container) ->
  $container.
    find('.task-list-item').removeClass('enabled').
    find('.task-list-item-checkbox').attr('disabled', 'disabled')
  $container.removeClass('is-task-list-enabled').
    trigger 'tasklist:disabled'

# Disables a collection of TaskList containers.
disableTaskLists = ($containers) ->
  for container in $containers
    disableTaskList $(container)

$.fn.taskList = (method) ->
  $container = $(this).closest('.js-task-list-container')

  methods =
    enable: enableTaskLists
    disable: disableTaskLists

  methods[method || 'enable']($container)

# When the page is updated, enable new TaskList containers.
$.pageUpdate ->
  $('.js-task-list-container.js-task-list-enable').taskList()
