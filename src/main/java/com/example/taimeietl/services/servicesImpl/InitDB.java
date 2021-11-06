package com.example.taimeietl.services.servicesImpl;

import org.apache.ibatis.jdbc.ScriptRunner;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.stereotype.Service;

import java.io.FileInputStream;
import java.io.FileReader;
import java.io.InputStreamReader;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
@Service
public class InitDB {
    @Value("${spring.datasource.driver-class-name}")
    public String driver;
    @Value("${spring.datasource.username}")
    public String localusr;
    @Value("${spring.datasource.password}")
    public String localpwd;
    @Value("${spring.datasource.url}")
    public String url;
    @Value("${spring.datasource.ip}")
    public String localip;
    public   void init(String jobName) throws ClassNotFoundException, SQLException {
        Class.forName(driver);
        Connection conn = DriverManager.getConnection(url, localusr, localpwd);

        ScriptRunner runner = new ScriptRunner(conn);
        try {
            runner.setStopOnError(true);
//            runner.setFullLineDelimiter(true);
            runner.setDelimiter("go;");
            runner.runScript(new InputStreamReader(new FileInputStream("src/main/resources/sqljob/"+jobName),"UTF-8"));
        } catch (Exception e) {
            e.printStackTrace();
        }
        conn.close();
    }
}
