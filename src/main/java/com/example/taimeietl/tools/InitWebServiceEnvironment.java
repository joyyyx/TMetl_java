package com.example.taimeietl.tools;

import com.example.taimeietl.tools.httpClient.requests.AnalyXML;
import com.example.taimeietl.tools.httpClient.requests.SoapRequest;

public class InitWebServiceEnvironment {
    public static void initEnvironment(){
        SoapRequest.requestSendCount=0;
        SoapRequest.requestResponseCount=0;
        AnalyXML.columnList.removeAll(AnalyXML.columnList);
    }
}
