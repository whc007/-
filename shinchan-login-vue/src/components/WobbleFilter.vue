<template>
  <!-- 手绘抖动滤镜：让卡片边缘有蜡笔涂抹的不规则感 -->
  <svg width="0" height="0" style="position: absolute" aria-hidden="true">
    <filter id="wobble">
      <feTurbulence type="fractalNoise" baseFrequency="0.012" numOctaves="2" result="noise" />
      <feDisplacementMap in="SourceGraphic" in2="noise" scale="3.5" />
    </filter>
  </svg>
</template>

<script setup></script>
