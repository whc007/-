<template>
  <div class="field">
    <input
      :type="type"
      :id="id"
      :placeholder="placeholder"
      v-model="model"
      required
    />
    <label :for="id">{{ label }}</label>
  </div>
</template>

<script setup>
// 可复用的浮动标签输入框：v-model 双向绑定
const model = defineModel({ type: String, default: '' })

defineProps({
  id: { type: String, required: true },
  label: { type: String, default: '' },
  type: { type: String, default: 'text' },
  // 必须保留占位符（即使是空格），浮动标签的 :placeholder-shown 判断才生效
  placeholder: { type: String, default: ' ' },
})
</script>

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
  color: var(--ink);
  background: var(--card-bg);
  border: 3px solid var(--ink);
  border-radius: var(--radius-input);
  outline: none;
  box-shadow: var(--shadow-input);
  transition: box-shadow 0.15s, transform 0.1s;
}
.field input:focus {
  box-shadow: var(--shadow-input-focus);
  transform: translate(-1px, -1px);
}
.field label {
  position: absolute;
  left: 14px;
  top: 13px;
  font-size: 15px;
  color: #999;
  pointer-events: none;
  transition: 0.15s ease;
  background: var(--card-bg);
  padding: 0 4px;
}
.field input:focus + label,
.field input:not(:placeholder-shown) + label {
  top: -10px;
  left: 11px;
  font-size: 12px;
  color: var(--red);
}
</style>
