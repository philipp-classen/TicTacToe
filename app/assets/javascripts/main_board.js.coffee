# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready ->
  $('#answer').text('Changed from CoffeeScript!')
  window.setTimeout(( () -> $('#answer').text('Changed from CoffeeScript! And again, it goes!')), 800);
  window.setTimeout(( () -> $('#answer').text('Changed from CoffeeScript!')), 2400);
