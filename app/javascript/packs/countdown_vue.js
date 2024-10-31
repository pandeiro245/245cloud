import { createApp } from 'vue';
import Countdown from '../countdown.vue';

document.addEventListener('DOMContentLoaded', () => {
  const app = createApp(Countdown);
  app.mount('.time'); // Vue 3 では mount メソッドを使用
  console.log(app);
});
