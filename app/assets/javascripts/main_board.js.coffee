# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

get_board_size = () ->
  (Number) ($('#board_size_input').val())

get_row_length = () ->
  (Number) ($('#row_length_input').val())

verify_result = () ->
  board_size = get_board_size()
  row_length = get_row_length()
  if row_length <= board_size
    $('.error-text').hide()
  else
    $('.error-text').text('Number of rows must not exceed the board size')
    $('.error-text').show()

$(document).ready ->
  verify_result
  $('select').change(verify_result)
