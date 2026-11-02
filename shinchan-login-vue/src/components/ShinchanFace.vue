<template>
  <!-- 纯 CSS 拼出的野原新之助头像 -->
  <div class="face">
    <div class="head"></div>
    <div class="brow"></div>
    <div class="eye l"></div>
    <div class="eye r"></div>
    <div class="nose"></div>
    <div class="cheek l"></div>
    <div class="cheek r"></div>
    <div class="mouth"></div>
  </div>
</template>

<script setup></script>

<style scoped>
.face {
  width: 74px;
  height: 74px;
  margin: 0 auto 14px;
  position: relative;
}
.face .head {
  position: absolute;
  inset: 0;
  background: var(--skin);
  border: 3px solid var(--ink);
  border-radius: 50% 50% 48% 52% / 55% 55% 45% 45%;
}
.face .eye {
  position: absolute;
  top: 30px;
  width: 7px;
  height: 9px;
  background: var(--ink);
  border-radius: 50%;
}
.face .eye.l {
  left: 22px;
}
.face .eye.r {
  right: 22px;
}
.face .brow {
  position: absolute;
  top: 22px;
  left: 18px;
  right: 18px;
  height: 3px;
  background: var(--ink);
  transform: rotate(-8deg);
  border-radius: 3px;
}
.face .nose {
  position: absolute;
  top: 40px;
  left: 50%;
  width: 6px;
  height: 6px;
  background: var(--ink);
  border-radius: 50%;
  transform: translateX(-50%);
}
.face .mouth {
  position: absolute;
  bottom: 16px;
  left: 50%;
  transform: translateX(-50%);
  width: 30px;
  height: 14px;
  border: 3px solid var(--ink);
  border-top: none;
  border-radius: 0 0 30px 30px;
}
.face .cheek {
  position: absolute;
  bottom: 22px;
  width: 10px;
  height: 6px;
  background: var(--cheek);
  border-radius: 50%;
  opacity: 0.7;
}
.face .cheek.l {
  left: 8px;
}
.face .cheek.r {
  right: 8px;
}
</style>
