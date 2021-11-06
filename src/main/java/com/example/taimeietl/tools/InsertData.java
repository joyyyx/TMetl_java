package com.example.taimeietl.tools;

import com.example.taimeietl.map.TableInfoMapper;

import java.util.LinkedList;
import java.util.List;
import java.util.Map;


public class InsertData {
    TableInfoMapper tableInfoMapper;
    private List<String> listBuffer = new LinkedList<>();
    private StringBuffer insertSql;

    public List<String> getListBuffer() {
        return listBuffer;
    }

    private String tableName;
    private List<String> columnList;

    public InsertData(TableInfoMapper tableInfoMapper, String tableName, List<String> columnList) {
        this.tableInfoMapper = tableInfoMapper;
        this.tableName = tableName;
        this.columnList = columnList;
    }

    public void runInsert() {
        if (listBuffer.size() != 0) {

            StringBuilder sql = new StringBuilder();
            for (String s:listBuffer
            ) {
                sql.append(s);
            }
//            WriteLog.write("d:/JavaLog/javalog3.txt",sql.toString());
            tableInfoMapper.runSQL(sql.toString());
            listBuffer.removeAll(listBuffer);
        }
    }

    public void runInsert(Map<String, String> map) {
        insertSql = new StringBuffer();
        insertSql.append("insert into " + tableName);
        for (String key : map.keySet()
        ) {
            insertSql.append(key + " values ");
            insertSql.append(map.get(key));
        }
        if (listBuffer.size() >= 100) {
            StringBuilder sql = new StringBuilder();
            for (String s:listBuffer
                 ) {
                sql.append(s);
            }
//            WriteLog.write("d:/JavaLog/javalog4.txt",sql.toString());
            tableInfoMapper.runSQL(sql.toString());
            listBuffer.removeAll(listBuffer);
            listBuffer.add(insertSql.toString());
        } else {
            listBuffer.add(insertSql.toString());
        }


    }

}
