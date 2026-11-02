<template>
  <!-- 手绘风提示气泡，替代原生 window.alert -->
  <transition name="toast">
    <div v-if="show" class="toast" @click="$emit('close')">
      <span class="star">★</span>
      <p class="text">{{ text }}</p>
    </div>
  </transition>
</template>

<script setup>
defineProps({
  show: { type: Boolean, default: false },
  text: { type: String, default: '' },
})
defineEmits(['close'])
</script>

<style scoped>
.toast {
  position: fixed;
  left: 50%;
  top: 22%;
  transform: translateX(-50%);
  z-index: 10;
  max-width: 80vw;
  padding: 18px 26px;
  background: var(--card-bg);
  border: 3px solid var(--ink);
  border-radius: 22px 16px 24px 14px;
  box-shadow: 6px 6px 0 var(--ink);
  text-align: center;
  font-size: 16px;
  color: var(--ink);
  cursor: pointer;
}
.toast .star {
  color: var(--red);
  font-size: 20px;
  display: block;
  margin-bottom: 4px;
}
.toast .text {
  white-space: pre-line;
  line-height: 1.5;
}
.toast-enter-active {
  animation: pop 0.4s var(--ease-pop) both;
}
.toast-leave-active {
  transition: opacity 0.25s ease;
}
.toast-leave-to {
  opacity: 0;
}
</style>
