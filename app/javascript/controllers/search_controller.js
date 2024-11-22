import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]
  
  connect() {
    // 初期表示時に保存された検索ワードを反映
    const savedSearchWord = localStorage.getItem("searchWord")
    if (savedSearchWord) {
      this.inputTarget.value = savedSearchWord
      this.updateSearchResults(savedSearchWord)
    }

    // ブラウザの戻る/進むボタンの処理
    window.addEventListener("popstate", this.handlePopState.bind(this))
    
    // 検索入力のイベントリスナー
    this.inputTarget.addEventListener("keypress", this.handleKeyPress.bind(this))
  }
  
  disconnect() {
    window.removeEventListener("popstate", this.handlePopState.bind(this))
    this.inputTarget.removeEventListener("keypress", this.handleKeyPress.bind(this))
  }

  handlePopState() {
    const savedSearchWord = localStorage.getItem("searchWord") || ""
    this.inputTarget.value = savedSearchWord
    this.updateSearchResults(savedSearchWord)
  }

  handleKeyPress(e) {
    if (e.key === "Enter") {
      e.preventDefault()
      const searchWord = this.inputTarget.value
      
      // localStorageに検索ワードを保存
      localStorage.setItem("searchWord", searchWord)
      
      // 履歴に追加（オプション）
      this.addToSearchHistory(searchWord)
      
      // 検索結果を更新
      this.updateSearchResults(searchWord)
    }
  }

  updateSearchResults(searchWord) {
    const frame = document.getElementById("search_results")
    const baseUrl = window.location.pathname
    const searchUrl = searchWord ? `${baseUrl}?search_word=${encodeURIComponent(searchWord)}` : baseUrl
    frame.setAttribute("src", searchUrl)
  }

  // 検索履歴を管理する機能（オプション）
  addToSearchHistory(searchWord) {
    const MAX_HISTORY = 10
    let searchHistory = JSON.parse(localStorage.getItem("searchHistory") || "[]")
    
    // 重複を避けて先頭に追加
    searchHistory = searchHistory.filter(word => word !== searchWord)
    searchHistory.unshift(searchWord)
    
    // 最大件数を超えた場合、古い履歴を削除
    if (searchHistory.length > MAX_HISTORY) {
      searchHistory = searchHistory.slice(0, MAX_HISTORY)
    }
    
    localStorage.setItem("searchHistory", JSON.stringify(searchHistory))
  }
}
