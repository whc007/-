import { ref, computed } from 'vue'

/**
 * 注册表单逻辑（数据 / 校验 / 提交 / 反馈）
 * 与原页面保持一致的交互节奏，但此处会真正调用后端 /api/register。
 *
 * 校验规则：名字非空、邮箱格式、密码至少 6 位、两次密码一致。
 *
 * @param {object} [options]
 * @param {(payload: {username:string,email:string,password:string}) => Promise<void>} [options.onRegister] 真实注册请求（由组件注入，内部 fetch 后端）
 */
export function useRegisterForm({ onRegister } = {}) {
  const username = ref('')
  const email = ref('')
  const password = ref('')
  const confirm = ref('')
  const submitting = ref(false)
  const toast = ref('') // 非空时显示提示气泡
  const error = ref('') // 校验失败 / 后端返回的具体原因

  const emailOk = computed(() =>
    /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email.value.trim())
  )

  const canSubmit = computed(
    () =>
      username.value.trim() !== '' &&
      emailOk.value &&
      password.value.length >= 6 &&
      password.value === confirm.value
  )

  function closeToast() {
    toast.value = ''
  }

  async function handleSubmit() {
    error.value = ''

    if (!canSubmit.value || submitting.value) {
      // 给出具体失败原因，而不是笼统拦截
      if (username.value.trim() === '') error.value = '名字不能为空哦'
      else if (!emailOk.value) error.value = '邮箱格式不对呀'
      else if (password.value.length < 6) error.value = '密码至少 6 位'
      else if (password.value !== confirm.value) error.value = '两次密码不一样！'
      return
    }

    submitting.value = true // 按钮文案 → 「冲 呀！」
    const payload = {
      username: username.value.trim(),
      email: email.value.trim(),
      password: password.value,
    }

    try {
      // 真正调用后端；onRegister 失败时应 throw 一个带 message 的错误
      if (typeof onRegister === 'function') {
        await onRegister(payload)
      }
      toast.value = `动感超人欢迎你！\n${payload.username} 注册成功～`
      // 自动消失
      setTimeout(closeToast, 2600)
    } catch (e) {
      error.value = e && e.message ? e.message : '注册失败了，待会儿再试'
    } finally {
      submitting.value = false
    }
  }

  return {
    username,
    email,
    password,
    confirm,
    submitting,
    toast,
    error,
    canSubmit,
    handleSubmit,
    closeToast,
  }
}
