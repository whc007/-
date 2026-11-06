-- ============================================================
-- 首页内容表初始化脚本（推荐卡片 + 搜索数据源）
-- 数据库：springboot_test
-- 说明：
--   1) 由 Spring Boot 的 spring.sql.init 在启动时自动执行（与 user_schema.sql 一起）。
--   2) CREATE TABLE IF NOT EXISTS + INSERT IGNORE（title 唯一键），可重复执行不产生重复数据。
--   3) color / symbol 是前端装饰字段：首页卡片直接按此渲染色块与符号。
-- ============================================================

USE springboot_test;

CREATE TABLE IF NOT EXISTS content
(
    id          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
    title       VARCHAR(100) NOT NULL                COMMENT '标题（唯一，便于种子数据幂等）',
    description VARCHAR(255) NOT NULL DEFAULT ''     COMMENT '一句话描述',
    tag         VARCHAR(50)  NOT NULL DEFAULT ''     COMMENT '标签（热血 / 萌宠 / 玩具 / 零食…）',
    category    VARCHAR(50)  NOT NULL DEFAULT ''     COMMENT '分类（动画 / 漫画 / 游戏）',
    color       VARCHAR(30)  NOT NULL DEFAULT 'var(--red)' COMMENT '前端装饰色（CSS 颜色或变量）',
    symbol      VARCHAR(8)   NOT NULL DEFAULT '★'    COMMENT '前端装饰符号',
    created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (id),
    UNIQUE KEY uk_title (title)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_general_ci
  COMMENT = '首页内容表（推荐与搜索）';

-- 种子数据：蜡笔小新主题，title 唯一 + INSERT IGNORE 保证可重复执行
INSERT IGNORE INTO content (title, description, tag, category, color, symbol) VALUES
('动感超人特辑',       '动感光波，哔哔哔！和怪人决一胜负。',           '热血', '动画', 'var(--red)',    '★'),
('小新的告白大作战',   '娜娜子姐姐来家里玩，小新使出浑身解数。',         '日常', '动画', 'var(--blue)',   '♡'),
('康达姆机器人剧场版', '风间最想要的超合金玩具，变形出击。',             '玩具', '动画', 'var(--yellow)', '◆'),
('双叶幼稚园运动会',   '向日葵小班全员出动，接力赛大混乱。',             '校园', '动画', 'var(--skin)',   '●'),
('小白的日常',         '汪汪！今天也去散步、捡棉花糖和看家。',           '萌宠', '漫画', 'var(--blue)',   '●'),
('风间彻的补习班',     '精英小学生的英语课，被小新搅得天翻地覆。',       '校园', '漫画', 'var(--red)',    '★'),
('妮妮的扮家家酒',     '超真实扮家家酒，台词一个比一个狠。',             '日常', '漫画', 'var(--yellow)', '♡'),
('阿呆的石头收藏',     '沉默的阿呆，口袋里全是宝贝石头。',               '日常', '漫画', 'var(--skin)',   '◆'),
('巧克比点心铺',       '甜甜的巧克力饼干，小熊形状限定。',               '零食', '游戏', 'var(--skin)',   '♡'),
('春日部防卫队出动',   '五人组的秘密基地大冒险。',                       '冒险', '游戏', 'var(--red)',    '★'),
('美冴的大拍卖',       '省钱主妇的超市特价情报战。',                     '日常', '游戏', 'var(--blue)',   '●'),
('广志的脚臭危机',     '春日部最强的生化武器，请勿靠近。',               '搞笑', '游戏', 'var(--yellow)', '◆');
