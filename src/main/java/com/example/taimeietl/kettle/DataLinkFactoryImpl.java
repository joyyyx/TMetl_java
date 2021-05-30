package com.example.taimeietl.kettle;

public class DataLinkFactoryImpl implements DataLinkFactory{
    private  String SERVERNAME;
    private  String DATABASE;
    private  String PORT;
    private  String USERNAME;
    private  String PASSWORD;
    public String getSERVERNAME() {
        return SERVERNAME;
    }
    public void setSERVERNAME(String sERVERNAME) {
        SERVERNAME = sERVERNAME;
    }
    public String getDATABASE() {
        return DATABASE;
    }
    public void setDATABASE(String dATABASE) {
        DATABASE = dATABASE;
    }
    public String getPORT() {
        return PORT;
    }
    public void setPORT(String pORT) {
        PORT = pORT;
    }
    public String getUSERNAME() {
        return USERNAME;
    }
    public void setUSERNAME(String uSERNAME) {
        USERNAME = uSERNAME;
    }
    public String getPASSWORD() {
        return PASSWORD;
    }
    public void setPASSWORD(String pASSWORD) {
        PASSWORD = pASSWORD;
    }

}