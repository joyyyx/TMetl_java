package com.example.taimeietl.controller;

import com.example.taimeietl.model.Crsql;
import com.example.taimeietl.model.TableInfo;
import com.example.taimeietl.services.CrsqlService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
public class CrtableController {
    @Autowired
    CrsqlService crsqlServiceImpl;

    @RequestMapping("/tmetl/crSql/selectAll")
    public List<Crsql> selectAll() {
        return crsqlServiceImpl.selectAll();
    }

    @RequestMapping("/tmetl/crSql/insertRecord")
    public int insertRecord(Crsql crsql) {
        return crsqlServiceImpl.insertRecord(crsql);
    }

    @RequestMapping("/tmetl/crSql/updateRecord")
    public int updateRecord(Crsql crsql) {
        return crsqlServiceImpl.updateRecord(crsql);
    }

    @RequestMapping("/tmetl/crSql/deleteRecord")
    public int deleteRecord(int id) {
        return crsqlServiceImpl.deleteRecord(id);
    }

    @RequestMapping("/tmetl/crSql/modifyCol")
    public int modifyCol(int sid, int tid, int toNvarchar, int narcharLenRate, int charLenRate,int changeDatetime) {
        return crsqlServiceImpl.modifyCol(sid,tid,toNvarchar,narcharLenRate,charLenRate,changeDatetime);
    }

}
