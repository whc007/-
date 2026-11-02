import { ref, computed } from 'vue'

/**
 * 登录表单逻辑（数据 / 校验 / 提交 / 反馈）
 * 与原 index.html 行为保持一致：
 *  - 用户名、密码都非空才提交，用户名先 trim()
 *  - 提交过程中按钮文案变为「冲 呀！」
 *  - 延迟 600ms 才给出反馈
 *
 * @param {object} [options]
 * @param {(payload: {username:string,password:string,remember:boolean}) => void|Promise<void>} [options.onLogin] 接入真实接口的位置
 */
export function useLoginForm({ onLogin } = {}) {
  const username = ref('')
  const password = ref('')
  const remember = ref(false)
  const submitting = ref(false)
  const toast = ref('') // 非空时显示提示气泡

  const canSubmit = computed(
    () => username.value.trim() !== '' && password.value !== ''
  )

  function closeToast() {
    toast.value = ''
  }

  function handleSubmit() {
    if (!canSubmit.value || submitting.value) return
    submitting.value = true // 按钮文案 → 「冲 呀！」

    const payload = {
      username: username.value.trim(),
      password: password.value,
      remember: remember.value,
    }

    // 与原页面一致：600ms 后才给出反馈
    setTimeout(() => {
      submitting.value = false

      if (typeof onLogin === 'function') {
        onLogin(payload)
      }

      toast.value = `动感超人出击！\n欢迎你，${payload.username}～`
      // 自动消失（原生 alert 需手动关闭，这里给个兜底）
      setTimeout(closeToast, 2600)
    }, 600)
  }

  return {
    username,
    password,
    remember,
    submitting,
    toast,
    canSubmit,
    handleSubmit,
    closeToast,
  }
}
