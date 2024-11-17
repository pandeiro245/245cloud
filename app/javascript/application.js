import "@hotwired/turbo-rails"
import { Application } from "@hotwired/stimulus"
import { registerControllers } from "@hotwired/stimulus-loading"

// Stimulus起動
window.Stimulus = Application.start()

// コントローラーの登録
const context = require.context("./controllers", true, /\.js$/)
registerControllers(context)

// コントローラーのデバッグ用（問題解決後に削除可能）
console.log("Registered Stimulus controllers:", Stimulus.controllers)
