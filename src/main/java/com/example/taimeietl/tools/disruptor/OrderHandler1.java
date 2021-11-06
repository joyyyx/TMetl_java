package com.example.taimeietl.tools.disruptor;

import com.example.taimeietl.tools.InsertData;
import com.example.taimeietl.tools.WriteLog;
import com.lmax.disruptor.EventHandler;
import com.lmax.disruptor.WorkHandler;
import org.springframework.beans.factory.annotation.Autowired;

public class OrderHandler1 implements EventHandler<Order>, WorkHandler<Order> {
    private String consumerId;
    private InsertData insertData;
    public OrderHandler1(String consumerId,InsertData insertData){
        this.consumerId = consumerId;
        this.insertData = insertData;
    }
    @Override
    public void onEvent(Order order, long l, boolean b) throws Exception {
        System.out.println("OrderHandler1 " + this.consumerId + "，消费信息：" + order.getSqlelement());
    }

    public static int count = 0;
    @Override
    public void onEvent(Order order) throws Exception {
//        System.out.println("OrderHandler1 " + this.consumerId +"||"+ count+++"，消费信息：" + order.getSqlelement());
        try {
//            System.out.println(22222222);
            WriteLog.write("d:/JavaLog/javalog5.txt",order.getSqlelement().toString());
            insertData.runInsert(order.getSqlelement());
        }
       catch (Exception e)
       {
           System.out.println("consumer failed:"+order.getSqlelement()+e.toString());
       }
    }
}
