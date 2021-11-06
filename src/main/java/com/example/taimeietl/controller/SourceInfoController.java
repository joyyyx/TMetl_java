package com.example.taimeietl.controller;

import com.example.taimeietl.model.SourceInfo;
import com.example.taimeietl.services.SourceInfoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
public class SourceInfoController {
    @Autowired
    SourceInfoService sourceInfoServiceImpl;
    @RequestMapping("/tmetl/sourceInfo/selectAll")
    public List<SourceInfo> selectAll(){
        return  sourceInfoServiceImpl.selectAll();
    }
    @RequestMapping("/tmetl/sourceInfo/insertRecord")
    public int insertRecord(SourceInfo sourceInfo){
        return  sourceInfoServiceImpl.insertRecord(sourceInfo);
    }
    @RequestMapping("/tmetl/sourceInfo/updateRecord")
    public int updateRecord(SourceInfo sourceInfo){
        return  sourceInfoServiceImpl.updateRecord(sourceInfo);
    }
    @RequestMapping("/tmetl/sourceInfo/deleteRecord")
    public int deleteRecord(int id){
        return  sourceInfoServiceImpl.deleteRecord(id);
    }


    @Value("${spring.datasource.ip}")
    public String localip;
    @Value("${spring.datasource.username}")
    public String localusr;
    @Value("${spring.datasource.password}")
    public String localpwd;
    @Value("${spring.datasource.port}")
    public String localport;
    @RequestMapping("/tmetl/sourceInfo/insertOdsSource")
    public int insertOdsSource(){
        SourceInfo sourceInfo = new SourceInfo();
        sourceInfo.setSourceDb("ods");
        sourceInfo.setSourceIp(localip);
        sourceInfo.setSourceName("odsdb");
        sourceInfo.setSourcePort(localport);
        sourceInfo.setSourcePwd(localpwd);
        sourceInfo.setDbType("MSSQLNATIVE");
        sourceInfo.setMark(1);
        sourceInfo.setSourceType(0);
        sourceInfo.setSourceUser(localusr);
        List<SourceInfo> sourceInfos = sourceInfoServiceImpl.selectAll();
        boolean isrflag = true;
        for (SourceInfo s:sourceInfos
             ) {
            int mark = s.getMark();
            int sourceType = s.getSourceType();
            if  (mark==1 && sourceType == 0)
            {
                isrflag=false;
                break;
            }
        }
        int returnstatus = 1;
        if (isrflag)
            returnstatus = sourceInfoServiceImpl.insertRecord(sourceInfo);
        return  returnstatus;
    }
}
