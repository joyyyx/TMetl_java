package com.example.taimeietl.controller;

import com.example.taimeietl.kettle.KettleLogs;
import com.example.taimeietl.kettle.RunJob;
import com.example.taimeietl.model.SourceInfo;
import com.example.taimeietl.model.TableInfo;
import com.example.taimeietl.services.SourceInfoService;
import com.example.taimeietl.services.TableInfoService;
import org.json.JSONObject;
import org.pentaho.di.job.Job;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Date;
import java.util.List;
import java.util.Map;

@RestController
public class TableInfoController {
    @Autowired
    TableInfoService tableInfoServiceImpl;
    @Autowired
    SourceInfoService sourceInfoService;
    @Autowired
    RunJob test;
    @RequestMapping("/tmetl/tableInfo/selectAll")
    public List<TableInfo> selectAll() {
        return tableInfoServiceImpl.selectAll();
    }

    @RequestMapping("/tmetl/tableInfo/insertRecord")
    public int insertRecord(TableInfo tableInfo) {
        return tableInfoServiceImpl.insertRecord(tableInfo);
    }

    @RequestMapping("/tmetl/tableInfo/updateRecord")
    public int updateRecord(TableInfo tableInfo) {
        return tableInfoServiceImpl.updateRecord(tableInfo);
    }

    @RequestMapping("/tmetl/tableInfo/deleteRecord")
    public int deleteRecord(int id) {
        return tableInfoServiceImpl.deleteRecord(id);
    }

    @RequestMapping("/tmetl/getTableContract")
    public String getTableContract(int sid,int tid) {
        SourceInfo sourceInfo = sourceInfoService.selectByPrimaryKey(sid);
        int sourceType = sourceInfo.getSourceType();
        if(sourceType==1) {
            Job job = test.runJob(sid, tid, "getTable");
            while (true) {
                if (job == null || !(job.getStatus().equals("Running") || job.getStatus().equals("Waiting"))) {
                    return job.getStatus();
                } else {

                    try {
                        Thread.sleep(100);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                        return e.toString();
                    }
                }
            }
        }
        if(sourceType>=2) {
            System.out.println(new Date());
            tableInfoServiceImpl.createTableOrInsertTableBywebService(sid,tid,1);
            System.out.println(new Date());
            return "success";
        }
        return "failed";
    }

    @RequestMapping("/tmetl/tableInfo//createTable")
    public int createTable(int sid,int tid,int reCreate) {
        return tableInfoServiceImpl.createTable(sid,tid,reCreate);
    }


    @RequestMapping("/tmetl/tableInfo/updateInit")
    public int updateInit(TableInfo tableInfo) {
        return tableInfoServiceImpl.updateInit(tableInfo);
    }

    @RequestMapping("/tmetl/tableInfo/checkTable")
    public int checkTable(String tableName) {
        return tableInfoServiceImpl.checkTable(tableName);
    }

    @RequestMapping("/tmetl/tableInfo/test")
    public List<Map<String, String>> test(int sid, int tid) {
        TableInfo tableInfo = tableInfoServiceImpl.selectByPrimaryKey(tid);
        SourceInfo sourceInfo = sourceInfoService.selectByPrimaryKey(sid);
        SourceInfo sourceInfo1 = sourceInfoService.selectBySourceType(0);
        String webserviceParamtable = tableInfo.getWebserviceParamtable();
        int sourceType = sourceInfo.getSourceType();
        String sourceDb = sourceInfo1.getSourceDb();
        String webserviceParam = tableInfo.getWebserviceParam();
        JSONObject jsonObject = new JSONObject(webserviceParam);
        Map<String, Object> stringObjectMap = jsonObject.toMap();
        String sql = " SELECT top 1000 ";
        for (String key:stringObjectMap.keySet()
        ) {
            sql = sql +  stringObjectMap.get(key)+",";
        }
        sql = sql.substring(0,sql.length()-1);
        sql =sql +" FROM "+sourceDb+".dbo."+webserviceParamtable;
        List<Map<String, String>> maps = tableInfoServiceImpl.selectSQL(sql);
        return maps;
    }


}
