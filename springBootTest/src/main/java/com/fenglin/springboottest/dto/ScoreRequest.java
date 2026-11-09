package com.fenglin.springboottest.dto;

/**
 * 小游戏成绩提交请求体。
 */
public class ScoreRequest {

    /** 玩家昵称（前端会话里的用户名） */
    private String username;

    /** 本局得分 */
    private Integer score;

    /** 击中怪人次数 */
    private Integer hits;

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
}
