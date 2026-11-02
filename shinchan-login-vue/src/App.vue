<template>
  <WobbleFilter />

  <!-- 背景蜡笔涂鸦 -->
  <div class="scribble s1">★</div>
  <div class="scribble s2">♡</div>

  <!-- 路由出口：/login 与 /register 共享同一套背景与滤镜 -->
  <router-view />
</template>

<script setup>
import WobbleFilter from './components/WobbleFilter.vue'
</script>
