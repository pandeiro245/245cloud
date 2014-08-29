window.fbAsyncInit = () ->
  ((d, s, id) ->
     fjs = d.getElementsByTagName(s)[0]
     return if d.getElementById(id)
     js = d.createElement(s)
     js.id = id
     js.src = "//connect.facebook.net/en_US/all.js"
     fjs.parentNode.insertBefore(js, fjs)
  )(document, 'script', 'facebook-jssdk')

  #FIXME
  if localStorage['is_dev']
    app_id = '275431495992174'
  else
    app_id = '275431199325537'

  Parse.FacebookUtils.init({
    appId      : app_id,
    status     : true,
    xfbml      : true
  })

  Parse.FacebookUtils.logIn("user_likes", {
    success: (user) ->
      if !user.existed()
        alert("User signed up and logged in through Facebook!")
      else
        console.log user
        alert("User logged in through Facebook!")
      location.reload()
    ,
    error: (user, error) ->
      console.log error
      alert("User cancelled the Facebook login or did not fully authorize.")
  })
