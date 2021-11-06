package com.example.taimeietl.services.servicesImpl;

import com.example.taimeietl.map.DrViewMapper;
import com.example.taimeietl.model.DrView;
import com.example.taimeietl.services.DrViewService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class DrViewServiceImpl implements DrViewService {

    @Autowired
    private DrViewMapper drViewMapper;
    @Override
    public int deleteByPrimaryKey(Integer id) {
        return drViewMapper.deleteByPrimaryKey(id);
    }

    @Override
    public int insert(DrView record) {
        return drViewMapper.insert(record);
    }

    @Override
    public int insertSelective(DrView record) {
        return drViewMapper.insertSelective(record);
    }

    @Override
    public DrView selectByPrimaryKey(Integer id) {
        return drViewMapper.selectByPrimaryKey(id);
    }

    @Override
    public List<DrView> selectAll() {
        return drViewMapper.selectAll();
    }

    @Override
    public int updateByPrimaryKeySelective(DrView record) {
        return drViewMapper.updateByPrimaryKeySelective(record);
    }

    @Override
    public int updateByPrimaryKey(DrView record) {
        return drViewMapper.updateByPrimaryKey(record);
    }
}
