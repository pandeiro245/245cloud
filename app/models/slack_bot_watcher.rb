class SlackBotWatcher < SlackRubyBot::Bot
  match /.*/ do |client, data, match|
    provider = Provider.find_by(name: 'slack')
    pu = ProviderUser.find_by(
      provider: provider,
      key: data.user
    )
    user = pu.present? ? pu.user : nil
    SlackBot.new(user, data, match).exec
  end
end
