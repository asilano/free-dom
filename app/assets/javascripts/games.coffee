# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->
  $('.random-name').on 'click', (e) ->
    $('#game_name').val(this.textContent)

  $('.random-regenerate').on 'ajax:success', (event) ->
    $('.random-name').text(event.detail[0])