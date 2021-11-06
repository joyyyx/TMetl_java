package com.example.taimeietl.controller;

import com.example.taimeietl.kettle.RunJob;
import com.example.taimeietl.map.TableInfoMapper;
import com.example.taimeietl.model.SourceInfo;
import com.example.taimeietl.model.TableInfo;
import com.example.taimeietl.services.SourceInfoService;
import com.example.taimeietl.services.TableInfoService;
import com.example.taimeietl.tools.SqlJobTools;
import org.pentaho.di.job.Job;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.util.Date;

@RestController
public class Runkettle {
    @Autowired
    RunJob runJob;
    @Autowired
    SourceInfoService sourceInfoService;
    //    tid is 0 then all
    @Autowired
    TableInfoService tableInfoService;

    @RequestMapping("/tmetl/hello")
    public String hello(int sid, int tid) {
        SourceInfo sourceInfo = sourceInfoService.selectByPrimaryKey(sid);
        int sourceType = sourceInfo.getSourceType();
        if (sourceType == 1) {
            Job job = runJob.runJob(sid, tid, "extractData");
//        try {
//            while (true) {
//                if (job == null || !(job.getStatus().equals("Running") || job.getStatus().equals("Waiting"))) {
//                    break;
//                }
//                System.out.println("sleep.....********** 上个job状态：" );
//                Thread.sleep(10000);
//            }
//        }
//        catch (Exception e){
//            e.printStackTrace();
//        }
            final Thread thread = new Thread(new Runnable() {
                @Override
                public void run() {
                    while (true) {
                        if (!(job.getStatus().equals("Running") || job.getStatus().equals("Waiting"))) {
                            if (job.getStatus().equals("Finished")) {
                                TableInfo tableInfo = tableInfoService.selectByPrimaryKey(tid);
                                tableInfoService.handleTable(sid, tid, 0, "aaa");
//                                tableInfoService.runSQL(SqlJobTools.getUpdateTableSql(tid, tableInfo.getPl()));
                                System.out.println("tableId:" + tid + " has finished successfully!!");
                            }
                            break;
                        }
                        try {
                            Thread.sleep(10000);
                        } catch (InterruptedException e) {
                            e.printStackTrace();
                        }
                        System.out.println("当前作业状态为：" + job.getStatus());
                    }
                }
            });
            thread.start();
        }
        else if(sourceType>=2){
            System.out.println(new Date());
            tableInfoService.createTableOrInsertTableBywebService(sid,tid,0);
            System.out.println(new Date());
            TableInfo tableInfo = tableInfoService.selectByPrimaryKey(tid);
            tableInfoService.handleTable(sid, tid, 0, "aaa");
//            tableInfoService.runSQL(SqlJobTools.getUpdateTableSql(tid, tableInfo.getPl()));
            System.out.println("tableId:" + tid + " has finished successfully!!");
        }
        return "hello";
    }
}
