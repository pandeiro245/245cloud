class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  def status
    return 'playing' if playing.present?
    return 'chatting' if chatting.present?
    return 'before'
  end

  def playing
    Workload.playings.where(user_id: id).first 
  end

  def chatting
    Workload.chattings.where(user_id: id).first
  end

  def url
    refresh_token! if token.blank?
    "https://245cloud.com/login?user_id=#{id}&token=#{token}"
  end

  def refresh_token!
    self.token = SecureRandom.hex(64)
    self.save!
  end

  def workloads
    Workload.his(id).bests.limit(48)
  end

  def start!(params)
    Workload.find_or_start_by_user(self, params)
  end

  def to_done!
    w = Workload.his(
      id
    ).chattings.first
    w.to_done! if w.present?
    w
  end

  def save_image_from_twitter(auth_hash)
    image_url = auth_hash[:info][:image]
    uri = URI.parse(image_url)

    unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
      raise "Invalid URL: #{image_url}"
    end

    file_path = "public/images/profile/#{id}.jpg"

    Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
      request = Net::HTTP::Get.new(uri)

      http.request(request) do |response|
        case response
        when Net::HTTPSuccess
          File.open(file_path, 'wb') do |file|
            response.read_body { |chunk| file.write(chunk) }
          end
        else
          raise "Failed to download image: #{response.message}"
        end
      end
    end
  end

  def email_required?
    false
  end

  def password_required?
    false
  end
end

