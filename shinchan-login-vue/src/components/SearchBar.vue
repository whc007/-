<template>
  <!-- 首页搜索栏：大输入框 + 按钮 + 热门标签（仅前端，搜索未接后端） -->
  <div class="search">
    <div class="box">
      <input
        v-model="keyword"
        type="text"
        placeholder="搜点什么好玩的…"
        @keyup.enter="submit"
      />
      <button type="button" @click="submit">搜 ！</button>
    </div>

    <div class="hots">
      <span class="label">热门：</span>
      <button
        v-for="hot in hots"
        :key="hot"
        class="chip"
        type="button"
        @click="pick(hot)"
        >{{ hot }}</button
      >
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'

const emit = defineEmits(['search'])

const keyword = ref('')
const hots = ['动感超人', '康达姆机器人', '巧克比', '小白', '风间彻', '妮妮']

function submit() {
  const k = keyword.value.trim()
  if (!k) return
  emit('search', k)
}

function pick(hot) {
  keyword.value = hot
  emit('search', hot)
}
</script>

<style scoped>
.search {
  width: min(92vw, 560px);
  margin: 0 auto;
}

.box {
  display: flex;
  gap: 12px;
}
.box input {
  flex: 1;
  min-width: 0;
  font-family: inherit;
  font-size: 17px;
  padding: 14px 18px;
  color: var(--ink);
  background: var(--card-bg);
  border: 3px solid var(--ink);
  border-radius: var(--radius-input);
  box-shadow: var(--shadow-input);
  outline: none;
  transition: box-shadow 0.12s;
}
.box input:focus {
  box-shadow: var(--shadow-input-focus);
}
.box input::placeholder {
  color: rgba(43, 43, 43, 0.4);
}
.box button {
  flex: none;
  font-family: inherit;
  font-size: 18px;
  letter-spacing: 3px;
  padding: 0 26px;
  color: #fff;
  background: var(--red);
  border: 3px solid var(--ink);
  border-radius: var(--radius-button);
  box-shadow: var(--shadow-button);
  cursor: pointer;
  transition: transform 0.08s, box-shadow 0.08s, background 0.12s;
}
.box button:hover {
  background: #ff5d4d;
}
.box button:active {
  transform: translate(5px, 5px);
  box-shadow: 0 0 0 var(--ink);
}

.hots {
  margin-top: 14px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-wrap: wrap;
  gap: 8px;
}
.label {
  font-size: 13px;
  color: rgba(43, 43, 43, 0.65);
}
.chip {
  font-family: inherit;
  font-size: 13px;
  padding: 5px 13px;
  color: var(--ink);
  background: var(--cream);
  border: 2px solid var(--ink);
  border-radius: 14px 10px 14px 10px;
  box-shadow: 2px 2px 0 rgba(43, 43, 43, 0.25);
  cursor: pointer;
  transition: background 0.12s, transform 0.08s;
}
.chip:hover {
  background: var(--yellow);
}
.chip:active {
  transform: translate(2px, 2px);
  box-shadow: 0 0 0 rgba(43, 43, 43, 0.25);
}
</style>
