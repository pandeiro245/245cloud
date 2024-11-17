import "@hotwired/turbo-rails"
import { Application } from "@hotwired/stimulus"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"

// Stimulusアプリケーションを開始
window.Stimulus = Application.start()

// controllersディレクトリ内のすべてのコントローラーをロード
eagerLoadControllersFrom("controllers", window.Stimulus)
