<script setup>
/**
 * 手绘风提示气泡
 * 替代原版的 window.alert()：不阻塞页面、样式统一、可自动消失。
 */
defineProps({
  /** 是否显示 */
  visible: { type: Boolean, default: false },
  /** 提示文案，支持 \n 换行 */
  text: { type: String, default: '' },
})
</script>

<template>
  <Transition name="note">
    <div v-if="visible" class="note" role="status" aria-live="polite">
      <p class="note__text">{{ text }}</p>
    </div>
  </Transition>
</template>

<style scoped>
.note {
  position: absolute;
  left: 50%;
  bottom: -66px;
  transform: translateX(-50%);
  min-width: 200px;
  max-width: 92%;
  padding: 12px 18px;
  background: var(--c-yellow);
  border: var(--stroke);
  border-radius: var(--r-btn);
  box-shadow: 4px 4px 0 var(--c-ink);
  animation: note-in 0.35s var(--ease-pop) both;
}

.note__text {
  font-size: 15px;
  line-height: 1.5;
  text-align: center;
  white-space: pre-line;
  color: var(--c-ink);
}

.note-leave-active {
  transition: opacity 0.25s ease, transform 0.25s ease;
}

.note-leave-to {
  opacity: 0;
  transform: translate(-50%, 6px);
}
</style>
