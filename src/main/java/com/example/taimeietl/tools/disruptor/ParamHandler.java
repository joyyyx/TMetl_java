package com.example.taimeietl.tools.disruptor;

import com.example.taimeietl.model.SourceInfo;
import com.example.taimeietl.tools.httpClient.requests.SoapRequest;
import com.lmax.disruptor.EventHandler;
import com.lmax.disruptor.RingBuffer;
import com.lmax.disruptor.WorkHandler;

import java.util.*;

public class ParamHandler implements EventHandler<Param>, WorkHandler<Param> {
    private String consumerId;
    private RingBuffer ringBuffer;
    private String requestParam;
    private Map<String, Object> paramMap;
    private List<String> columnList;
    private String url;
    private String xmlNodes;
    private SourceInfo sourceInfo;

    public ParamHandler(String consumerId, RingBuffer ringBuffer, String requestParam, Map<String, Object> paramMap, List<String> columnList, String url, String xmlNodes, SourceInfo sourceInfo) {
        this.consumerId = consumerId;
        this.ringBuffer = ringBuffer;
        this.requestParam = requestParam;
        this.paramMap = paramMap;
        this.columnList=columnList;
        this.url = url;
        this.xmlNodes = xmlNodes;
        this.sourceInfo = sourceInfo;
    }

    @Override
    public void onEvent(Param param, long l, boolean b) throws Exception {
    }

    @Override
    public void onEvent(Param param) throws Exception {

        String ssparam = "";
        Map<String, String> map = param.getParam();
        List<String> values = new ArrayList<>();
        List<String> headers = new ArrayList<>();
        int count = 0;
        String insertColumns = paramMap.get("insertColumn").toString();
        for (String columnName : map.keySet()
        ) {
            //set param list
            for (String paramName : paramMap.keySet()
            ) {
                String pColumnName = paramMap.get(paramName).toString();
                if (!paramName.equals("insertColumn") && !paramName.equals("INSERTMARK"))
                    if (pColumnName.contains(columnName))
                        if(sourceInfo.getDbType().equals("GET"))
                            ssparam=ssparam+paramName+"="+ map.get(columnName);
                        else
                            ssparam = ssparam+"<" + paramName + ">" + map.get(columnName) + "</" + paramName + ">";
            }

            //set insert list
            if (insertColumns.toLowerCase().contains(columnName.toLowerCase())) {
                values.add("'"+map.get(columnName)+"'");
                headers.add(columnName);
            }
        }
//        System.out.println(ssparam);
        SoapRequest soapRequest = new SoapRequest();
        int blockCount = sourceInfo.getDbType().equals("PDF")?10:100;
        while (SoapRequest.requestSendCount - SoapRequest.requestResponseCount >= blockCount) {
            Thread.sleep(1000);
        }
        String valueString = values.toString().replaceAll("\\[", "").replaceAll("]", "");
        String hearderString = headers.toString().replaceAll("\\[", "").replaceAll("]", "");
        String geturl = url;
        if(sourceInfo.getDbType().equals("GET"))
            geturl = url.replaceAll("\\$\\{PARAM}", ssparam);
        else if (requestParam != null)
            ssparam = requestParam.replaceAll("\\$\\{PARAM}", ssparam);
        Map<String,String> paramap= new HashMap<>();
        paramap.put(hearderString,valueString);
        if(sourceInfo.getDbType().equals("PDF"))
            soapRequest.getPdf(ringBuffer,sourceInfo,param.getParam().get("pdf_url"));
        else if (sourceInfo.getDbType().equals("XML")){
            soapRequest.getXml(ringBuffer,param.getParam().get("XML").toString(),paramap,columnList,xmlNodes,"XML");
        }
        else if (sourceInfo.getDbType().equals("XML-ALLTEXT")){
            soapRequest.getXml(ringBuffer,param.getParam().get("XML").toString(),paramap,columnList,xmlNodes,"XML-ALLTEXT");
        }
        else {
//            System.out.println("ffff"+paramap);
            soapRequest.sendRequest(ringBuffer, ssparam, paramap, columnList, geturl, xmlNodes, sourceInfo, param);
        }
//        System.out.println("OrderHandler1 " + this.consumerId + "，消费信息：" + ssparam);
    }
}
