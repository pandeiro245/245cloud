require "active_support/core_ext/integer/time"

Rails.application.configure do
  # 基本設定
  config.enable_reloading = true
  config.eager_load = false
  config.consider_all_requests_local = true
  config.server_timing = true

  # アセットパイプライン設定
  config.assets.debug = true
  config.assets.compile = true
  config.assets.digest = false
  config.assets.version = Time.now.to_i.to_s
  config.assets.check_precompiled_asset = false
  
  # キャッシュ設定
  config.cache_classes = false
  config.action_controller.perform_caching = false
  config.cache_store = :null_store
  config.assets.cache_limit = false
  config.assets.configure do |env|
    env.cache = ActiveSupport::Cache.lookup_store(:null_store)
  end

  # ファイル監視設定
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker
  
  # Live Reload設定
  config.middleware.insert_after ActionDispatch::Static, Rack::LiveReload, 
    min_delay: 0.5,
    max_delay: 10,
    pure_js: true,
    host: 'localhost',
    port: '35729',
    ignore: [ %r{.map$} ]

  # その他の既存設定は残したまま...
  config.active_storage.service = :local
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.perform_caching = false
  config.action_mailer.default_url_options = { host: "localhost", port: 3000 }
  config.active_support.deprecation = :log
  config.active_record.migration_error = :page_load
  config.active_record.verbose_query_logs = true
  config.active_record.query_log_tags_enabled = true
  config.active_job.verbose_enqueue_logs = true
  config.action_view.annotate_rendered_view_with_filenames = true
  config.action_controller.raise_on_missing_callback_actions = true
  config.web_console.permissions = '106.72.63.101'
  config.hosts.clear
  config.web_console.whitelisted_ips = '0.0.0.0/0'
end
