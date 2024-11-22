import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["time"];
  
  connect() {
    console.log("Timer controller connected");
    this.originalTitle = document.title;  // 元のタイトルを保存
    this.updateTimer();
  }

  updateTimer() {
    const now = new Date().getTime();
    const diff = (window.will_reload_at - now) / 1000;
    
    if (diff < 0) {
      location.reload();
    } else {
      const min = Math.floor(diff / 60);
      const sec = Math.floor(diff % 60);
      const timeString = `${min}:${sec < 10 ? "0" + sec : sec}`;
      
      // カウントダウン表示の更新
      this.timeTarget.textContent = timeString;
      
      // タイトルの更新
      document.title = `${timeString} | ${this.originalTitle}`;
      
      setTimeout(() => {
        this.updateTimer();
      }, 1000);
    }   
  }

  disconnect() {
    // コントローラーが切断されたときに元のタイトルに戻す
    document.title = this.originalTitle;
  }
}
