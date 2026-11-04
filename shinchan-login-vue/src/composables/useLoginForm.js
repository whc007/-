import { ref, computed } from 'vue'

/**
 * 登录表单逻辑（数据 / 校验 / 提交 / 反馈）
 * 与原页面保持一致的交互节奏，但此处会真正调用后端 /api/login。
 *
 * @param {object} [options]
 * @param {(payload: {username:string,password:string,remember:boolean}) => Promise<void>} [options.onLogin] 真实登录请求（由组件注入，内部 fetch 后端）
 */
export function useLoginForm({ onLogin } = {}) {
  const username = ref('')
  const password = ref('')
  const remember = ref(false)
  const submitting = ref(false)
  const toast = ref('') // 非空时显示提示气泡
  const error = ref('') // 校验失败 / 后端返回的具体原因

  const canSubmit = computed(
    () => username.value.trim() !== '' && password.value !== ''
  )

  function closeToast() {
    toast.value = ''
  }

  async function handleSubmit() {
    error.value = ''

    if (!canSubmit.value || submitting.value) {
      if (username.value.trim() === '') error.value = '名字不能为空哦'
      else if (password.value === '') error.value = '密码不能为空呀'
      return
    }

    submitting.value = true // 按钮文案 → 「冲 呀！」
    const payload = {
      username: username.value.trim(),
      password: password.value,
      remember: remember.value,
    }

    try {
      if (typeof onLogin === 'function') {
        await onLogin(payload)
      }
      toast.value = `动感超人出击！\n欢迎你，${payload.username}～`
      setTimeout(closeToast, 2600)
    } catch (e) {
      error.value = e && e.message ? e.message : '登录失败了，待会儿再试'
    } finally {
      submitting.value = false
    }
  }

  return {
    username,
    password,
    remember,
    submitting,
    toast,
    error,
    canSubmit,
    handleSubmit,
    closeToast,
  }
}
