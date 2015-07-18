$(() ->
  $(document).on('click', '.pref_title', () ->
    $pref_city = $(this).parent().parent().find('.pref_city')
    if $pref_city.hasClass('off')
      $pref_city.show()
      $pref_city.removeClass('off')
    else
      $pref_city.hide()
      $pref_city.addClass('off')
    return false
  )

  $(document).on('click', '.city_title', () ->
    $pref_city = $(this).parent().parent().find('.city_lot')
    if $pref_city.hasClass('off')
      $pref_city.show()
      $pref_city.removeClass('off')
    else
      $pref_city.hide()
      $pref_city.addClass('off')
    return false
  )
)
