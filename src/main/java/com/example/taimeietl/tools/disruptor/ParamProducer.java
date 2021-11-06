package com.example.taimeietl.tools.disruptor;

import com.lmax.disruptor.RingBuffer;

import java.util.Map;

public class ParamProducer {
    private final RingBuffer<Param> ringBuffer;
    public ParamProducer(RingBuffer<Param> ringBuffer){
        this.ringBuffer = ringBuffer;
    }
    public void onData(Map<String, String> map){
        long sequence = ringBuffer.next();
        try {
            Param param = ringBuffer.get(sequence);
            param.setParam(map);
        } finally {
            ringBuffer.publish(sequence);
        }
    }
}
