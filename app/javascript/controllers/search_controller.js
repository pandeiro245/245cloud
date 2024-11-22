import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]

  connect() {
    // 戻る/進むボタンの処理を追加
    window.addEventListener("popstate", () => {
      const frame = document.getElementById("search_results")
      frame.setAttribute("src", window.location.href)
      
      // 検索ワードを入力欄に反映
      const params = new URLSearchParams(window.location.search)
      this.inputTarget.value = params.get("search_word") || ""
    })

    this.inputTarget.addEventListener("keypress", (e) => {
      if (e.key === "Enter") {
        e.preventDefault()
        
        const frame = document.getElementById("search_results")
        const currentUrl = new URL(window.location.href)
        const searchParams = new URLSearchParams(currentUrl.search)
        searchParams.set("search_word", this.inputTarget.value)
        
        const newUrl = `${currentUrl.pathname}?${searchParams.toString()}`
        
        // URLを更新
        window.history.pushState({}, '', newUrl)
        
        // Turbo Frame を更新
        frame.setAttribute("src", newUrl)
      }
    })
  }

  disconnect() {
    this.inputTarget.removeEventListener("keypress")
    window.removeEventListener("popstate")
  }
}
