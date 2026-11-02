<template>
  <main class="card">
    <ShinchanFace />

    <h1>登 录 啦！</h1>
    <p class="sub">我是<b>野原新之助</b>，快来一起玩～</p>

    <form @submit.prevent="onSubmit">
      <FormField id="username" v-model="username" label="名字 / 邮箱" />
      <FormField
        id="password"
        v-model="password"
        type="password"
        label="密码（别告诉美冴）"
      />

      <div class="row">
        <label><input type="checkbox" v-model="remember" /> 记住我</label>
        <a href="#">忘记啦？</a>
      </div>

      <button class="submit" type="submit" :disabled="submitting">
        {{ submitting ? '冲 呀！' : '出 动！' }}
      </button>
    </form>

    <p class="foot">还没有号？<router-link to="/register">马上去注册</router-link></p>

    <ToastNote :show="!!toast" :text="toast" @close="closeToast" />
  </main>
</template>

<script setup>
import { useLoginForm } from '../composables/useLoginForm.js'
import ShinchanFace from './ShinchanFace.vue'
import FormField from './FormField.vue'
import ToastNote from './ToastNote.vue'

const { username, password, remember, submitting, toast, handleSubmit, closeToast } =
  useLoginForm()

// 接入真实接口的位置：把这里换成 fetch / axios 即可
function onLogin({ username }) {
  // 示例：await fetch('/api/login', { method: 'POST', body: JSON.stringify(payload) })
  console.log('登录请求：', username)
}

function onSubmit() {
  handleSubmit(onLogin)
}
</script>

<style scoped>
.card {
  position: relative;
  z-index: 1;
  width: min(92vw, 380px);
  padding: 40px 34px 36px;
  background: var(--card-bg);
  border: 3px solid var(--ink);
  border-radius: var(--radius-card);
  box-shadow: var(--shadow-card);
  filter: url(#wobble);
  animation: pop var(--dur-pop) var(--ease-pop) both;
}

h1 {
  text-align: center;
  font-size: 30px;
  letter-spacing: 3px;
  color: var(--red);
  text-shadow: 2px 2px 0 var(--yellow);
  margin-bottom: 4px;
}
.sub {
  text-align: center;
  font-size: 14px;
  color: var(--ink);
  margin-bottom: 26px;
}
.sub b {
  color: var(--blue);
}

.row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  font-size: 13px;
  margin: -4px 4px 22px;
}
.row label {
  display: flex;
  align-items: center;
  gap: 5px;
  cursor: pointer;
}
.row a {
  color: var(--blue);
  text-decoration: none;
}
.row a:hover {
  text-decoration: underline wavy;
}

button.submit {
  width: 100%;
  padding: 13px;
  font-family: inherit;
  font-size: 19px;
  letter-spacing: 4px;
  color: #fff;
  border: 3px solid var(--ink);
  border-radius: var(--radius-button);
  cursor: pointer;
  background: var(--red);
  box-shadow: var(--shadow-button);
  transition: transform 0.08s, box-shadow 0.08s;
}
button.submit:hover {
  background: #ff5d4d;
}
button.submit:active {
  transform: translate(5px, 5px);
  box-shadow: 0 0 0 var(--ink);
}
button.submit:disabled {
  cursor: default;
}

.foot {
  text-align: center;
  font-size: 13px;
  margin-top: 20px;
}
.foot a {
  color: var(--red);
  text-decoration: none;
}
.foot a:hover {
  text-decoration: underline wavy;
}
</style>
