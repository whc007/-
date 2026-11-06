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

      <div class="row" v-if="error">
        <span class="err">{{ error }}</span>
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
import { useRouter } from 'vue-router'
import { useLoginForm } from '../composables/useLoginForm.js'
import ShinchanFace from './ShinchanFace.vue'
import FormField from './FormField.vue'
import ToastNote from './ToastNote.vue'

const router = useRouter()

// 后端地址：默认走 Vite 开发代理（/api -> 8081）；
// 生产构建可通过环境变量 VITE_API_BASE 指定，例如 http://localhost:8081
const API_BASE = import.meta.env.VITE_API_BASE || ''

// 真正对接后端的登录请求；失败需抛出带 message 的错误，由 composable 显示
async function onLogin({ username, password }) {
  const res = await fetch(`${API_BASE}/api/login`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ username, password }),
  })
  const data = await res.json()
  if (data.code !== 0) {
    throw new Error(data.message || '登录失败')
  }
  // 记住当前用户（仅前端会话），并给首页一个欢迎标记
  sessionStorage.setItem('shinchan-user', JSON.stringify(data.data || { username }))
  sessionStorage.setItem('shinchan-welcome', '1')
  // 让提示气泡露个脸，再跳首页
  setTimeout(() => router.push('/home'), 1100)
  return data
}

const { username, password, remember, submitting, toast, error, handleSubmit, closeToast } =
  useLoginForm({ onLogin })

function onSubmit() {
  handleSubmit()
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
.row .err {
  color: var(--red);
  font-weight: bold;
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
