package com.fenglin.springboottest.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.fenglin.springboottest.entity.FleaMarketItem;
import com.fenglin.springboottest.mapper.FleaMarketItemMapper;
import com.fenglin.springboottest.service.FleaMarketItemService;
import org.springframework.stereotype.Service;

/**
 * 跳蚤市场商品服务实现。
 */
@Service
public class FleaMarketItemServiceImpl extends ServiceImpl<FleaMarketItemMapper, FleaMarketItem>
        implements FleaMarketItemService {
}
