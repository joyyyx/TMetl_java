package com.example.taimeietl.tools.disruptor;

import com.lmax.disruptor.RingBuffer;
import org.dom4j.Element;

import java.util.Map;

public  class Producer {
    private final RingBuffer<Order> ringBuffer;
    public Producer(RingBuffer<Order> ringBuffer){
        this.ringBuffer = ringBuffer;
    }
    public void onData(Map<String,String> map){
        long sequence = ringBuffer.next();
        try {
            Order order = ringBuffer.get(sequence);
            order.setSqlelement(map);
        } finally {
            ringBuffer.publish(sequence);
        }
    }
}
