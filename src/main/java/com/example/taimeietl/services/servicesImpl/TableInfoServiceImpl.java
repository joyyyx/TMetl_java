package com.example.taimeietl.services.servicesImpl;

import com.example.taimeietl.map.CrsqlMapper;
import com.example.taimeietl.map.SourceInfoMapper;
import com.example.taimeietl.map.TableInfoMapper;
import com.example.taimeietl.model.Crsql;
import com.example.taimeietl.model.SourceInfo;
import com.example.taimeietl.model.TableInfo;
import com.example.taimeietl.services.TableInfoService;
import com.example.taimeietl.tools.InitWebServiceEnvironment;
import com.example.taimeietl.tools.disruptor.*;
import com.example.taimeietl.tools.InsertData;
import com.example.taimeietl.tools.httpClient.requests.AnalyXML;
import com.example.taimeietl.tools.httpClient.requests.SoapRequest;
import com.lmax.disruptor.EventFactory;
import com.lmax.disruptor.RingBuffer;
import com.lmax.disruptor.YieldingWaitStrategy;
import com.lmax.disruptor.dsl.Disruptor;
import com.lmax.disruptor.dsl.ProducerType;
import org.apache.commons.lang.StringUtils;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

@Service
public class TableInfoServiceImpl implements TableInfoService {
    @Autowired
    TableInfoMapper tableInfoMapper;
    @Autowired
    SourceInfoMapper sourceInfoMapper;
    @Autowired
    CrsqlMapper crsqlMapper;

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

    @Override
    public int createTable(int sid, int tid, int reCreate) {
        return tableInfoMapper.createTable(sid, tid, reCreate);
    }

    @Override
    public int updateInit(TableInfo record) {
        return tableInfoMapper.updateInit(record);
    }

    @Override
    public int checkTable(String tableName) {
        return tableInfoMapper.checkTable(tableName);
    }

    @Override
    public int handleTable(int sid, int tid, int method, String partitionFields) {
        return tableInfoMapper.handleTable(sid, tid, method, partitionFields);
    }

    @Override
    public List<TableInfo> selectAllBySid(int sid) {
        return tableInfoMapper.selectAllBySid(sid);
    }

    @Override
    public int runSQL(String sql) {
        tableInfoMapper.runSQL(sql);
        return 1;
    }

    @Override
    public List<Map<String, String>> selectSQL(String sql) {
        return tableInfoMapper.selectSQL(sql);
    }

    @Override
    public TableInfo selectByPrimaryKey(Integer id) {
        return tableInfoMapper.selectByPrimaryKey(id);
    }


    @Override
    public void createTableOrInsertTableBywebService(int sid,int tid,int createMark) {
        InitWebServiceEnvironment.initEnvironment();
        SoapRequest.createMark = createMark;
        TableInfo tableInfo = tableInfoMapper.selectByPrimaryKey(tid);
        SourceInfo sourceInfo = sourceInfoMapper.selectBySourceType(0);
        SourceInfo sourceInfo1 = sourceInfoMapper.selectByPrimaryKey(sid);
        String webserviceParamtable = tableInfo.getWebserviceParamtable();
        String sourceDb = sourceInfo.getSourceDb();
        List<Crsql> crsqls = crsqlMapper.selectByTableId(tid);
        List<String> columnList = new ArrayList<>();
        for (Crsql crsql:crsqls
        ) {
            columnList.add(crsql.getColumnName());
        }
        String tableName = tableInfo.getOdstableName();
        String xmlNodes = tableInfo.getXmlNodes();
        String url = tableInfo.getTableName();
        String originTableName = sourceDb+".dbo.ORIGIN_"+tableName;
        String distintTableName = sourceDb+".dbo.DISTINCT_"+tableName;
        Integer extractType = tableInfo.getExtractType();
        if(extractType==1)
            tableName = distintTableName;
        else if (extractType==2 | extractType == 3)
            tableName= originTableName;
        else if(createMark==0){
            tableName = sourceDb+".dbo."+tableName;
            tableInfoMapper.runSQL("truncate table "+tableName);
        }

        String webserviceParam = tableInfo.getWebserviceParam();
        String requestParam = tableInfo.getRequestParam();
        String webserviceCondition = tableInfo.getWebserviceCondition()==null?"":tableInfo.getWebserviceCondition();
        webserviceCondition = webserviceCondition.replaceAll("\\$\\{START_TIME}", "'"+tableInfo.getStartTime()+"'");
        webserviceCondition = webserviceCondition.replaceAll("\\$\\{END_TIME}", "'"+tableInfo.getEndTime()+"'");
        JSONObject jsonObject = new JSONObject(webserviceParam);
        Map<String, Object> stringObjectMap = jsonObject.toMap();
        String sql = " SELECT   ";
        if(createMark==1)
            sql = sql+"top 500 ";
        else if(createMark==0)
        {
            tableInfoMapper.runSQL("truncate table "+originTableName);
            tableInfoMapper.runSQL("truncate table "+distintTableName);
        }
        for (String key : stringObjectMap.keySet()
        ) {
            if(!key.equals("insertColumn")&& !StringUtils.isEmpty(stringObjectMap.get(key).toString().trim()))
                sql = sql + stringObjectMap.get(key) + ",";
        }
        sql = sql.trim().substring(0, sql.trim().length() - 1);
        if(!StringUtils.isEmpty(webserviceParamtable.trim()))
             sql = sql + " FROM " +  webserviceParamtable+" "+webserviceCondition;
        System.out.println(sql);
        List<Map<String, String>> maps = tableInfoMapper.selectSQL(sql);

        //if pfd create pdf table
        if(sourceInfo1.getDbType().equals("PDF")&&createMark==1){
            Crsql crsql = new Crsql();
            crsql.setTableId(tid);
            crsql.setMark(1);
            crsql.setColumnName("pdf_url");
            crsql.setTableName(tableInfo.getTableName());
            crsql.setColumnType("NVARCHAR(MAX)");
            crsqlMapper.insertSelective(crsql);
            crsql.setColumnName("body_text");
            crsqlMapper.insertSelective(crsql);
            return;
        }

        int ringBufferSize =  1024 * 1024;
        EventFactory<Param> paramFactory = new ParamFactory();
        EventFactory<Order> orderFactory = new OrderFactory();
        Disruptor<Order> orderdisruptor =
                new Disruptor<Order>(orderFactory, ringBufferSize, Executors.defaultThreadFactory(), ProducerType.MULTI, new YieldingWaitStrategy());
        InsertData insertData1 = new InsertData(tableInfoMapper,tableName,columnList);
        InsertData insertData2 = new InsertData(tableInfoMapper,tableName,columnList);
        InsertData insertData3 = new InsertData(tableInfoMapper,tableName,columnList);
        orderdisruptor.handleEventsWithWorkerPool(
                new OrderHandler1("1",insertData1),
                new OrderHandler1("2",insertData2),
                new OrderHandler1("3",insertData3)
        );
        orderdisruptor.start();
        RingBuffer<Order> orderRingBuffer = orderdisruptor.getRingBuffer();
        Disruptor<Param> disruptor =
                new Disruptor<Param>(paramFactory, ringBufferSize, Executors.defaultThreadFactory(), ProducerType.MULTI, new YieldingWaitStrategy());
        disruptor.handleEventsWithWorkerPool(
                new ParamHandler("1",orderRingBuffer,requestParam,stringObjectMap,columnList,url,xmlNodes,sourceInfo1),
                new ParamHandler("2",orderRingBuffer,requestParam,stringObjectMap,columnList,url,xmlNodes,sourceInfo1),
                new ParamHandler("3",orderRingBuffer,requestParam,stringObjectMap,columnList,url,xmlNodes,sourceInfo1),
                new ParamHandler("4",orderRingBuffer,requestParam,stringObjectMap,columnList,url,xmlNodes,sourceInfo1),
                new ParamHandler("5",orderRingBuffer,requestParam,stringObjectMap,columnList,url,xmlNodes,sourceInfo1)
        );
        disruptor.start();

        RingBuffer<Param> ringBuffer = disruptor.getRingBuffer();
        ParamProducer paramProducer = new ParamProducer(ringBuffer);
        for (Map<String, String> map : maps
        ) {
            paramProducer.onData(map);
        }
        try {
            Thread.sleep(10000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        do {
            try {
                Thread.sleep(1000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            System.out.println("send:"+SoapRequest.requestSendCount+"||recive:"+SoapRequest.requestResponseCount);
            if(AnalyXML.columns.size()>=3&&createMark==1){
                crsqlMapper.deleteByTableId(tid);
                //insert param columns
                for (String key : stringObjectMap.keySet()
                ) {
                    if(AnalyXML.columns.toString().toLowerCase().contains(stringObjectMap.get(key).toString().toLowerCase())
                            ||key.equals("insertColumn")||!stringObjectMap.get("insertColumn").toString().contains(stringObjectMap.get(key).toString()))
                        continue;
                    String[] inrcolarr = stringObjectMap.get(key).toString().split(",");
                    for (String col:inrcolarr
                         ) {
                        Crsql crsql = new Crsql();
                        crsql.setTableId(tid);
                        crsql.setMark(1);
                        crsql.setColumnName(col);
                        crsql.setTableName(tableInfo.getTableName());
                        crsql.setColumnType("NVARCHAR(MAX)");
                        crsqlMapper.insertSelective(crsql);
                    }
                }

                //insert response columns
                for (String column:AnalyXML.columns
                ) {
                    Crsql crsql = new Crsql();
                    crsql.setTableId(tid);
                    crsql.setMark(1);
                    crsql.setColumnName(column);
                    crsql.setTableName(tableInfo.getTableName());
                    crsql.setColumnType("NVARCHAR(MAX)");
                    System.out.println(crsql.toString());
                    crsqlMapper.insertSelective(crsql);
                }
                AnalyXML.columns.removeAll(AnalyXML.columns);
//                try {
//                    Thread.sleep(100000);
//                } catch (InterruptedException e) {
//                    e.printStackTrace();
//                }
                disruptor.shutdown();
                orderdisruptor.shutdown();
                return;
            }
        }
        while(SoapRequest.requestResponseCount<maps.size()-100);

        try {
            Thread.sleep(10000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        disruptor.shutdown();
        orderdisruptor.shutdown();
        insertData1.runInsert();
        insertData2.runInsert();
        insertData3.runInsert();
        return;
    }


}
