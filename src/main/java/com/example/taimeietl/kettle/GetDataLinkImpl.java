package com.example.taimeietl.kettle;


import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

public class GetDataLinkImpl implements DataLinkFactory {
    private DataLinkFactoryImpl dataLinkFactory;
    /**
     * 构造方法，初始化数据库连接信息
     * ***/
    public GetDataLinkImpl(DataBaseType dataBaseType) throws FileNotFoundException {
        this.dataLinkFactory = new DataLinkFactoryImpl();


        switch (dataBaseType) {
            case MYSQL:
                getMysqlData("jdbc_url", "jdbc_username", "jdbc_password");
                break;
            case MYSQL_CESHI:
                getMysqlData("mysql_ceshi_url", "mysql_ceshi_username", "mysql_ceshi_password");
                break;
            case MYSQL_ALI:
                getMysqlData("mysql_ali_url", "mysql_ali_username", "mysql_ali_password");
                break;

            default:
                break;
        }
    }
    private void getMysqlData(String url,String username,String password) {
        Properties properties = getProperties();
        String jdbcUrl = properties.getProperty(url);
        String[] split = jdbcUrl.split("/");
        dataLinkFactory.setSERVERNAME(split[2].split(":")[0]);
        dataLinkFactory.setPORT(split[2].split(":")[1]);
        dataLinkFactory.setDATABASE(split[3].split("\\?")[0]);
        dataLinkFactory.setUSERNAME(properties.getProperty(username));
        dataLinkFactory.setPASSWORD(properties.getProperty(password));
    }

    /**
     * 获取配置文件中数据库的连接信息**/
    private Properties getProperties(){
        //in = DataLinkFactoryImpl.class.getClassLoader().getResourceAsStream("/conf/jdbc.properties");
        Properties  props = new Properties();
        InputStream in = null;
        in = getClass().getClassLoader().getResourceAsStream("conf/jdbc.properties");
        try {
            props.load(in);
        } catch (IOException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        return props == null?null:props;
    }


    public DataLinkFactoryImpl getDataLinkFactory() {
        return dataLinkFactory;
    }


    public void setDataLinkFactory(DataLinkFactoryImpl dataLinkFactory) {
        this.dataLinkFactory = dataLinkFactory;
    }
}
