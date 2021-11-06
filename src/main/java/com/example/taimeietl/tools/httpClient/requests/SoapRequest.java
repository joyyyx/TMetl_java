package com.example.taimeietl.tools.httpClient.requests;

import com.example.taimeietl.model.SourceInfo;
import com.example.taimeietl.tools.PDFUtil;
import com.example.taimeietl.tools.WriteLog;
import com.example.taimeietl.tools.XmlFormat;
import com.example.taimeietl.tools.disruptor.Param;
import com.example.taimeietl.tools.disruptor.Producer;
import com.example.taimeietl.tools.httpClient.converter.StringConverterFactory;
import com.lmax.disruptor.RingBuffer;
import net.javacrumbs.json2xml.JsonXmlReader;
import okhttp3.OkHttpClient;
import okhttp3.ResponseBody;
import org.dom4j.Document;
import org.dom4j.DocumentException;
import org.dom4j.DocumentHelper;
import org.dom4j.Element;
import org.junit.Test;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;
import retrofit2.Retrofit;

import java.io.IOException;
import java.io.InputStream;
import java.util.*;
import java.util.concurrent.TimeUnit;


public class SoapRequest {
    public static Integer requestSendCount = 0;
    public static Integer requestResponseCount = 0;
    public static int createMark = 0;
    private static final OkHttpClient client = new OkHttpClient.Builder().
            connectTimeout(60, TimeUnit.SECONDS).
            readTimeout(60, TimeUnit.SECONDS).
            writeTimeout(60, TimeUnit.SECONDS).build();

    @Test
    public static void sendRequest(RingBuffer ringBuffer, String param, Map<String,String> paramString, List<String> tablecolumnList
            , String url, String xmlNodes, SourceInfo sourceInfo, Param param1) {


//        System.out.println(param);
        String baseUrl = sourceInfo.getSourceIp();
        Retrofit restAdapter = new Retrofit.Builder().baseUrl(baseUrl)
                .addConverterFactory(
                        StringConverterFactory.create()
                ).client(client)
                .build();
        WebServices request = restAdapter.create(WebServices.class);
        Call<String> call = null;
        if (sourceInfo.getDbType().equals("GET"))
            call = request.getGetRepose(url);
        if (sourceInfo.getDbType().equals("SOAP"))
            call = request.getSoapRepose(url,param);
//        System.out.println(param1.getParam());
//        System.out.println(baseUrl+url);
        synchronized (SoapRequest.requestResponseCount) {
            SoapRequest.requestSendCount++;
        }
        if (createMark != 1) {
            call.enqueue(new Callback<String>() {
                             //请求成功时回调
                             @Override
                             public void onResponse(Call<String> call, Response<String> response) {
                                 //请求处理,输出结果
                                 Document document = null;
                                 try {
//                                     System.out.println(response.body().toString());
                                     String body =response.body().replaceAll("&","");
//                                      WriteLog.write("d:/JavaLog/javalog.txt",param+body);
                                     if (XmlFormat.isJson(body))
                                     {
                                         body = XmlFormat.convertToXml(body,new JsonXmlReader("", false, "root"));
                                     }
                                     document = DocumentHelper.parseText(body);
                                     Element rootElement = document.getRootElement();
                                     XmlFormat.formatXml(rootElement);
                                     String asXML = rootElement.asXML();
//                                     WriteLog.write("d:/JavaLog/javalog1.txt",asXML);
                                     AnalyXML analyXML = new AnalyXML();
                                     analyXML.loopElement(rootElement, paramString, 1,tablecolumnList,xmlNodes);
                                     List<Map<String,String>> recordList = analyXML.getRecordList();
                                     Producer producer = new Producer(ringBuffer);
                                     for (Map<String,String> map : recordList
                                     ) {
//                                     System.out.println(111111);
//                                         WriteLog.write("d:/JavaLog/javalog2.txt",map.toString());
                                         producer.onData(map);
                                     }
                                     synchronized (SoapRequest.requestResponseCount) {
                                         SoapRequest.requestResponseCount++;
                                     }
                                 } catch (Exception e) {
                                     System.out.println(response.body());
                                     synchronized (SoapRequest.requestResponseCount) {
                                         SoapRequest.requestResponseCount++;
                                     }
                                     e.printStackTrace();
                                 }

                             }

                             //请求失败时候的回调
                             @Override
                             public void onFailure(Call<String> call, Throwable throwable) {
                                 synchronized (SoapRequest.requestResponseCount) {
                                     SoapRequest.requestResponseCount++;
                                 }
                                 System.out.println(throwable.toString());
                                 System.out.println("连接失败");
                             }
                         }
            );
        } else {
            synchronized (AnalyXML.columns) {
                if (AnalyXML.columns.size() == 0) {
                    try {
                        Response<String> response = call.execute();
                        String body = response.body();
                        System.out.println(param);
                        if (XmlFormat.isJson(body))
                        {
                            body = XmlFormat.convertToXml(body,new JsonXmlReader("", false, "root"));
                        }
                        Document document = DocumentHelper.parseText(body);
                        Element rootElement = document.getRootElement();
                        XmlFormat.formatXml(rootElement);
//                        System.out.println(rootElement.asXML());
                        AnalyXML.setColumnList(rootElement,xmlNodes);
                        List<String> columnList = AnalyXML.getColumnList();
                        if (columnList.size() >= 3)
                            AnalyXML.columns.addAll(columnList);
                        synchronized (SoapRequest.requestResponseCount) {
                            SoapRequest.requestResponseCount++;
                        }
                    } catch (Exception e) {
                        synchronized (SoapRequest.requestResponseCount) {
                            SoapRequest.requestResponseCount++;
                        }
                        e.printStackTrace();
                    }
                }
                else{
                    synchronized (SoapRequest.requestResponseCount) {
                        SoapRequest.requestResponseCount++;
                    }
                }
            }
        }

//        try {
//            Thread.sleep(10000);
//        } catch (InterruptedException e) {
//            e.printStackTrace();
//        }

//        Element rootElement = null;

    }


    public void getPdf(RingBuffer ringBuffer, SourceInfo sourceInfo, String pdf_url) throws Exception {
        try {
            synchronized (SoapRequest.requestResponseCount) {
                SoapRequest.requestSendCount++;
            }
            Retrofit restAdapter = new Retrofit.Builder().baseUrl(sourceInfo.getSourceIp())
                    .addConverterFactory(
                            StringConverterFactory.create()
                    ).client(client)
                    .build();
            WebServices request = restAdapter.create(WebServices.class);
            Call<ResponseBody> call = request.downloadFile(pdf_url.replaceAll(sourceInfo.getSourceIp() + "/", ""));
            Response<ResponseBody> response = null;
//        System.out.println(response.code());
            Producer producer = new Producer(ringBuffer);
            int count = 0;
            while (count<=10) {
                call = request.downloadFile(pdf_url.replaceAll(sourceInfo.getSourceIp() + "/", ""));
                response = call.execute();
                if(response.code() != 200)
                {
                    count++;
                    continue;
                }
                InputStream inputStream = response.body().byteStream();
                String s = PDFUtil.readPDF(inputStream);
//            System.out.println(pdf_url)
                Map<String, String> map = new HashMap<>();
                map.put("(pdf_url,body_text,response_status)", "('" + pdf_url + "'" + "," + "'" + s.replaceAll("'", "''") + "',200)");
                producer.onData(map);
                break;
            }
            if(response.code() != 200)
            {
                Map<String, String> map = new HashMap<>();
                map.put("(pdf_url,response_status)","('" + pdf_url +"',"+response.code()+")");
                producer.onData(map);
            }
            synchronized (SoapRequest.requestResponseCount) {
                SoapRequest.requestResponseCount++;
            }
        }
        catch (Exception e){  synchronized (SoapRequest.requestResponseCount) {
            SoapRequest.requestResponseCount++;
        }e.printStackTrace();}
        finally {

        }
    }


    public void getXml(RingBuffer ringBuffer, String xml, Map<String,String> paramString, List<String> tablecolumnList
            , String xmlNodes,String xmlType) {
        synchronized (SoapRequest.requestResponseCount) {
            SoapRequest.requestSendCount++;
        }
        if (createMark != 1) {
            try {
                if (XmlFormat.isJson(xml)) {
                    xml = XmlFormat.convertToXml(xml, new JsonXmlReader("", false, "root"));
                }
                 xml =xml.replaceAll("&","");
                Document document = DocumentHelper.parseText(xml);
                Element rootElement = document.getRootElement();
                XmlFormat.formatXml(rootElement);
                String asXML = rootElement.asXML();
                AnalyXML analyXML = new AnalyXML();
                if(xmlType.equals("XML"))
                analyXML.loopElement(rootElement, paramString, 1, tablecolumnList, xmlNodes);
                if(xmlType.equals("XML-ALLTEXT"))
                    analyXML.getAllXmlText(rootElement, paramString, 1, tablecolumnList, xmlNodes);
                List<Map<String, String>> recordList = analyXML.getRecordList();
                Producer producer = new Producer(ringBuffer);
                for (Map<String, String> map : recordList
                ) {
                    producer.onData(map);
                }
                synchronized (SoapRequest.requestResponseCount) {
                    SoapRequest.requestResponseCount++;
                }
            } catch (Exception e) {
                synchronized (SoapRequest.requestResponseCount) {
                    SoapRequest.requestResponseCount++;
                }
                e.printStackTrace();
            }
        } else {
            synchronized (AnalyXML.columns) {
                if (AnalyXML.columns.size() == 0){
                    try {
                        if (XmlFormat.isJson(xml)) {
                            xml = XmlFormat.convertToXml(xml, new JsonXmlReader("", false, "root"));
                        }
                        Document document = DocumentHelper.parseText(xml);
                        Element rootElement = document.getRootElement();
                        XmlFormat.formatXml(rootElement);
                        AnalyXML.setColumnList(rootElement, xmlNodes);
                        List<String> columnList = AnalyXML.getColumnList();
                        if (columnList.size() >= 3)
                            AnalyXML.columns.addAll(columnList);
                    } catch (Exception e) {
                        synchronized (SoapRequest.requestResponseCount) {
                            SoapRequest.requestResponseCount++;
                        }
                        e.printStackTrace();
                    }

                }
            }
            synchronized (SoapRequest.requestResponseCount) {
                SoapRequest.requestResponseCount++;
            }
        }
    }

}
