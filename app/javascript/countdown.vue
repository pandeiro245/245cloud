<template>
  <span class='time'>{{ timerCount }}</span>
</template>

<script>
export default {
  data() {
    return {
      timerCount: '24:00'
    }
  },
  watch: {
    timerCount: {
      handler() {
        var now = new Date().getTime();
        var diff = (window.will_reload_at - now) / 1000;
        if (diff < 0) {
          location.reload();
        } else {
          setTimeout(() => {
            var min = parseInt(diff / 60);
            var sec = parseInt(diff - min * 60);
            this.timerCount = min+':'+sec;
          }, 1000);
        }
      },
      immediate: true // This ensures the watcher is triggered upon creation
    }
  }
}
</script>

<style scoped>
p {
  font-size: 2em;
  text-align: center;
}
</style>
