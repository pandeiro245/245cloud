class Instance < ApplicationRecord
  def fetch_users
    data = fetch_json_from_api('users.json')
    data.each do |user_data|
      process_record(user_data, User, find_by: [:id]) do |user, data|
        params = data.except('screen_name')
        user.update(params)
        download_profile_image(user)
      end
    end
  end

  def fetch_workloads
    data = fetch_json_from_api('api/workloads/download.json')
    data.each { |record| process_record(record, Workload, find_by: [:created_at, :user_id]) }
  end

  def fetch_workloads_all
    fetch_paginated_data('api/workloads/download.json', Workload, find_by: [:created_at, :user_id])
  end

  def fetch_comments
    data = fetch_json_from_api('api/comments/download.json')
    data.each do |record|
      process_record(record, Comment, find_by: [:created_at, :user_id]) do |comment, data|
        data = data.except('id')
        data.each { |key, val| comment.send("#{key}=", val) }
        comment.save!(validate: false)
      end
    end
  end

  def fetch_comments_all
    fetch_paginated_data('api/comments/download.json', Comment, find_by: [:created_at, :user_id]) do |comment, data|
      data.each { |key, val| comment.send("#{key}=", val) }
      comment.save!(validate: false)
    end
  end

  private

  def fetch_json_from_api(endpoint, params = {})
    query_params = { token: ENV.fetch('TOKEN', nil) }.merge(params)
    query_string = query_params.map { |k, v| "#{k}=#{v}" }.join('&')
    uri = URI("https://#{host}/#{endpoint}?#{query_string}")
    json = Net::HTTP.get(uri)
    JSON.parse(json) unless json.blank?
  end

  def process_record(record, model_class, find_by: [:id], custom_processing = nil)
    Rails.logger.debug record['id']
    
    # find_byの条件を構築
    conditions = find_by.each_with_object({}) do |attr, hash|
      hash[attr] = record[attr.to_s]
    end
    
    instance = model_class.find_or_initialize_by(conditions)
    
    if custom_processing
      custom_processing.call(instance, record)
    else
      instance.update(record)
    end
  end

  def fetch_paginated_data(endpoint, model_class, find_by: [:id], custom_processing = nil)
    page = 1
    loop do
      Rails.logger.debug { "page is #{page} #{model_class}.count is #{model_class.count}" }
      data = fetch_json_from_api(endpoint, { page: page })
      break unless data

      data.each do |record|
        process_record(record, model_class, find_by: find_by, custom_processing: custom_processing)
      end
      page += 1
    end
  end

  def download_profile_image(user)
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
