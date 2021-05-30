package com.example.taimeietl.controller;

import com.example.taimeietl.model.SourceInfo;
import com.example.taimeietl.model.TableInfo;
import com.example.taimeietl.services.SourceInfoService;
import com.example.taimeietl.services.TableInfoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
public class TableInfoController {
    @Autowired
    TableInfoService tableInfoServiceImpl;
    @RequestMapping("/tmetl/tableInfo/selectAll")
    public List<TableInfo> selectAll(){
        return  tableInfoServiceImpl.selectAll();
    }
    @RequestMapping("/tmetl/tableInfo/insertRecord")
    public int insertRecord(TableInfo tableInfo){
        return  tableInfoServiceImpl.insertRecord(tableInfo);
    }
    @RequestMapping("/tmetl/tableInfo/updateRecord")
    public int updateRecord(TableInfo tableInfo){
        return  tableInfoServiceImpl.updateRecord(tableInfo);
    }
    @RequestMapping("/tmetl/tableInfo/deleteRecord")
    public int deleteRecord(int id){
        return  tableInfoServiceImpl.deleteRecord(id);
    }

}
