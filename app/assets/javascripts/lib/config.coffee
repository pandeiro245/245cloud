env = {
  sc_client_id: '2b9312964a1619d99082a76ad2d6d8c6'
  et_client_id: '534872bc1c3389f658f335e241a25efd219fd144'
}
env.pomotime =  if localStorage['dev_pomo'] then parseFloat(localStorage['dev_pomo']) else 24
env.chattime =  if localStorage['dev_chat'] then parseFloat(localStorage['dev_chat']) else 5

if location.href.match(/245cloud.com/) || location.href.match(/production_mode=/)
  env.yt_client_id = 'AIzaSyAvb5RW4gNEcQlaHODHZ1h0jjYxD8mKvIM'
else
  env.yt_client_id = 'AIzaSyD1A25NZMbp4VA4uikV8e-naG7oVa-B1pY'
  
@env = env
