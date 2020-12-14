// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require rails-ujs
//= require turbolinks
//= require jquery3
//= require foundation
//= require onmount
//= require sortable-rails-jquery
//= require_tree .

Foundation.Tooltip.defaults.triggerClass = ''

$(document).on('ready show.bs closed.bs load page:change turbolinks:load', function () {
  $.onmount()
})
$(document).on('turbolinks:before-cache', function () { $.onmount.teardown() })

$(function() {
  FontAwesome.dom.watch({observeMutationsRoot: document})
})

$.onmount('body', function() {
  $(this).addClass('js-active')
  $(document).foundation()
})
$.onmount('.js', function() {
  $(this).removeClass('js')
})