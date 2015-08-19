$(()->
  $(".create_comment").keypress((e) ->
    if e.which == 13 #enter
      console.log 'comment start'
      addComment()

      return false
  )
)

addComment = () ->
  console.log @env.milkcocoa
  content = $('.create_comment').val()
  return if content.length < 1
  $('.create_comment').val('')

  mlkcca = new MilkCocoa("#{@env.milkcocoa}.mlkcca.com")
  @socket = mlkcca.dataStore('workload')

  @socket.push({
    type: 'comment'
    comment: {body: content, objectId:'aaa', _url: 'bbb'}
    room_id: 'room_id'
  })
  $.post('/comments', {comment: {content: content, room_id: location.href.split('/').pop()}})
  
