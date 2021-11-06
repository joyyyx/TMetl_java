package com.example.taimeietl.controller;

import com.example.taimeietl.services.servicesImpl.InitDB;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class InitDBController {
    @Autowired
    InitDB initDB;

    @RequestMapping("/tmetl/initDB")
    public String initDB() {
       try {
           initDB.init("ods.sql");
       }
       catch (Exception e){
           e.printStackTrace();;
       }
        return "success";
    }
}
