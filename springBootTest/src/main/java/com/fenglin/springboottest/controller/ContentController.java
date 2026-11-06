package com.fenglin.springboottest.controller;

import com.fenglin.springboottest.common.Result;
import com.fenglin.springboottest.entity.Content;
import com.fenglin.springboottest.service.ContentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * 首页内容接口：推荐列表 / 关键词搜索。
 * 路径前缀 /api，与前端 Vite 代理（/api -> 8081）对应。
 */
@RestController
@RequestMapping("/api")
public class ContentController {

    /** 首页推荐条数上限 */
    private static final int HOME_LIMIT = 12;

    @Autowired
    private ContentService contentService;

    /**
     * 首页展示：推荐内容列表（按 id 升序，最多 HOME_LIMIT 条）。
     */
    @GetMapping("/contents")
    public Result<List<Content>> list() {
        List<Content> list = contentService.lambdaQuery()
                .orderByAsc(Content::getId)
                .last("limit " + HOME_LIMIT)
                .list();
        return Result.ok("获取成功", list);
    }

    /**
     * 搜索：标题 / 描述 / 标签 / 分类 模糊匹配。
     * 关键词为空时等同于推荐列表。
     */
    @GetMapping("/contents/search")
    public Result<List<Content>> search(@RequestParam(required = false) String keyword) {
        String kw = keyword == null ? "" : keyword.trim();

        if (kw.isEmpty()) {
            return list();
        }

        List<Content> list = contentService.lambdaQuery()
                .like(Content::getTitle, kw)
                .or().like(Content::getDescription, kw)
                .or().like(Content::getTag, kw)
                .or().like(Content::getCategory, kw)
                .orderByAsc(Content::getId)
                .list();
        return Result.ok("搜索成功", list);
    }
}
