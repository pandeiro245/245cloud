require_relative "boot"
require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module NishikoCloud
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    config.hosts << ENV['WHITE_HOST']
    Time.zone = 'Tokyo'

    # アセットパイプラインの設定
    config.assets.enabled = true

    # アセットのパスを明示的に指定
    config.assets.paths << Rails.root.join("app/assets/stylesheets")
    config.assets.paths << Rails.root.join("app/assets/javascripts")
    config.assets.paths << Rails.root.join("app/assets/images")

    # プリコンパイル対象のアセットを指定
    config.assets.precompile += %w[chatting.css]

    # 開発環境特有の設定
    if Rails.env.development?
      # アセットのキャッシュを無効化
      config.assets.configure do |env|
        env.cache = ActiveSupport::Cache.lookup_store(:null_store)
      end

      # デバッグ情報の出力を有効化
      config.assets.debug = true

      # アセットのダイジェストを無効化
      config.assets.digest = false

      # ライブリロードの設定
      config.middleware.insert_after ActionDispatch::Static, Rack::LiveReload if defined?(Rack::LiveReload)
    end

    # production環境特有の設定
    if Rails.env.production?
      # 本番環境ではアセットの圧縮を有効化
      config.assets.compress = true
      config.assets.compile = false
      config.assets.digest = true
    end
  end
end
