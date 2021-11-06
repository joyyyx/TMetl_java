package com.example.taimeietl.services;

import com.example.taimeietl.model.Crsql;

import java.util.List;

public interface CrsqlService {
    List<Crsql> selectAll();
    int insertRecord(Crsql record);
    int updateRecord(Crsql record);
    int deleteRecord(int id);
    int modifyCol(int sid, int tid, int toNvarchar, int narcharLenRate, int charLenRate,int changeDatetime);
    int deleteByTableId(Integer tid);
    List<Crsql> selectByTableId(int tid);
}
