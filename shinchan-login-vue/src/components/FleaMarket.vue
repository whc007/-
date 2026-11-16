<template>
  <!-- 跳蚤市场：春日部二手摊 -->
  <section class="market">
    <header class="head">
      <div class="title">
        <h2><span class="mark">🛒</span> 春日部二手摊</h2>
        <p class="sub">家里的闲置拿出来换「巧克比」～点「我想要」就能抱回家</p>
      </div>
      <div class="actions">
        <div class="tabs">
          <button
            v-for="t in tabs"
            :key="t.value"
            type="button"
            class="tab"
            :class="{ on: status === t.value }"
            @click="switchStatus(t.value)"
          >{{ t.label }}</button>
        </div>
        <button class="sell-btn" type="button" @click="openPublish">+ 摆摊卖点啥</button>
      </div>
    </header>

    <p v-if="loading" class="state">小新正在翻箱倒柜…</p>
    <p v-else-if="!items.length" class="state">{{ emptyText }}</p>

    <div v-else class="grid">
      <article
        v-for="it in items"
        :key="it.id"
        class="card"
        :class="{ sold: !!it.buyer }"
      >
        <div class="deco" :style="{ background: it.color }">
          <span class="sym">{{ it.symbol }}</span>
          <span v-if="it.buyer" class="sold-mark">已售</span>
        </div>
        <div class="body">
          <h3>{{ it.title }}</h3>
          <p class="desc">{{ it.description || '（卖家什么也没说）' }}</p>
          <div class="meta">
            <span class="price">🍪 × {{ it.price }}</span>
            <span class="seller">摊主：{{ it.seller }}</span>
          </div>
          <button
            v-if="!it.buyer"
            class="buy"
            type="button"
            :disabled="it.seller === username || buyingId === it.id"
            @click="buy(it)"
          >
            {{ it.seller === username ? '自己的宝贝' : buyingId === it.id ? '交易中…' : '我想要！' }}
          </button>
          <div v-else class="buyer-line">被 <b>{{ it.buyer }}</b> 抱走了</div>
        </div>
      </article>
    </div>

    <!-- 上架弹层 -->
    <transition name="fade">
      <div v-if="showPublish" class="mask" @click.self="closePublish">
        <div class="sheet" role="dialog" aria-modal="true" aria-label="上架新商品">
          <div class="banner" :style="{ background: form.color }">
            <span class="sym">{{ form.symbol || '🎁' }}</span>
            <button class="x" type="button" aria-label="关闭" @click="closePublish">×</button>
          </div>

          <form class="form" @submit.prevent="submit">
            <label>
              <span>宝贝名字</span>
              <input v-model.trim="form.title" type="text" maxlength="60" placeholder="比如：动感超人手办" required />
            </label>

            <label>
              <span>描述（可不写）</span>
              <textarea v-model.trim="form.description" rows="3" maxlength="255" placeholder="几成新？哪里有意思？"></textarea>
            </label>

            <div class="row">
              <label>
                <span>价格（🍪 巧克比）</span>
                <input v-model.number="form.price" type="number" min="1" max="9999" required />
              </label>
              <label>
                <span>装饰符号</span>
                <input v-model.trim="form.symbol" type="text" maxlength="4" placeholder="🎁" />
              </label>
            </div>

            <div class="color-row">
              <span>底色</span>
              <button
                v-for="c in colorOptions"
                :key="c"
                type="button"
                class="swatch"
                :class="{ on: form.color === c }"
                :style="{ background: c }"
                :aria-label="c"
                @click="form.color = c"
              ></button>
            </div>

            <p v-if="formError" class="err">{{ formError }}</p>

            <div class="actions-row">
              <button class="ghost" type="button" @click="closePublish">先不卖了</button>
              <button class="solid" type="submit" :disabled="submitting">
                {{ submitting ? '上架中…' : '上架！' }}
              </button>
            </div>
          </form>
        </div>
      </div>
    </transition>
  </section>
</template>

<script setup>
import { computed, onMounted, ref } from 'vue'

const props = defineProps({
  username: { type: String, default: '小伙伴' },
})
const emit = defineEmits(['toast'])

const API_BASE = import.meta.env.VITE_API_BASE || ''

/* ---------------- 列表 ---------------- */
const items = ref([])
const loading = ref(true)
const status = ref('all') // all / on / sold
const buyingId = ref(null)

const tabs = [
  { value: 'all', label: '全部' },
  { value: 'on', label: '在售' },
  { value: 'sold', label: '已售' },
]

const emptyText = computed(() => {
  if (status.value === 'on') return '现在没有在售的宝贝，去上架一件吧～'
  if (status.value === 'sold') return '还没有成交记录，第一件等你来'
  return '跳蚤市场空空如也，谁来开第一摊？'
})

async function request(url, fallbackMessage, options) {
  const res = await fetch(url, options)
  const data = await res.json()
  if (data.code !== 0) {
    throw new Error(data.message || fallbackMessage)
  }
  return data.data
}

async function load() {
  loading.value = true
  try {
    const qs = status.value === 'all' ? '' : `?status=${status.value}`
    items.value = await request(`${API_BASE}/api/market/items${qs}`, '加载失败')
  } catch (e) {
    items.value = []
    emit('toast', `跳蚤市场加载失败了\n${e.message || '待会儿再试'}`)
  } finally {
    loading.value = false
  }
}

function switchStatus(v) {
  if (status.value === v) return
  status.value = v
  load()
}

onMounted(load)

/* ---------------- 购买 ---------------- */
async function buy(item) {
  if (buyingId.value) return
  buyingId.value = item.id
  try {
    const updated = await request(
      `${API_BASE}/api/market/items/${item.id}/buy`,
      '交易失败',
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ buyer: props.username }),
      }
    )
    // 本地同步更新
    const idx = items.value.findIndex((x) => x.id === item.id)
    if (idx >= 0) items.value[idx] = updated
    emit('toast', `成交啦！\n「${updated.title}」被你抱回家～`)
  } catch (e) {
    emit('toast', e.message || '交易失败')
  } finally {
    buyingId.value = null
  }
}

/* ---------------- 上架 ---------------- */
const showPublish = ref(false)
const submitting = ref(false)
const formError = ref('')
const colorOptions = [
  'var(--red)',
  'var(--yellow)',
  'var(--blue)',
  'var(--skin)',
  'var(--cream)',
  'var(--cheek)',
]
const form = ref({
  title: '',
  description: '',
  price: 5,
  symbol: '',
  color: 'var(--yellow)',
})

function openPublish() {
  formError.value = ''
  showPublish.value = true
}

function closePublish() {
  if (submitting.value) return
  showPublish.value = false
}

function resetForm() {
  form.value = {
    title: '',
    description: '',
    price: 5,
    symbol: '',
    color: 'var(--yellow)',
  }
}

async function submit() {
  formError.value = ''
  if (!form.value.title) {
    formError.value = '给宝贝起个名字吧'
    return
  }
  if (!form.value.price || form.value.price < 1 || form.value.price > 9999) {
    formError.value = '价格要在 1 ~ 9999 之间'
    return
  }
  submitting.value = true
  try {
    const created = await request(
      `${API_BASE}/api/market/items`,
      '上架失败',
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          title: form.value.title,
          description: form.value.description,
          price: form.value.price,
          symbol: form.value.symbol,
          color: form.value.color,
          seller: props.username,
        }),
      }
    )
    items.value = [created, ...items.value]
    emit('toast', `「${created.title}」上架成功！\n等着有缘人来抱走`)
    closePublish()
    resetForm()
    // 如果当前过滤是「已售」，新商品看不到，自动切回全部
    if (status.value === 'sold') {
      status.value = 'all'
      load()
    }
  } catch (e) {
    formError.value = e.message || '上架失败'
  } finally {
    submitting.value = false
  }
}
</script>

<style scoped>
.market {
  margin-top: 40px;
  animation: pop var(--dur-pop) var(--ease-pop) 0.15s both;
}

.head {
  display: flex;
  align-items: flex-end;
  justify-content: space-between;
  gap: 12px;
  flex-wrap: wrap;
  margin-bottom: 16px;
}
.title h2 {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 20px;
  letter-spacing: 2px;
}
.mark {
  font-size: 22px;
}
.sub {
  margin-top: 4px;
  font-size: 12.5px;
  color: rgba(43, 43, 43, 0.6);
}

.actions {
  display: flex;
  align-items: center;
  gap: 10px;
  flex-wrap: wrap;
}
.tabs {
  display: flex;
  gap: 6px;
  background: var(--card-bg);
  border: 2px solid var(--ink);
  border-radius: 14px 10px 14px 10px;
  padding: 4px;
}
.tab {
  font-family: inherit;
  font-size: 12.5px;
  padding: 4px 12px;
  color: var(--ink);
  background: transparent;
  border: none;
  border-radius: 10px 8px 10px 8px;
  cursor: pointer;
  transition: background 0.12s, color 0.12s;
}
.tab.on {
  color: #fff;
  background: var(--red);
}
.tab:hover:not(.on) {
  background: var(--cream);
}

.sell-btn {
  font-family: inherit;
  font-size: 13px;
  padding: 6px 14px;
  color: var(--ink);
  background: var(--yellow);
  border: 2px solid var(--ink);
  border-radius: 14px 10px 14px 10px;
  box-shadow: 3px 3px 0 var(--ink);
  cursor: pointer;
  transition: transform 0.08s, box-shadow 0.08s, background 0.12s;
}
.sell-btn:hover {
  background: #ffe266;
}
.sell-btn:active {
  transform: translate(3px, 3px);
  box-shadow: 0 0 0 var(--ink);
}

.state {
  text-align: center;
  font-size: 15px;
  color: rgba(43, 43, 43, 0.6);
  padding: 36px 0;
}

.grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
  gap: 18px;
}

.card {
  background: var(--card-bg);
  border: 3px solid var(--ink);
  border-radius: var(--radius-card);
  box-shadow: var(--shadow-card);
  overflow: hidden;
  transition: transform 0.12s, box-shadow 0.12s;
}
.card:hover {
  transform: translate(-2px, -4px);
  box-shadow: 9px 11px 0 var(--ink);
}
.card.sold {
  opacity: 0.7;
}

.deco {
  position: relative;
  height: 78px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-bottom: 3px solid var(--ink);
}
.sym {
  font-size: 36px;
  filter: drop-shadow(2px 2px 0 rgba(43, 43, 43, 0.3));
}
.sold-mark {
  position: absolute;
  top: 8px;
  right: 10px;
  font-size: 11px;
  padding: 3px 8px;
  color: #fff;
  background: var(--ink);
  border-radius: 10px 8px 10px 8px;
  letter-spacing: 1px;
  transform: rotate(6deg);
}

.body {
  padding: 12px 14px 14px;
}
.body h3 {
  font-size: 15.5px;
  letter-spacing: 1px;
  margin-bottom: 6px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.desc {
  font-size: 12.5px;
  line-height: 1.55;
  color: rgba(43, 43, 43, 0.72);
  margin-bottom: 10px;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
  min-height: 38px;
}
.meta {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 8px;
  margin-bottom: 10px;
}
.price {
  font-size: 14px;
  font-weight: bold;
  color: var(--red);
}
.seller {
  font-size: 11.5px;
  color: rgba(43, 43, 43, 0.55);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.buy {
  width: 100%;
  font-family: inherit;
  font-size: 14px;
  letter-spacing: 2px;
  padding: 8px 0;
  color: #fff;
  background: var(--red);
  border: 2px solid var(--ink);
  border-radius: var(--radius-button);
  box-shadow: 3px 3px 0 var(--ink);
  cursor: pointer;
  transition: transform 0.08s, box-shadow 0.08s, background 0.12s;
}
.buy:hover:not(:disabled) {
  background: #d63f31;
}
.buy:active:not(:disabled) {
  transform: translate(3px, 3px);
  box-shadow: 0 0 0 var(--ink);
}
.buy:disabled {
  background: rgba(43, 43, 43, 0.25);
  cursor: not-allowed;
  box-shadow: none;
}

.buyer-line {
  text-align: center;
  font-size: 12.5px;
  color: rgba(43, 43, 43, 0.6);
  padding: 8px 0 2px;
}
.buyer-line b {
  color: var(--red);
}

/* ------ 上架弹层 ------ */
.mask {
  position: fixed;
  inset: 0;
  z-index: 20;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 20px;
  background: rgba(43, 43, 43, 0.42);
  backdrop-filter: blur(2px);
}
.sheet {
  width: min(94vw, 460px);
  background: var(--card-bg);
  border: 3px solid var(--ink);
  border-radius: 26px 18px 30px 16px;
  box-shadow: 10px 12px 0 var(--ink);
  overflow: hidden;
  animation: pop 0.35s var(--ease-pop) both;
}
.banner {
  position: relative;
  height: 92px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-bottom: 3px solid var(--ink);
}
.banner .sym {
  font-size: 40px;
}
.x {
  position: absolute;
  top: 10px;
  right: 12px;
  width: 30px;
  height: 30px;
  font-size: 18px;
  line-height: 1;
  color: var(--ink);
  background: var(--card-bg);
  border: 2px solid var(--ink);
  border-radius: 10px 8px 10px 8px;
  cursor: pointer;
  transition: background 0.12s, transform 0.08s;
}
.x:hover {
  background: var(--yellow);
}
.x:active {
  transform: translate(2px, 2px);
}

.form {
  padding: 18px 20px 20px;
  display: flex;
  flex-direction: column;
  gap: 12px;
}
.form label {
  display: flex;
  flex-direction: column;
  gap: 5px;
  font-size: 13px;
  color: var(--ink);
}
.form input,
.form textarea {
  font-family: inherit;
  font-size: 14px;
  padding: 8px 12px;
  color: var(--ink);
  background: var(--cream);
  border: 2px solid var(--ink);
  border-radius: var(--radius-input);
  box-shadow: var(--shadow-input);
  resize: vertical;
}
.form input:focus,
.form textarea:focus {
  outline: none;
  box-shadow: var(--shadow-input-focus);
}
.row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 12px;
}

.color-row {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 13px;
}
.swatch {
  width: 26px;
  height: 26px;
  border: 2px solid var(--ink);
  border-radius: 8px 6px 8px 6px;
  cursor: pointer;
  transition: transform 0.1s, box-shadow 0.1s;
}
.swatch.on {
  transform: scale(1.15);
  box-shadow: 3px 3px 0 var(--ink);
}

.err {
  font-size: 12.5px;
  color: var(--red);
  background: rgba(239, 75, 60, 0.08);
  padding: 8px 10px;
  border-radius: 8px;
  border: 1px dashed var(--red);
}

.actions-row {
  display: flex;
  justify-content: space-between;
  gap: 12px;
  margin-top: 4px;
}
.ghost,
.solid {
  font-family: inherit;
  font-size: 14px;
  letter-spacing: 1px;
  padding: 8px 18px;
  border: 2px solid var(--ink);
  border-radius: var(--radius-button);
  cursor: pointer;
  transition: transform 0.08s, box-shadow 0.08s, background 0.12s;
}
.ghost {
  color: var(--ink);
  background: var(--card-bg);
}
.ghost:hover {
  background: var(--cream);
}
.solid {
  flex: 1;
  color: #fff;
  background: var(--red);
  box-shadow: 4px 4px 0 var(--ink);
}
.solid:hover:not(:disabled) {
  background: #d63f31;
}
.solid:active:not(:disabled) {
  transform: translate(4px, 4px);
  box-shadow: 0 0 0 var(--ink);
}
.solid:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.18s;
}
.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}

@media (max-width: 640px) {
  .head {
    align-items: flex-start;
    flex-direction: column;
  }
  .row {
    grid-template-columns: 1fr;
  }
}
</style>
