package com.fenglin.springboottest.controller;

import com.fenglin.springboottest.common.Result;
import com.fenglin.springboottest.dto.MarketBuyRequest;
import com.fenglin.springboottest.dto.MarketItemRequest;
import com.fenglin.springboottest.entity.FleaMarketItem;
import com.fenglin.springboottest.service.FleaMarketItemService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 跳蚤市场接口：列表 / 上架 / 购买。
 * 路径前缀 /api/market，与前端 Vite 代理一致。
 */
@RestController
@RequestMapping("/api/market")
public class FleaMarketController {

    /** 单次返回上限，防止前端乱传 */
    private static final int MAX_LIMIT = 100;

    /** 标题最长 */
    private static final int TITLE_MAX = 60;

    /** 描述最长 */
    private static final int DESC_MAX = 255;

    /** 价格范围（单位：巧克比） */
    private static final int PRICE_MIN = 1;
    private static final int PRICE_MAX = 9999;

    /** 颜色白名单：与前端 variables.css 对齐，避免脏数据 */
    private static final java.util.Set<String> COLOR_WHITELIST = java.util.Set.of(
            "var(--red)", "var(--yellow)", "var(--blue)", "var(--skin)",
            "var(--cream)", "var(--cheek)", "var(--ink)", "var(--card-bg)"
    );

    @Autowired
    private FleaMarketItemService fleaMarketItemService;

    /**
     * 列表：默认返回全部，status=on 仅在售 / sold 仅已售。
     * 按创建时间倒序，新上架的排前面。
     */
    @GetMapping("/items")
    public Result<List<FleaMarketItem>> list(@RequestParam(required = false) String status,
                                             @RequestParam(required = false) Integer limit) {
        var query = fleaMarketItemService.lambdaQuery().orderByDesc(FleaMarketItem::getCreatedAt);
        if ("on".equalsIgnoreCase(status)) {
            query.isNull(FleaMarketItem::getBuyer);
        } else if ("sold".equalsIgnoreCase(status)) {
            query.isNotNull(FleaMarketItem::getBuyer);
        }
        int size = limit == null || limit <= 0 ? MAX_LIMIT : Math.min(limit, MAX_LIMIT);
        return Result.ok("获取成功", query.last("limit " + size).list());
    }

    /**
     * 上架新商品。
     */
    @PostMapping("/items")
    public Result<FleaMarketItem> publish(@RequestBody MarketItemRequest req) {
        String title = req.getTitle() == null ? "" : req.getTitle().trim();
        String seller = req.getSeller() == null ? "" : req.getSeller().trim();
        String description = req.getDescription() == null ? "" : req.getDescription().trim();
        String symbol = req.getSymbol() == null ? "" : req.getSymbol().trim();
        String color = req.getColor() == null ? "" : req.getColor().trim();

        if (title.isEmpty()) {
            return Result.fail("给宝贝起个名字吧");
        }
        if (title.length() > TITLE_MAX) {
            return Result.fail("标题太长啦，最多 " + TITLE_MAX + " 个字");
        }
        if (description.length() > DESC_MAX) {
            return Result.fail("描述写不下啦，最多 " + DESC_MAX + " 个字");
        }
        if (seller.isEmpty()) {
            return Result.fail("卖家是谁呀？");
        }

        int price = req.getPrice() == null ? PRICE_MIN : req.getPrice();
        if (price < PRICE_MIN || price > PRICE_MAX) {
            return Result.fail("价格不对哦，要在 " + PRICE_MIN + " 到 " + PRICE_MAX + " 之间");
        }

        FleaMarketItem item = new FleaMarketItem();
        item.setTitle(title);
        item.setDescription(description);
        item.setPrice(price);
        item.setSeller(seller);
        item.setSymbol(symbol.isEmpty() ? "🎁" : symbol);
        // 颜色在白名单里才认，否则回退默认色
        item.setColor(COLOR_WHITELIST.contains(color) ? color : "var(--yellow)");

        fleaMarketItemService.save(item);
        return Result.ok("上架成功", item);
    }

    /**
     * 「我想要」：把商品标记为已售，并记录买家。
     * 已售出的商品重复购买会失败。
     */
    @PostMapping("/items/{id}/buy")
    public Result<FleaMarketItem> buy(@PathVariable Long id, @RequestBody MarketBuyRequest req) {
        FleaMarketItem item = fleaMarketItemService.getById(id);
        if (item == null) {
            return Result.fail("这个宝贝不存在哦");
        }
        if (item.getBuyer() != null) {
            return Result.fail("晚了一步，已经被「" + item.getBuyer() + "」买走啦");
        }

        String buyer = req.getBuyer() == null ? "" : req.getBuyer().trim();
        if (buyer.isEmpty()) {
            return Result.fail("先告诉我你是谁呀");
        }
        if (buyer.equals(item.getSeller())) {
            return Result.fail("自己的东西不能自己买哦");
        }

        item.setBuyer(buyer);
        item.setSoldAt(LocalDateTime.now());
        fleaMarketItemService.updateById(item);
        return Result.ok("成交！", item);
    }
}
