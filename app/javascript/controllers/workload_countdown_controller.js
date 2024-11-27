import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = { 
    finishTime: Number,
    pomoTime: Number,
    chatTime: Number,
    status: String
  }
  
  connect() {
    this.updateTimer();
  }

  updateTimer() {
    const now = new Date().getTime();
    const diff = (this.finishTimeValue - now) / 1000;

    if (diff <= 0) {
      // カウントダウン終了時の処理
      this.moveWorkload();
      if (this.timeout) {
        clearTimeout(this.timeout);
      }
      return;
    }

    const timeLeft = Math.abs(diff);
    const min = Math.floor(timeLeft / 60);
    const sec = Math.floor(timeLeft % 60);
    const timeText = `あと${min}:${sec < 10 ? "0" + sec : sec}`;
    this.element.textContent = timeText;

    this.timeout = setTimeout(() => {
      this.updateTimer();
    }, 1000);
  }

  moveWorkload() {
    const workloadElement = this.element.closest('.workload');
    const currentStatus = this.statusValue;
    
    // 移動先のセクションを決定
    let targetSection;
    if (currentStatus === 'playing') {
      targetSection = document.querySelector('#chatting .workloads_list');
      this.element.textContent = 'チャット中...';
    } else if (currentStatus === 'chatting') {
      targetSection = document.querySelector('#done .workloads_list');
      this.element.textContent = '完了';
    }

    if (targetSection && workloadElement) {
      // 要素を移動
      targetSection.insertBefore(workloadElement, targetSection.firstChild);
    }
  }

  disconnect() {
    if (this.timeout) {
      clearTimeout(this.timeout);
    }
  }
}
