package com.example.taimeietl.services.servicesImpl;

import com.example.taimeietl.map.CrsqlMapper;
import com.example.taimeietl.model.Crsql;
import com.example.taimeietl.services.CrsqlService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class CrsqlServiceImpl implements CrsqlService {
    @Autowired
    CrsqlMapper crsqlMapper;
    @Override
    public List<Crsql> selectAll() {
        return crsqlMapper.selectAll();

    }

    @Override
    public int insertRecord(Crsql record) {
        return crsqlMapper.insertSelective(record);
    }

    @Override
    public int updateRecord(Crsql record) {
        return crsqlMapper.updateByPrimaryKeySelective(record);
    }

    @Override
    public int deleteRecord(int id) {
        return crsqlMapper.deleteByPrimaryKey(id);
    }

    @Override
    public int modifyCol(int sid, int tid, int toNvarchar, int narcharLenRate, int charLenRate, int changeDatetime) {
        return crsqlMapper.modifyCol(sid,tid,toNvarchar,narcharLenRate,charLenRate,changeDatetime);
    }

    @Override
    public int deleteByTableId(Integer tid) {
        return crsqlMapper.deleteByTableId(tid);
    }

    @Override
    public List<Crsql> selectByTableId(int tid) {
        return crsqlMapper.selectByTableId(tid);
    }
}
