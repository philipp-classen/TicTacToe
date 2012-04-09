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
    $('#start_game_button').show()
  else
    $('.error-text').text('The number of rows must not exceed the board size')
    $('.error-text').show()
    $('#start_game_button').hide()

# for setup screen...
$(document).ready ->
  verify_result
  $('select').change(verify_result)


move_made = (elem) ->
  elem[0].value = $('#hidden-next-to-move')[0].value.toUpperCase()
  elem.removeClass('empty_square')
  $('.empty_square:enabled').attr('disabled', 'true')
  $('#main_title').text('Waiting for computer move')
  setInterval((()->
    title = $('#main_title').text()
    if title == 'Waiting for computer move...'
      $('#main_title').text('Waiting for computer move')
    else
      $('#main_title').text(title + '.')
  ), 700);

# for wait_for_move...
$(document).ready ->
  $('.empty_square:enabled').click(() -> move_made($(this)))
