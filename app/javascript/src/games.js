// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
// You can use CoffeeScript in this file: http://coffeescript.org/
import Sortable from 'sortablejs';
var onmount = require("onmount")

onmount('.random-name', function() {
  $(this).on('click', function(e) {
    $('#game_name').val(this.textContent);
  });
});

onmount('.random-regenerate', function() {
  $(this).on('ajax:success', event => $('.random-name').text(event.detail[0]));
});

onmount('.reorder-cards', function() {
  let reorderable;
  const wrapper = $(this);
  wrapper.find('.reorder-no-js').each(function(ix, el) {
    const sel = $(el).find('select');
    $(el).append($('<span class="reorder-position">').text(sel.children('option:selected').text()));
    sel.hide();
  });
  reorderable = Sortable.create(this, {
    onEnd(evt) {
      wrapper.find('.reorder-no-js').each(function(ix, el) {
        const sel = $(el).find('select');
        sel.val(ix + 1);
        $(el).children('span.reorder-position').text(sel.children('option:selected').text());
      });
    }
  });
});

let scrollPosition = 0;
const refreshTimer = undefined;
onmount('body[data-controller=games][data-action=show]', function() {
  let reloader;
  clearTimeout(refreshTimer);
  $('html').scrollTop(scrollPosition);
  scrollPosition = 0;

  const journals = $('#journal-log')[0];
  journals.scrollTop = journals.scrollHeight;
  const SECONDS = 30;
  reloader = function() {
    scrollPosition = $('html').scrollTop();
    Turbolinks.visit(location.toString(), {action: 'replace'});
  };
});
  // refreshTimer = setTimeout reloader, SECONDS * 1000

onmount('#discord-report', function() {
  $(this).on('click', 'span', function(e) {
    $(this).siblings('form').toggle();
  });
});