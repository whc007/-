package com.fenglin.springboottest.common;

import com.fenglin.springboottest.entity.User;

/**
 * 返回给前端的用户视图对象，刻意不携带 password 等敏感字段。
 */
public class UserVO {

    private Long id;
    private String username;
    private String email;

    public static UserVO from(User user) {
        UserVO vo = new UserVO();
        vo.id = user.getId();
        vo.username = user.getUsername();
        vo.email = user.getEmail();
        return vo;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }
}
