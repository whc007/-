package com.fenglin.springboottest.controller;

import com.fenglin.springboottest.common.Result;
import com.fenglin.springboottest.dto.ScoreRequest;
import com.fenglin.springboottest.entity.GameScore;
import com.fenglin.springboottest.service.GameScoreService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 小游戏「动感光波大作战」成绩接口：提交得分 + 排行榜。
 */
@RestController
@RequestMapping("/api/game")
public class GameController {

    /** 排行榜默认条数 */
    private static final int DEFAULT_SIZE = 5;

    /** 排行榜上限 */
    private static final int MAX_SIZE = 20;

    /** 单局得分上限（防手滑/刷分） */
    private static final int MAX_SCORE = 9999;

    @Autowired
    private GameScoreService gameScoreService;

    /**
     * 提交一局成绩，返回该玩家的历史最高分、本局名次和总场次。
     */
    @PostMapping("/scores")
    public Result<Map<String, Object>> submit(@RequestBody ScoreRequest req) {
        String username = req.getUsername() == null ? "" : req.getUsername().trim();
        if (username.isEmpty()) {
            username = "无名小卒";
        }
        int score = req.getScore() == null ? 0 : req.getScore();
        int hits = req.getHits() == null ? 0 : req.getHits();

        if (score < 0 || score > MAX_SCORE) {
            return Result.fail("这个分数不太像话哦");
        }

        GameScore record = new GameScore();
        record.setUsername(username);
        record.setScore(score);
        record.setHits(Math.max(0, hits));
        gameScoreService.save(record);

        // 该玩家历史最高分
        List<GameScore> mine = gameScoreService.lambdaQuery()
                .eq(GameScore::getUsername, username)
                .orderByDesc(GameScore::getScore)
                .last("limit 1")
                .list();
        int best = mine.isEmpty() ? score : Math.max(score, mine.get(0).getScore());

        // 名次：比我高分的人数 + 1
        long higher = gameScoreService.lambdaQuery().gt(GameScore::getScore, score).count();
        long total = gameScoreService.count();

        Map<String, Object> data = new LinkedHashMap<>();
        data.put("best", best);
        data.put("rank", higher + 1);
        data.put("total", total);
        data.put("username", username);
        return Result.ok("成绩已记录", data);
    }

    /**
     * 排行榜：按分数倒序，同分先到先排。
     */
    @GetMapping("/leaderboard")
    public Result<List<GameScore>> leaderboard(@RequestParam(required = false) Integer size) {
        int limit = size == null || size <= 0 ? DEFAULT_SIZE : Math.min(size, MAX_SIZE);
        List<GameScore> list = gameScoreService.lambdaQuery()
                .orderByDesc(GameScore::getScore)
                .orderByAsc(GameScore::getId)
                .last("limit " + limit)
                .list();
        return Result.ok("获取成功", list);
    }
}
