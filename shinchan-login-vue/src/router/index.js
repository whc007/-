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
]

export default createRouter({
  history: createWebHistory(),
  routes,
})
