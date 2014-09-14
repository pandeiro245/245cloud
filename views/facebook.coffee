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
    appId      : window.env['facebook_app_id'],
    status     : true,
    xfbml      : true
  })

  Parse.FacebookUtils.logIn("user_likes", {
    success: (user) ->
      if !user.existed()
        alert("User signed up and logged in through Facebook!")
      else
        alert("Facebookログインに成功しました！")
      
      location.reload()
    ,
    error: (user, error) ->
      console.log error
      alert("User cancelled the Facebook login or did not fully authorize.")
  })
