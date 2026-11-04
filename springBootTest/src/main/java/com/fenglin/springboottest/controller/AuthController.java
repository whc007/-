package com.fenglin.springboottest.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.fenglin.springboottest.common.Result;
import com.fenglin.springboottest.common.UserVO;
import com.fenglin.springboottest.dto.LoginRequest;
import com.fenglin.springboottest.dto.RegisterRequest;
import com.fenglin.springboottest.entity.User;
import com.fenglin.springboottest.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * 认证接口：注册 / 登录。
 * 路径前缀 /api，与前端 Vite 代理（/api -> 8081）对应。
 */
@RestController
@RequestMapping("/api")
public class AuthController {

    @Autowired
    private UserService userService;

    private final BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();

    /**
     * 注册：用户名/邮箱查重 -> BCrypt 加密 -> 落库。
     */
    @PostMapping("/register")
    public Result<UserVO> register(@RequestBody RegisterRequest req) {
        String username = req.getUsername() == null ? "" : req.getUsername().trim();
        String email = req.getEmail() == null ? "" : req.getEmail().trim();
        String password = req.getPassword() == null ? "" : req.getPassword();

        if (username.isEmpty()) {
            return Result.fail("名字不能为空");
        }
        if (!email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$")) {
            return Result.fail("邮箱格式不正确");
        }
        if (password.length() < 6) {
            return Result.fail("密码至少 6 位");
        }

        boolean exists = userService.lambdaQuery()
                .eq(User::getUsername, username)
                .or()
                .eq(User::getEmail, email)
                .exists();
        if (exists) {
            return Result.fail("用户名或邮箱已被注册");
        }

        User user = new User();
        user.setUsername(username);
        user.setEmail(email);
        user.setPassword(encoder.encode(password));
        userService.save(user);

        return Result.ok("注册成功", UserVO.from(user));
    }

    /**
     * 登录：支持用昵称或邮箱登录，BCrypt 校验密码。
     */
    @PostMapping("/login")
    public Result<UserVO> login(@RequestBody LoginRequest req) {
        String account = req.getUsername() == null ? "" : req.getUsername().trim();
        String password = req.getPassword() == null ? "" : req.getPassword();

        if (account.isEmpty() || password.isEmpty()) {
            return Result.fail("账号或密码不能为空");
        }

        User user = userService.lambdaQuery()
                .eq(User::getUsername, account)
                .or()
                .eq(User::getEmail, account)
                .one();

        if (user == null || !encoder.matches(password, user.getPassword())) {
            return Result.fail("用户名或密码错误");
        }

        return Result.ok("登录成功", UserVO.from(user));
    }
}
