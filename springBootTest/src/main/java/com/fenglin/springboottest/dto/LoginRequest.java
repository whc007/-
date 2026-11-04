package com.fenglin.springboottest.dto;

/**
 * 登录请求体。username 可以是昵称，也可以是邮箱。
 */
public class LoginRequest {

    /** 昵称 或 邮箱 */
    private String username;

    /** 明文密码 */
    private String password;

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }
}
