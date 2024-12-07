class User < ActiveRecord::Base
  has_many :workloads, dependent: :destroy

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  attr_accessor :done

  def status
    return 'playing' if playing.present?
    return 'chatting' if chatting.present? && done.blank?
    return 'before'
  end

  def playing
    workloads.playings.first
  end

  def chatting
    workloads.chattings.first
  end

  def url
    refresh_token! if token.blank?
    "https://245cloud.com/login?user_id=#{id}&token=#{token}"
  end

  def refresh_token!
    self.token = SecureRandom.hex(64)
    self.save!
  end

  def recent_workloads
    workloads.bests.limit(48)
  end

  def start!(params)
    workloads.find_or_start_by_user(self, params)
  end

  def to_done!
    workload = workloads.chattings.first
    workload.to_done! if workload.present?
    workload
  end

  def recalculate_workload_numbers!(start_date: nil, end_date: nil)
    end_date ||= Time.zone.now.to_date
    start_date ||= Time.zone.now.to_date - 30.days
    workloads.recalculate_numbers_for_user(id, start_date: start_date, end_date: end_date)
  end

  def save_image_from_twitter(auth_hash)
    image_url = auth_hash[:info][:image]
    uri = URI.parse(image_url)

    raise "Invalid URL: #{image_url}" unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)

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
