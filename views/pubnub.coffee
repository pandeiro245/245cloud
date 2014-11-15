if location.href.match(/245cloud.com/)
  channel = '245cloud_prod'
else
  channel = '245cloud_dev'

pubnub_setup = {
  channel       : channel,
  publish_key: 'pub-c-3a4bd949-4c5d-4803-86a4-503439a445dc',
  subscribe_key: 'sub-c-449d11bc-67c1-11e4-814d-02ee2ddab7fe'
}

@socket = io.connect( 'http://pubsub.pubnub.com', pubnub_setup )

@socket.on( 'connect', () ->
  console.log('Connection Established! Ready to send/receive data!')
)

@socket.on( 'message', (params) ->
  console.log 'pubnub', params
  if params.type == 'comment'
    @addComment(params.comment)
  else if params.type == 'doing'
    @addDoing(params.workload)
)

@socket.on( 'disconnect', () ->
  console.log('my connection dropped')
)

@socket.on( 'reconnect', () ->
  console.log('my connection has been restored!')
)

