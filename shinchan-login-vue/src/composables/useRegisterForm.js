import { ref, computed } from 'vue'

/**
 * 注册表单逻辑（数据 / 校验 / 提交 / 反馈）
 * 与 useLoginForm 保持同一套交互节奏：
 *  - 提交过程中按钮文案变为「冲 呀！」
 *  - 延迟 600ms 才给出反馈
 *
 * 校验规则：名字非空、邮箱格式、密码至少 6 位、两次密码一致。
 *
 * @param {object} [options]
 * @param {(payload: {username:string,email:string,password:string}) => void|Promise<void>} [options.onRegister] 接入真实接口的位置
 */
export function useRegisterForm({ onRegister } = {}) {
  const username = ref('')
  const email = ref('')
  const password = ref('')
  const confirm = ref('')
  const submitting = ref(false)
  const toast = ref('') // 非空时显示提示气泡
  const error = ref('') // 校验失败的具体原因

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

  function handleSubmit() {
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

    // 与原页面一致的 600ms 延迟反馈
    setTimeout(() => {
      submitting.value = false

      if (typeof onRegister === 'function') {
        onRegister(payload)
      }

      toast.value = `动感超人欢迎你！\n${payload.username} 注册成功～`
      setTimeout(closeToast, 2600)
    }, 600)
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
