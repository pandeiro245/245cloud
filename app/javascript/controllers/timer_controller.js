import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["time"];
  
  connect() {
    console.log("Timer controller connected");
    this.originalTitle = document.title;
    this.audioPlayed = false;
    this.setupAudio();
    this.updateTimer();
  }

  setupAudio() {
    // 音声要素を取得（DOMから直接取得）
    this.audio = document.getElementById('hato');
    
    if (!this.audio) {
      console.error('音声要素が見つかりません');
      return;
    }

    // 音声の読み込みを監視
    this.audio.addEventListener('canplaythrough', () => {
      console.log('音声ファイルの読み込みが完了しました');
    });

    this.audio.addEventListener('error', (e) => {
      console.error('音声ファイルの読み込みエラー:', e);
    });

    // ユーザーインタラクションを待機
    document.addEventListener('click', () => {
      // 音声を読み込むだけ（まだ再生はしない）
      this.audio.load();
    }, { once: true });
  }

  updateTimer() {
    const now = new Date().getTime();
    const diff = (window.will_reload_at - now) / 1000;
    console.log("残り時間:", diff);

    if (diff < 0) {
      location.reload();
    } else {
      const min = Math.floor(diff / 60);
      const sec = Math.floor(diff % 60);
      const timeString = `${min}:${sec < 10 ? "0" + sec : sec}`;
      
      this.timeTarget.textContent = timeString;
      document.title = `${timeString} | ${this.originalTitle}`;

      // 7秒前の処理
      if (diff <= 7 && !this.audioPlayed && this.audio) {
        console.log("7秒前：音声再生開始");
        try {
          // 音声の再生位置をリセット
          this.audio.currentTime = 0;
          const playPromise = this.audio.play();
          
          if (playPromise !== undefined) {
            playPromise.then(() => {
              console.log("音声再生成功");
              this.audioPlayed = true;
            }).catch(error => {
              console.error("音声再生失敗:", error);
              // エラーが発生した場合、フラグをリセットして再試行できるようにする
              this.audioPlayed = false;
            });
          }
        } catch(e) {
          console.error("再生エラー:", e);
          this.audioPlayed = false;
        }
      }

      setTimeout(() => {
        this.updateTimer();
      }, 1000);
    }
  }

  disconnect() {
    if (this.audio) {
      this.audio.pause();
      this.audio.currentTime = 0;
    }
    document.title = this.originalTitle;
  }
}
