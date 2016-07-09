require 'rails_helper'

def login(user)
  OmniAuth.config.test_mode = true
  OmniAuth.config.mock_auth[:facebook] = OmniAuth::AuthHash.new({
    :provider => 'facebook',
    :uid => '123545'
  })
  find("input[value='facebookログイン']").click
end

def debug_network
  page.driver.network_traffic.each do |a|
    a.response_parts.uniq(&:url).each do |response|
      puts "Responce URL #{response.url}: Status #{response.status}"
    end
  end
end

feature 'TOPページ' do
  context 'ログイン前' do
    let(:user) { FactoryGirl.create(:user) }

    scenario 'トップページが表示する' do
      visit '/'
      expect(page).to have_content '245cloudは24分間、自分の作業に集中'
      # Facebookログインボタン
      expect(page).to have_css("input[value='facebookログイン']")
      page.save_screenshot 'screenshot0.png'
    end

    scenario 'Facebookでログインする' do
      visit '/'
      login(user)
      expect(page).to have_content 'おまかせ'
      expect(page).to have_content '無音'
      page.save_screenshot 'screenshot1.png'
    end
  end
end
