class DiscordBotWatcher
  def self.run
    self.new.run
  end

  def provider
    @provider ||= Provider.find_by(name: 'discord')
  end

  def run
    bot = Discordrb::Commands::CommandBot.new(
      token: ENV['DISCORD_TOKEN'],
      client_id: ENV['DISCORD_CLIENT_ID'],
      prefix: '/',
    )
    bot.command :pomo do |event|
      user = ProviderUser.find_by(
        provider: provider,
        key: event.user.id
      ).user
      DiscordBot.new(event, user).exec
    end
    bot.run
  end
end
