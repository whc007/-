<script setup>
/**
 * 浮动标签输入框
 * - v-model 双向绑定（Vue 3.4+ defineModel）
 * - 沿用原版 placeholder=" " + :placeholder-shown 实现“标签浮起”效果
 * - id 用 useId() 生成，避免多实例冲突
 */
import { useId } from 'vue'

const model = defineModel({ type: String, default: '' })

defineProps({
  /** 标签文案 */
  label: { type: String, required: true },
  /** 输入类型：text / password / email ... */
  type: { type: String, default: 'text' },
  /** 自动填充提示 */
  autocomplete: { type: String, default: 'off' },
})

const inputId = useId()
</script>

<template>
  <div class="field">
    <input
      :id="inputId"
      v-model="model"
      :type="type"
      :autocomplete="autocomplete"
      placeholder=" "
      required
    />
    <label :for="inputId">{{ label }}</label>
  </div>
</template>

<style scoped>
.field {
  position: relative;
  margin-bottom: 18px;
}

.field input {
  width: 100%;
  padding: 13px 15px;
  font-size: 15px;
  font-family: inherit;
  color: var(--c-ink);
  background: var(--c-paper);
  border: var(--stroke);
  border-radius: var(--r-input);
  outline: none;
  box-shadow: var(--shadow-soft);
  transition: box-shadow var(--dur-base), transform 0.1s;
}

.field input:focus {
  box-shadow: 3px 3px 0 var(--c-blue);
  transform: translate(-1px, -1px);
}

.field label {
  position: absolute;
  left: 14px;
  top: 13px;
  font-size: 15px;
  color: var(--c-placeholder);
  pointer-events: none;
  transition: var(--dur-base) ease;
  background: var(--c-paper);
  padding: 0 4px;
}

/* 聚焦 or 已有内容时，标签上浮 */
.field input:focus + label,
.field input:not(:placeholder-shown) + label {
  top: -10px;
  left: 11px;
  font-size: 12px;
  color: var(--c-red);
}
</style>
