package com.fenglin.springboottest.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.fenglin.springboottest.entity.FleaMarketItem;
import org.apache.ibatis.annotations.Mapper;

/**
 * 跳蚤市场商品 Mapper。
 */
@Mapper
public interface FleaMarketItemMapper extends BaseMapper<FleaMarketItem> {
}
