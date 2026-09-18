<script setup>
/**
 * 应用根组件
 * 只负责舞台布局：滤镜 -> 背景涂鸦 -> 登录卡片
 */
import WobbleFilter from './components/WobbleFilter.vue'
import LoginCard from './components/LoginCard.vue'
</script>

<template>
  <!-- 手绘抖动滤镜（全局 SVG filter，卡片通过 url(#wobble) 引用） -->
  <WobbleFilter />

  <!-- 背景涂鸦 -->
  <span class="scribble scribble--star" aria-hidden="true">★</span>
  <span class="scribble scribble--heart" aria-hidden="true">♡</span>

  <!-- 登录卡片 -->
  <LoginCard />
</template>
