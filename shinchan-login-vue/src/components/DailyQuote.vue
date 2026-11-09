<template>
  <!-- 今日小新：每天一句台词，可手动换一句（纯前端互动） -->
  <section class="quote">
    <div class="face-wrap" :class="{ wobble }" @click="next">
      <ShinchanFace />
    </div>
    <div class="body">
      <p class="label">今日小新 · {{ dayLabel }}</p>
      <p class="text" :key="index">{{ quotes[index] }}</p>
      <button class="next" type="button" @click="next">换一句 ↻</button>
    </div>
  </section>
</template>

<script setup>
import { computed, ref } from 'vue'
import ShinchanFace from './ShinchanFace.vue'
import { quotes } from '../data/shinchan.js'

const dayIndex = Math.floor(Date.now() / 86400000) % quotes.length
const index = ref(dayIndex)
const wobble = ref(false)

const dayLabel = computed(() => {
  const d = new Date()
  return `${d.getMonth() + 1} 月 ${d.getDate()} 日`
})

function next() {
  if (quotes.length < 2) return
  let i = index.value
  while (i === index.value) {
    i = Math.floor(Math.random() * quotes.length)
  }
  index.value = i
  wobble.value = false
  requestAnimationFrame(() => {
    wobble.value = true
  })
  setTimeout(() => (wobble.value = false), 520)
}
</script>

<style scoped>
.quote {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 14px 18px;
  background: var(--card-bg);
  border: 3px solid var(--ink);
  border-radius: 22px 16px 24px 15px;
  box-shadow: 5px 5px 0 rgba(43, 43, 43, 0.2);
}

.face-wrap {
  flex: none;
  width: 58px;
  height: 58px;
  cursor: pointer;
}
/* ShinchanFace 固定 74px，这里缩到 58px */
.face-wrap :deep(.face) {
  transform: scale(0.78);
  transform-origin: top left;
  margin: 0;
}
.face-wrap.wobble :deep(.face) {
  animation: shake 0.5s var(--ease-pop);
}
@keyframes shake {
  0%,
  100% {
    transform: scale(0.78) rotate(0);
  }
  30% {
    transform: scale(0.84) rotate(-7deg);
  }
  65% {
    transform: scale(0.84) rotate(6deg);
  }
}

.body {
  flex: 1;
  min-width: 0;
}
.label {
  font-size: 11px;
  color: rgba(43, 43, 43, 0.55);
  letter-spacing: 1px;
}
.text {
  font-size: 15px;
  line-height: 1.6;
  color: var(--ink);
  margin: 3px 0 6px;
  animation: fade 0.28s ease-out;
}
@keyframes fade {
  from {
    opacity: 0;
    transform: translateY(4px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}
.next {
  font-family: inherit;
  font-size: 12px;
  padding: 3px 11px;
  color: var(--blue);
  background: var(--cream);
  border: 2px solid var(--blue);
  border-radius: 13px 9px 13px 9px;
  cursor: pointer;
  transition: background 0.12s, transform 0.08s;
}
.next:hover {
  background: #e8f4ff;
}
.next:active {
  transform: translate(1px, 1px);
}
</style>
