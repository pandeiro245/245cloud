class SlackBot < Bot
  Slack.configure do |config|
    config.token = ENV['SLACK_API_TOKEN']
  end 

  def initialize(user=nil, data=nil, match=nil)
    @user = user
    @client = Slack::Web::Client.new
    @data = data
    if @data.present?
      @channel = @data['channel']
      @ts = @data['ts']
    else
      @channel = 'CR4Q7GH0Q'
      @ts = '1575166363.041900'
    end
    @match = match
    @provider = Provider.find_by(name: 'slack')
  end

  def echo(text)
    @client.chat_postMessage(
      channel: @channel,
      text: text,
      thread_ts: @ts,
      as_user: false
    )
  end

  def update(text)
    @client.chat_update(
      channel: @channel,
      text: text,
      ts: thread_ts,
			as_user: false
    )
  end

  def thread_ts
    @message.present? ? @message.message.ts : '1575167814.043700'
  end

  def sleep_sec
    0.8
  end
end
