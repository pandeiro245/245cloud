require "active_support/core_ext/integer/time"

Rails.application.configure do
  # 基本設定
  config.enable_reloading = false
  config.eager_load = true
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  # アセット設定
  config.public_file_server.enabled = true
  config.public_file_server.headers = { "cache-control" => "public, max-age=#{1.year.to_i}" }
  config.assets.js_compressor = nil
  config.assets.compile = true

  # ストレージ設定
  config.active_storage.service = :local

  # SSL設定
  config.assume_ssl = true
  config.force_ssl = true
  config.ssl_options = {
    redirect: {
      port: 443,
      status: 307
    },
    hsts: {
      subdomains: true,
      preload: true,
      expires: 1.year
    }
  }

  # ログ設定
  config.log_level = :debug
  config.log_tags = [ :request_id ]
  config.logger = ActiveSupport::TaggedLogging.new(
    Logger.new(Rails.root.join("log/production.log"))
  )

  # ヘルスチェック
  config.silence_healthcheck_path = "/up"

  # キャッシュとジョブ
  config.active_support.report_deprecations = false
  config.cache_store = :solid_cache_store
  config.active_job.queue_adapter = :solid_queue
  config.solid_queue.connects_to = { database: { writing: :queue } }

  # メール設定
  config.action_mailer.default_url_options = { host: ENV.fetch('DOMAIN', nil) }

  # 国際化
  config.i18n.fallbacks = true

  # Active Record設定
  config.active_record.dump_schema_after_migration = false
  config.active_record.attributes_for_inspect = [ :id ]

  # セキュリティ設定
  config.action_controller.forgery_protection_origin_check = true
  config.action_controller.allow_forgery_protection = true
  config.action_dispatch.default_headers = {
    'X-Frame-Options' => 'SAMEORIGIN',
    'X-XSS-Protection' => '1; mode=block',
    'X-Content-Type-Options' => 'nosniff',
    'Strict-Transport-Security' => 'max-age=31536000; includeSubDomains'
  }
  config.hosts = nil
  config.host_authorization = { exclude: ->(_request) { true } }
end
