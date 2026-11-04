package com.fenglin.springboottest.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.fenglin.springboottest.entity.User;

/**
 * 用户服务接口，继承 MyBatis-Plus 的 IService 获得批量/分页等能力。
 */
public interface UserService extends IService<User> {
}
