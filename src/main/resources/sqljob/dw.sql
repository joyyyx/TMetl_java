USE [master]
go
drop view [dbo].[ccr_patients]
    go
create VIEW [dbo].[ccr_patients]
AS
SELECT [PATIENTID],
    ISNULL([CARDNO], '')                                             [CARDNO],
    ISNULL([CARDNO], '')                                             [MRN],
    ISNULL([CARDNO], '')                                             [SSN],
    ISNULL([NAME], '')                                               [NAME],
    CASE [SEX] WHEN 'M' THEN '男' WHEN 'F' THEN '女' ELSE '' END       SEX,
       ISNULL([BIRTHDAY], '')                                           [DOB],
       ISNULL([MARRIAGESTATUS], '')                                     [MARITALSTATUS],
       ISNULL([NATIONALITY], '')                                        [RACE],
       ISNULL([NATIONALITY], '')                                        [NATIONALITY],
       ISNULL([HOMEADDRESS], '')                                        [ADDRESS],
       ISNULL([HOMEPOSTCODE], '')                                       [ZIPCODE],
       ISNULL([MOBILEPHONE], '')                                        [PHONE],
       ISNULL([CONTACTS], '')                                           [CONTACTPERSONNAME],
       ISNULL([CONTACTSRELATION], '')                                   [CONTACTRELATIONSHIP],
       ISNULL([CONTACTSPHONE], '')                                      [CONTACTPHONE],
       ISNULL('', '')                                                   [COMPANY],
       ISNULL('', '')                                                   [COMPANYPHONE],
       DATEDIFF(YEAR, CAST(ISNULL(BIRTHDAY, '') AS DATE), GETDATE()) AS age,
       ISNULL(NAME, '')                                              AS TRUENAME,
       ISNULL(CARDNO, '')                                            AS TRUESSN,
       GETDATE()                                                     AS createtime
FROM ODS.dbo.PATIENT_PATIENTINFO;
GO

select *
from ODS.dbo.PATIENT_PATIENTINFO;
---VISIT
GO
DROP VIEW [dbo].[ccr_encounters]
    GO
CREATE view [dbo].[ccr_encounters] as
SELECT [PATIENTSN],
    '住院'                  [FACILITY],
    [PATIENTID],
    CURRENTDEPARTMENTID   [SERVICECODE],
    CURRENTDEPARTMENT     [SERVICENAME],
    ''                    [WARDCODE],
    ''                    [WARDNAME],
    ''                    [BED],
    ADMISSIONREGISTERTIME [REGISTERDTTM],
    ADMISSIONREGISTERTIME [ADMITDTTM],
    LEAVEHOSPITALTIME     [DISCHARGEDTTM],
    CONTROLDOCTORID       [CONSULTINGMDNO],
    CONTROLDOCTOR         [CONSULTINGMDNAME],
    DOCTORID              [ATTENDINGMDNO],
    DOCTOR                [ATTENDINGMDNAME],
    ''                    [OUTCOME],
    ''                    [COMPANY],
    ''                    [COMPANYPHONE]
from ODS.DBO.PATIENT_INPATIENTINFO WITH (NOLOCK)
union all
SELECT [VISIT_SN],
    '门诊'                                                                                               [FACILITY],
    OUT_PATIENT_SN                                                                                     [PATIENTID],
    DEPARTMENT_ID                                                                                      [SERVICECODE],
    (select top 1 DEPARTMENTNAME from ods.dbo.PUBLIC_DEPARTMENT where DEPARTMENT_ID = a.DEPARTMENT_ID) [SERVICENAME],
    ''                                                                                                 [WARDCODE],
    ''                                                                                                 [WARDNAME],
    ''                                                                                                 [BED],
    REGISTER_TIME                                                                                      [REGISTERDTTM],
    ''                                                                                                 [ADMITDTTM],
    ''                                                                                                 [DISCHARGEDTTM],
    DOCTOR_ID                                                                                          [CONSULTINGMDNO],
    (select top 1 DOCTOR
    from ods.dbo.PATIENT_INPATIENTINFO
    where DOCTOR_ID = a.DOCTOR_ID)                                                                    [CONSULTINGMDNAME],
    ''                                                                                                 [ATTENDINGMDNO],
    ''                                                                                                 [ATTENDINGMDNAME],
    ''                                                                                                 [OUTCOME],
    ''                                                                                                 [COMPANY],
    ''                                                                                                 [COMPANYPHONE]
from ODS.DBO.OUT_PATIENT_MEDICAL_RECORD a WITH (NOLOCK);
SELECT *
FROM ODS.DBO.OUT_PATIENT_MEDICAL_RECORD;

--DIAGS
GO
DROP VIEW [dbo].[ccr_diagnoses]
    GO
CREATE VIEW [dbo].[ccr_diagnoses]
AS
SELECT VISIT_SN                                                 visitnumber,
       DIAG_SN                                                  dxsequenceid,
       ''                                                       dxsequenceidaa,
       (select OUT_PATIENT_SN
        from ods.dbo.OUT_PATIENT_MEDICAL_RECORD
        where OUT_PATIENT_MEDICAL_RECORD.VISIT_SN = a.VISIT_SN) patientid,
       ''                                                       patientname,
       ''                                                       sex,
       ''                                                       dxcategorycode,
       ''                                                       dxcategoryname,
       DIAG_CODE                                                dxcode,
       DIAG_NAME                                                dxdesc,
       DIAG_CODE                                                dxicd10code,
       DIAG_NAME                                                dxicd10desc,
       CREATE_TIME                                              dxdttm,
       ''                                                       dxmdno,
       ''                                                       dxmdname,
       ''                                                       dischargedisposition,
       ''                                                       doctname,
       '门诊'                                                     facility,
       ''                                                       dxprioritycode,
       ''                                                       dxpriorityname
FROM ods.[dbo].OUT_MEDICAL_DIAG a
union all
SELECT PATIENT_SN  visitnumber,
       CODE        dxsequenceid,
       ''          dxsequenceidaa,
       PATIENT_ID  patientid,
       ''          patientname,
       ''          sex,
       ''          dxcategorycode,
       ''          dxcategoryname,
       DIAG_CODE   dxcode,
       DIAG_NAME   dxdesc,
       DIAG_CODE   dxicd10code,
       DIAG_NAME   dxicd10desc,
       CREATE_TIME dxdttm,
       ''          dxmdno,
       ''          dxmdname,
       ''          dischargedisposition,
       ''          doctname,
       '住院'        facility,
       ''          dxprioritycode,
       ''          dxpriorityname
FROM ods.[dbo].MEDICAL_DIAG a

select *
from ods.dbo.MEDICAL_DIAG;
GO

--DRUGS
GO
DROP VIEW [dbo].[ccr_medications]
    GO
CREATE VIEW [dbo].[ccr_medications] AS
SELECT ORDER_SN                                                 [PRESCRIPTIONID],     --Char(100) 开单流水号 门诊处方、住院医嘱、发药主表流水号
       ORDER_SN                                                 [PRESCRIPTIONITEMID], --Char(50) 开单明细号 门诊处方、住院医嘱、发药明细表流水号
       ''                                                       [PRESCRIPTIONIDAA],   --Char(20) 流水号名称空间 通常是系统名称，如HIS门诊，HIS住院，EMR，病案等
       VISIT_SN                                                 [VISITNUMBER],        --Char(100) 就诊唯一号 标识一次门诊，或一次住院，通常是一个挂号流水号或住院流水号
       (select OUT_PATIENT_SN
        from ods.dbo.OUT_PATIENT_MEDICAL_RECORD
        where OUT_PATIENT_MEDICAL_RECORD.VISIT_SN = a.VISIT_SN) [PATIENTID],          --Char(100) 病人ID 业务系统标识一个病人的ID，如卡号，病案号等
       ''[COMPONENTGROUPNO],                                                          --Char(50) 组号 成组药品编号
       ORDER_CODE                                               [DRUGID],             --Char(100) 药品代码 对应药品字典表的主键
       ORDER_NAME                                               [DRUGNAME],           --Char(200) 药品名称 药品通用名
       ''                                                       [PRODUCTNAME],        --Char(100) 产品名称 药品商品名
       'A'                                                      [CATEGORYCODE],       --Char(100) 分类代码 药品分类代码，药品通常有几个层次的分类，这里需要最明细的一层分类
       ORDER_CONTENT                                            [CATEGORYNAME],       --Char(100) 分类名称 药品分类代码，药品通常有几个层次的分类，这里需要最明细的一层分类
       ''                                                       [DOSE],               --Decimal 剂量 药品一次使用的量
       ''                                                       [DOSEUNIT],           --Char(50) 剂量单位 药品一次使用量的单位
       ''                                                       [FREQUENCYCODE],      --Char(50) 频次代码 药品使用频次，如TID即每日三次，qid即每日一次
       FREQUENCY_NAME                                           [FREQUENCYTEXT],      --Char(100) 频次名称 药品使用频次，如TID即每日三次，qid即每日一次
       ''                                                       [ROUTECODE],          --Char(50) 用法代码 药品使用方式代码
       ''                                                       [ROUTENAME],          --Char(100) 用法名称 药品使用方式代码
       ''                                                       [QUANTITY],           --Int 药品数量 药品总数量，单位在规格中体现
       ''                                                       [DRUGSPECIFICATION],  --Char(100) 药品规格 药品规格
       ''                                                       [TOTALDOSE],          --Decimal 总剂量 药品总剂量
       SUBMIT_TIME                                              [STARTDTTM],          --Date 开始日期 药品开始使用的日期，通常为发药日期，也可为门诊的处方开单日期
       ''                                                       [ENDDTTM],            --Date 结束日期 药品最后使用的日期，可能需要计算
       ''                                                       [DURATION]            --Int 持续天数 药品使用持续天数
FROM ODS.dbo.OUT_ORDER a
union all
SELECT ORDER_SN                                              [PRESCRIPTIONID],     --Char(100) 开单流水号 门诊处方、住院医嘱、发药主表流水号
       ORDER_SN                                              [PRESCRIPTIONITEMID], --Char(50) 开单明细号 门诊处方、住院医嘱、发药明细表流水号
       ''                                                    [PRESCRIPTIONIDAA],   --Char(20) 流水号名称空间 通常是系统名称，如HIS门诊，HIS住院，EMR，病案等
       PATIENT_SN                                            [VISITNUMBER],        --Char(100) 就诊唯一号 标识一次门诊，或一次住院，通常是一个挂号流水号或住院流水号
       (select PATIENTID
        from ods.dbo.PATIENT_INPATIENTINFO
        where PATIENT_INPATIENTINFO.VISIT_SN = b.PATIENT_SN) [PATIENTID],          --Char(100) 病人ID 业务系统标识一个病人的ID，如卡号，病案号等
       ''[COMPONENTGROUPNO],                                                       --Char(50) 组号 成组药品编号
       ORDER_CODE                                            [DRUGID],             --Char(100) 药品代码 对应药品字典表的主键
       ORDER_NAME                                            [DRUGNAME],           --Char(200) 药品名称 药品通用名
       ''                                                    [PRODUCTNAME],        --Char(100) 产品名称 药品商品名
       'A'                                                   [CATEGORYCODE],       --Char(100) 分类代码 药品分类代码，药品通常有几个层次的分类，这里需要最明细的一层分类
       ORDER_CONTENT                                         [CATEGORYNAME],       --Char(100) 分类名称 药品分类代码，药品通常有几个层次的分类，这里需要最明细的一层分类
       ''                                                    [DOSE],               --Decimal 剂量 药品一次使用的量
       ''                                                    [DOSEUNIT],           --Char(50) 剂量单位 药品一次使用量的单位
       ''                                                    [FREQUENCYCODE],      --Char(50) 频次代码 药品使用频次，如TID即每日三次，qid即每日一次
       FREQUENCY_NAME                                        [FREQUENCYTEXT],      --Char(100) 频次名称 药品使用频次，如TID即每日三次，qid即每日一次
       ''                                                    [ROUTECODE],          --Char(50) 用法代码 药品使用方式代码
       ''                                                    [ROUTENAME],          --Char(100) 用法名称 药品使用方式代码
       ''                                                    [QUANTITY],           --Int 药品数量 药品总数量，单位在规格中体现
       ''                                                    [DRUGSPECIFICATION],  --Char(100) 药品规格 药品规格
       ''                                                    [TOTALDOSE],          --Decimal 总剂量 药品总剂量
       START_TIME                                            [STARTDTTM],          --Date 开始日期 药品开始使用的日期，通常为发药日期，也可为门诊的处方开单日期
       STOP_TIME                                             [ENDDTTM],            --Date 结束日期 药品最后使用的日期，可能需要计算
       datediff(day, START_TIME, STOP_TIME)                  [DURATION]            --Int 持续天数 药品使用持续天数
FROM ODS.dbo.MEDICAL_ORDER b;


CREATE VIEW [dbo].[ccr_lab_obr] AS
SELECT SAMPLENO      fillerorderno,        --Char(100) 流水号 标识一份检验报告
       PATIENTSN     visitnumber,          --Char(100) 就诊唯一号 标识一次门诊，或一次住院，通常是一个挂号流水号或住院流水号
       PATIENTID     patientid,            --Char(100) 病人ID 业务系统标识一个病人的ID，如卡号，病案号等
       SAMPLENO      placerorderno,        --Char(100) 申请单号 门诊、住院的开单单号
       ''            specimenid,           --Char(50) 样本号 检验系统样本号
       ''            [specimensourcecode], --Char(100) 样本来源代码 尿液，血液等样本类型
       ''            specimensourcename,   --Char(100) 样本来源名称 尿液，血液等样本类型
       ''            [RESULTSTATUS],                   --Char(100) 报告状态 如已出报告、已审核等
       ''            [diagsvcsectid],      --Char(50) 诊断服务类别代码 血常规、尿常规等
       ''            [diagsvcsectname],    --Char(100) 诊断服务类别名称 血常规、尿常规等
       ''            relevantclinicalinfo, --Char(500) 临床信息 临床诊断等相关的描述
       ''            orderingfacility,     --Char(10) 申请机构 门诊、住院等
       EXAMINAIMCODE universalserviceid,   --Char(50) 申请科室代码
       EXAMINAIM     universalservicename, --Char(50) 申请医生代码
       CHECK_TIME    observationdttm,      --Char(50) 检查项目代码 检查的具体项目
       SUBMIT_TIME   finalresultdttm
FROM ods.dbo.CHECK_JYTMXX
union all
SELECT      SAMPLENO fillerorderno,        --Char(100) 流水号 标识一份检验报告
            ''     visitnumber,          --Char(100) 就诊唯一号 标识一次门诊，或一次住院，通常是一个挂号流水号或住院流水号
            PATIENTID     patientid,            --Char(100) 病人ID 业务系统标识一个病人的ID，如卡号，病案号等
            SAMPLENO      placerorderno,        --Char(100) 申请单号 门诊、住院的开单单号
            ''            specimenid,           --Char(50) 样本号 检验系统样本号
            ''            [specimensourcecode], --Char(100) 样本来源代码 尿液，血液等样本类型
       ''            specimensourcename,   --Char(100) 样本来源名称 尿液，血液等样本类型
       ''            [RESULTSTATUS],                   --Char(100) 报告状态 如已出报告、已审核等
       ''            [diagsvcsectid],      --Char(50) 诊断服务类别代码 血常规、尿常规等
       ''            [diagsvcsectname],    --Char(100) 诊断服务类别名称 血常规、尿常规等
       ''            relevantclinicalinfo, --Char(500) 临床信息 临床诊断等相关的描述
       ''            orderingfacility,     --Char(10) 申请机构 门诊、住院等
       EXAMINAIMCODE universalserviceid,   --Char(50) 申请科室代码
       EXAMINAIM     universalservicename, --Char(50) 申请医生代码
       CHECKTIME    observationdttm,      --Char(50) 检查项目代码 检查的具体项目
       CHECKTIME   finalresultdttm
FROM ods.dbo.L_PATIENTINFO;



--EMR
GO
DROP VIEW [dbo].[emrdocuments]
    GO
CREATE VIEW [dbo].[emrdocuments] AS
SELECT CONCAT([patientid], [visitnumber], [DOCUMENTID]) [DOCUMENTID], --Char(100) 文书id emr文书唯一号
    [visitnumber],                                                 --Char(100) 就诊唯一号 标识一次门诊，或一次住院，通常是一个挂号流水号或住院流水号
    [patientid],                                                   --Char(100) 病人ID 业务系统标识一个病人的ID，如卡号，病案号等
    [createdttm],                                                  --Date 创建日期 文书创建日期
    [categorycode],                                                --Char(100) 文书类别代码 如入院记录、出院记录、手术记录等
    [categoryname],                                                --Char(100) 文书类别名称 如入院记录、出院记录、手术记录等
    [authenticatedttm],                                            --Date 审核日期 审核日期
    [authorno],                                                    --Char(50) 作者代码 创建文书的医生
    [authorname],                                                  --Char(50) 作者 创建文书的医生
    ''                                               [body_html],  --Char 文书内容html 文书html格式的内容
    [body_text],                                                   --Char 文书内容text 文书text格式的内容
    ''                                               [body_xml]    --Char 文书内容xml 文书xml格式的内容
FROM ODS..V_INPATIENT_RECORD


CREATE VIEW [dbo].[ccr_lab_obx] AS
select INSPECTION_ID,                   --Char(100) 流水号 标识一份检验报告
       TEST_ITEM_ID,                    --Char(50) 明细序号 标识一份检验报告中的一个细项
       OUTPATIENT_ID,                   --Char(100) 就诊唯一号 标识一次门诊，或一次住院，通常是一个挂号流水号或住院流水号
       INPATIENT_ID,                    --Char(100) 病人ID 业务系统标识一个病人的ID，如卡号，病案号等
       ENGLISH_NAME,                    --Char(100) 观察项目id 检验明细项目，如RBC(红细胞)、WBC(白细胞)
       CHINESE_NAME,                    --Char(50) 观察项目 检验明细项目，如红细胞、白细胞
       QUANTITATIVE_RESULT,             --Char(100) 检验结果 检验明细项目的值，如阴性、阳性、具体的数值等
       --CASE WHEN eResearch.dbo.TryPraseNumber(QUANTITATIVE_RESULT,-999)=-999 THEN 1 ELSE eResearch.dbo.TryPraseNumber(QUANTITATIVE_RESULT,-999) END , --Decimal 检验结果数字值 检验明细项目的值，数值部分
       TEST_ITEM_UNIT,                  --Char(100) 单位 检验结果值的单位
       TEST_ITEM_REFERENCE,             --Char(100) 参考范围 检验明细项目的正常参考范围
       ABNORMALFLAGS,                   --Char(20) 异常标志 标志结果是否异常
       ''              TEST_ORDER_CODE, --Char(100) 检查项目代码 检查的具体项目
       ''              TEST_ORDER_NAME, --Char(100) 检查项目名称 检查的具体项目
       INSPECTION_DATE SAMPLING_TIME,   --Date 检查日期 执行检查的具体日期
       CHECK_PERSON,                    --Char(50) 审核医生代码
       ''              CHECK_TIME       --Date 审核日期

from (SELECT * FROM CQZL.dbo.VIEW_GCP_LIS_RESULT_MZ UNION ALL SELECT * FROM CQZL.dbo.VIEW_GCP_LIS_RESULT_ZY) A

select * from ods.dbo.LIS_TEST_RESULT
    GO
/****** Object:  View [dbo].[ccr_medications]    Script Date: 2021/4/14 12:09:30 ******/
SET ANSI_NULLS ON
    GO
    SET QUOTED_IDENTIFIER ON
    GO


CREATE VIEW [dbo].[ccr_surgeries] AS
SELECT [VISITNUMBER],                                                                                   --Char(100) 就诊唯一号 标识一次门诊，或一次住院，通常是一个挂号流水号或住院流水号
    [PATIENTID],                                                                                     --Char(100) 病人ID 业务系统标识一个病人的ID，如卡号，病案号等
    OPERATION,                                                                                       --Char(50) 手术代码 业务系统手术代码
    OPER_NO,                                                                                         --Char(50) 手术科室代码
    (SELECT top 1 DEPTNAME FROM CQZL.DBO.VIEW_GCP_DEPTADD B WHERE B.DEPTCODE = OPER_NO) DEPTNAME,    --Char(100) 手术科室名称
    [ANESTHESIA_METHOD],                                                                             --Char(50) 麻醉方式代码 如全身麻醉，局部麻醉等
    ASA_GRADE,                                                                                       --Char(50) 手术等级代码 手术等级综合描述，如特，大，中，小等
    (SELECT TOP 1 DOCTOR_NAME
    FROM CQZL.DBO.VIEW_GCP_DOCTOR B
    WHERE B.DOCTOR_CODE = [SURGEN])                                                    DOCNAME,     --Char(50) 主刀医生
    [FIRST_ASSISTANT],                                                                               --Char(50) 第一助手
    [SECOND_ASSISTANT],                                                                              --Char(50) 第二助手
    (SELECT TOP 1 DOCTOR_NAME
    FROM CQZL.DBO.VIEW_GCP_DOCTOR B
    WHERE B.DOCTOR_CODE = ANESTHESIA_DOCTOR)                                           ANESTHETIST, --Char(50) 麻醉医生
    OPER_START_TIME,                                                                                 --Date 手术开始时间
    OPER_END_TIME                                                                                    --Date 手术结束时间
FROM CQZL.[dbo].[VIEW_OPS_SS]
    GO
/****** Object:  View [dbo].[ccr_vitalsigns]    Script Date: 2021/4/14 12:09:30 ******/
SET ANSI_NULLS ON
    GO
    SET QUOTED_IDENTIFIER ON
    GO

CREATE VIEW [dbo].[ccr_vitalsigns] AS
SELECT VITALSIGNID,                 --Char(100) 记录流水号 记录流水号
       VISITNUMBER,                 --Char(100) 就诊唯一号 标识一次门诊，或一次住院，通常是一个挂号流水号或住院流水号
    [PATIENTID],                 --Char(100) 病人ID 业务系统标识一个病人的ID，如卡号，病案号等
    [OBSERVATIONDTTM],           --Date 观察日期
    [VITALSIGN_CODE],            --Char(100) 观察项目代码
    [VITALSIGN_ITEM],            --Char(200) 观察项目名称 如血压、心率等
    [VITALSIGN_VALUE],           --Decimal 观察值 观察值
    [VITALSIGN_UNIT] = NULL,     --Char(20) 观察项目单位 观察项目单位
    [VITALSIGN_REFERENCESRANGE], --Char(100) 参考范围 参考范围
    [VUTAKSIGN_ABNORMALFLAGS]    --Char(10) 异常标志 异常标志
FROM CQZL.DBO.VIEW_GCP_SMTZ
    GO
/****** Object:  View [dbo].[emrdocuments]    Script Date: 2021/4/14 12:09:30 ******/
SET ANSI_NULLS ON
    GO
    SET QUOTED_IDENTIFIER ON
    GO



CREATE VIEW [dbo].[imagereport] AS
select EXAM_APPLY_FLOW fillerorderno,                 --Char(100) 流水号 标识一份影像报告
       PATIENT_SN visitnumber,   --Char(100) 就诊唯一号 标识一次门诊，或一次住院，通常是一个挂号流水号或住院流水号
       PATIENT_ID patientid,                     --Char(100) 病人ID 业务系统标识一个病人的ID，如卡号，病案号等
       '' orderingfacility,                --Char(100) 申请单号 门诊、住院的开单单号
       '' placerorderno,                 --Char(50) 诊断服务类别代码 CT、MR、US等等
       EXAM_CODE diagsvcsectid,                --Char(500) 临床信息 临床诊断等相关的描述
       EXAM_NAME diagsvcsectname,                 --Char(50) 申请科室代码
       '' relevantclinicalinfo,
       EXAM_CODE universalserviceid,
       EXAM_NAME universalservicename,
       EXAM_TIME observationdttm,
       EXAM_REPORTER principalresultinterpreterno,
       EXAM_REPORTER principalresultinterpretername,
       findings imagingfindings,
       result imagingconclusion,
       EXAM_TIME finalresultdttm,
       '' diagnosticimagingtech,
       '' bodypart
from ods.dbo.EXAM_REPORT a join ods.dbo.pacs_jx b on a.EXAM_APPLY_FLOW = b.EXAM_RPT_FLOW;
GO


---CREATE PIX
USE DW
GO
DROP PROC [UPDATEPIX]
GO
CREATE PROCEDURE [UPDATEPIX]
AS
BEGIN
BEGIN TRANSACTION
        --建表
        IF NOT EXISTS(SELECT 1 FROM DW.sys.tables WHERE NAME = 'PIX')
BEGIN
CREATE TABLE DW.DBO.PIX
(
    empi          NVARCHAR(100),
    patientid     NVARCHAR(100),
    cardno        NVARCHAR(100),
    mrn           NVARCHAR(100),
    ssn           NVARCHAR(50),
    name          NVARCHAR(50),
    sex           NVARCHAR(10),
    dob           DATETIME2,
    [address]     NVARCHAR(200),
    phone         NVARCHAR(50),
    company       NVARCHAR(50),
    entrydate     DATETIME,
    relationproof NVARCHAR(500),
    mergeflag     SMALLINT
    )
CREATE CLUSTERED INDEX ix_patientid ON PIX (patientid)
                CREATE NONCLUSTERED INDEX ix_empi ON PIX (empi)
                CREATE NONCLUSTERED INDEX ix_cardno ON PIX (cardno)
                CREATE NONCLUSTERED INDEX ix_mrn ON PIX (mrn)
                CREATE NONCLUSTERED INDEX ix_ssn ON PIX (ssn)
                CREATE NONCLUSTERED INDEX ix_name ON PIX (name)
END

--增量导入病人数据
MERGE DW..PIX AS TARGET
    USING DW..ccr_patients AS SOURCE
    ON (TARGET.patientid = SOURCE.patientid)
    WHEN NOT MATCHED BY TARGET THEN
    INSERT (empi, patientid, cardno, mrn, ssn, name, sex, dob, address, phone, company, entrydate, mergeflag)
    VALUES ( NEWID(), SOURCE.patientid, SOURCE.cardno, SOURCE.mrn, SOURCE.ssn, SOURCE.name, SOURCE.sex
    , SOURCE.dob, SOURCE.address, SOURCE.phone, SOURCE.company, GETDATE(), 0);


--病人合并 name+ssn
SELECT CASE WHEN LEN(ssn) > 15 THEN SUBSTRING(ssn, 1, 6) + SUBSTRING(ssn, 9, 9) ELSE ssn END AS ssn,
       name                                                                                  AS name,
       (SELECT TOP 1 empi
        FROM DW..PIX b
        WHERE CASE WHEN LEN(a.ssn) > 15 THEN SUBSTRING(a.ssn, 1, 6) + SUBSTRING(a.ssn, 9, 9) ELSE a.ssn END =
              CASE WHEN LEN(b.ssn) > 15 THEN SUBSTRING(b.ssn, 1, 6) + SUBSTRING(b.ssn, 9, 9) ELSE b.ssn END
          AND a.name = b.name
        ORDER BY entrydate ASC, mergeflag DESC, empi ASC)                                    AS orginal_empi
INTO #temp_ssn_name
FROM DW..PIX (NOLOCK) a
WHERE (ssn IS NOT NULL AND LEN(ssn) > 0)
  AND (name IS NOT NULL AND LEN(name) > 0)
GROUP BY CASE WHEN LEN(ssn) > 15 THEN SUBSTRING(ssn, 1, 6) + SUBSTRING(ssn, 9, 9) ELSE ssn END, name
HAVING COUNT(DISTINCT empi) > 1

SELECT a.empi, orginal_empi=Min(b.orginal_empi)
INTO #empi_ssn_name
FROM DW..PIX (NOLOCK) a
         INNER JOIN #temp_ssn_name b ON CASE
                                            WHEN LEN(a.ssn) > 15
                                                THEN SUBSTRING(a.ssn, 1, 6) + SUBSTRING(a.ssn, 9, 9)
                                            ELSE a.ssn END = b.ssn AND a.name = b.name
GROUP BY a.empi

UPDATE a
SET a.empi=b.orginal_empi,
    a.mergeflag=1,
    relationproof='name+ssn'
    FROM DW..PIX a
                 INNER JOIN #empi_ssn_name b ON a.empi = b.empi AND a.empi <> b.orginal_empi

DROP TABLE #temp_ssn_name
DROP TABLE #empi_ssn_name

--病人合并 name+dob+phone
SELECT name                                               AS name,
       phone                                              AS phone,
       CONVERT(VARCHAR(50), dob, 23)                      AS dob,
       (SELECT TOP 1 empi
        FROM DW..PIX b
        WHERE a.name = b.name
          AND a.phone = b.phone
          AND CONVERT(VARCHAR(50), a.dob, 23) = CONVERT(VARCHAR(50), b.dob, 23)
        ORDER BY entrydate ASC, mergeflag DESC, empi ASC) AS orginal_empi
INTO #temp_name_phone_dob
FROM DW..PIX (NOLOCK) a
WHERE (name IS NOT NULL AND LEN(name) > 0)
  AND (phone IS NOT NULL AND LEN(phone) > 0)
  AND (dob IS NOT NULL AND LEN(dob) > 0)
GROUP BY name, phone, CONVERT(VARCHAR(50), dob, 23)
HAVING COUNT(DISTINCT empi) > 1

SELECT a.empi, orginal_empi=Min(b.orginal_empi)
INTO #empi_name_phone_dob
FROM DW..PIX (NOLOCK) a
         INNER JOIN #temp_name_phone_dob b
                    ON a.name = b.name AND a.phone = b.phone AND CONVERT(VARCHAR(50), a.dob, 23) = b.dob
GROUP BY a.empi

UPDATE a
SET a.empi=b.orginal_empi,
    a.mergeflag=1,
    relationproof='name+dob+phone'
    FROM DW..PIX a
                 INNER JOIN #empi_name_phone_dob b ON a.empi = b.empi AND a.empi <> b.orginal_empi

DROP TABLE #temp_name_phone_dob
DROP TABLE #empi_name_phone_dob
    COMMIT TRANSACTION
END
GO