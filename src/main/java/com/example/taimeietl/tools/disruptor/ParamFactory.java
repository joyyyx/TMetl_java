package com.example.taimeietl.tools.disruptor;

import com.lmax.disruptor.EventFactory;

public class ParamFactory implements EventFactory<Param> {

    @Override
    public Param newInstance() {
        return new Param();
    }
}
