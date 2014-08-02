window.fbAsyncInit = () ->
  ((d, s, id) ->
     fjs = d.getElementsByTagName(s)[0]
     return if d.getElementById(id)
     js = d.createElement(s)
     js.id = id
     js.src = "//connect.facebook.net/en_US/all.js"
     fjs.parentNode.insertBefore(js, fjs)
  )(document, 'script', 'facebook-jssdk')

  Parse.FacebookUtils.init({
    appId      : '275431495992174',
    status     : true,
    xfbml      : true
  })

  Parse.FacebookUtils.logIn(null, {
    success: (user) ->
      if !user.existed()
        alert("User signed up and logged in through Facebook!")
      else
        alert("User logged in through Facebook!")
      location.reload()
    ,
    error: (user, error) ->
      console.log error
      alert("User cancelled the Facebook login or did not fully authorize.")
  })
