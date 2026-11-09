package com.fenglin.springboottest.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.conditions.query.LambdaQueryChainWrapper;
import com.fenglin.springboottest.common.Result;
import com.fenglin.springboottest.entity.Content;
import com.fenglin.springboottest.service.ContentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

/**
 * 首页内容接口：推荐列表 / 关键词搜索 / 随机换一批 / 分类统计。
 * 路径前缀 /api，与前端 Vite 代理（/api -> 8081）对应。
 */
@RestController
@RequestMapping("/api")
public class ContentController {

    /** 首页默认推荐条数 */
    private static final int HOME_LIMIT = 12;

    /** 单次返回上限，防止前端乱传 */
    private static final int MAX_LIMIT = 60;

    @Autowired
    private ContentService contentService;

    /**
     * 首页展示：推荐内容列表（按 id 升序）。
     *
     * @param limit    返回条数，默认 12，上限 60
     * @param category 分类过滤（动画 / 漫画 / 游戏 / 剧场版 / 角色 / 美食），为空表示全部
     */
    @GetMapping("/contents")
    public Result<List<Content>> list(@RequestParam(required = false) Integer limit,
                                      @RequestParam(required = false) String category) {
        return Result.ok("获取成功", queryByCategory(category)
                .orderByAsc(Content::getId)
                .last("limit " + normalize(limit))
                .list());
    }

    /**
     * 「换一批」：同分类内随机推荐。
     */
    @GetMapping("/contents/recommend")
    public Result<List<Content>> recommend(@RequestParam(required = false) Integer size,
                                           @RequestParam(required = false) String category) {
        return Result.ok("换好啦", queryByCategory(category)
                .last("order by rand() limit " + normalize(size))
                .list());
    }

    /**
     * 分类统计：首页筛选 chips 的角标数据。
     */
    @GetMapping("/contents/categories")
    public Result<List<Map<String, Object>>> categories() {
        QueryWrapper<Content> wrapper = new QueryWrapper<>();
        wrapper.select("category", "count(*) as total").groupBy("category").orderByAsc("category");
        return Result.ok("获取成功", contentService.listMaps(wrapper));
    }

    /**
     * 搜索：标题 / 描述 / 标签 / 分类 模糊匹配。
     * 关键词为空时等同于推荐列表。
     */
    @GetMapping("/contents/search")
    public Result<List<Content>> search(@RequestParam(required = false) String keyword) {
        String kw = keyword == null ? "" : keyword.trim();

        if (kw.isEmpty()) {
            return list(null, null);
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

    /** 带可选分类条件的链式查询 */
    private LambdaQueryChainWrapper<Content> queryByCategory(String category) {
        LambdaQueryChainWrapper<Content> query = contentService.lambdaQuery();
        if (category != null && !category.isBlank() && !"全部".equals(category)) {
            query.eq(Content::getCategory, category.trim());
        }
        return query;
    }

    /** 条数兜底：空/非正数用默认值，超过上限按上限算 */
    private int normalize(Integer limit) {
        if (limit == null || limit <= 0) {
            return HOME_LIMIT;
        }
        return Math.min(limit, MAX_LIMIT);
    }
}
