package com.fenglin.springboottest.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.fenglin.springboottest.entity.Content;
import com.fenglin.springboottest.mapper.ContentMapper;
import com.fenglin.springboottest.service.ContentService;
import org.springframework.stereotype.Service;

/**
 * 首页内容服务实现。
 */
@Service
public class ContentServiceImpl extends ServiceImpl<ContentMapper, Content> implements ContentService {
}
