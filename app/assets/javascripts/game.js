function enable_freq_form() {
  $('#update_freq').removeClass("lighter");
  $('#update_freq_value').hide();
  $('#update_freq_form').show();
  $('#change_freq').hide();
  $('#cancel_freq').show();
};
function disable_freq_form() {
  $('#update_freq').addClass("lighter");
  $('#update_freq_value').show();
  $('#update_freq_form').hide();
  $('#change_freq').show();
  $('#cancel_freq').hide();
}

$(function() {
  $('#change_freq a').click(enable_freq_form);
  $('#cancel_freq a').click(disable_freq_form);

  $('#show_ranking_explain').click(function() {
    $('#explain_ranking').slideToggle();
  });
});
