package com.example.taimeietl.tools;

import com.example.taimeietl.kettle.Test;
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

import java.text.SimpleDateFormat;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
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
    }

    @Autowired      //注入mapper
    @SuppressWarnings("all")
    CronMapper cronMapper;
    @Autowired
    Test test;

    /**
     * 执行定时任务.
     */
    @Override
    public void configureTasks(ScheduledTaskRegistrar taskRegistrar) {

        taskRegistrar.addTriggerTask(
                //1.添加任务内容(Runnable)
                () -> {
                    List<Map<String,Object>> sources = cronMapper.getSources();
                    Job job = null;
                    LocalDateTime now = LocalDateTime.now();
                    String status = "";
                    for (Map<String,Object> source:sources
                         ) {
                        int sourceId = (int)source.get("id");
                        String cron = (String)source.get("cron");
                        try {
                            if (filterWithCronTime(cron,now)) {
                                while (true){
                                    if(job == null || !(job.getStatus().equals("Running") || job.getStatus().equals("Waiting")))
                                    {
                                        System.out.printf("**********"+job);

                                        System.out.println("执行动态定时任务: "  +sourceId+"--"+  LocalDateTime.now().toLocalTime());
                                        job = test.runJob(sourceId);
                                        if(job != null){
                                            status=job.getStatus();
                                            System.out.printf(job.getStatus());
                                        }
                                        break;
                                    }
                                    System.out.printf("sleep.....********** 上个job状态："+status);
                                    Thread.sleep(10000);
                                }
                            }
                            else {

                            }
                        }
                        catch (Exception e){
                            e.printStackTrace();
                            String sss = e.toString();
                        }
                    }

                },
                //2.设置执行周期(Trigger)
                triggerContext -> {
                    //2.1 从数据库获取执行周期
                    String cron = cronMapper.getCron();
                    //2.2 合法性校验.
                    if (StringUtils.isEmpty(cron)) {
                        return new CronTrigger("0/3 * * * * ? ").nextExecutionTime(triggerContext);
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