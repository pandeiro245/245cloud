env = {
  sc_client_id: '2b9312964a1619d99082a76ad2d6d8c6'
  et_client_id: '534872bc1c3389f658f335e241a25efd219fd144'
}
env.pomotime =  if localStorage['dev_pomo'] then parseFloat(localStorage['dev_pomo']) else 24
env.chattime =  if localStorage['dev_chat'] then parseFloat(localStorage['dev_chat']) else 5
env.spartatime =  if localStorage['dev_sparta'] then parseFloat(localStorage['dev_sparta']) else 1

if location.href.match(/245cloud.com/)
  env.parse_app_id = 'jemiGIUHsvNeVQojqiUaXxFJZvzFDxFbUsfjPr78'
  env.parse_key = 'ZoyMZflFV5H2VoASJv505vJ2wWd9zqa2ZW5MU780'
  env.facebook_app_id = '275431199325537'
else if location.href.match(/nishikocloud-c9.herokuapp.com/)
  env.parse_app_id = 'jemiGIUHsvNeVQojqiUaXxFJZvzFDxFbUsfjPr78'
  env.parse_key = 'ZoyMZflFV5H2VoASJv505vJ2wWd9zqa2ZW5MU780'
  env.facebook_app_id = '296210843914239'
else if location.href.match(/245cloud-c9-pandeiro245.c9.io/)
  #env.parse_app_id = 'FbrNkMgFmJ5QXas2RyRvpg82MakbIA1Bz7C8XXX5'
  #env.parse_key = 'yYO5mVgOdcCSiGMyog7vDp2PzTHqukuFGYnZU9wU'

  # 245cloud-old
  env.parse_app_id = '8QzCMkUbx7TyEApZjDRlhpLQ2OUj0sQWTnkEExod'
  env.parse_key = 'gzlnFfIOoLFQzQ08bU4mxkhAHcSqEok3rox0PBOM'
  env.facebook_app_id = '287966291405361'

else if location.href.match(/vast-reef-2868.herokuapp.com/)
  env.parse_app_id = '8QzCMkUbx7TyEApZjDRlhpLQ2OUj0sQWTnkEExod'
  env.parse_key = 'gzlnFfIOoLFQzQ08bU4mxkhAHcSqEok3rox0PBOM'
  env.facebook_app_id = '322021711333152'
  
else if location.href.match(/localhost:3001/)
  env.parse_app_id = '8QzCMkUbx7TyEApZjDRlhpLQ2OUj0sQWTnkEExod'
  env.parse_key = 'gzlnFfIOoLFQzQ08bU4mxkhAHcSqEok3rox0PBOM'
  env.facebook_app_id = '322004764668180'

  #env.parse_app_id = 'jemiGIUHsvNeVQojqiUaXxFJZvzFDxFbUsfjPr78'
  #env.parse_key = 'ZoyMZflFV5H2VoASJv505vJ2wWd9zqa2ZW5MU780'
else
  alert 'please check config.coffee'

@env = env
