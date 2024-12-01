require_relative "boot"
require "rails/all"
Bundler.require(*Rails.groups)

module NishikoCloud
  class Application < Rails::Application
    config.load_defaults 8.0
    config.autoload_paths += %W[#{config.root}/app/services]
    config.autoload_lib(ignore: %w[assets tasks])

    # ホスト認証設定
    config.hosts << ENV['DOMAIN']
    config.hosts << "localhost"
    config.hosts << "127.0.0.1"

    # タイムゾーン設定
    Time.zone = 'Tokyo'

    # アセット設定
    config.assets.enabled = true
    config.assets.paths << Rails.root.join("app/assets/stylesheets")
    config.assets.paths << Rails.root.join("app/assets/javascripts")
    config.assets.paths << Rails.root.join("app/assets/images")
    config.assets.precompile += %w[chatting.css]
    config.assets.js_compressor = nil
    config.assets.compile = true

    if Rails.env.production?
      # SSL設定
      config.force_ssl = true
      config.ssl_options = {
        hsts: { expires: 1.year, subdomains: true },
        redirect: { status: 307 }
      }

      # セキュリティヘッダー設定
      config.action_dispatch.default_headers.merge!(
        'Strict-Transport-Security' => 'max-age=31536000; includeSubDomains',
        'X-Frame-Options' => 'SAMEORIGIN',
        'X-XSS-Protection' => '1; mode=block',
        'X-Content-Type-Options' => 'nosniff'
      )

      # アセット設定
      config.assets.compress = true
      config.assets.compile = false
      config.assets.digest = true

      # エラーレポート設定
      config.consider_all_requests_local = false

      # ロガー設定
      config.logger = ActiveSupport::Logger.new($stdout)
    end

    if Rails.env.development?
      config.assets.configure do |env|
        env.cache = ActiveSupport::Cache.lookup_store(:null_store)
      end
      config.assets.debug = true
      config.assets.digest = false
      config.middleware.insert_after ActionDispatch::Static, Rack::LiveReload if defined?(Rack::LiveReload)
    end
  end
end
