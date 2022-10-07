// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
// You can use CoffeeScript in this file: http://coffeescript.org/
import Sortable from 'sortablejs';
var onmount = require("onmount")

onmount('#discord-report', function() {
  $(this).on('click', 'span', function(e) {
    $(this).siblings('form').toggle();
  });
});