package com.demo.upimesh.controller;

import com.demo.upimesh.service.DemoService;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ResponseBody;

@Controller
public class DashboardController {

    private final DemoService demoService;

    public DashboardController(DemoService demoService) {
        this.demoService = demoService;
    }

    @GetMapping("/")
    public String home() {
        demoService.resetDemo();
        return "dashboard";
    }

    @GetMapping("/health")
    @ResponseBody
    public String health() {
        return "{\"status\": \"UP\", \"service\": \"upi-mesh-poc\"}";
    }
}