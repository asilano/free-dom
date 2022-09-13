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
import "../src/games"
import 'jquery-sortablejs'
import "@hotwired/turbo-rails"

import "controllers"

import Rails from "@rails/ujs";
Rails.start();

window.jQuery = $;
var onmount = require("onmount")

$(document).on('ready show.bs closed.bs load page:change turbo:load', function () {
  onmount()
})
$(document).on('turbo:before-cache', function () { onmount.teardown() })

$(function() {
  FontAwesome.dom.watch({observeMutationsRoot: document})
})

onmount('body', function() {
  $(this).addClass('js-active')
})
onmount('.js', function() {
  $(this).removeClass('js')
})
onmount('.hide-js', function() {
  $(this).hide()
})
