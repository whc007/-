import { computed, onScopeDispose, reactive, ref } from 'vue'

/** 按钮文案（保留原版叫法） */
const BTN_IDLE = '出 动！'
const BTN_BUSY = '冲 呀！'

/** 提交后延迟给出反馈的毫秒数（与原版一致） */
const FEEDBACK_DELAY = 600

/** 提示气泡自动消失时间 */
const TOAST_DURATION = 2600

/**
 * 登录表单逻辑
 *
 * 把原 index.html 内联 <script> 的行为完整抽成组合式函数：
 * 1. 表单数据与校验
 * 2. 提交时按钮文案切换到「冲 呀！」
 * 3. 600ms 后给出反馈（原版是 alert，这里换成页面内提示气泡）
 *
 * @param {object} [options]
 * @param {(payload: {username: string, password: string, remember: boolean}) => void} [options.onLogin]
 *        校验通过并反馈完成后触发，接入真实接口时在这里调用即可。
 */
export function useLoginForm({ onLogin } = {}) {
  const form = reactive({
    username: '',
    password: '',
    remember: false,
  })

  const submitting = ref(false)
  const toast = reactive({ visible: false, text: '' })

  const buttonText = computed(() => (submitting.value ? BTN_BUSY : BTN_IDLE))

  /** 两个字段都填了才允许提交 */
  const isValid = computed(() => Boolean(form.username.trim()) && Boolean(form.password))

  let toastTimer = null

  function showToast(text, duration = TOAST_DURATION) {
    toast.text = text
    toast.visible = true
    clearTimeout(toastTimer)
    toastTimer = setTimeout(() => {
      toast.visible = false
    }, duration)
  }

  function hideToast() {
    clearTimeout(toastTimer)
    toast.visible = false
  }

  async function submit() {
    if (submitting.value || !isValid.value) return

    const username = form.username.trim()

    submitting.value = true

    await new Promise((resolve) => setTimeout(resolve, FEEDBACK_DELAY))

    submitting.value = false
    showToast(`动感超人出击！\n欢迎你，${username}～`)

    onLogin?.({
      username,
      password: form.password,
      remember: form.remember,
    })
  }

  // 组件卸载时清掉定时器，避免内存泄漏
  onScopeDispose(() => clearTimeout(toastTimer))

  return {
    form,
    submitting,
    buttonText,
    isValid,
    toast,
    submit,
    showToast,
    hideToast,
  }
}
