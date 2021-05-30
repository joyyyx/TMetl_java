package com.example.taimeietl.services.servicesImpl;

import com.example.taimeietl.map.SourceInfoMapper;
import com.example.taimeietl.model.SourceInfo;
import com.example.taimeietl.services.SourceInfoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
@Service
public class SourceInfoServiceImpl implements SourceInfoService {
    @Autowired
    SourceInfoMapper sourceInfoMapper;
    @Override
    public List<SourceInfo> selectAll() {
        List<SourceInfo> result = sourceInfoMapper.selectAll();
        return result;
    }

    @Override
    public int insertRecord(SourceInfo sourceInfo) {
        int re = sourceInfoMapper.insertSelective(sourceInfo);
        return re;
    }

    @Override
    public int updateRecord(SourceInfo sourceInfo) {
        int re = sourceInfoMapper.updateByPrimaryKeySelective(sourceInfo);
        return re;
    }

    @Override
    public int deleteRecord(int id) {
        int re = sourceInfoMapper.deleteByPrimaryKey(id);
        return re;
    }
}
