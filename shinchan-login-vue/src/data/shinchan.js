/**
 * 首页静态内容：小新台词 + 角色图鉴。
 * 内容型数据放前端，避免每次改文案都要动数据库；卡片数据仍来自后端 content 表。
 */

/** 「今日小新」轮播台词 */
export const quotes = [
  '我回来了～ / 你回来啦～',
  '动感光波！哔哔哔——',
  '大姐姐，要不要和我一起玩呀？',
  '巧克比和小熊饼干，是人生大事。',
  '我是野原新之助，五岁，向日葵小班。',
  '努力不一定有用，但不努力一定很舒服。',
  '小白，我们散步去吧。',
  '大人的世界真难懂。',
  '就算被骂，明天也照样惹事。',
  '妈妈做的咖喱饭，周一和周三一模一样。',
  '风间，你的补习班真的那么好玩吗？',
  '遇到怪人就要上，这才叫英雄。'
];

/** 角色图鉴 */
export const characters = [
  {
    name: '野原新之助',
    nick: '小新',
    age: '5 岁',
    role: '向日葵小班',
    line: '我是野原新之助，五岁！',
    initial: '新',
    color: 'var(--red)'
  },
  {
    name: '野原美冴',
    nick: '美冴妈妈',
    age: '二十代（自称）',
    role: '野原家财政大臣',
    line: '特价，是主妇的战场。',
    initial: '美',
    color: 'var(--cheek)'
  },
  {
    name: '野原广志',
    nick: '广志爸爸',
    age: '35 岁',
    role: '双叶商事课长',
    line: '回家第一件事：脱袜子。',
    initial: '广',
    color: 'var(--blue)'
  },
  {
    name: '野原向日葵',
    nick: '小葵',
    age: '0 岁',
    role: '宝石收藏家',
    line: '闪……闪……',
    initial: '葵',
    color: 'var(--yellow)'
  },
  {
    name: '小白',
    nick: '小白',
    age: '汪',
    role: '野原家的狗',
    line: '汪！（翻译：棉花糖）',
    initial: '白',
    color: 'var(--skin)'
  },
  {
    name: '风间彻',
    nick: '风间',
    age: '5 岁',
    role: '精英小学生',
    line: '我才不跟你们一起胡闹！',
    initial: '风',
    color: 'var(--blue)'
  },
  {
    name: '樱田妮妮',
    nick: '妮妮',
    age: '5 岁',
    role: '扮家家酒导演',
    line: '来玩超真实扮家家酒吧。',
    initial: '妮',
    color: 'var(--red)'
  },
  {
    name: '佐藤正男',
    nick: '正男',
    age: '5 岁',
    role: '向日葵小班',
    line: '呜……对不起。',
    initial: '正',
    color: 'var(--skin)'
  },
  {
    name: '阿呆',
    nick: '阿呆',
    age: '5 岁',
    role: '石头收藏家',
    line: '这块石头，很圆。',
    initial: '呆',
    color: 'var(--yellow)'
  },
  {
    name: '园长先生',
    nick: '园长',
    age: '中年',
    role: '双叶幼稚园',
    line: '大家要好好相处哦。',
    initial: '园',
    color: 'var(--blue)'
  },
  {
    name: '吉永绿',
    nick: '吉永老师',
    age: '年轻',
    role: '向日葵班班主任',
    line: '小新，把裤子穿上。',
    initial: '吉',
    color: 'var(--cheek)'
  },
  {
    name: '动感超人',
    nick: '动感超人',
    age: '永远年轻',
    role: '正义的伙伴',
    line: '动感光波！',
    initial: '超',
    color: 'var(--red)'
  }
];

/** 游戏结束评级台词 */
export const ranks = {
  S: { label: 'S', text: '动感光波全开！你就是春日部的英雄。' },
  A: { label: 'A', text: '相当能打，怪人已经开始躲你了。' },
  B: { label: 'B', text: '不错嘛，再练练就能上电视了。' },
  C: { label: 'C', text: '没关系，小新也经常输给怪人。' }
};
