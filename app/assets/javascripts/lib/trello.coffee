$ ->
  console.log 'start to Trello.authorize'
  Trello.authorize({
    type: "popup"
    name: "Getting Started Application"
    scope: {
      read: true
      write: true
    },
    expiration: "never",
    authenticationSuccess,
    authenticationFailure
  })

authenticationSuccess = ()->
 console.log "Successful authentication"
authenticationFailure = ()->
  console.log "Failed authentication"

