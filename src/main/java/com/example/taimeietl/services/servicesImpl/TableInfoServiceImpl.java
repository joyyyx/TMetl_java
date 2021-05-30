package com.example.taimeietl.services.servicesImpl;

import com.example.taimeietl.map.SourceInfoMapper;
import com.example.taimeietl.map.TableInfoMapper;
import com.example.taimeietl.model.SourceInfo;
import com.example.taimeietl.model.TableInfo;
import com.example.taimeietl.services.SourceInfoService;
import com.example.taimeietl.services.TableInfoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class TableInfoServiceImpl implements TableInfoService {
    @Autowired
    TableInfoMapper tableInfoMapper;


    @Override
    public List<TableInfo> selectAll() {
        return tableInfoMapper.selectAll();
    }

    @Override
    public int insertRecord(TableInfo tableInfo) {
        return tableInfoMapper.insertSelective(tableInfo);
    }

    @Override
    public int updateRecord(TableInfo tableInfo) {
        return tableInfoMapper.updateByPrimaryKeySelective(tableInfo);
    }

    @Override
    public int deleteRecord(int id) {
        return tableInfoMapper.deleteByPrimaryKey(id);
    }
}
