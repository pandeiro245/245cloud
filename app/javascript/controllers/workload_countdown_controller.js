import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = { 
    finishTime: Number,
    pomoTime: Number,
    chatTime: Number
  }
  
  connect() {
    this.updateTimer();
  }

  updateTimer() {
    const now = new Date().getTime();
    const diff = (this.finishTimeValue - now) / 1000;

    if (diff < -((this.pomoTimeValue + this.chatTimeValue) * 60)) {
      this.element.remove();
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

  disconnect() {
    if (this.timeout) {
      clearTimeout(this.timeout);
    }
  }
}
