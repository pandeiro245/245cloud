class Instance < ApplicationRecord
  def fetch_users
    uri = URI("https://#{host}/users.json?&token=#{ENV.fetch('TOKEN', nil)}")
    json = Net::HTTP.get(uri)
    JSON.parse(json).each do |u|
      Rails.logger.debug u['id']
      user = User.find_or_initialize_by(
        id: u['id']
      )
      params = u
      params.delete('screen_name')
      user.update(u)

      image_url = "https://#{host}/images/profile/#{user['id']}.jpg"
      uri = URI.parse(image_url)
      file_path = "public/images/profile/#{user.id}.jpg"
      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
        request = Net::HTTP::Get.new(uri)

        http.request(request) do |response|
          case response
          when Net::HTTPSuccess
            File.open(file_path, 'wb') do |file|
              response.read_body { |chunk| file.write(chunk) }
            end
          else
            Rails.logger.debug { "Failed to download image: #{response.message}" }
          end
        end
      end
    end
  end

  def fetch_workloads
    uri = URI("https://host/api/workloads/download.json?&token=#{ENV.fetch('TOKEN', nil)}")
    json = Net::HTTP.get(uri)
    JSON.parse(json).each do |w|
      Rails.logger.debug w['id']
      workload = Workload.find_or_initialize_by(
        id: w['id']
      )
      workload.update(w)
    end
  end

  def fetch_workloads_all
    page = 1
    loop do
      Rails.logger.debug { "page is #{page} Workload.count is #{Workload.count}" }
      uri = URI("https://host/api/workloads/download.json?&token=#{ENV.fetch('TOKEN', nil)}&page=#{page}")
      json = Net::HTTP.get(uri)
      break if json.blank?

      JSON.parse(json).each do |w|
        Rails.logger.debug w['id']
        workload = Workload.find_or_initialize_by(
          id: w['id']
        )
        workload.update(w)
      end
      page += 1
    end
  end

  def fetch_comments
    uri = URI("https://host/api/comments/download.json?&token=#{ENV.fetch('TOKEN', nil)}")
    json = Net::HTTP.get(uri)
    array = JSON.parse(json)
    array.each do |w|
      Rails.logger.debug w['id']
      comment = Comment.find_or_initialize_by(
        id: w['id']
      )
      w.delete('id')
      w.each do |key, val|
        comment.send("#{key}=", val)
      end
      comment.save!(validate: false)
    end
  end

  def fetch_comments_all
    page = 1
    loop do
      Rails.logger.debug { "page is #{page} Comment.count is #{Comment.count}" }
      uri = URI("https://host/api/comments/download.json?&token=#{ENV.fetch('TOKEN', nil)}&page=#{page}")
      json = Net::HTTP.get(uri)
      break if json.blank?

      JSON.parse(json).each do |w|
        Rails.logger.debug w['id']
        comment = Comment.find_or_initialize_by(
          id: w['id']
        )
        w.each do |key, val|
          comment.send("#{key}=", val)
        end
        comment.save!(validate: false)
      end
      page += 1
    end
  end
end
