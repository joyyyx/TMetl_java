package com.example.taimeietl;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.ComponentScan;

@SpringBootApplication
@ComponentScan({"com.example.taimeietl.*"})
public class TaimeietlApplication {

    public static void main(String[] args) {
        SpringApplication.run(TaimeietlApplication.class, args);
    }

}
