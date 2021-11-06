package com.example.taimeietl.tools;

import com.alibaba.fastjson.JSONObject;
import net.javacrumbs.json2xml.JsonSaxAdapter;
import net.javacrumbs.json2xml.JsonXmlReader;
import org.apache.commons.lang.StringUtils;
import org.dom4j.Document;
import org.dom4j.DocumentHelper;
import org.dom4j.Element;
import org.junit.Test;
import org.xml.sax.ContentHandler;
import org.xml.sax.InputSource;


import javax.xml.transform.Result;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMResult;
import javax.xml.transform.sax.SAXSource;
import javax.xml.transform.stream.StreamResult;
import java.io.BufferedReader;
import java.io.ByteArrayOutputStream;
import java.io.FileReader;
import java.io.StringReader;
import java.util.Iterator;

public class XmlFormat {
    @Test
    public void test() throws Exception {
        String xml =  convertToXml("[{\"a\":1, \"e\":true}, {\"b\":2},{\"c\":3}, {\"d\":4}]", new JsonXmlReader("", false, "root123"));
        System.out.println(xml);
//    BufferedReader bufferedReader = new BufferedReader(new FileReader("D:\\上海胸科医院\\response.xml"));
//    String line = "";
//    StringBuilder xmlContent = new StringBuilder();
//    while ((line =  bufferedReader.readLine())!=null){
//        xmlContent.append(line);
//    }
//    Document document = DocumentHelper.parseText(xmlContent.toString());
//    Element element = (Element) document.getRootElement();
//    formatXml(element);
    }

    public static String convertToXml(final String json) throws Exception {
        return convertToXml(json, new JsonXmlReader());
    }

    public static String convertToXml(final String json, final JsonXmlReader reader) throws Exception {
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        Transformer transformer = TransformerFactory.newInstance().newTransformer();
        InputSource source = new InputSource(new StringReader(json));
        Result result = new StreamResult(out);
        transformer.transform(new SAXSource(reader, source), result);
        return new String(out.toByteArray());
    }

    public static Element formatXml(Element element) throws Exception {
        Iterator<Element> elementIterator = element.elementIterator();
        while (elementIterator.hasNext()){
            Element ele = elementIterator.next();
            String text = ele.getText();
            if(isJson(text)&&!StringTools.isEmpty(text.trim())){
                Document document = null;
                text=convertToXml(text,new JsonXmlReader("", false, "root"));
                text=text.replace("&","");
                try {
                     document = DocumentHelper.parseText(text);
                }
               catch (Exception e){
                   System.out.println("uuu:"+text);
                    e.printStackTrace();

               }
                Element rtele = document.getRootElement();
                ele.setText("");
                ele.add(rtele);
            }
            else
                formatXml(ele);
        }
        return element;
    }




    public static boolean isJson(String content) {
        if(StringUtils.isEmpty(content)){
            return false;
        }
        boolean isJsonObject = true;
        boolean isJsonArray = true;
        try {
            JSONObject.parseObject(content);
        } catch (Exception e) {
            isJsonObject = false;
        }
        try {
            JSONObject.parseArray(content);
        } catch (Exception e) {
            isJsonArray = false;
        }
        if(!isJsonObject && !isJsonArray){ //不是json格式
            return false;
        }
        return true;
    }

}
