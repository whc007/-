package com.fenglin.springboottest.dto;

/**
 * 注册请求体。
 */
public class RegisterRequest {

    /** 名字 / 昵称 */
    private String username;

    /** 邮箱 */
    private String email;

    /** 明文密码 */
    private String password;

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

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }
}
