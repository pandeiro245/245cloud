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
      if ENV['DISCORD_DEBUG_CHANNEL'].blank? || event.channel.id == ENV['DISCORD_DEBUG_CHANNEL']
        user = ProviderUser.find_by(
          provider: provider,
          key: event.user.id
        ).user
        DiscordBot.new(event, user).exec
      end
    end
    bot.run
  end
end
