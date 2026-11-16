-- ============================================================
-- 跳蚤市场表（春日部二手摊）
-- 说明：
--   1) 由 Spring Boot 的 spring.sql.init 在启动时自动执行，可重复执行。
--   2) 商品上架后买家点击「我想要」即成交，价格单位为「巧克比」。
--   3) buyer 为 NULL 表示在售，非 NULL 表示已售出并记录买家昵称。
-- ============================================================

USE springboot_test;

CREATE TABLE IF NOT EXISTS flea_market_item
(
    id          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
    title       VARCHAR(60)  NOT NULL                COMMENT '商品标题',
    description VARCHAR(255) NOT NULL DEFAULT ''     COMMENT '商品描述',
    price       INT          NOT NULL DEFAULT 1      COMMENT '价格（单位：巧克比）',
    symbol      VARCHAR(8)   NOT NULL DEFAULT '★'    COMMENT '装饰符号（emoji/字符画）',
    color       VARCHAR(40)  NOT NULL DEFAULT 'var(--yellow)' COMMENT '卡片底色（CSS 变量或色值）',
    seller      VARCHAR(50)  NOT NULL                COMMENT '卖家昵称',
    buyer       VARCHAR(50)  NULL                    COMMENT '买家昵称（NULL=在售）',
    created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '上架时间',
    sold_at     DATETIME     NULL                    COMMENT '成交时间',
    PRIMARY KEY (id),
    KEY idx_buyer (buyer),
    KEY idx_created (created_at DESC)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_general_ci
  COMMENT = '跳蚤市场商品';

-- 演示数据：仅当表为空时插入一次（count 守卫），与 game_score 同款策略
INSERT INTO flea_market_item (title, description, price, symbol, color, seller)
SELECT t, d, p, s, c, u
FROM (
         SELECT '小新的动感超人手办' AS t, '99 新，只是盒子被小白咬过一角，配件齐全。' AS d, 12 AS p, '🦸' AS s, 'var(--red)' AS c, '野原新之助' AS u
         UNION ALL
         SELECT '妮妮的兔子玩偶（二手）', '之前陪睡的，现在换新的了，谁带走就给谁讲故事。', 5, '🐰', 'var(--cheek)', '樱田妮妮'
         UNION ALL
         SELECT '风间的英语单词卡', '春日部小学五年级全套，附赠重点整理笔记。', 8, '📚', 'var(--blue)', '风间彻'
         UNION ALL
         SELECT '正男的便当布', '洗得很干净，花纹是动感超人，已经不想要了。', 3, '🍱', 'var(--cream)', '佐藤正男'
         UNION ALL
         SELECT '阿呆的石头收藏', '河边捡的，形状像小白，价格随便给。', 1, '🪨', 'var(--skin)', '阿呆'
         UNION ALL
         SELECT '小白的项圈', '有点大，狗已经戴不下了，求好心人收留。', 4, '🐕', 'var(--yellow)', '野原新之助'
     ) AS seed
WHERE (SELECT COUNT(*) FROM flea_market_item) = 0;
