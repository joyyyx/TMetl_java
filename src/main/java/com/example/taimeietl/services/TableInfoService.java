package com.example.taimeietl.services;

import com.example.taimeietl.model.TableInfo;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Service
public interface TableInfoService {
   public List<TableInfo> selectAll();
   public int insertRecord(TableInfo sourceInfo);
   public int updateRecord(TableInfo sourceInfo);
   public int deleteRecord(int id);
   int createTable(int sid,int tid, int reCreate);
   int updateInit(TableInfo record);
   int checkTable(String tableName);
   int handleTable(int sid,int tid ,int method,String partition_fields);
   List<TableInfo> selectAllBySid(int sid);
   int runSQL(String sql);
   List<Map<String,String>> selectSQL(String sql);
   TableInfo selectByPrimaryKey(Integer id);

   void createTableOrInsertTableBywebService( int sid,int tid,int createMark);
}
