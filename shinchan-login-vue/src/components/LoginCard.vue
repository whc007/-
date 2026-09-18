<script setup>
/**
 * 登录卡片
 * 组装头像 + 标题 + 表单 + 底部链接 + 提示气泡
 */
import ShinchanFace from './ShinchanFace.vue'
import FormField from './FormField.vue'
import ToastNote from './ToastNote.vue'
import { useLoginForm } from '../composables/useLoginForm.js'

const { form, submitting, buttonText, toast, submit } = useLoginForm({
  // 接真实接口时在这里处理登录请求
  onLogin: (payload) => {
    console.log('[login] 提交成功：', payload)
  },
})
</script>

<template>
  <main class="card">
    <ShinchanFace />

    <h1 class="title">登 录 啦！</h1>
    <p class="sub">我是<b>野原新之助</b>，快来一起玩～</p>

    <form autocomplete="off" @submit.prevent="submit">
      <FormField
        v-model="form.username"
        label="名字 / 邮箱"
        type="text"
        autocomplete="username"
      />
      <FormField
        v-model="form.password"
        label="密码（别告诉美冴）"
        type="password"
        autocomplete="current-password"
      />

      <div class="row">
        <label class="remember">
          <input v-model="form.remember" type="checkbox" />
          记住我
        </label>
        <a href="#" @click.prevent>忘记啦？</a>
      </div>

      <button class="submit" type="submit" :disabled="submitting">
        {{ buttonText }}
      </button>
    </form>

    <p class="foot">还没有号？<a href="#" @click.prevent>马上去注册</a></p>

    <ToastNote :visible="toast.visible" :text="toast.text" />
  </main>
</template>

<style scoped>
.card {
  position: relative;
  z-index: 1;
  width: var(--card-width);
  padding: 40px 34px 36px;
  background: var(--c-paper);
  border: var(--stroke);
  border-radius: var(--r-card);
  box-shadow: 7px 7px 0 var(--c-ink);
  filter: url(#wobble);
  animation: pop var(--dur-pop) var(--ease-pop) both;
}

.title {
  text-align: center;
  font-size: 30px;
  letter-spacing: 3px;
  color: var(--c-red);
  text-shadow: 2px 2px 0 var(--c-yellow);
  margin-bottom: 4px;
}

.sub {
  text-align: center;
  font-size: 14px;
  color: var(--c-ink);
  margin-bottom: 26px;
}

.sub b {
  color: var(--c-blue);
}

.row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  font-size: 13px;
  margin: -4px 4px 22px;
}

.remember {
  display: flex;
  align-items: center;
  gap: 5px;
  cursor: pointer;
}

.row a {
  color: var(--c-blue);
  text-decoration: none;
}

.row a:hover {
  text-decoration: underline wavy;
}

.submit {
  width: 100%;
  padding: 13px;
  font-family: inherit;
  font-size: 19px;
  letter-spacing: 4px;
  color: var(--c-white);
  border: var(--stroke);
  border-radius: var(--r-btn);
  cursor: pointer;
  background: var(--c-red);
  box-shadow: var(--shadow-hard);
  transition: transform var(--dur-fast), box-shadow var(--dur-fast), background var(--dur-base);
}

.submit:hover:not(:disabled) {
  background: var(--c-red-hover);
}

.submit:active:not(:disabled) {
  transform: translate(5px, 5px);
  box-shadow: 0 0 0 var(--c-ink);
}

.submit:disabled {
  cursor: progress;
  opacity: 0.9;
}

.foot {
  text-align: center;
  font-size: 13px;
  margin-top: 20px;
}

.foot a {
  color: var(--c-red);
  text-decoration: none;
}

.foot a:hover {
  text-decoration: underline wavy;
}
</style>
