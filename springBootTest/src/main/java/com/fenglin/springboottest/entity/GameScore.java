package com.fenglin.springboottest.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;

import java.time.LocalDateTime;

/**
 * 小游戏成绩实体，对应表 game_score。
 * 「动感光波大作战」每局结束提交一次，用于首页排行榜。
 */
@TableName("game_score")
public class GameScore {

    @TableId(type = IdType.AUTO)
    private Long id;

    /** 玩家昵称（取自前端会话） */
    private String username;

    /** 本局得分 */
    private Integer score;

    /** 击中怪人次数 */
    private Integer hits;

    private LocalDateTime createdAt;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public Integer getScore() {
        return score;
    }

    public void setScore(Integer score) {
        this.score = score;
    }

    public Integer getHits() {
        return hits;
    }

    public void setHits(Integer hits) {
        this.hits = hits;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
}
