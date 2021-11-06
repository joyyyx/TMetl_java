package com.example.taimeietl.controller;

import com.example.taimeietl.model.Crsql;
import com.example.taimeietl.model.DrView;
import com.example.taimeietl.services.DrViewService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
public class DrViewController {
    @Autowired
    private DrViewService drViewServiceimpl;

    @RequestMapping("/tmetl/drView/selectAll")
    public List<DrView> selectAll() {
        return drViewServiceimpl.selectAll();
    }

    @RequestMapping("/tmetl/drView/insertRecord")
    public int insertRecord(DrView drView) {
        return drViewServiceimpl.insertSelective(drView);
    }

    @RequestMapping("/tmetl/drView/updateRecord")
    public int updateRecord(DrView drView) {
        return drViewServiceimpl.updateByPrimaryKeySelective(drView);
    }

    @RequestMapping("/tmetl/drView/deleteRecord")
    public int deleteRecord(int id) {
        return drViewServiceimpl.deleteByPrimaryKey(id);
    }


}
