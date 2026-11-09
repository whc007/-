<template>
  <!-- 卡片详情弹窗：点推荐卡打开，可左右翻看 -->
  <transition name="fade">
    <div v-if="item" class="mask" @click.self="$emit('close')">
      <div class="sheet" role="dialog" aria-modal="true">
        <div class="banner" :style="{ background: item.color }">
          <span class="sym">{{ item.symbol }}</span>
          <button class="x" type="button" aria-label="关闭" @click="$emit('close')">×</button>
        </div>

        <div class="body">
          <span class="cat">{{ item.category }} · {{ item.tag }}</span>
          <h3>{{ item.title }}</h3>
          <p class="desc">{{ item.description }}</p>
          <p class="review">小新说：「{{ review }}」</p>

          <div class="actions">
            <button class="ghost" type="button" @click="$emit('prev')">← 上一个</button>
            <button class="ghost" type="button" @click="$emit('next')">下一个 →</button>
            <button class="solid" type="button" @click="$emit('close')">关掉啦</button>
          </div>
        </div>
      </div>
    </div>
  </transition>
</template>

<script setup>
import { ref, watch } from 'vue'
import { quotes } from '../data/shinchan.js'

const props = defineProps({
  item: { type: Object, default: null }
})
defineEmits(['close', 'prev', 'next'])

const review = ref('')

function rollReview() {
  review.value = quotes[Math.floor(Math.random() * quotes.length)]
}

watch(() => props.item, (v) => {
  if (v) rollReview()
}, { immediate: true })
</script>

<style scoped>
.mask {
  position: fixed;
  inset: 0;
  z-index: 20;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 20px;
  background: rgba(43, 43, 43, 0.42);
  backdrop-filter: blur(2px);
}

.sheet {
  width: min(94vw, 420px);
  background: var(--card-bg);
  border: 3px solid var(--ink);
  border-radius: 26px 18px 30px 16px;
  box-shadow: 10px 12px 0 var(--ink);
  overflow: hidden;
  animation: pop 0.35s var(--ease-pop) both;
}

.banner {
  position: relative;
  height: 92px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-bottom: 3px solid var(--ink);
}
.sym {
  font-size: 40px;
  color: #fff;
  text-shadow: 2px 2px 0 var(--ink);
}
.x {
  position: absolute;
  top: 8px;
  right: 10px;
  width: 28px;
  height: 28px;
  font-family: inherit;
  font-size: 18px;
  line-height: 1;
  color: #fff;
  background: rgba(43, 43, 43, 0.55);
  border: 2px solid #fff;
  border-radius: 50%;
  cursor: pointer;
}

.body {
  padding: 16px 20px 18px;
}
.cat {
  display: inline-block;
  font-size: 11px;
  padding: 2px 9px;
  color: var(--blue);
  background: var(--cream);
  border: 2px solid var(--blue);
  border-radius: 11px 8px 11px 8px;
}
h3 {
  font-size: 20px;
  letter-spacing: 1px;
  margin: 8px 0 6px;
}
.desc {
  font-size: 14px;
  line-height: 1.65;
  color: rgba(43, 43, 43, 0.8);
}
.review {
  margin-top: 12px;
  padding: 9px 12px;
  font-size: 13px;
  line-height: 1.6;
  color: var(--ink);
  background: var(--cream);
  border: 2px dashed rgba(43, 43, 43, 0.35);
  border-radius: 14px 10px 14px 10px;
}

.actions {
  display: flex;
  gap: 8px;
  margin-top: 16px;
}
.ghost,
.solid {
  flex: 1;
  font-family: inherit;
  font-size: 13px;
  padding: 8px 6px;
  border: 2.5px solid var(--ink);
  border-radius: 14px 10px 14px 10px;
  cursor: pointer;
  transition: background 0.12s, transform 0.08s, box-shadow 0.08s;
}
.ghost {
  color: var(--ink);
  background: var(--cream);
}
.ghost:hover {
  background: var(--yellow);
}
.solid {
  color: #fff;
  background: var(--red);
  box-shadow: 3px 3px 0 var(--ink);
}
.solid:active {
  transform: translate(3px, 3px);
  box-shadow: 0 0 0 var(--ink);
}

.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.18s ease;
}
.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>
