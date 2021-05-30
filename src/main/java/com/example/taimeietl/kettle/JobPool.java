package com.example.taimeietl.kettle;


import org.pentaho.di.core.KettleEnvironment;
import org.pentaho.di.job.Job;
import org.pentaho.di.job.JobMeta;
import org.pentaho.di.repository.Repository;

import java.util.Map;

public class JobPool extends Job {
    private static String jobPath;   //job的路径
    private static JobMeta jobMeta;
    private static Repository repository;
    private static JobPool jobDown;
    //构造方法
    private JobPool(Repository repository, JobMeta jobMeta) {
        super(repository, jobMeta);
    }

    /**
     * 获取对象实例入口
     * @param
     */
    public static JobPool getJob(String Path) {
        //jobPath = "G:\\同步前置机数据 --下发\\上传前置机数据到MYSQL.kjb";
        jobPath = Path;
        try {
            KettleEnvironment.init();
            jobMeta = new JobMeta(jobPath, null);
            jobDown = new JobPool(repository, jobMeta);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return jobDown;
    }

//    public String start(DealKettleError dealKettleError) {
//        try {
//            // 向Job 脚本传递参数，脚本中获取参数值：${参数名}
//            // job.setVariable(paraname, paravalue);
//            super.start();
//            // this.waitUntilFinished();
//            if (this.getErrors() > 0) {
//                Map<String, String> map  = dealKettleError.dealWhileKettleError();
//                if(map.get("state")=="success")
//                    return map.get("step")+"  执行失败";
//                else
//                    return "执行失败，且无法连接到mysql更新错误信息";
//            }
//
//        } catch (Exception e) {
//            e.printStackTrace();
//        }
//        return "执行成功";
//    }
}
