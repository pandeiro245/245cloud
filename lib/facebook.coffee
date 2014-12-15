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
      alert("Facebookログインに成功しました！")
      FB.api(
        "/me",
        (response) ->
          if response && !response.error
            user.set('icon_url', response.data.url)
            FB.api(
              "/me",
              (response) ->
                success: () ->
                  if response && !response.error
                    user.set('name', response.name)
                    user.set('facebook_id_str', response.id)
                    user.save()
                    location.reload()
                ,
                error: (model, error) ->
                  console.log error
                  alert '何かしらのエラーが発生しました...西小倉に直接ご連絡お願いします...'
            )
      )
    ,
    error: (user, error) ->
      console.log error
      alert("User cancelled the Facebook login or did not fully authorize.")
  })
