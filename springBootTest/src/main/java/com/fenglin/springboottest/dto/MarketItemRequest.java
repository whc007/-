package com.fenglin.springboottest.dto;

/**
 * 跳蚤市场上架新商品的请求体。
 */
public class MarketItemRequest {

    /** 商品标题（必填，最长 60） */
    private String title;

    /** 商品描述（可选） */
    private String description;

    /** 价格（单位：巧克比，1-9999） */
    private Integer price;

    /** 装饰符号（emoji/字符画，可选） */
    private String symbol;

    /** 卡片底色（CSS 变量或色值，可选） */
    private String color;

    /** 卖家昵称（必填） */
    private String seller;

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Integer getPrice() {
        return price;
    }

    public void setPrice(Integer price) {
        this.price = price;
    }

    public String getSymbol() {
        return symbol;
    }

    public void setSymbol(String symbol) {
        this.symbol = symbol;
    }

    public String getColor() {
        return color;
    }

    public void setColor(String color) {
        this.color = color;
    }

    public String getSeller() {
        return seller;
    }

    public void setSeller(String seller) {
        this.seller = seller;
    }
}
