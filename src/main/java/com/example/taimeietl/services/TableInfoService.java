package com.example.taimeietl.services;

import com.example.taimeietl.model.TableInfo;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public interface TableInfoService {
   public List<TableInfo> selectAll();
   public int insertRecord(TableInfo sourceInfo);
   public int updateRecord(TableInfo sourceInfo);
   public int deleteRecord(int id);
}
