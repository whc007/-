-- ============================================================
-- 小游戏成绩表（动感光波大作战排行榜）
-- 说明：
--   1) 由 Spring Boot 的 spring.sql.init 在启动时自动执行，可重复执行。
--   2) 只存成绩，不存用户关系；username 取自前端 sessionStorage（仅前端登录态）。
-- ============================================================

USE springboot_test;

CREATE TABLE IF NOT EXISTS game_score
(
    id         BIGINT      NOT NULL AUTO_INCREMENT COMMENT '主键',
    username   VARCHAR(50) NOT NULL                COMMENT '玩家昵称',
    score      INT         NOT NULL DEFAULT 0      COMMENT '本局得分',
    hits       INT         NOT NULL DEFAULT 0      COMMENT '击中怪人次数',
    created_at DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (id),
    KEY idx_score (score DESC, id ASC)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_general_ci
  COMMENT = '小游戏成绩（排行榜）';

-- 演示数据：仅当表为空时插入一次（count 守卫），之后玩家成绩会自然叠加
INSERT INTO game_score (username, score, hits)
SELECT u, s, h
FROM (SELECT '野原新之助' AS u, 260 AS s, 26 AS h
      UNION ALL
      SELECT '风间彻', 180, 18
      UNION ALL
      SELECT '樱田妮妮', 120, 14) AS seed
WHERE (SELECT COUNT(*) FROM game_score) = 0;
