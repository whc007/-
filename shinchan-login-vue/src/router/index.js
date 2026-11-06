import { createRouter, createWebHistory } from 'vue-router'
import LoginCard from '../components/LoginCard.vue'

const routes = [
  { path: '/', redirect: '/login' },
  { path: '/login', name: 'login', component: LoginCard },
  {
    path: '/register',
    name: 'register',
    component: () => import('../components/RegisterCard.vue'),
  },
  {
    path: '/home',
    name: 'home',
    component: () => import('../views/HomeView.vue'),
  },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

// 首页需要登录态（仅前端 sessionStorage 会话）：没登录就回登录页
router.beforeEach((to) => {
  if (to.path === '/home' && !sessionStorage.getItem('shinchan-user')) {
    return { path: '/login' }
  }
})

export default router
