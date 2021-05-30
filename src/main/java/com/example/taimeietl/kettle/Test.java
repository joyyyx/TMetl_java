package com.example.taimeietl.kettle;

import org.pentaho.di.job.Job;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

@Component
public class Test {
    @Value("${kettlefileurl}")
    public String kettlefileurl;
    @Value("${spring.datasource.username}")
    public String localusr;
    @Value("${spring.datasource.password}")
    public String localpwd;
    @Value("${spring.datasource.port}")
    public String localport;
    @Value("${spring.datasource.ip}")
    public String localip;




    public Job runJob(int sid)
    {
//        DataLinkFactoryImpl dataLinkFactory = null;
//        try {
//            dataLinkFactory = new GetDataLinkImpl(DataBaseType.MYSQL).getDataLinkFactory();
//        } catch (FileNotFoundException e) {
//            e.printStackTrace();
//        }
        JobPool job = JobPool.getJob(kettlefileurl);
        job.setVariable("sid", String.valueOf(sid));
        job.setVariable("LOCALUSR", localusr);
        job.setVariable("LOCALPWD", localpwd);
        job.setVariable("LOCALPORT", localport);
        job.setVariable("LOCALIP", localip);
//        job.setVariable("TABLE_NAME", table_name);
//        job.setVariable("CHECK_SQL", SqlFactory.getAllCheckSql()[0]);
//        job.setVariable("CHECK_DBA", SqlFactory.getAllCheckSql()[1]);
        job.start();
        return job;
    }
}
