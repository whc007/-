import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

const serverHost = process.env.VITE_HOST || '192.168.68.2'
const apiTarget = process.env.VITE_API_TARGET || 'http://192.168.68.2:8081'

export default defineConfig({
  plugins: [vue()],
  server: {
    // 绑定本机局域网 IP（2026-11-20 按用户要求固定为 192.168.68.2）
    // 若本机 IP 变化导致 EADDRNOTAVAIL，可用环境变量 VITE_HOST 临时覆盖，无需改文件
    host: serverHost,
    port: 5173,
    open: false,
    // 开发时把 /api 请求转发到同机 Spring Boot（8081），可用 VITE_API_TARGET 覆盖
    proxy: {
      '/api': {
        target: apiTarget,
        changeOrigin: true,
      },
    },
  },
  build: {
    outDir: 'dist',
    assetsDir: 'assets',
  },
})
