package com.fenglin.springboottest.dto;

/**
 * 跳蚤市场「我想要」的请求体。
 */
public class MarketBuyRequest {

    /** 买家昵称 */
    private String buyer;

    public String getBuyer() {
        return buyer;
    }

    public void setBuyer(String buyer) {
        this.buyer = buyer;
    }
}
