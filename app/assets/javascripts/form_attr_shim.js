var supportForm = function()
{
  var input = document.createElement("input");
  if ("form" in input)
  {
    input.setAttribute("form", "12345");

    if (input.form == "12345")
      return true;
  }

  return false;
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
