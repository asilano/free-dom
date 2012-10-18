var supportForm = function()
{
  var input = document.createElement('input'),
         form = document.createElement('form'),
         formId = 'test-input-form-reference-support';
    // Id of the remote form
    form.id = formId;
    // Add form and input to DOM
    $('body').append($(form));
    $('body').append($(input));
    // Add reference of form to input
    input.setAttribute('form', formId);
    // Check if reference exists
    var res = !(input.form == null);
    // Remove elements
    $(form).remove();
    $(input).remove();
    return res;

}

if (!supportForm())
{

  $(document).on('click', 'input[type=submit][form], button[form]', function() {
      var form = $('#' + $(this).attr('form'));
      form.submit();
    })
    .on('submit', 'form', function() {
      var form = $(this);
      $('input[form='+form.attr('id')+'][type!=submit]').each(function() {
        form.append('<input type="hidden" />').attr('name', $(this).attr('name')).val($(this).val());
      });
    });
}
