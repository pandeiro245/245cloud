require 'rails_helper'

def brwoser_log
   puts page.driver.error_messages
   puts page.driver.console_messages
end

def login(user)
  OmniAuth.config.test_mode = true
  OmniAuth.config.mock_auth[:facebook] = OmniAuth::AuthHash.new({
    :provider => 'facebook',
    :uid => '123545'
  })
  #post '/auth/identity/callback', screen_name: user.screen_name, password: password
end

feature 'TOPページ' do
  it 'トップページが表示できること' do
    visit '/'
    expect(page).to have_content '24分間集中しましょう'
  end
end

feature 'Facebookでログインする' do
  context do
    let(:user) { FactoryGirl.create(:user) }

    scenario js: true do
      visit '/'
      login(user)
      page.save_screenshot 'screenshot.png'
      brwoser_log
      expect(page).to have_content 'Facebook'
    end
  end
end
