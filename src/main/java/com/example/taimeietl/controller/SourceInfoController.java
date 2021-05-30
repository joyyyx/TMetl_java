package com.example.taimeietl.controller;

import com.example.taimeietl.kettle.Test;
import com.example.taimeietl.model.SourceInfo;
import com.example.taimeietl.services.SourceInfoService;
import com.example.taimeietl.services.servicesImpl.SourceInfoServiceImpl;
import org.springframework.beans.factory.annotation.Autowired;
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

}
