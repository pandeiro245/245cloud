class SlackBotWatcher < SlackRubyBot::Bot
  match /.*/ do |client, data, match|
    provider = Provider.find_by(name: 'slack')
    user = ProviderUser.find_by(
      provider: provider,
      key: data.user
    ).user
    SlackBot.new(user, data, match).exec
  end
end
