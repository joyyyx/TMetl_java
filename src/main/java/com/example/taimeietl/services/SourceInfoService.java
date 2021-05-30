package com.example.taimeietl.services;

import com.example.taimeietl.model.SourceInfo;
import org.springframework.stereotype.Service;

import java.util.List;
@Service
public interface SourceInfoService {
   public List<SourceInfo> selectAll();
   public int insertRecord(SourceInfo sourceInfo);
   public int updateRecord(SourceInfo sourceInfo);
   public int deleteRecord(int id);

}
