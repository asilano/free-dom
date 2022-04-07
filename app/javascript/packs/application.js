/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb


// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)
import $ from "jquery"
import "onmount"
import "../src/games"
import Turbolinks from "turbolinks"
import 'jquery-sortablejs'
import Foundation from "foundation-sites"

import "controllers"

require("@rails/ujs").start();
window.jQuery = $;
require('foundation-sites');
var onmount = require("onmount")

Turbolinks.start();

Foundation.Tooltip.defaults.triggerClass = ''

$(document).on('ready show.bs closed.bs load page:change turbolinks:load', function () {
  onmount()
})
$(document).on('turbolinks:before-cache', function () { onmount.teardown() })

$(function() {
  FontAwesome.dom.watch({observeMutationsRoot: document})
})

onmount('body', function() {
  $(this).addClass('js-active')
  $(document).foundation()
})
onmount('.js', function() {
  $(this).removeClass('js')
})
onmount('.hide-js', function() {
  $(this).hide()
})