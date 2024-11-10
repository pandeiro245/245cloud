import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["time"];

  connect() {
    console.log("Timer controller connected");
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
      this.timeTarget.textContent = `${min}:${sec < 10 ? "0" + sec : sec}`;

      setTimeout(() => {
        this.updateTimer();
      }, 1000);
    }
  }
}

