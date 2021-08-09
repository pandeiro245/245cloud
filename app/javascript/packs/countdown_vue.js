import Vue from 'vue'
import Countdown from '../countdown.vue'

document.addEventListener('DOMContentLoaded', () => {
  const countdown = new Vue({
    el: '.time',
    render: h => h(Countdown)
  })
  console.log(countdown)
})

