<template>
  <!-- 首页顶部导航栏：品牌 + 导航链接 + 用户区 -->
  <nav class="nav">
    <div class="inner">
      <div class="brand">
        <div class="logo-face"><ShinchanFace /></div>
        <span class="name">春日部乐园</span>
      </div>

      <div class="links">
        <a
          v-for="item in items"
          :key="item"
          href="#"
          :class="{ active: item === current }"
          @click.prevent="onClick(item)"
          >{{ item }}</a
        >
      </div>

      <div class="user">
        <span class="hello">{{ username }}</span>
        <button class="logout" type="button" @click="$emit('logout')">溜了溜了</button>
      </div>
    </div>
  </nav>
</template>

<script setup>
import { ref } from 'vue'
import ShinchanFace from './ShinchanFace.vue'

defineProps({
  username: { type: String, default: '小伙伴' },
})
const emit = defineEmits(['logout', 'nav-todo'])

const items = ['首页', '动画', '漫画', '游戏']
const current = ref('首页')

function onClick(item) {
  if (item === current.value) return
  // 其他页面还没做，交给首页弹提示
  emit('nav-todo', item)
}
</script>

<style scoped>
.nav {
  position: sticky;
  top: 0;
  z-index: 5;
  background: var(--card-bg);
  border-bottom: 3px solid var(--ink);
  box-shadow: 0 4px 0 rgba(43, 43, 43, 0.15);
}

.inner {
  max-width: 1080px;
  margin: 0 auto;
  padding: 10px 20px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
  flex-wrap: wrap;
}

.brand {
  display: flex;
  align-items: center;
  gap: 10px;
}
.logo-face {
  width: 42px;
  height: 42px;
  overflow: visible;
  flex: none;
}
/* ShinchanFace 固定 74px，这里缩小成导航栏 logo */
.logo-face :deep(.face) {
  transform: scale(0.55);
  transform-origin: top left;
  margin: 0;
}
.name {
  font-size: 20px;
  letter-spacing: 2px;
  color: var(--red);
  text-shadow: 2px 2px 0 var(--yellow);
}

.links {
  display: flex;
  align-items: center;
  gap: 20px;
}
.links a {
  color: var(--ink);
  text-decoration: none;
  font-size: 16px;
  letter-spacing: 1px;
}
.links a:hover {
  text-decoration: underline wavy;
}
.links a.active {
  color: var(--red);
  font-weight: bold;
  text-decoration: underline wavy var(--red);
  text-underline-offset: 5px;
}

.user {
  display: flex;
  align-items: center;
  gap: 12px;
}
.hello {
  color: var(--blue);
  font-weight: bold;
  font-size: 15px;
}
.logout {
  font-family: inherit;
  font-size: 14px;
  letter-spacing: 1px;
  padding: 7px 14px;
  color: var(--ink);
  background: var(--yellow);
  border: 3px solid var(--ink);
  border-radius: var(--radius-button);
  box-shadow: 4px 4px 0 var(--ink);
  cursor: pointer;
  transition: transform 0.08s, box-shadow 0.08s;
}
.logout:hover {
  background: #ffe266;
}
.logout:active {
  transform: translate(4px, 4px);
  box-shadow: 0 0 0 var(--ink);
}

@media (max-width: 640px) {
  .inner {
    justify-content: center;
  }
}
</style>
