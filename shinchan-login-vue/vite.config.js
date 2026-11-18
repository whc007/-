import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  plugins: [vue()],
  server: {
    host: '192.168.68.6',
    port: 5173,
    open: true,
    // 开发时把 /api 请求转发到 Spring Boot 后端（192.168.68.6:8081），避免跨域
    proxy: {
      '/api': {
        target: 'http://192.168.68.6:8081',
        changeOrigin: true,
      },
    },
  },
  build: {
    outDir: 'dist',
    assetsDir: 'assets',
  },
})
