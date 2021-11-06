package com.example.taimeietl.tools.disruptor;

import org.dom4j.Element;

import java.util.Map;

public class Order {
    private Map<String,String> sqlelement;

    public Map<String,String> getSqlelement() {
        return sqlelement;
    }

    public void setSqlelement(Map<String,String> sqlelement) {
        this.sqlelement = sqlelement;
    }
}
