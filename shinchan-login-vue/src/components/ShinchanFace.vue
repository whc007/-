<script setup>
/**
 * 野原新之助的头像
 * 纯 CSS 拼的“手绘脸”：头 / 眉 / 眼 / 鼻 / 腮红 / 嘴
 * 装饰性元素，对读屏器隐藏。
 */
</script>

<template>
  <div class="face" aria-hidden="true">
    <div class="head"></div>
    <div class="brow"></div>
    <div class="eye eye--left"></div>
    <div class="eye eye--right"></div>
    <div class="nose"></div>
    <div class="cheek cheek--left"></div>
    <div class="cheek cheek--right"></div>
    <div class="mouth"></div>
  </div>
</template>

<style scoped>
.face {
  width: 74px;
  height: 74px;
  margin: 0 auto 14px;
  position: relative;
}

.head {
  position: absolute;
  inset: 0;
  background: var(--c-skin);
  border: var(--stroke);
  border-radius: 50% 50% 48% 52% / 55% 55% 45% 45%;
}

.brow {
  position: absolute;
  top: 22px;
  left: 18px;
  right: 18px;
  height: 3px;
  background: var(--c-ink);
  transform: rotate(-8deg);
  border-radius: 3px;
}

.eye {
  position: absolute;
  top: 30px;
  width: 7px;
  height: 9px;
  background: var(--c-ink);
  border-radius: 50%;
}

.eye--left {
  left: 22px;
}

.eye--right {
  right: 22px;
}

.nose {
  position: absolute;
  top: 40px;
  left: 50%;
  width: 6px;
  height: 6px;
  background: var(--c-ink);
  border-radius: 50%;
  transform: translateX(-50%);
}

.cheek {
  position: absolute;
  bottom: 22px;
  width: 10px;
  height: 6px;
  background: var(--c-cheek);
  border-radius: 50%;
  opacity: 0.7;
}

.cheek--left {
  left: 8px;
}

.cheek--right {
  right: 8px;
}

.mouth {
  position: absolute;
  bottom: 16px;
  left: 50%;
  transform: translateX(-50%);
  width: 30px;
  height: 14px;
  border: var(--stroke);
  border-top: none;
  border-radius: 0 0 30px 30px;
}
</style>
