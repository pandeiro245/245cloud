import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["time"];
  
  connect() {
    console.log("Timer controller connected");
    this.originalTitle = document.title;
    this.audioPlayed = false;
    this.isTransitioning = false;
    this.retryCount = 0;
    this.maxRetries = 3;
    this.setupAudio();
    this.updateTimer();
  }

  setupAudio() {
    this.audio = document.getElementById('hato');
    
    if (!this.audio) {
      console.error('音声要素が見つかりません');
      return;
    }

    this.audio.addEventListener('canplaythrough', () => {
      console.log('音声ファイルの読み込みが完了しました');
    });

    this.audio.addEventListener('error', (e) => {
      console.error('音声ファイルの読み込みエラー:', e);
    });

    document.addEventListener('click', () => {
      this.audio.load();
    }, { once: true });
  }

  async handleStateTransition() {
    if (this.isTransitioning) return;
    
    try {
      this.isTransitioning = true;
      
      // ページ遷移の前に少し待機して状態の同期を待つ
      await new Promise(resolve => setTimeout(resolve, 500));
      
      const response = await fetch('/api/check_state', {
        method: 'GET',
        headers: {
          'Accept': 'application/json',
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]')?.content
        }
      });

      if (!response.ok) {
        throw new Error(`State check failed: ${response.status}`);
      }

      location.reload();
    } catch (error) {
      console.error('State transition error:', error);
      
      if (this.retryCount < this.maxRetries) {
        this.retryCount++;
        console.log(`Retrying transition (${this.retryCount}/${this.maxRetries})...`);
        setTimeout(() => this.handleStateTransition(), 1000);
      } else {
        console.error('Max retries reached, forcing reload');
        location.reload();
      }
    } finally {
      this.isTransitioning = false;
    }
  }

  updateTimer() {
    const now = new Date().getTime();
    const diff = (window.will_reload_at - now) / 1000;
    console.log("残り時間:", diff);

    if (diff <= 0) {
      if (!this.isTransitioning) {
        this.handleStateTransition();
      }
    } else {
      const min = Math.floor(diff / 60);
      const sec = Math.floor(diff % 60);
      const timeString = `${min}:${sec < 10 ? "0" + sec : sec}`;
      
      this.timeTarget.textContent = timeString;
      document.title = `${timeString} | ${this.originalTitle}`;

      if (diff <= 7 && !this.audioPlayed && this.audio) {
        console.log("7秒前：音声再生開始");
        try {
          this.audio.currentTime = 0;
          const playPromise = this.audio.play();
          
          if (playPromise !== undefined) {
            playPromise.then(() => {
              console.log("音声再生成功");
              this.audioPlayed = true;
            }).catch(error => {
              console.error("音声再生失敗:", error);
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
