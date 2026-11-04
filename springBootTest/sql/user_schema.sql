-- ============================================================
-- 蜡笔小新风 · 用户表初始化脚本
-- 数据库：springboot_test
-- 说明：
--   1) 本文件由 Spring Boot 的 spring.sql.init 在启动时自动执行（CREATE TABLE IF NOT EXISTS，可重复运行）。
--   2) 若你希望手动建表，可在 MySQL 客户端（root / 123456）直接执行本文件。
--   3) JDBC URL 已配置 createDatabaseIfNotExist=true，数据库不存在时会自动创建；
--      若手动执行，请先确保已执行下面的 CREATE DATABASE 与 USE。
-- ============================================================

CREATE DATABASE IF NOT EXISTS springboot_test
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_general_ci;

USE springboot_test;

CREATE TABLE IF NOT EXISTS sys_user
(
    id          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
    username    VARCHAR(50)  NOT NULL                COMMENT '名字 / 昵称',
    email       VARCHAR(100) NOT NULL                COMMENT '邮箱（登录也可用作账号）',
    password    VARCHAR(100) NOT NULL                COMMENT 'BCrypt 加密后的密码',
    created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (id),
    UNIQUE KEY uk_username (username),
    UNIQUE KEY uk_email (email)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_general_ci
  COMMENT = '用户表';
