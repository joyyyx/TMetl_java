package com.example.taimeietl.tools.httpClient.requests;

import com.example.taimeietl.tools.StringTools;
import org.dom4j.Element;

import java.util.*;

public class AnalyXML {
    private StringBuilder values = new StringBuilder();
    private StringBuilder headers = new StringBuilder();
    private List<Map<String, String>> recordList = new LinkedList<>();

    public static List<String> columnList = new ArrayList<>();

    public static List<String> columns = new ArrayList<>();

    public List<Map<String, String>> getRecordList() {
        return recordList;
    }


    public void setRecordList(List<Map<String, String>> recordList) {
        this.recordList = recordList;
    }

    int loopCount = 1;

    public int getAllXmlText(Element element, Map<String, String> paramMap, int loopMark, List<String> tablecolumnList, String xmlNodes) {

        String ele = element.asXML();
        ele.replaceAll("(\\r)+","*r*r*r*");
        ele.replaceAll("(\\n)+","*n*n*n*");
        ele = ele.replaceAll("<ImageDataBase64String.*ImageDataBase64String>", "");
        ele = ele.replaceAll("<.*>", "");
        ele.replaceAll("</.*>", "");
        values.append(ele);
        String headppp = "";
        String valueppp = "";
        for (String key : paramMap.keySet()
        ) {
            headppp = StringTools.isEmpty(key) ? "" : key + ",";
            valueppp = StringTools.isEmpty(paramMap.get(key)) ? "" : paramMap.get(key) + ",";
        }
        Map<String, String> map = new HashMap<>();
        if (tablecolumnList.contains("PARENT_NODE")) {
            headers.append("PARENT_NODE,");
            values.append("'" + element.getParent().getParent().asXML().replaceAll("'", "''") + "',");
        }
        map.put("( " + headppp + "text)", "( " + valueppp + "'" + values.substring(0, values.length() - 1) + ")'");
        recordList.add(map);
        values = new StringBuilder();
        headers = new StringBuilder();
        loopCount = 1;
        return loopMark;
    }


    public int loopElement(Element element, Map<String, String> paramMap, int loopMark, List<String> tablecolumnList, String xmlNodes) {
        Iterator<Element> elementIterator = element.elementIterator();
        if (!elementIterator.hasNext()) {
            if (element.getParent().nodeCount() >= 5 && tablecolumnList.contains(element.getName()) && xmlNodes.contains(element.getParent().getName())) {
                values.append("'" + element.getStringValue().replaceAll("'", "''") + "',");
                headers.append(element.getName() + ",");
                loopCount++;
            }

        } else {
            while (elementIterator.hasNext()) {
                element = elementIterator.next();
                loopMark = loopElement(element, paramMap, loopMark, tablecolumnList, xmlNodes);
            }
            if (loopCount > 3 && xmlNodes.contains(element.getParent().getName())) {
                String headppp = "";
                String valueppp = "";
                for (String key : paramMap.keySet()
                ) {
                    headppp = StringTools.isEmpty(key) ? "" : key + ",";
                    valueppp = StringTools.isEmpty(paramMap.get(key)) ? "" : paramMap.get(key) + ",";
                }
                Map<String, String> map = new HashMap<>();
                if (tablecolumnList.contains("PARENT_NODE")) {
                    headers.append("PARENT_NODE,");
                    values.append("'" + element.getParent().getParent().asXML().replaceAll("'", "''") + "',");
                }
                map.put("( " + headppp + headers.substring(0, headers.length() - 1) + ")", "( " + valueppp + values.substring(0, values.length() - 1) + ")");
                recordList.add(map);
//                System.out.println(element.getParent().getParent().asXML());
//                System.out.println("loopCount:"+loopCount);
//                System.out.println("-------------\n"+"( " + values.substring(0, values.length() - 1) + ")"+"\r\n-------------");
                values = new StringBuilder();
                headers = new StringBuilder();
                loopCount = 1;
            }

        }
        return loopMark;
    }

    public void newLoopElement(Element element) {
        List<Element> elements = element.elements("return");
        for (Element ele : elements
        ) {
            Map<String, String> map = new HashMap<>();
            map.put(ele.getName(), ele.getText());
            recordList.add(map);
        }
    }

    private static void getColumns(Element element, String xmlNodes) {
        Iterator<Element> elementIterator = element.elementIterator();
        String ss = element.asXML();
        if (!elementIterator.hasNext() && xmlNodes.contains(element.getParent().getName())) {
            columnList.add(element.getName());
//            System.out.println(element.getName()+"----"+element.getText());
        } else {
            if (columnList.size() >= 3) {
                return;
            }
            while (elementIterator.hasNext()) {
                element = elementIterator.next();
                getColumns(element, xmlNodes);
            }
        }
        return;
    }

    public static List<String> getColumnList() {
        return columnList;
    }

    public static synchronized void setColumnList(Element element, String xmlNodes) {

        if (columnList.size() == 0) {
            System.out.println("aaaa----" + element.asXML());
            getColumns(element, xmlNodes);
        } else if (columnList.size() <= 3)
            columnList.removeAll(columnList);
    }
}
