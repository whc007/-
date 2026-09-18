import { createApp } from 'vue'
import App from './App.vue'

// 全局样式：先设计令牌，再基础样式
import './assets/styles/variables.css'
import './assets/styles/global.css'

createApp(App).mount('#app')
