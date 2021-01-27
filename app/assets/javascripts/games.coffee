# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$.onmount '.random-name', ->
  $(this).on 'click', (e) ->
    $('#game_name').val(this.textContent)

$.onmount '.random-regenerate', ->
  $(this).on 'ajax:success', (event) ->
    $('.random-name').text(event.detail[0])

$.onmount '.reorder-cards', ->
  wrapper = $(this)
  wrapper.find('.reorder-no-js').each (ix, el) ->
    sel = $(el).find('select')
    $(el).append($('<span class="reorder-position">').text(sel.children('option:selected').text()))
    sel.hide()
  reorderable = Sortable.create this,
    onEnd: (evt) ->
      wrapper.find('.reorder-no-js').each (ix, el) ->
        sel = $(el).find('select')
        sel.val(ix + 1)
        $(el).children('span.reorder-position').text(sel.children('option:selected').text())

scrollPosition = 0
refreshTimer = undefined
$.onmount 'body', ->
  clearTimeout(refreshTimer)
  $('html').scrollTop(scrollPosition)
  scrollPosition = 0

  journals = $('#journal-log')[0]
  journals.scrollTop = journals.scrollHeight
  SECONDS = 30
  reloader = ->
    scrollPosition = $('html').scrollTop()
    Turbolinks.visit(location.toString(), {action: 'replace'})
  refreshTimer = setTimeout reloader, SECONDS * 1000
