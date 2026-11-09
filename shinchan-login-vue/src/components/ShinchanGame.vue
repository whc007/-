<template>
  <!-- 互动小游戏：动感光波大作战（15 秒反应力） -->
  <section class="game">
    <header class="head">
      <div class="title">
        <h2><span class="mark">⚡</span> 动感光波大作战</h2>
        <p class="sub">15 秒内点掉冒出来的怪人，巧克比是补给（+5 分 / +1.2 秒）</p>
      </div>
      <div class="stats">
        <span class="stat"><i>得分</i><b>{{ score }}</b></span>
        <span class="stat"><i>时间</i><b>{{ (timeLeft / 1000).toFixed(1) }}s</b></span>
        <span class="stat"><i>最高</i><b>{{ best }}</b></span>
      </div>
    </header>

    <div class="stage">
      <div class="grid" :class="{ live: status === 'playing' }">
        <button
          v-for="(cell, i) in cells"
          :key="i"
          class="hole"
          type="button"
          :aria-label="cell ? (cell.type === 'monster' ? '怪人' : '巧克比') : '空'"
          @pointerdown.prevent="hit(i)"
        >
          <span v-if="cell" class="target" :class="cell.type">
            <!-- 怪人 -->
            <svg v-if="cell.type === 'monster'" viewBox="0 0 64 64" class="art">
              <path
                d="M32 8c13 0 21 8.5 21 21 0 13-8 24-21 24S11 42 11 29C11 16.5 19 8 32 8z"
                fill="#8ed081"
                stroke="#2b2b2b"
                stroke-width="3"
              />
              <path d="M13 10 7 3M51 10l6-7" stroke="#2b2b2b" stroke-width="3" stroke-linecap="round" />
              <circle cx="24" cy="27" r="6" fill="#fff" stroke="#2b2b2b" stroke-width="2.5" />
              <circle cx="41" cy="27" r="6" fill="#fff" stroke="#2b2b2b" stroke-width="2.5" />
              <circle cx="24" cy="28" r="2.6" fill="#2b2b2b" />
              <circle cx="41" cy="28" r="2.6" fill="#2b2b2b" />
              <path d="M22 41q10 8 20 0" fill="none" stroke="#2b2b2b" stroke-width="3" stroke-linecap="round" />
            </svg>
            <!-- 巧克比 -->
            <svg v-else viewBox="0 0 64 64" class="art">
              <circle cx="20" cy="17" r="6" fill="#a9662f" stroke="#2b2b2b" stroke-width="2.5" />
              <circle cx="44" cy="17" r="6" fill="#a9662f" stroke="#2b2b2b" stroke-width="2.5" />
              <rect x="9" y="13" width="46" height="42" rx="10" fill="#a9662f" stroke="#2b2b2b" stroke-width="3" />
              <circle cx="24" cy="30" r="3.2" fill="#fff8e1" />
              <circle cx="41" cy="30" r="3.2" fill="#fff8e1" />
              <path d="M26 42q6 5 12 0" fill="none" stroke="#fff8e1" stroke-width="3" stroke-linecap="round" />
            </svg>
          </span>

          <span
            v-for="f in floats.filter((x) => x.cell === i)"
            :key="f.id"
            class="float"
            :class="f.kind"
            >{{ f.text }}</span
          >
        </button>
      </div>

      <aside class="side">
        <div class="panel">
          <!-- 未开始 -->
          <template v-if="status === 'idle'">
            <p class="p-tip">准备好了吗？<br />怪人出现就戳它！</p>
            <button class="primary" type="button" @click="start">开 打 ！</button>
            <p class="p-note">键盘党：按空格也能开始</p>
          </template>

          <!-- 进行中 -->
          <template v-else-if="status === 'playing'">
            <div class="bar"><span :style="{ width: percent + '%' }"></span></div>
            <p class="p-tip big">{{ score }} 分</p>
            <p class="p-note">击中 {{ hits }} 只怪人</p>
            <p v-if="combo >= 3" class="combo">连击 ×{{ combo }}！</p>
          </template>

          <!-- 结束 -->
          <template v-else>
            <div class="rank" :class="'r-' + result.grade">{{ result.grade }}</div>
            <p class="p-tip">{{ result.text }}</p>
            <p class="p-note">本局 {{ score }} 分 · 击中 {{ hits }} 只</p>
            <p v-if="submitInfo" class="p-note submit">
              已上榜：第 {{ submitInfo.rank }} 名 / 共 {{ submitInfo.total }} 场
            </p>
            <button class="primary" type="button" @click="start">再 来 一 局</button>
          </template>
        </div>

        <div class="board">
          <div class="board-head">
            <h3>春日部排行榜</h3>
            <button class="mini" type="button" @click="loadBoard">刷新</button>
          </div>
          <ol v-if="board.length" class="board-list">
            <li v-for="(row, i) in board" :key="row.id">
              <span class="no">{{ i + 1 }}</span>
              <span class="who">{{ row.username }}</span>
              <span class="sc">{{ row.score }} 分</span>
            </li>
          </ol>
          <p v-else class="board-empty">还没有人上榜，快去当第一个英雄。</p>
        </div>
      </aside>
    </div>
  </section>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { ranks } from '../data/shinchan.js'

const props = defineProps({
  username: { type: String, default: '小伙伴' }
})
const emit = defineEmits(['toast'])

const API_BASE = import.meta.env.VITE_API_BASE || ''
const BEST_KEY = 'shinchan-game-best'

const CELLS = 9
const DURATION = 15000

const status = ref('idle') // idle | playing | over
const cells = ref(Array.from({ length: CELLS }, () => null))
const score = ref(0)
const hits = ref(0)
const combo = ref(0)
const timeLeft = ref(DURATION)
const best = ref(Number(localStorage.getItem(BEST_KEY) || 0))
const result = ref({ grade: 'C', text: '' })
const submitInfo = ref(null)
const board = ref([])
const floats = ref([])

let spawnTimer = null
let tickTimer = null
let flowTimers = []
let seq = 0
let floatSeq = 0

const percent = computed(() => Math.max(0, Math.min(100, (timeLeft.value / DURATION) * 100)))

function clearTimers() {
  if (spawnTimer) clearTimeout(spawnTimer)
  if (tickTimer) clearInterval(tickTimer)
  flowTimers.forEach(clearTimeout)
  spawnTimer = null
  tickTimer = null
  flowTimers = []
}

function start() {
  clearTimers()
  status.value = 'playing'
  cells.value = Array.from({ length: CELLS }, () => null)
  score.value = 0
  hits.value = 0
  combo.value = 0
  floats.value = []
  submitInfo.value = null
  timeLeft.value = DURATION

  tickTimer = setInterval(() => {
    timeLeft.value -= 100
    if (timeLeft.value <= 0) {
      timeLeft.value = 0
      end()
    }
  }, 100)

  scheduleSpawn(400)
}

/** 越到后面怪人冒头越快 */
function scheduleSpawn(delay) {
  spawnTimer = setTimeout(() => {
    spawn()
    if (status.value !== 'playing') return
    const elapsed = DURATION - timeLeft.value
    const pace = 560 - (elapsed / DURATION) * 220
    scheduleSpawn(pace + Math.random() * 200)
  }, delay)
}

function spawn() {
  if (status.value !== 'playing') return
  const empty = cells.value.map((c, i) => (c ? -1 : i)).filter((i) => i >= 0)
  if (!empty.length) return

  const idx = empty[Math.floor(Math.random() * empty.length)]
  const type = Math.random() < 0.78 ? 'monster' : 'choco'
  const token = ++seq
  const next = cells.value.slice()
  next[idx] = { type, token }
  cells.value = next

  // 到时间自己缩回去（漏掉不扣分，只断连击）
  const life = type === 'monster' ? 1000 : 1200
  flowTimers.push(
    setTimeout(() => {
      if (cells.value[idx] && cells.value[idx].token === token) {
        const copy = cells.value.slice()
        copy[idx] = null
        cells.value = copy
        if (type === 'monster') combo.value = 0
      }
    }, life)
  )
}

function hit(i) {
  if (status.value !== 'playing') return
  const cell = cells.value[i]
  if (!cell) return

  const copy = cells.value.slice()
  copy[i] = null
  cells.value = copy

  if (cell.type === 'monster') {
    score.value += 10
    hits.value += 1
    combo.value += 1
    addFloat(i, '+10', 'good')
  } else {
    score.value += 5
    timeLeft.value = Math.min(timeLeft.value + 1200, DURATION)
    addFloat(i, '+5 ⏱', 'choco')
  }
}

function addFloat(cell, text, kind) {
  const id = ++floatSeq
  floats.value = [...floats.value, { id, cell, text, kind }]
  flowTimers.push(
    setTimeout(() => {
      floats.value = floats.value.filter((f) => f.id !== id)
    }, 700)
  )
}

function end() {
  clearTimers()
  status.value = 'over'
  cells.value = Array.from({ length: CELLS }, () => null)
  const grade = score.value >= 200 ? 'S' : score.value >= 140 ? 'A' : score.value >= 80 ? 'B' : 'C'
  result.value = { grade, text: ranks[grade].text }

  if (score.value > best.value) {
    best.value = score.value
    localStorage.setItem(BEST_KEY, String(best.value))
  }

  submitScore()
}

async function submitScore() {
  try {
    const res = await fetch(`${API_BASE}/api/game/scores`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ username: props.username, score: score.value, hits: hits.value })
    })
    const data = await res.json()
    if (data.code === 0) {
      submitInfo.value = data.data
      await loadBoard()
    }
  } catch (e) {
    emit('toast', `成绩没能上传\n${e.message || '待会儿再试'}`)
  }
}

async function loadBoard() {
  try {
    const res = await fetch(`${API_BASE}/api/game/leaderboard?size=5`)
    const data = await res.json()
    board.value = data.code === 0 ? data.data || [] : []
  } catch {
    board.value = []
  }
}

function onKeydown(e) {
  if (e.code === 'Space' && status.value !== 'playing') {
    e.preventDefault()
    start()
  }
}

onMounted(() => {
  loadBoard()
  window.addEventListener('keydown', onKeydown)
})

onUnmounted(() => {
  clearTimers()
  window.removeEventListener('keydown', onKeydown)
})
</script>

<style scoped>
.game {
  background: var(--card-bg);
  border: 3px solid var(--ink);
  border-radius: var(--radius-card);
  box-shadow: var(--shadow-card);
  padding: 20px 22px 18px;
  animation: pop var(--dur-pop) var(--ease-pop) 0.15s both;
}

.head {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 14px;
  flex-wrap: wrap;
  margin-bottom: 14px;
}
.head h2 {
  font-size: 19px;
  letter-spacing: 2px;
}
.head .mark {
  color: var(--red);
}
.head .sub {
  font-size: 12px;
  color: rgba(43, 43, 43, 0.62);
  margin-top: 4px;
}
.stats {
  display: flex;
  gap: 10px;
}
.stat {
  display: flex;
  flex-direction: column;
  align-items: center;
  min-width: 62px;
  padding: 5px 10px;
  background: var(--cream);
  border: 2px solid var(--ink);
  border-radius: 12px 9px 13px 9px;
}
.stat i {
  font-style: normal;
  font-size: 11px;
  color: rgba(43, 43, 43, 0.6);
}
.stat b {
  font-size: 16px;
  color: var(--red);
}

.stage {
  display: flex;
  gap: 22px;
  align-items: stretch;
}
@media (max-width: 680px) {
  .stage {
    flex-direction: column;
  }
}

.grid {
  flex: 0 0 400px;
  max-width: 100%;
  align-self: center;
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 9px;
  padding: 10px;
  background: #f6e7bd;
  border: 3px dashed rgba(43, 43, 43, 0.35);
  border-radius: 20px 14px 20px 14px;
}
@media (max-width: 680px) {
  .grid {
    flex: 0 0 auto;
    width: 100%;
  }
}
.grid.live {
  border-style: solid;
  border-color: var(--red);
}

.hole {
  position: relative;
  aspect-ratio: 1 / 1;
  display: flex;
  align-items: center;
  justify-content: center;
  font-family: inherit;
  background: rgba(255, 255, 255, 0.75);
  border: 2px solid rgba(43, 43, 43, 0.25);
  border-radius: 50% 44% 50% 46%;
  cursor: pointer;
  overflow: visible;
  -webkit-tap-highlight-color: transparent;
}
.hole::after {
  content: '';
  position: absolute;
  inset: 26% 22%;
  border-radius: 50%;
  background: rgba(43, 43, 43, 0.08);
  box-shadow: inset 0 3px 6px rgba(43, 43, 43, 0.18);
}

.target {
  position: relative;
  z-index: 2;
  width: 74%;
  height: 74%;
  display: flex;
  align-items: center;
  justify-content: center;
  animation: poke 0.22s var(--ease-pop) both;
}
.target .art {
  width: 100%;
  height: 100%;
  filter: drop-shadow(2px 3px 0 rgba(43, 43, 43, 0.2));
}
@keyframes poke {
  from {
    transform: scale(0.4) rotate(-12deg);
    opacity: 0;
  }
  to {
    transform: scale(1) rotate(0);
    opacity: 1;
  }
}

.float {
  position: absolute;
  top: 4%;
  left: 50%;
  transform: translateX(-50%);
  font-size: 15px;
  font-weight: bold;
  color: var(--red);
  text-shadow: 1px 1px 0 #fff;
  animation: rise 0.7s ease-out both;
  pointer-events: none;
  z-index: 3;
}
.float.choco {
  color: #a9662f;
}
@keyframes rise {
  from {
    opacity: 1;
    transform: translate(-50%, 0);
  }
  to {
    opacity: 0;
    transform: translate(-50%, -26px);
  }
}

.side {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.panel {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 8px;
  text-align: center;
  padding: 8px 4px;
}
@media (max-width: 680px) {
  .side {
    width: 100%;
  }
}
.p-tip {
  font-size: 14px;
  line-height: 1.6;
}
.p-tip.big {
  font-size: 26px;
  color: var(--red);
}
.p-note {
  font-size: 12px;
  color: rgba(43, 43, 43, 0.6);
}
.p-note.submit {
  color: var(--blue);
}
.combo {
  font-size: 14px;
  color: var(--yellow);
  text-shadow: 1px 1px 0 var(--ink);
}

.bar {
  width: min(100%, 280px);
  height: 12px;
  background: rgba(43, 43, 43, 0.12);
  border: 2px solid var(--ink);
  border-radius: 8px;
  overflow: hidden;
}
.bar span {
  display: block;
  height: 100%;
  background: linear-gradient(90deg, var(--yellow), var(--red));
  transition: width 0.1s linear;
}

.primary {
  font-family: inherit;
  font-size: 17px;
  letter-spacing: 2px;
  padding: 10px 22px;
  color: #fff;
  background: var(--red);
  border: 3px solid var(--ink);
  border-radius: var(--radius-button);
  box-shadow: var(--shadow-button);
  cursor: pointer;
  transition: transform 0.08s, box-shadow 0.08s, background 0.12s;
}
.primary:hover {
  background: #ff5d4d;
}
.primary:active {
  transform: translate(4px, 4px);
  box-shadow: 0 0 0 var(--ink);
}

.rank {
  width: 62px;
  height: 62px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 32px;
  color: #fff;
  text-shadow: 2px 2px 0 var(--ink);
  background: var(--blue);
  border: 3px solid var(--ink);
  border-radius: 50% 44% 52% 46%;
  box-shadow: 3px 4px 0 var(--ink);
  animation: pop 0.45s var(--ease-pop) both;
}
.rank.r-S {
  background: var(--red);
}
.rank.r-A {
  background: var(--yellow);
  color: var(--ink);
  text-shadow: none;
}
.rank.r-B {
  background: var(--skin);
  color: var(--ink);
  text-shadow: none;
}

.board {
  padding: 10px 12px 12px;
  background: rgba(255, 244, 207, 0.55);
  border: 2px dashed rgba(43, 43, 43, 0.22);
  border-radius: 16px 12px 16px 12px;
}
.board-head {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 8px;
}
.board-head h3 {
  font-size: 15px;
  letter-spacing: 1px;
}
.mini {
  font-family: inherit;
  font-size: 12px;
  padding: 2px 10px;
  color: var(--ink);
  background: var(--cream);
  border: 2px solid var(--ink);
  border-radius: 12px 9px 12px 9px;
  cursor: pointer;
}
.mini:hover {
  background: var(--yellow);
}
.board-list {
  list-style: none;
  display: flex;
  flex-direction: column;
  gap: 6px;
}
.board-list li {
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 13px;
  padding: 5px 10px;
  background: var(--cream);
  border: 2px solid rgba(43, 43, 43, 0.2);
  border-radius: 12px 9px 12px 9px;
}
.board-list .no {
  width: 20px;
  height: 20px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
  color: #fff;
  background: var(--blue);
  border-radius: 50%;
}
.board-list li:nth-child(1) .no {
  background: var(--red);
}
.board-list .who {
  flex: 1;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.board-list .sc {
  color: var(--red);
  font-weight: bold;
}
.board-empty {
  font-size: 12px;
  color: rgba(43, 43, 43, 0.55);
}
</style>
