package com.example.taimeietl.tools.httpClient.requests;

import com.example.taimeietl.tools.InsertData;
import com.example.taimeietl.tools.SqlJobTools;
import com.example.taimeietl.tools.disruptor.Order;
import com.example.taimeietl.tools.disruptor.OrderFactory;
import com.example.taimeietl.tools.disruptor.OrderHandler1;
import com.example.taimeietl.tools.disruptor.Producer;
import com.lmax.disruptor.EventFactory;
import com.lmax.disruptor.RingBuffer;
import com.lmax.disruptor.YieldingWaitStrategy;
import com.lmax.disruptor.dsl.Disruptor;
import com.lmax.disruptor.dsl.ProducerType;
import org.dom4j.*;
import org.junit.Test;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.concurrent.Executors;

public class RequestTest {


    public void testRequest(){


        EventFactory<Order> factory = new OrderFactory();
        int ringBufferSize = 1024 * 1024;
        Disruptor<Order> disruptor =
                new Disruptor<Order>(factory, ringBufferSize, Executors.defaultThreadFactory(), ProducerType.SINGLE, new YieldingWaitStrategy());
        /*
         * 该方法传入的消费者需要实现WorkHandler接口，方法的内部实现是：先创建WorkPool，然后封装WorkPool为EventHandlerPool返回。
         * 消费者1、2对于消息的消费有时有竞争，保证同一消息只能有一个消费者消费
         */
//        InsertData insertData1 = new InsertData();
//        disruptor.handleEventsWithWorkerPool(new OrderHandler1("1",insertData1));
        disruptor.start();
        RingBuffer<Order> ringBuffer = disruptor.getRingBuffer();
        Producer producer = new Producer(ringBuffer);

        StringBuilder sqlBuilder = new StringBuilder();
        int count = 0;
        for (int i =0;i<=0;i++) {
            SoapRequest soapRequest = new SoapRequest();
//            soapRequest.sendRequest(ringBuffer);
        }

        disruptor.shutdown();
//        insertData1.runInsert();

    }


    public void tesst1(){
        test("fds");
    }

   public  void test(String s){
        List<String> list = new ArrayList<>();
        list.add(s);
        list.add(s+s);
        list.add(s+s+s);
        System.out.println(list);



    }

    public static void main(String[] args) {
        String sql = "SELECT DISTINCT top 500 '{\"kssj\":\"2010-01-01\",\"jssj\":\"2022-01-01\"}' ls_input,";
        System.out.printf(sql.trim().substring(0, sql.length() - 1));
    }
}
