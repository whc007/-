<template>
  <!-- 首页：整页布局（body 是登录页居中 flex，这里自己占满并滚动） -->
  <div class="home">
    <NavBar :username="username" @logout="onLogout" @nav-todo="onNavTodo" />

    <main class="content">
      <section class="hero">
        <h1>今天想找点啥？</h1>
        <p class="sub">春日部乐园 · 搜你喜欢的动画、玩具和点心</p>
        <SearchBar ref="searchBar" @search="onSearch" />
      </section>

      <section class="section">
        <h2>
          <span class="mark">★</span>
          {{ searching ? `「${searchKeyword}」的搜索结果（${cards.length} 条）` : '今日推荐' }}
          <button v-if="searching" class="back" type="button" @click="clearSearch">
            ← 回推荐
          </button>
        </h2>

        <p v-if="loading" class="state">正在翻箱倒柜…</p>
        <p v-else-if="!cards.length" class="state">啥都没找到，换个词试试～</p>

        <div v-else class="grid">
          <article v-for="card in cards" :key="card.id" class="rec-card">
            <div class="deco" :style="{ background: card.color }">{{ card.symbol }}</div>
            <div class="body">
              <h3>{{ card.title }}</h3>
              <p>{{ card.description }}</p>
              <span class="tag">{{ card.tag }}</span>
            </div>
          </article>
        </div>
      </section>
    </main>

    <ToastNote :show="!!toast" :text="toast" @close="toast = ''" />
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import NavBar from '../components/NavBar.vue'
import SearchBar from '../components/SearchBar.vue'
import ToastNote from '../components/ToastNote.vue'

const router = useRouter()
const toast = ref('')

// 后端地址：默认走 Vite 开发代理（/api -> 8081），与登录页一致
const API_BASE = import.meta.env.VITE_API_BASE || ''

// 登录态（仅前端会话）：没有就回登录页，路由守卫之外的双保险
const stored = sessionStorage.getItem('shinchan-user')
if (!stored) {
  router.replace('/login')
}
const username = (() => {
  try {
    return JSON.parse(stored)?.username || '小伙伴'
  } catch {
    return '小伙伴'
  }
})()

// 首页内容：来自后端 content 表（推荐列表 / 搜索结果共用一份渲染）
const cards = ref([])
const loading = ref(true)
const searching = ref(false)
const searchKeyword = ref('')

onMounted(() => {
  fetchContents()
  // 从登录页跳过来时给一个欢迎气泡
  if (sessionStorage.getItem('shinchan-welcome')) {
    sessionStorage.removeItem('shinchan-welcome')
    showToast(`动感超人出击！\n欢迎回来，${username}～`)
  }
})

async function request(url, fallbackMessage) {
  const res = await fetch(url)
  const data = await res.json()
  if (data.code !== 0) {
    throw new Error(data.message || fallbackMessage)
  }
  return data.data || []
}

/** 首页推荐列表 */
async function fetchContents() {
  loading.value = true
  try {
    cards.value = await request(`${API_BASE}/api/contents`, '推荐加载失败')
  } catch (e) {
    cards.value = []
    showToast(`推荐加载失败了\n${e.message || '待会儿再试'}`)
  } finally {
    loading.value = false
  }
}

/** 搜索：走后端 /api/contents/search */
async function onSearch(keyword) {
  searching.value = true
  searchKeyword.value = keyword
  loading.value = true
  try {
    cards.value = await request(
      `${API_BASE}/api/contents/search?keyword=${encodeURIComponent(keyword)}`,
      '搜索失败'
    )
  } catch (e) {
    cards.value = []
    showToast(`搜索失败了\n${e.message || '待会儿再试'}`)
  } finally {
    loading.value = false
  }
}

/** 退出搜索态，回到推荐列表 */
function clearSearch() {
  searching.value = false
  searchKeyword.value = ''
  fetchContents()
}

function showToast(text) {
  toast.value = text
  setTimeout(() => (toast.value = ''), 2600)
}

function onNavTodo(label) {
  showToast(`「${label}」还没做好，\n先去别的地方玩～`)
}

function onLogout() {
  sessionStorage.removeItem('shinchan-user')
  sessionStorage.removeItem('shinchan-welcome')
  router.push('/login')
}
</script>

<style scoped>
.home {
  position: fixed;
  inset: 0;
  z-index: 1;
  overflow-y: auto;
}

.content {
  max-width: 960px;
  margin: 0 auto;
  padding: 48px 20px 64px;
}

.hero {
  text-align: center;
  animation: pop var(--dur-pop) var(--ease-pop) both;
}
.hero h1 {
  font-size: 32px;
  letter-spacing: 3px;
  color: var(--red);
  text-shadow: 2px 2px 0 var(--yellow);
  margin-bottom: 6px;
}
.hero .sub {
  font-size: 14px;
  color: var(--ink);
  margin-bottom: 26px;
}

.section {
  margin-top: 52px;
  animation: pop var(--dur-pop) var(--ease-pop) 0.1s both;
}
.section h2 {
  display: flex;
  align-items: center;
  gap: 10px;
  flex-wrap: wrap;
  font-size: 20px;
  letter-spacing: 2px;
  margin-bottom: 18px;
}
.section .mark {
  color: var(--red);
}
.back {
  font-family: inherit;
  font-size: 13px;
  padding: 5px 13px;
  color: var(--ink);
  background: var(--cream);
  border: 2px solid var(--ink);
  border-radius: 14px 10px 14px 10px;
  box-shadow: 2px 2px 0 rgba(43, 43, 43, 0.25);
  cursor: pointer;
  transition: background 0.12s, transform 0.08s;
}
.back:hover {
  background: var(--yellow);
}
.back:active {
  transform: translate(2px, 2px);
  box-shadow: 0 0 0 rgba(43, 43, 43, 0.25);
}

.state {
  text-align: center;
  font-size: 15px;
  color: rgba(43, 43, 43, 0.6);
  padding: 40px 0;
}

.grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(210px, 1fr));
  gap: 18px;
}
.rec-card {
  background: var(--card-bg);
  border: 3px solid var(--ink);
  border-radius: var(--radius-card);
  box-shadow: var(--shadow-card);
  overflow: hidden;
  cursor: pointer;
  transition: transform 0.12s, box-shadow 0.12s;
}
.rec-card:hover {
  transform: translate(-2px, -4px);
  box-shadow: 9px 11px 0 var(--ink);
}
.rec-card .deco {
  height: 66px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 30px;
  color: #fff;
  text-shadow: 2px 2px 0 var(--ink);
  border-bottom: 3px solid var(--ink);
}
.rec-card .body {
  padding: 14px 16px 16px;
}
.rec-card h3 {
  font-size: 17px;
  letter-spacing: 1px;
  margin-bottom: 6px;
}
.rec-card p {
  font-size: 13px;
  line-height: 1.6;
  color: rgba(43, 43, 43, 0.75);
  margin-bottom: 10px;
}
.rec-card .tag {
  font-size: 12px;
  padding: 3px 10px;
  color: var(--blue);
  background: var(--cream);
  border: 2px solid var(--blue);
  border-radius: 12px 9px 12px 9px;
}
</style>
