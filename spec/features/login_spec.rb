require 'rails_helper'

def brwoser_log
  puts '--- error log ---'
   p page.driver.error_messages
  puts '--- console log ---'
   p page.driver.console_messages
end

# FIXME: 実際にログイン処理を実装できてるわけでない
def login(user)
  OmniAuth.config.test_mode = true
  OmniAuth.config.mock_auth[:facebook] = OmniAuth::AuthHash.new({
    :provider => 'facebook',
    :uid => '123545'
  })
  #post '/auth/faceboo/callback', screen_name: user.facebook_id
end

feature 'TOPページ' do
  scenario 'トップページが表示する' do
    visit '/'

    expect(page).to have_content '245cloudは24分間、自分の作業に集中'
    # Facebookログインボタン
    expect(page).to have_css("input[value='facebookログイン']")
  end

  context 'ログイン前' do
    skip 'Facebook処理をモックにしないといけないため実装できてない'
    let(:user) { FactoryGirl.create(:user) }
    scenario 'Facebookでログインする' do
      visit '/'
      login(user)
    end
  end
end
