class Sync
  def users
    uri = URI("https://245cloud.com/users.json?&token=#{ENV.fetch('TOKEN', nil)}")
    json = Net::HTTP.get(uri)
    JSON.parse(json).each do |u|
      Rails.logger.debug u['id']
      user = User.find_or_initialize_by(
        id: u['id']
      )
      params = u
      params.delete('screen_name')
      user.update(u)

      image_url = "https://245cloud.com/images/profile/#{user['id']}.jpg"
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

  def workloads
    page = 1
    loop do
      puts "page is #{page} Workload.count is #{Workload.count}"
      uri = URI("https://245cloud.com/api/workloads/download.json?&token=#{ENV.fetch('TOKEN', nil)}&page=page")
      json = Net::HTTP.get(uri)
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
end
