#mlkcca = new MilkCocoa("#{@env.milkcocoa}.mlkcca.com")
#@socket = mlkcca.dataStore('workload')
#
#@socket.on( 'push', (params) ->
#  console.log 'mlkcca', params
#  params = params.value
#  if params.type == 'comment'
#    #unless params.comment.facebook_id == window.facebook_id
#    if true
#      @addComment(params.room_id, params.comment)
#  else if params.type == 'doing'
#    @addDoing(params.workload)
#  else if params.type == 'chatting'
#    @addChatting(params.workload)
#  else if params.type == 'finish'
#    @stopUser(params.workload.facebook_id)
#)
#
