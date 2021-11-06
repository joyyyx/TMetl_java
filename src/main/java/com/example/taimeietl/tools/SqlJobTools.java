package com.example.taimeietl.tools;

import org.junit.Test;
import org.springframework.core.io.ClassPathResource;

import java.io.*;

public class SqlJobTools {
    @Test
    public void test(){
        System.out.println(getUpdateTableSql(1,1));
    }

    public static String getUpdateTableSql(int tid,int pl){
        InputStream inputStream = null;
        ClassPathResource classPathResource = new ClassPathResource("sqljob/udpateTableStatus.sql");
        try {
             inputStream =classPathResource.getInputStream();
        } catch (IOException e) {
            e.printStackTrace();
        }
        return getFileSql(inputStream).replaceAll("\\$\\{TABLE_ID}",String.valueOf(tid)).replaceAll("\\$\\{PL}",String.valueOf(pl));
    }
    public static String getFileSql(InputStream inputStream){
        StringBuilder stringBuilder = new StringBuilder();
        try {
            try (BufferedReader bufferedReader = new BufferedReader(new InputStreamReader(inputStream))) {
                String line;
                while ((line = bufferedReader.readLine()) != null) {
                    stringBuilder.append(line);
                    stringBuilder.append("\r\n");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return stringBuilder.toString();


    }
}
