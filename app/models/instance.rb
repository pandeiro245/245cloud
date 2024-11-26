class Instance < ApplicationRecord
  USER_IDENTIFIER_KEYS = %w[facebook_id discord_id twitter_id token].freeze

  def self.fetch
    actives.each(&:fetch)
  end

  def self.actives
    all.reject { |i| i.host == ENV['DOMAIN'] }
  end

  def fetch
    fetch_workloads
    fetch_comments
  end

  def fetch_users
    data = fetch_json_from_api('users.json')
    data.each do |user_data|
      next unless should_sync_user?(user_data)

      process_record(user_data, User, find_keys: detect_user_key(user_data)) do |user, api_data|
        params = api_data.except('screen_name')
        user.update(params)
        download_profile_image(user, api_data)
      end
    end
  end

  def fetch_workloads
    data = fetch_json_from_api('api/workloads/download.json')
    data.each do |record|
      process_record(record, Workload, find_keys: %w[created_at user_id]) do |workload, api_data|
        # is_doneがtrueの場合は保持し、それ以外の属性を更新
        if workload.persisted? && workload.is_done
          api_data = api_data.except('id', 'is_done')
          workload.update(api_data)
        else
          api_data = api_data.except('id')
          workload.update(api_data)
        end
      end
    end
  end

  def fetch_workloads_all(resume: nil)
    fetch_paginated_data('api/workloads/download.json', Workload, find_keys: %w[created_at user_id], resume: resume)
  end

  def fetch_comments
    data = fetch_json_from_api('api/comments/download.json')
    data.each do |record|
      process_record(record, Comment, find_keys: %w[created_at user_id]) do |comment, api_data|
        api_data = api_data.except('id')
        api_data.each { |key, val| comment.send("#{key}=", val) }
        comment.save!(validate: false)
      end
    end
  end

  def fetch_comments_all
    fetch_paginated_data('api/comments/download.json', Comment, find_keys: %w[created_at user_id]) do |comment, api_data|
      api_data.each { |key, val| comment.send("#{key}=", val) }
      comment.save!(validate: false)
    end
  end

  private

  def should_sync_user?(user_data)
    USER_IDENTIFIER_KEYS.any? { |key| user_data[key].present? }
  end

  def detect_user_key(user_data)
    USER_IDENTIFIER_KEYS.each do |key|
      return [key] if user_data[key].present?
    end
    ['id'] # フォールバック（通常は呼ばれない）
  end

  def fetch_json_from_api(endpoint, params = {})
    query_params = { token: ENV.fetch('TOKEN', nil) }.merge(params)
    query_string = query_params.map { |k, v| "#{k}=#{v}" }.join('&')
    uri = URI("https://#{host}/#{endpoint}?#{query_string}")
    json = Net::HTTP.get(uri)
    JSON.parse(json) if json.present?
  end

  def process_record(record, model_class, find_keys:, custom_processing: nil)
    if record.is_a?(Array)
      Rails.logger.error "#{host} is invalid"
      return
    end

    Rails.logger.debug record['id']

    conditions = find_keys.each_with_object({}) do |key, hash|
      hash[key.to_sym] = record[key]
    end

    target_record = model_class.find_or_initialize_by(conditions)

    if custom_processing
      custom_processing.call(target_record, record)
    else
      record_without_id = record.except('id')
      target_record.update(record_without_id)
    end
  end

  def fetch_paginated_data(endpoint, model_class, find_keys:, custom_processing: nil, resume: nil)
    page = 1
    page = (resume / 1000) + 1 if resume.present?
    loop do
      Rails.logger.debug { "page is #{page} #{model_class}.count is #{model_class.count}" }
      data = fetch_json_from_api(endpoint, { page: page })
      break unless data

      data.each do |record|
        process_record(record, model_class, find_keys: find_keys, custom_processing: custom_processing)
      end
      page += 1
    end
  end

  def download_profile_image(user, data)
    image_url = "https://#{host}/images/profile/#{data['id']}.jpg"
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
