package com.example.taimeietl.tools;

import com.example.taimeietl.kettle.RunJob;
import com.example.taimeietl.map.TableInfoMapper;
import com.example.taimeietl.model.TableInfo;
import com.example.taimeietl.services.TableInfoService;
import com.example.taimeietl.services.servicesImpl.InitDB;
import org.apache.commons.lang.StringUtils;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;
import org.pentaho.di.job.Job;
import org.quartz.CronExpression;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.scheduling.annotation.SchedulingConfigurer;
import org.springframework.scheduling.config.ScheduledTaskRegistrar;
import org.springframework.scheduling.support.CronTrigger;

import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Date;
import java.util.List;
import java.util.Map;

@Configuration      //1.主要用于标记配置类，兼备Component的效果。
@EnableScheduling   // 2.开启定时任务
public class DynamicScheduleTask implements SchedulingConfigurer {

    @Mapper
    public interface CronMapper {
        @Select(" select top 1 cron from ETL.dbo.SOURCE_INFO where SOURCE_TYPE = 0")
        public String getCron();
        @Select(" select id,cron from ETL.dbo.SOURCE_INFO where SOURCE_TYPE = 1")
        public List<Map<String,Object>> getSources();

        @Select(" select id,cron from ETL.dbo.SOURCE_INFO where SOURCE_TYPE >= 2")
        public List<Map<String,Object>> getWebServiceSources();
    }

    @Autowired      //注入mapper
    @SuppressWarnings("all")
    CronMapper cronMapper;
    @Autowired
    RunJob test;
    @Autowired
    TableInfoMapper tableInfoMapper;
    @Autowired
    TableInfoService tableInfoService;
    @Autowired
    InitDB initDB;
    /**
     * 执行定时任务.
     */
    @Override
    public void configureTasks(ScheduledTaskRegistrar taskRegistrar) {

        taskRegistrar.addTriggerTask(
                //1.添加任务内容(Runnable)
                () -> {
//                    System.out.println("dynamicschedule heart break!!!!");
                    List<Map<String, Object>> sources = cronMapper.getSources();
                    List<Map<String, Object>> webServiceSources = cronMapper.getWebServiceSources();
                    Job job = null;
                    LocalDateTime now = LocalDateTime.now();
                    String status = "";

                    //update table&view
                    for (Map<String, Object> source : sources
                    ) {
                        int sourceId = (int) source.get("id");
                        String cron = (String) source.get("cron");
                        List<TableInfo> tableInfos = tableInfoMapper.selectAllBySid(sourceId);

                        for (TableInfo tableInfo : tableInfos) {
                            int extractType = tableInfo.getExtractType();
                            int tid = tableInfo.getId();
                            try {
                                if (filterWithCronTime(cron, now)) {
                                    while (true) {
                                        if (job == null || !(job.getStatus().equals("Running") || job.getStatus().equals("Waiting"))) {
                                            System.out.printf("**********" + job);

                                            System.out.println("执行动态定时任务: " + sourceId + "--" + LocalDateTime.now().toLocalTime());
                                            job = test.runJob(sourceId, tid, "extractData");
                                            if (job != null) {
                                                status = job.getStatus();
                                                System.out.printf(job.getStatus());
                                            }
                                            break;
                                        }
                                        System.out.println("sleep.....********** 上个job状态：" + status);
                                        Thread.sleep(10000);
                                    }
                                    final Thread thread = new Thread(new Runnable() {
                                        @Override
                                        public void run() {
                                            System.out.println("start handle table ");
                                            tableInfoMapper.handleTable(sourceId, tid, 0, "aaa");
//                                            System.out.println("start update time ");
//                                            tableInfoMapper.runSQL(SqlJobTools.getUpdateTableSql(tid, tableInfo.getPl()));
                                            System.out.println("update successfully!!! ");
                                        }
                                    });
                                    while (true) {
                                        if (job == null || !(job.getStatus().equals("Running") || job.getStatus().equals("Waiting"))) {
                                            thread.start();
                                            break;
                                        }
                                        Thread.sleep(10000);
                                        System.out.println("sleep.....********** 当前job状态：" + status);
                                    }
                                } else {

                                }
                            } catch (Exception e) {
                                e.printStackTrace();
                                String sss = e.toString();
                            }

                        }

                    }

                    //update
                    for (Map<String, Object> source : webServiceSources
                    ) {
                        int sid = (int) source.get("id");
                        String cron = (String) source.get("cron");
                        List<TableInfo> tableInfos = tableInfoMapper.selectAllBySid(sid);

                        for (TableInfo tableInfo : tableInfos) {
                            int extractType = tableInfo.getExtractType();
                            int tid = tableInfo.getId();
                            try {
                                if (filterWithCronTime(cron, now))
                                {
                                    System.out.println(new Date());
                                    tableInfoService.createTableOrInsertTableBywebService(sid,tid,0);
                                    System.out.println(new Date());
                                    tableInfoService.handleTable(sid, tid, 0, "aaa");
                                    System.out.println("tableId:" + tid + " has finished successfully!!");
                                }
                            } catch (Exception e) {
                                e.printStackTrace();
                            }
                        }
                    }




                },
                //2.设置执行周期(Trigger)
                triggerContext -> {
                    String cron = "";
                    try {
                        //2.1 从数据库获取执行周期
                         cron = cronMapper.getCron();
                    }
                    catch (Exception e){
                        try {
                            initDB.init("createDB.sql");
                            initDB.init("db_etl.sql");
                        } catch (ClassNotFoundException classNotFoundException) {
                            classNotFoundException.printStackTrace();
                        } catch (SQLException throwables) {
                            throwables.printStackTrace();
                        }
                    }
                    //2.2 合法性校验.
                    if (StringUtils.isEmpty(cron)) {
                        return new CronTrigger("0/1 * * * * ? ").nextExecutionTime(triggerContext);
                    }
                    //2.3 返回执行周期(Date)
                    return new CronTrigger(cron).nextExecutionTime(triggerContext);
                }
        );
    }
    private Boolean filterWithCronTime(String cron,LocalDateTime now) throws Exception {
        if (StringUtils.isEmpty(cron)){
            return false;
        }
        SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
        CronExpression exp = new CronExpression(cron);
        Boolean inCron = exp.isSatisfiedBy(simpleDateFormat.parse(formatter.format(now))) ;
        return inCron;
    }


}