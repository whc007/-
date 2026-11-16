<template>
  <!-- 首页：整页布局（body 是登录页居中 flex，这里自己占满并滚动） -->
  <div class="home">
    <NavBar
      :username="username"
      :items="navItems"
      :current="navCurrent"
      @logout="onLogout"
      @nav="onNav"
    />

    <main class="content">
      <section class="hero">
        <h1>今天想找点啥？</h1>
        <p class="sub">春日部乐园 · 动画、剧场版、角色和点心，全都在这里</p>
        <SearchBar ref="searchBar" @search="onSearch" />
      </section>

      <DailyQuote class="daily" />

      <section class="section">
        <div class="toolbar">
          <h2>
            <span class="mark">★</span>
            {{ searching ? `「${searchKeyword}」的搜索结果` : titleText }}
            <span class="count">{{ cards.length }} 条</span>
            <button v-if="searching" class="back" type="button" @click="clearSearch">
              ← 回推荐
            </button>
          </h2>

          <div v-if="!searching" class="tools">
            <div class="chips">
              <button
                v-for="c in chips"
                :key="c.name"
                class="chip"
                type="button"
                :class="{ on: c.name === category }"
                @click="pickCategory(c.name)"
              >
                {{ c.name }}<i v-if="c.total">{{ c.total }}</i>
              </button>
            </div>
            <button class="shuffle" type="button" :disabled="loading" @click="shuffle">
              ↻ 换一批
            </button>
          </div>
        </div>

        <p v-if="loading" class="state">正在翻箱倒柜…</p>
        <p v-else-if="!cards.length" class="state">啥都没找到，换个词试试～</p>

        <div v-else class="grid">
          <article
            v-for="(card, i) in cards"
            :key="card.id"
            class="rec-card"
            role="button"
            tabindex="0"
            @click="openCard(i)"
            @keydown.enter="openCard(i)"
          >
            <div class="deco" :style="{ background: card.color }">{{ card.symbol }}</div>
            <div class="body">
              <span class="cat">{{ card.category }}</span>
              <h3>{{ card.title }}</h3>
              <p>{{ card.description }}</p>
              <span class="tag">{{ card.tag }}</span>
            </div>
          </article>
        </div>
      </section>

      <ShinchanGame class="game-block" :username="username" @toast="showToast" />

      <div ref="marketEl">
        <FleaMarket class="market-block" :username="username" @toast="showToast" />
      </div>

      <div ref="galleryEl">
        <CharacterGallery />
      </div>

      <footer class="foot">春日部乐园 · 内容仅供学习娱乐 · 企划·制作 野原新之助</footer>
    </main>

    <ToastNote :show="!!toast" :text="toast" @close="toast = ''" />

    <ContentModal
      :item="activeCard"
      @close="closeCard"
      @prev="stepCard(-1)"
      @next="stepCard(1)"
    />
  </div>
</template>

<script setup>
import { computed, onMounted, onUnmounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import NavBar from '../components/NavBar.vue'
import SearchBar from '../components/SearchBar.vue'
import ToastNote from '../components/ToastNote.vue'
import DailyQuote from '../components/DailyQuote.vue'
import CharacterGallery from '../components/CharacterGallery.vue'
import ShinchanGame from '../components/ShinchanGame.vue'
import FleaMarket from '../components/FleaMarket.vue'
import ContentModal from '../components/ContentModal.vue'

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

/* ---------------- 首页内容 ---------------- */
const PAGE_SIZE = 12
const cards = ref([])
const loading = ref(true)
const searching = ref(false)
const searchKeyword = ref('')
const category = ref('全部')
const categoryStats = ref([])

const navItems = ['首页', '动画', '漫画', '游戏', '角色', '跳蚤市场']
const navCurrent = ref('首页')

const chips = computed(() => [
  { name: '全部', total: 0 },
  ...categoryStats.value.map((c) => ({ name: c.category, total: c.total }))
])

const titleText = computed(() => (category.value === '全部' ? '今日推荐' : `${category.value}专区`))

const galleryEl = ref(null)
const marketEl = ref(null)

onMounted(() => {
  // 首屏用随机推荐，保证每次进来都能看到不同的小新内容
  shuffle()
  loadCategories()
  // 从登录页跳过来时给一个欢迎气泡
  if (sessionStorage.getItem('shinchan-welcome')) {
    sessionStorage.removeItem('shinchan-welcome')
    showToast(`动感超人出击！\n欢迎回来，${username}～`)
  }
  window.addEventListener('keydown', onKeyDown)
})

onUnmounted(() => window.removeEventListener('keydown', onKeyDown))

async function request(url, fallbackMessage) {
  const res = await fetch(url)
  const data = await res.json()
  if (data.code !== 0) {
    throw new Error(data.message || fallbackMessage)
  }
  return data.data || []
}

function categoryQuery() {
  return category.value === '全部' ? '' : `&category=${encodeURIComponent(category.value)}`
}

/** 列表（按 id 顺序，首页默认 12 条） */
async function fetchContents() {
  loading.value = true
  try {
    cards.value = await request(
      `${API_BASE}/api/contents?limit=${PAGE_SIZE}${categoryQuery()}`,
      '推荐加载失败'
    )
  } catch (e) {
    cards.value = []
    showToast(`推荐加载失败了\n${e.message || '待会儿再试'}`)
  } finally {
    loading.value = false
  }
}

/** 换一批：同分类随机 */
async function shuffle() {
  loading.value = true
  try {
    cards.value = await request(
      `${API_BASE}/api/contents/recommend?size=${PAGE_SIZE}${categoryQuery()}`,
      '换一批失败了'
    )
  } catch (e) {
    cards.value = []
    showToast(`换一批失败了\n${e.message || '待会儿再试'}`)
  } finally {
    loading.value = false
  }
}

/** 分类统计（chips 角标） */
async function loadCategories() {
  try {
    categoryStats.value = await request(`${API_BASE}/api/contents/categories`, '分类加载失败')
  } catch {
    categoryStats.value = []
  }
}

/** 搜索：走后端 /api/contents/search */
async function onSearch(keyword) {
  searching.value = true
  searchKeyword.value = keyword
  navCurrent.value = '首页'
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

function pickCategory(name) {
  if (category.value === name && !searching.value) return
  category.value = name
  searching.value = false
  searchKeyword.value = ''
  navCurrent.value = name === '全部' ? '首页' : name
  shuffle()
}

/** 顶部导航：首页=全部，角色=跳到图鉴，跳蚤市场=滚动定位，其余=分类筛选 */
function onNav(item) {
  if (item === '角色') {
    pickCategory('角色')
    galleryEl.value?.scrollIntoView({ behavior: 'smooth', block: 'start' })
    return
  }
  if (item === '跳蚤市场') {
    navCurrent.value = '跳蚤市场'
    marketEl.value?.scrollIntoView({ behavior: 'smooth', block: 'start' })
    return
  }
  pickCategory(item === '首页' ? '全部' : item)
}

/* ---------------- 卡片详情 ---------------- */
const activeIndex = ref(-1)
const activeCard = computed(() => (activeIndex.value >= 0 ? cards.value[activeIndex.value] : null))

function openCard(i) {
  activeIndex.value = i
}
function closeCard() {
  activeIndex.value = -1
}
function stepCard(step) {
  if (!cards.value.length) return
  const len = cards.value.length
  activeIndex.value = (activeIndex.value + step + len) % len
}
function onKeyDown(e) {
  if (e.key === 'Escape') closeCard()
  if (!activeCard.value) return
  if (e.key === 'ArrowLeft') stepCard(-1)
  if (e.key === 'ArrowRight') stepCard(1)
}

/* ---------------- 其它 ---------------- */
function showToast(text) {
  toast.value = text
  setTimeout(() => (toast.value = ''), 2600)
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
  max-width: 1000px;
  margin: 0 auto;
  padding: 44px 20px 56px;
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
  margin-bottom: 24px;
}

.daily {
  margin-top: 26px;
}

.section {
  margin-top: 34px;
  animation: pop var(--dur-pop) var(--ease-pop) 0.1s both;
}

.toolbar {
  margin-bottom: 16px;
}
.section h2 {
  display: flex;
  align-items: center;
  gap: 10px;
  flex-wrap: wrap;
  font-size: 20px;
  letter-spacing: 2px;
}
.section .mark {
  color: var(--red);
}
.section .count {
  font-size: 12px;
  font-weight: normal;
  letter-spacing: 0;
  color: rgba(43, 43, 43, 0.5);
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

.tools {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  flex-wrap: wrap;
  margin-top: 12px;
}
.chips {
  display: flex;
  gap: 7px;
  flex-wrap: wrap;
}
.chip {
  font-family: inherit;
  font-size: 13px;
  padding: 4px 12px;
  color: var(--ink);
  background: var(--card-bg);
  border: 2px solid rgba(43, 43, 43, 0.35);
  border-radius: 14px 10px 14px 10px;
  cursor: pointer;
  transition: background 0.12s, border-color 0.12s, transform 0.08s;
}
.chip i {
  font-style: normal;
  font-size: 10px;
  margin-left: 4px;
  color: rgba(43, 43, 43, 0.45);
}
.chip:hover {
  background: var(--cream);
}
.chip.on {
  color: #fff;
  background: var(--red);
  border-color: var(--ink);
  box-shadow: 2px 2px 0 var(--ink);
}
.chip.on i {
  color: rgba(255, 255, 255, 0.75);
}
.shuffle {
  font-family: inherit;
  font-size: 13px;
  padding: 5px 14px;
  color: var(--blue);
  background: var(--cream);
  border: 2px solid var(--blue);
  border-radius: 14px 10px 14px 10px;
  cursor: pointer;
  transition: background 0.12s, transform 0.08s;
}
.shuffle:hover:not(:disabled) {
  background: #e6f3ff;
}
.shuffle:disabled {
  opacity: 0.5;
  cursor: default;
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
.rec-card:focus-visible {
  outline: 3px dashed var(--blue);
  outline-offset: 3px;
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
  padding: 13px 16px 16px;
}
.rec-card .cat {
  display: inline-block;
  font-size: 10.5px;
  letter-spacing: 1px;
  color: rgba(43, 43, 43, 0.55);
  border-bottom: 2px dotted rgba(43, 43, 43, 0.3);
  margin-bottom: 4px;
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

.game-block {
  margin-top: 40px;
}

.market-block {
  margin-top: 40px;
}

.foot {
  margin-top: 44px;
  text-align: center;
  font-size: 11.5px;
  color: rgba(43, 43, 43, 0.42);
  letter-spacing: 1px;
}
</style>
