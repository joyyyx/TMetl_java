package com.example.taimeietl.controller;

import com.example.taimeietl.kettle.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class Runkettle {
    @Autowired
    Test test;
    @RequestMapping("/tmetl/hello")
    public String hello(int sid) {
        test.runJob(sid);
        return "hello";
    }
}
