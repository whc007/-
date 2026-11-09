package com.fenglin.springboottest.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.fenglin.springboottest.entity.GameScore;
import com.fenglin.springboottest.mapper.GameScoreMapper;
import com.fenglin.springboottest.service.GameScoreService;
import org.springframework.stereotype.Service;

/**
 * 小游戏成绩服务实现。
 */
@Service
public class GameScoreServiceImpl extends ServiceImpl<GameScoreMapper, GameScore> implements GameScoreService {
}
