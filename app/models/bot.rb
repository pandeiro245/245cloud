class Bot
  attr_accessor :user, :message
 def exec
    start = Time.now 
    if user.blank?
      # echo("please login https://245cloud.com/auth/#{@provider.name}")
    else
      @workload = user.start!

      base_uri = 'https://neat-glazing-702.firebaseio.com/'
      token = File.open('tmp/token.json').read
      firebase = Firebase::Client.new(base_uri, token)
     response = firebase.push("workloads", {
        facebook_id: user.facebook_id,
        created_at: Time.now.to_i * 1000
      })
  
      start_post

      case self.class.to_s
      when 'DiscordBot'
        while(@workload.playing?) do
          process_post
          sleep sleep_sec
        end
        @workload.to_done!
        complete_post
      when 'SlackBot'
        pw = @workload.provider_workload(@provider.name)
        pw.val = @data.to_json
        pw.save!
      end
    end
  end

  def batch
    loop do
      Workload.playings.each do |workload|
        puts "workload.id is #{workload.id}"
        workload.check
      end
      sleep 0.2
    end
  end

  def start_post
    @message = echo("#{@workload.number}回目の集中開始！ ")
  end

  def process_post(workload=nil)
    workload ||= @workload
    binding.pry
    update("#{workload.number}回目の集中完了まであと#{workload.remain_text}#{by_user_name}")
  end

  def by_user_name
    ''
  end

  def complete_post(workload=nil)
    workload ||= @workload
    update("#{workload.number}回集中しました。おつかれさまでした！#{by_user_name}")
  end
end
