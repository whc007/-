<template>
  <!-- 角色图鉴：横向滚动，点开看角色口头禅 -->
  <section class="gallery">
    <div class="head">
      <h2><span class="mark">◆</span> 角色图鉴</h2>
      <span class="hint">点一下卡片，看它说了什么</span>
    </div>

    <div class="row">
      <button
        v-for="c in characters"
        :key="c.name"
        class="person"
        type="button"
        :class="{ open: active === c.name }"
        @click="toggle(c.name)"
      >
        <span class="avatar" :style="{ background: c.color }">
          <img
            v-if="avatars[c.key]"
            :src="avatars[c.key]"
            :alt="c.name"
            loading="lazy"
            decoding="async"
          />
          <i v-else class="initial">{{ c.initial }}</i>
        </span>
        <span class="nm">{{ c.name }}</span>
        <span class="meta">{{ c.age }} · {{ c.role }}</span>
        <span v-if="active === c.name" class="line">「{{ c.line }}」</span>
      </button>
    </div>
  </section>
</template>

<script setup>
import { ref } from 'vue'
import { characters } from '../data/shinchan.js'
import { avatars } from '../data/avatars.js'

const active = ref('')

function toggle(name) {
  active.value = active.value === name ? '' : name
}
</script>

<style scoped>
.gallery {
  margin-top: 34px;
}
.head {
  display: flex;
  align-items: baseline;
  gap: 10px;
  margin-bottom: 12px;
}
.head h2 {
  font-size: 20px;
  letter-spacing: 2px;
}
.head .mark {
  color: var(--blue);
}
.hint {
  font-size: 12px;
  color: rgba(43, 43, 43, 0.55);
}

.row {
  display: flex;
  gap: 10px;
  overflow-x: auto;
  padding: 4px 2px 12px;
  scrollbar-width: thin;
}
.row::-webkit-scrollbar {
  height: 6px;
}
.row::-webkit-scrollbar-thumb {
  background: rgba(43, 43, 43, 0.25);
  border-radius: 3px;
}

.person {
  flex: none;
  width: 148px;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 3px;
  padding: 12px 8px 12px;
  font-family: inherit;
  text-align: center;
  background: var(--card-bg);
  border: 2.5px solid var(--ink);
  border-radius: 18px 13px 19px 13px;
  box-shadow: 3px 3px 0 rgba(43, 43, 43, 0.22);
  cursor: pointer;
  transition: transform 0.1s, box-shadow 0.1s;
}
.person:hover {
  transform: translate(-1px, -3px);
  box-shadow: 5px 6px 0 var(--ink);
}
.person.open {
  border-color: var(--red);
  box-shadow: 4px 5px 0 var(--red);
}

.avatar {
  position: relative;
  width: 84px;
  height: 84px;
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
  border: 2.5px solid var(--ink);
  border-radius: 50% 46% 52% 47%;
  margin-bottom: 5px;
  transition: border-color 0.12s;
}
.avatar img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  display: block;
}
.avatar .initial {
  font-style: normal;
  font-size: 30px;
  color: #fff;
  text-shadow: 1.5px 1.5px 0 var(--ink);
}
.person:hover .avatar {
  border-color: var(--ink);
  filter: saturate(1.08);
}
.person.open .avatar {
  border-color: var(--red);
}
.nm {
  font-size: 13px;
  letter-spacing: 0.5px;
}
.meta {
  font-size: 10.5px;
  color: rgba(43, 43, 43, 0.58);
  line-height: 1.4;
}
.line {
  margin-top: 5px;
  font-size: 11.5px;
  line-height: 1.45;
  color: var(--red);
  animation: fade 0.25s ease-out;
}
@keyframes fade {
  from {
    opacity: 0;
    transform: translateY(3px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}
</style>
