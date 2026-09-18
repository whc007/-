<script setup>
/**
 * 手绘抖动滤镜
 * 用 feTurbulence + feDisplacementMap 制造“线条不直”的蜡笔感。
 * 尺寸为 0 的隐藏 SVG，只提供 <filter id="wobble"> 供其他组件引用。
 */
</script>

<template>
  <svg class="wobble-filter" width="0" height="0" aria-hidden="true" focusable="false">
    <filter id="wobble">
      <feTurbulence type="fractalNoise" baseFrequency="0.012" numOctaves="2" result="noise" />
      <feDisplacementMap in="SourceGraphic" in2="noise" scale="3.5" />
    </filter>
  </svg>
</template>

<style scoped>
.wobble-filter {
  position: absolute;
  pointer-events: none;
}
</style>
