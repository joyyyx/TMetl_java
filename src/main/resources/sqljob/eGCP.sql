USE [master]
GO
/****** Object:  Database [eGCP]    Script Date: 2021/5/25 9:53:32 ******/
IF NOT EXISTS (
SELECT * FROM SYS.DATABASES WHERE NAME = 'eGCP'
)
BEGINf
CREATE DATABASE [eGCP]
END
GO
USE [eGCP]
GO
/****** Object:  UserDefinedFunction [dbo].[FN_GetDownloadUrl]    Script Date: 2021/5/25 9:53:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[FN_GetDownloadUrl]
    (
      @StudyId VARCHAR(50) ,
      @PatientId VARCHAR(50) ,
      @PacsNo VARCHAR(50)
    )
RETURNS NVARCHAR(500)
AS
BEGIN

        DECLARE @ReturnString NVARCHAR(500);
        SET @ReturnString = '';
        IF @StudyId IS NOT NULL
            AND @PatientId IS NOT NULL
            AND @PacsNo IS NOT NULL
BEGIN

      --          SELECT TOP 1
      --                  @ReturnString = 'http://192.168.0.65:8001/dicomzip/'
      --                  + LTRIM(RTRIM(t2.NAME)) + '-' + t1.screening_no + '-'
      --                  + LTRIM(RTRIM(t3.UNIVERSALSERVICENAME)) + '-'
      --                  + CONVERT(NVARCHAR(8), t1.observation_dttm, 112) + '-' + t1.pacs_no
						--+ '.zip'
      --          FROM    dbo.dcm_proc_state t1
      --                  JOIN CQZL.dbo.gcp_group_dict t2 ON t2.CODE = t1.study_id
      --                  JOIN ( SELECT   PATIENTID ,
      --                                  PACSNO ,
      --                                  MAX(UNIVERSALSERVICENAME) AS UNIVERSALSERVICENAME
      --                         FROM     [CQZL].[dbo].[yxbg]
      --                         GROUP BY PATIENTID ,
      --                                  PACSNO
      --                       ) t3 ON t3.PATIENTID = t1.patient_id
      --                               AND t3.PACSNO = t1.pacs_no
      --          WHERE   t1.study_id = @StudyId
      --                  AND t1.patient_id = @PatientId
      --                  AND t1.pacs_no = @PacsNo;

SELECT TOP 1
                        @ReturnString = CASE WHEN t1.state IN ( '20', '30',
                                                              '31', '39', '90' )
                                             THEN ( 'http://192.168.104.130:8091/dicomzip/'
                                                    + CQZL.dbo.GetMD5(t1.study_id
                                                              + '|'
                                                              + t1.screening_no
                                                              + '|'
                                                              + t1.pacs_no)
                                                    + '.zip' )
                                             ELSE ''
                                        END
FROM    dbo.dcm_proc_state t1
            JOIN CQZL.dbo.gcp_group_dict t2 ON t2.CODE = t1.study_id
            JOIN ( SELECT   PATIENTID ,
                            PACSNO ,
                            MAX(UNIVERSALSERVICENAME) AS UNIVERSALSERVICENAME
                   FROM     [CQZL].[dbo].[yxbg]
                   GROUP BY PATIENTID ,
                       PACSNO
) t3 ON t3.PATIENTID = t1.patient_id
    AND t3.PACSNO = t1.pacs_no
WHERE   t1.study_id = @StudyId
  AND t1.patient_id = @PatientId
  AND t1.pacs_no = @PacsNo;

END;

RETURN @ReturnString;

END;

GO
/****** Object:  Table [dbo].[attachment_info]    Script Date: 2021/5/25 9:53:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[attachment_info](
    [file_id] [nvarchar](50) NOT NULL,
    [client_id] [nvarchar](50) NULL,
    [creation_time] [datetime] NULL,
    [deleted] [bit] NULL,
    [dir_path] [nvarchar](max) NULL,
    [extension_name] [nvarchar](50) NULL,
    [file_category] [int] NULL,
    [file_name] [nvarchar](100) NULL,
    [file_path] [nvarchar](max) NULL,
    [file_size] [int] NULL,
    [file_type] [nvarchar](50) NULL,
    [last_update_time] [datetime] NULL,
    [last_update_user] [nvarchar](50) NULL,
    [remark] [nvarchar](200) NULL,
    [status_code] [int] NULL,
    [upload_user] [nvarchar](50) NULL,
    [feed_source] [int] NULL,
    [file_abs_path] [nvarchar](2000) NULL,
    PRIMARY KEY CLUSTERED
(
[file_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
    ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
    GO
/****** Object:  Table [dbo].[check_item]    Script Date: 2021/5/25 9:53:34 ******/
    SET ANSI_NULLS ON
    GO
    SET QUOTED_IDENTIFIER ON
    GO
CREATE TABLE [dbo].[check_item](
    [id] [varchar](255) NOT NULL,
    [check_date] [datetime] NULL,
    [check_user] [varchar](50) NULL,
    [empi] [varchar](100) NULL,
    [item_key] [varchar](100) NULL,
    [item_type] [varchar](100) NULL,
    PRIMARY KEY CLUSTERED
(
[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
    ) ON [PRIMARY]
    GO
/****** Object:  Table [dbo].[check_mark]    Script Date: 2021/5/25 9:53:34 ******/
    SET ANSI_NULLS ON
    GO
    SET QUOTED_IDENTIFIER ON
    GO
CREATE TABLE [dbo].[check_mark](
    [id] [varchar](50) NOT NULL,
    [study_id] [varchar](50) NULL,
    [subject_id] [varchar](50) NULL,
    [module] [nvarchar](50) NULL,
    [oper] [nvarchar](50) NULL,
    [oper_user] [nvarchar](50) NULL,
    [oper_time] [datetime2](7) NULL,
    [oper_desc] [nvarchar](1000) NULL,
    [client_id] [varchar](50) NULL,
    CONSTRAINT [PK_check_mark] PRIMARY KEY CLUSTERED
(
[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
    ) ON [PRIMARY]
    GO
/****** Object:  Table [dbo].[check_mark_item]    Script Date: 2021/5/25 9:53:34 ******/
    SET ANSI_NULLS ON
    GO
    SET QUOTED_IDENTIFIER ON
    GO
CREATE TABLE [dbo].[check_mark_item](
    [id] [varchar](255) NOT NULL,
    [check_mark_id] [varchar](50) NULL,
    [client_id] [varchar](200) NULL,
    [field_name] [nvarchar](50) NULL,
    [field_namecn] [nvarchar](50) NULL,
    [field_value] [nvarchar](50) NULL,
    [oper] [nvarchar](50) NULL,
    [oper_time] [datetime] NULL,
    [oper_user] [nvarchar](50) NULL,
    [table_name] [nvarchar](50) NULL,
    PRIMARY KEY CLUSTERED
(
[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
    ) ON [PRIMARY]
    GO
/****** Object:  Table [dbo].[dcm_proc_state]    Script Date: 2021/5/25 9:53:34 ******/
    SET ANSI_NULLS ON
    GO
    SET QUOTED_IDENTIFIER ON
    GO
CREATE TABLE [dbo].[dcm_proc_state](
    [id] [bigint] IDENTITY(1,1) NOT NULL,
    [source] [varchar](50) NULL,
    [patient_id] [varchar](50) NULL,
    [pacs_no] [varchar](100) NULL,
    [study_id] [varchar](50) NULL,
    [screening_no] [varchar](50) NULL,
    [state] [int] NULL,
    [dcm_dl_path] [nvarchar](1000) NULL,
    [dcm_dl_urls] [ntext] NULL,
    [dcm_an_path] [nvarchar](1000) NULL,
    [dcm_an_urls] [ntext] NULL,
    [dcm_count] [int] NULL,
    [observation_dttm] [datetime2](7) NULL,
    [err_msg] [nvarchar](max) NULL,
    [insert_dttm] [datetime2](7) NULL,
    [upload_dttm] [datetime2](7) NULL,
    [timestamp] [timestamp] NULL,
    [progress] [int] NULL,
    CONSTRAINT [PK_dcm_proc_state] PRIMARY KEY CLUSTERED
(
[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
    ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
    GO
/****** Object:  Table [dbo].[dcm_study_map]    Script Date: 2021/5/25 9:53:34 ******/
    SET ANSI_NULLS ON
    GO
    SET QUOTED_IDENTIFIER ON
    GO
CREATE TABLE [dbo].[dcm_study_map](
    [hosp_study_id] [varchar](50) NOT NULL,
    [tm_study_id] [varchar](50) NULL,
    [site_code] [varchar](50) NULL,
    CONSTRAINT [PK_dcm_study_map] PRIMARY KEY CLUSTERED
(
[hosp_study_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
    ) ON [PRIMARY]
    GO
/****** Object:  Table [dbo].[dic_sponsor]    Script Date: 2021/5/25 9:53:34 ******/
    SET ANSI_NULLS ON
    GO
    SET QUOTED_IDENTIFIER ON
    GO
CREATE TABLE [dbo].[dic_sponsor](
    [id] [nvarchar](50) NOT NULL,
    [name] [nvarchar](500) NULL,
    [locale_name_en] [nvarchar](500) NULL,
    [social_credit_code] [nvarchar](500) NULL,
    [organization_code] [nvarchar](500) NULL,
    [country_id] [nvarchar](50) NULL,
    [country_name] [nvarchar](200) NULL,
    [province_id] [nvarchar](500) NULL,
    [province_name] [nvarchar](200) NULL,
    [city_id] [nvarchar](50) NULL,
    [city_name] [nvarchar](200) NULL,
    [county_id] [nvarchar](500) NULL,
    [county_name] [nvarchar](500) NULL,
    [address] [nvarchar](500) NULL,
    [locale_address_en] [nvarchar](500) NULL,
    [contacts] [nvarchar](200) NULL,
    [telephone] [nvarchar](200) NULL,
    [email] [nvarchar](200) NULL,
    [tenant_id] [nvarchar](50) NULL,
    [master_data_id] [nvarchar](50) NULL,
    [master_data_name] [nvarchar](50) NULL,
    [master_data_name_en] [nvarchar](50) NULL,
    [version] [bigint] NOT NULL,
    [create_by] [nvarchar](50) NULL,
    [create_time] [datetime2](7) NULL,
    [update_by] [nvarchar](50) NULL,
    [update_time] [datetime2](7) NULL,
    [is_deleted] [tinyint] NOT NULL,
    PRIMARY KEY CLUSTERED
(
[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
    ) ON [PRIMARY]
    GO
/****** Object:  Table [dbo].[dicom_apply]    Script Date: 2021/5/25 9:53:34 ******/
    SET ANSI_NULLS ON
    GO
    SET QUOTED_IDENTIFIER ON
    GO
CREATE TABLE [dbo].[dicom_apply](
    [apply_id] [nvarchar](50) NOT NULL,
    [apply_time] [datetime] NULL,
    [apply_times] [int] NULL,
    [apply_user] [nvarchar](50) NULL,
    [export_time] [datetime] NULL,
    [export_times] [int] NULL,
    [export_user] [nvarchar](50) NULL,
    [filler_order_no] [nvarchar](50) NULL,
    [state] [int] NULL,
    [patient_id] [nvarchar](50) NULL,
    [study_id] [nvarchar](50) NULL,
    [emergency_level] [int] NULL,
    [empi] [nvarchar](50) NULL,
    [screening_no] [nvarchar](50) NULL,
    [update_time] [datetime] NULL,
    [update_user] [nvarchar](50) NULL,
    PRIMARY KEY CLUSTERED
(
[apply_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
    ) ON [PRIMARY]
    GO
/****** Object:  Table [dbo].[dq_check_result]    Script Date: 2021/5/25 9:53:34 ******/
    SET ANSI_NULLS ON
    GO
    SET QUOTED_IDENTIFIER ON
    GO
CREATE TABLE [dbo].[dq_check_result](
    [id] [nvarchar](50) NULL,
    [check_name] [nvarchar](50) NULL,
    [check_cname] [nvarchar](50) NULL,
    [check_result_s] [nvarchar](50) NULL
    ) ON [PRIMARY]
    GO
/****** Object:  Table [dbo].[dq_check_rule]    Script Date: 2021/5/25 9:53:34 ******/
    SET ANSI_NULLS ON
    GO
    SET QUOTED_IDENTIFIER ON
    GO
CREATE TABLE [dbo].[dq_check_rule](
    [id] [nvarchar](50) NOT NULL,
    [name] [nvarchar](50) NOT NULL,
    [c_name] [nvarchar](50) NOT NULL,
    [control_offset] [int] NOT NULL,
    [rule_txt] [nvarchar](max) NOT NULL,
    [description] [nvarchar](200) NULL,
    CONSTRAINT [PK_dq_rule] PRIMARY KEY CLUSTERED
(
[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
    ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
    GO
/****** Object:  Table [dbo].[dq_view]    Script Date: 2021/5/25 9:53:34 ******/
    SET ANSI_NULLS ON
    GO
    SET QUOTED_IDENTIFIER ON
    GO
CREATE TABLE [dbo].[dq_view](
    [id] [nvarchar](50) NOT NULL,
    [date_field] [nvarchar](50) NULL,
    [description] [nvarchar](200) NULL,
    [encounter_tb_flag] [int] NULL,
    [name] [nvarchar](50) NULL,
    [patient_tb_flag] [int] NULL,
    [pk_cluster_flag] [nvarchar](50) NULL,
    [primary_key] [nvarchar](200) NULL,
    [source_system] [nvarchar](50) NULL,
    [version_id] [nvarchar](50) NULL,
    [check_control_flag] [nvarchar](50) NULL,
    PRIMARY KEY CLUSTERED
(
[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
    ) ON [PRIMARY]
    GO
/****** Object:  Table [dbo].[dq_view_col]    Script Date: 2021/5/25 9:53:34 ******/
    SET ANSI_NULLS ON
    GO
    SET QUOTED_IDENTIFIER ON
    GO
CREATE TABLE [dbo].[dq_view_col](
    [id] [nvarchar](50) NOT NULL,
    [data_type] [nvarchar](50) NULL,
    [description] [nvarchar](200) NULL,
    [dq_view_id] [nvarchar](50) NULL,
    [field] [nvarchar](50) NULL,
    [field_name] [nvarchar](50) NULL,
    [length] [int] NULL,
    [order_no] [int] NULL,
    [required] [nvarchar](50) NULL,
    [check_control_flag] [nvarchar](50) NULL,
    PRIMARY KEY CLUSTERED
(
[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
    ) ON [PRIMARY]
    GO
/****** Object:  Table [dbo].[feed_app]    Script Date: 2021/5/25 9:53:34 ******/
    SET ANSI_NULLS ON
    GO
    SET QUOTED_IDENTIFIER ON
    GO
CREATE TABLE [dbo].[feed_app](
    [id] [varchar](255) NOT NULL,
    [code] [varchar](50) NULL,
    [create_time] [datetime] NULL,
    [creator] [nvarchar](50) NULL,
    [deleted] [bit] NULL,
    [description] [nvarchar](200) NULL,
    [hosp_code] [nvarchar](50) NULL,
    [name] [nvarchar](200) NULL,
    [update_time] [datetime] NULL,
    PRIMARY KEY CLUSTERED
(
[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
    ) ON [PRIMARY]
    GO
/****** Object:  Table [dbo].[icd_map]    Script Date: 2021/5/25 9:53:34 ******/
    SET ANSI_NULLS ON
    GO
    SET QUOTED_IDENTIFIER ON
    GO
CREATE TABLE [dbo].[icd_map](
    [id] [varchar](255) NOT NULL,
    [code] [varchar](50) NULL,
    [create_time] [datetime] NULL,
    [creator] [nvarchar](50) NULL,
    [deleted] [bit] NULL,
    [feed_app_code] [nvarchar](50) NULL,
    [feed_code] [nvarchar](200) NULL,
    [feed_name] [nvarchar](50) NULL,
    [name] [nvarchar](200) NULL,
    [update_time] [datetime] NULL,
    [category_id] [varchar](50) NULL,
    [feed_app_name] [nvarchar](200) NULL,
    PRIMARY KEY CLUSTERED
(
[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
    ) ON [PRIMARY]
    GO
/****** Object:  Table [dbo].[kb_category]    Script Date: 2021/5/25 9:53:34 ******/
    SET ANSI_NULLS ON
    GO
    SET QUOTED_IDENTIFIER ON
    GO
CREATE TABLE [dbo].[kb_category](
    [id] [varchar](255) NOT NULL,
    [category_code] [varchar](50) NULL,
    [category_name] [nvarchar](200) NULL,
    [create_time] [datetime] NULL,
    [creator] [nvarchar](50) NULL,
    [deleted] [bit] NULL,
    [description] [nvarchar](200) NULL,
    [first_spell] [nvarchar](200) NULL,
    [full_spell] [nvarchar](200) NULL,
    [kb_type] [nvarchar](50) NULL,
    [sort] [int] NULL,
    [update_time] [datetime] NULL,
    [version_no] [nvarchar](50) NULL,
    [parent_id] [varchar](50) NULL,
    PRIMARY KEY CLUSTERED
(
[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
    ) ON [PRIMARY]
    GO
/****** Object:  Table [dbo].[kb_category_item]    Script Date: 2021/5/25 9:53:34 ******/
    SET ANSI_NULLS ON
    GO
    SET QUOTED_IDENTIFIER ON
    GO
CREATE TABLE [dbo].[kb_category_item](
    [id] [varchar](255) NOT NULL,
    [category_code] [varchar](50) NULL,
    [category_id] [varchar](50) NULL,
    [create_time] [datetime] NULL,
    [creator] [nvarchar](50) NULL,
    [deleted] [bit] NULL,
    [description] [nvarchar](200) NULL,
    [first_spell] [nvarchar](200) NULL,
    [full_spell] [nvarchar](200) NULL,
    [item_code] [nvarchar](50) NULL,
    [item_name] [nvarchar](200) NULL,
    [sort] [int] NULL,
    [update_time] [datetime] NULL,
    PRIMARY KEY CLUSTERED
(
[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
    ) ON [PRIMARY]
    GO
/****** Object:  Table [dbo].[kb_category_item_type]    Script Date: 2021/5/25 9:53:34 ******/
    SET ANSI_NULLS ON
    GO
    SET QUOTED_IDENTIFIER ON
    GO
CREATE TABLE [dbo].[kb_category_item_type](
    [id] [varchar](255) NOT NULL,
    [create_time] [datetime] NULL,
    [creator] [nvarchar](50) NULL,
    [deleted] [bit] NULL,
    [description] [nvarchar](200) NULL,
    [first_spell] [nvarchar](200) NULL,
    [full_spell] [nvarchar](200) NULL,
    [parent_id] [varchar](50) NULL,
    [sort] [int] NULL,
    [type_code] [varchar](50) NULL,
    [type_name] [nvarchar](200) NULL,
    [update_time] [datetime] NULL,
    PRIMARY KEY CLUSTERED
(
[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
    ) ON [PRIMARY]
    GO
/****** Object:  Table [dbo].[kb_category_item_type_map]    Script Date: 2021/5/25 9:53:34 ******/
    SET ANSI_NULLS ON
    GO
    SET QUOTED_IDENTIFIER ON
    GO
CREATE TABLE [dbo].[kb_category_item_type_map](
    [id] [varchar](255) NOT NULL,
    [create_time] [datetime] NULL,
    [creator] [nvarchar](50) NULL,
    [deleted] [bit] NULL,
    [item_id] [varchar](255) NULL,
    [type_id] [varchar](255) NULL,
    [type_parent_id] [varchar](255) NULL,
    [update_time] [datetime] NULL,
    PRIMARY KEY CLUSTERED
(
[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
    ) ON [PRIMARY]
    GO
/****** Object:  Table [dbo].[kb_drug_hosp_map]    Script Date: 2021/5/25 9:53:34 ******/
    SET ANSI_NULLS ON
    GO
    SET QUOTED_IDENTIFIER ON
    GO
CREATE TABLE [dbo].[kb_drug_hosp_map](
    [id] [varchar](50) NULL,
    [drug_item_id] [varchar](50) NULL,
    [hosp_drug_id] [varchar](50) NULL
    ) ON [PRIMARY]
    GO
/****** Object:  Table [dbo].[kb_drug_item]    Script Date: 2021/5/25 9:53:34 ******/
    SET ANSI_NULLS ON
    GO
    SET QUOTED_IDENTIFIER ON
    GO
CREATE TABLE [dbo].[kb_drug_item](
    [id] [varchar](50) NOT NULL,
    [med_item_id] [varchar](50) NOT NULL,
    [name] [nvarchar](200) NULL,
    [unit] [nvarchar](50) NULL,
    [name_common] [nvarchar](200) NULL,
    [name_en] [nvarchar](200) NULL,
    [hxmc] [nvarchar](200) NULL,
    [zycf] [nvarchar](200) NULL,
    [xz] [nvarchar](max) NULL,
    [yldl] [nvarchar](max) NULL,
    [yddlx] [nvarchar](max) NULL,
    [syz] [nvarchar](max) NULL,
    [yfyl] [nvarchar](max) NULL,
    [blfy] [nvarchar](max) NULL,
    [jjz] [nvarchar](max) NULL,
    [zysx] [nvarchar](max) NULL,
    [yfyy] [nvarchar](max) NULL,
    [etyy] [nvarchar](max) NULL,
    [lnryy] [nvarchar](max) NULL,
    [xhzy] [nvarchar](max) NULL,
    [ywgl] [nvarchar](max) NULL,
    [ywgg] [nvarchar](max) NULL,
    [cctj] [nvarchar](max) NULL,
    [ydts] [nvarchar](max) NULL,
    [pzwh] [nvarchar](200) NULL,
    [is_deleted] [bit] NULL,
    CONSTRAINT [PK_kb_drug_sda] PRIMARY KEY CLUSTERED
(
[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
    ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
    GO
/****** Object:  Table [dbo].[kb_med_category]    Script Date: 2021/5/25 9:53:34 ******/
    SET ANSI_NULLS ON
    GO
    SET QUOTED_IDENTIFIER ON
    GO
CREATE TABLE [dbo].[kb_med_category](
    [id] [varchar](50) NOT NULL,
    [parent_id] [varchar](50) NULL,
    [name] [nvarchar](200) NULL,
    [creator] [nvarchar](50) NULL,
    [create_time] [datetime] NULL,
    [update_time] [datetime] NULL,
    [is_deleted] [bit] NULL,
    CONSTRAINT [PK_kb_drug_category] PRIMARY KEY CLUSTERED
(
[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
    ) ON [PRIMARY]
    GO
/****** Object:  Table [dbo].[kb_med_category_item_rel]    Script Date: 2021/5/25 9:53:34 ******/
    SET ANSI_NULLS ON
    GO
    SET QUOTED_IDENTIFIER ON
    GO
CREATE TABLE [dbo].[kb_med_category_item_rel](
    [id] [varchar](50) NULL,
    [med_category_id] [varchar](50) NULL,
    [med_item_id] [varchar](50) NULL,
    [creator] [nvarchar](50) NULL,
    [create_time] [datetime] NULL,
    [update_time] [datetime] NULL,
    [is_deleted] [bit] NULL
    ) ON [PRIMARY]
    GO
/****** Object:  Table [dbo].[kb_med_item]    Script Date: 2021/5/25 9:53:34 ******/
    SET ANSI_NULLS ON
    GO
    SET QUOTED_IDENTIFIER ON
    GO
CREATE TABLE [dbo].[kb_med_item](
    [id] [varchar](50) NOT NULL,
    [name] [nvarchar](max) NULL,
    [zxybs] [varchar](4) NULL,
    [ff] [varchar](4) NULL,
    [creator] [nvarchar](50) NULL,
    [create_time] [datetime] NULL,
    [update_time] [datetime] NULL,
    [is_deleted] [bit] NULL,
    CONSTRAINT [PK_kb_drug] PRIMARY KEY CLUSTERED
(
[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
    ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
    GO
/****** Object:  Table [dbo].[kb_med_name]    Script Date: 2021/5/25 9:53:34 ******/
    SET ANSI_NULLS ON
    GO
    SET QUOTED_IDENTIFIER ON
    GO
CREATE TABLE [dbo].[kb_med_name](
    [id] [varchar](50) NULL,
    [med_item_id] [varchar](50) NULL,
    [med_item_name] [nvarchar](max) NULL,
    [create_time] [datetime] NULL,
    [creator] [nvarchar](50) NULL,
    [is_deleted] [bit] NULL,
    [update_time] [datetime] NULL
    ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
    GO
/****** Object:  Table [dbo].[msg_board]    Script Date: 2021/5/25 9:53:34 ******/
    SET ANSI_NULLS ON
    GO
    SET QUOTED_IDENTIFIER ON
    GO
CREATE TABLE [dbo].[msg_board](
    [id] [int] IDENTITY(1,1) NOT NULL,
    [been_read] [bit] NULL,
    [client_id] [nvarchar](50) NULL,
    [creation_time] [datetime] NULL,
    [creation_user] [nvarchar](50) NULL,
    [msg] [nvarchar](1000) NULL,
    [msg_id] [nvarchar](50) NULL,
    [msg_type] [nvarchar](50) NULL,
    [parent_msg_id] [nvarchar](50) NULL,
    PRIMARY KEY CLUSTERED
(
[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
    ) ON [PRIMARY]
    GO
/****** Object:  Table [dbo].[study_event]    Script Date: 2021/5/25 9:53:34 ******/
    SET ANSI_NULLS ON
    GO
    SET QUOTED_IDENTIFIER ON
    GO
CREATE TABLE [dbo].[study_event](
    [id] [varchar](255) NOT NULL,
    [event_relation] [varchar](100) NULL,
    [event_relation_days] [int] NULL,
    [event_relation_times] [int] NULL,
    [main_event_filter] [varchar](max) NULL,
    [main_event_view] [int] NULL,
    [memo] [varchar](200) NULL,
    [secondary_event_filter] [varchar](max) NULL,
    [secondary_event_view] [int] NULL,
    [sql_text] [varchar](1500) NULL,
    [study_code] [varchar](100) NULL,
    PRIMARY KEY CLUSTERED
(
[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
    ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
    GO
/****** Object:  Table [dbo].[study_info]    Script Date: 2021/5/25 9:53:34 ******/
    SET ANSI_NULLS ON
    GO
    SET QUOTED_IDENTIFIER ON
    GO
CREATE TABLE [dbo].[study_info](
    [code] [varchar](255) NOT NULL,
    [sponsor_id] [varchar](50) NULL,
    [sponsor] [varchar](100) NULL,
    [principal_investigator] [varchar](100) NULL,
    [research_department] [varchar](100) NULL,
    [creation_time] [datetime] NULL,
    [update_time] [datetime] NULL,
    [study_name] [nvarchar](100) NULL,
    [event_config] [nvarchar](max) NULL,
    [memo] [nvarchar](200) NULL,
    [data] [varchar](100) NULL,
    [sequence] [varchar](100) NULL,
    [spell_code] [varchar](100) NULL,
    [study_code_manual] [nvarchar](50) NULL,
    [valid] [varchar](100) NULL,
    [wbzx_code] [varchar](100) NULL,
    [creator] [nvarchar](50) NULL,
    [deleted] [bit] NULL,
    [update_user] [nvarchar](50) NULL,
    [delete_reason] [nvarchar](200) NULL,
    [delete_time] [datetime] NULL,
    [delete_user] [nvarchar](50) NULL,
    [expect_join_end_date] [date] NULL,
    [indication] [nvarchar](200) NULL,
    [recruit_start_dttm] [datetime] NULL,
    CONSTRAINT [PK__study_in__357D4CF816C02690] PRIMARY KEY CLUSTERED
(
[code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
    ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
    GO
/****** Object:  Table [dbo].[study_quality_control]    Script Date: 2021/5/25 9:53:34 ******/
    SET ANSI_NULLS ON
    GO
    SET QUOTED_IDENTIFIER ON
    GO
CREATE TABLE [dbo].[study_quality_control](
    [id] [varchar](100) NOT NULL,
    [action] [varchar](100) NULL,
    [category] [varchar](100) NULL,
    [create_dt] [datetime] NULL,
    [description] [varchar](500) NULL,
    [enabled] [int] NULL,
    [name] [varchar](100) NULL,
    [rule_json] [varchar](max) NULL,
    [study_code] [varchar](100) NULL,
    [var_json] [varchar](max) NULL,
    [code] [varchar](100) NULL,
    [creation_time] [datetime] NULL,
    [quality_control_desc] [varchar](500) NULL,
    [quality_control_rule] [varchar](max) NULL,
    [quality_control_source] [varchar](max) NULL,
    [update_time] [datetime] NULL,
    [sql_text] [varchar](max) NULL,
    PRIMARY KEY CLUSTERED
(
[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
    ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
    GO
/****** Object:  Table [dbo].[study_quality_control_log]    Script Date: 2021/5/25 9:53:34 ******/
    SET ANSI_NULLS ON
    GO
    SET QUOTED_IDENTIFIER ON
    GO
CREATE TABLE [dbo].[study_quality_control_log](
    [id] [varchar](100) NOT NULL,
    [exec_dt] [datetime] NULL,
    [quality_control_id] [varchar](100) NULL,
    [result_message] [varchar](max) NULL,
    [result_status] [int] NULL,
    [sql_text] [varchar](max) NULL,
    [study_code] [varchar](100) NULL,
    PRIMARY KEY CLUSTERED
(
[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
    ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
    GO
/****** Object:  Table [dbo].[study_quality_control_med]    Script Date: 2021/5/25 9:53:34 ******/
    SET ANSI_NULLS ON
    GO
    SET QUOTED_IDENTIFIER ON
    GO
CREATE TABLE [dbo].[study_quality_control_med](
    [id] [varchar](50) NOT NULL,
    [kb_med_item_id] [varchar](50) NULL,
    [study_code] [varchar](100) NULL,
    PRIMARY KEY CLUSTERED
(
[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
    ) ON [PRIMARY]
    GO
/****** Object:  Table [dbo].[study_quality_control_med_log]    Script Date: 2021/5/25 9:53:34 ******/
    SET ANSI_NULLS ON
    GO
    SET QUOTED_IDENTIFIER ON
    GO
CREATE TABLE [dbo].[study_quality_control_med_log](
    [id] [varchar](50) NOT NULL,
    [study_code] [varchar](100) NOT NULL,
    [empi] [varchar](50) NOT NULL,
    [screening_no] [nvarchar](100) NOT NULL,
    [hosp_drug_id] [varchar](100) NOT NULL,
    [hosp_drug_name] [nvarchar](100) NOT NULL,
    [log_time] [datetime2](7) NOT NULL,
    CONSTRAINT [PK_study_quality_control_med_log] PRIMARY KEY CLUSTERED
(
[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
    ) ON [PRIMARY]
    GO
/****** Object:  Table [dbo].[study_quality_control_subject]    Script Date: 2021/5/25 9:53:34 ******/
    SET ANSI_NULLS ON
    GO
    SET QUOTED_IDENTIFIER ON
    GO
CREATE TABLE [dbo].[study_quality_control_subject](
    [empi] [varchar](100) NOT NULL,
    [quality_control_id] [varchar](100) NOT NULL,
    [study_code] [varchar](100) NOT NULL,
    [confirmed] [int] NULL,
    [update_date] [datetime] NULL,
    [confirmed_result] [int] NULL,
    PRIMARY KEY CLUSTERED
(
    [empi] ASC,
    [quality_control_id] ASC,
[study_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
    ) ON [PRIMARY]
    GO
/****** Object:  Table [dbo].[study_rule]    Script Date: 2021/5/25 9:53:34 ******/
    SET ANSI_NULLS ON
    GO
    SET QUOTED_IDENTIFIER ON
    GO
CREATE TABLE [dbo].[study_rule](
    [id] [varchar](255) NOT NULL,
    [content] [varchar](max) NULL,
    [memo] [varchar](500) NULL,
    [seq] [int] NULL,
    [sql_txt] [varchar](max) NULL,
    [study_code] [varchar](100) NULL,
    [type] [int] NULL,
    [sql_txt_possible] [varchar](max) NULL,
    [last_refresh_time] [datetime] NULL,
    [is_running_refresh] [bit] NULL,
    [event_config] [varchar](max) NULL,
    [event_filters] [varchar](max) NULL,
    CONSTRAINT [PK__study_ru__3213E83F2051847D] PRIMARY KEY CLUSTERED
(
[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
    ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
    GO
/****** Object:  Table [dbo].[study_rule_subject]    Script Date: 2021/5/25 9:53:34 ******/
    SET ANSI_NULLS ON
    GO
    SET QUOTED_IDENTIFIER ON
    GO
CREATE TABLE [dbo].[study_rule_subject](
    [rule_id] [nvarchar](255) NOT NULL,
    [empi] [nvarchar](100) NOT NULL,
    [type] [int] NULL,
    CONSTRAINT [PK_study_rule_subject] PRIMARY KEY CLUSTERED
(
    [rule_id] ASC,
[empi] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
    ) ON [PRIMARY]
    GO
/****** Object:  Table [dbo].[study_subject]    Script Date: 2021/5/25 9:53:34 ******/
    SET ANSI_NULLS ON
    GO
    SET QUOTED_IDENTIFIER ON
    GO
CREATE TABLE [dbo].[study_subject](
    [code] [nvarchar](50) NOT NULL,
    [empi] [nvarchar](50) NOT NULL,
    [type] [int] NULL,
    CONSTRAINT [PK_study_subject] PRIMARY KEY CLUSTERED
(
    [code] ASC,
[empi] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
    ) ON [PRIMARY]
    GO
/****** Object:  Table [dbo].[subject_excluded]    Script Date: 2021/5/25 9:53:34 ******/
    SET ANSI_NULLS ON
    GO
    SET QUOTED_IDENTIFIER ON
    GO
CREATE TABLE [dbo].[subject_excluded](
    [empi] [varchar](100) NOT NULL,
    [study_code] [varchar](100) NOT NULL,
    [exclude_reason] [nvarchar](max) NULL,
    PRIMARY KEY CLUSTERED
(
    [empi] ASC,
[study_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
    ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
    GO
/****** Object:  Table [dbo].[subject_info]    Script Date: 2021/5/25 9:53:34 ******/
    SET ANSI_NULLS ON
    GO
    SET QUOTED_IDENTIFIER ON
    GO
CREATE TABLE [dbo].[subject_info](
    [empi] [varchar](100) NOT NULL,
    [study_code] [varchar](100) NOT NULL,
    [join_date] [datetime] NULL,
    [screening_no] [varchar](100) NULL,
    [screening_date] [datetime] NULL,
    [screening_end_date] [datetime] NULL,
    [educated_youth_date] [datetime] NULL,
    [join_end_date] [datetime] NULL,
    [join_status] [varchar](20) NULL,
    [follow_up_end_date] [datetime] NULL,
    [medication_observation_end_date] [datetime] NULL,
    PRIMARY KEY CLUSTERED
(
    [empi] ASC,
[study_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
    ) ON [PRIMARY]
    GO
/****** Object:  Table [dbo].[sys_config]    Script Date: 2021/5/25 9:53:34 ******/
    SET ANSI_NULLS ON
    GO
    SET QUOTED_IDENTIFIER ON
    GO
CREATE TABLE [dbo].[sys_config](
    [name] [nvarchar](100) NOT NULL,
    [value] [nvarchar](max) NULL,
    [description] [nvarchar](200) NULL,
    CONSTRAINT [PK_sys_config] PRIMARY KEY CLUSTERED
(
[name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
    ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
    GO
/****** Object:  Table [dbo].[sys_dic]    Script Date: 2021/5/25 9:53:34 ******/
    SET ANSI_NULLS ON
    GO
    SET QUOTED_IDENTIFIER ON
    GO
CREATE TABLE [dbo].[sys_dic](
    [id] [int] IDENTITY(1,1) NOT NULL,
    [creation_time] [datetime] NULL,
    [deleted] [bit] NULL,
    [dic_category] [nvarchar](50) NULL,
    [dic_name] [nvarchar](50) NULL,
    [dic_value] [nvarchar](100) NULL,
    [remark] [nvarchar](200) NULL,
    [sort_seq] [int] NULL,
    [state] [int] NULL,
    [update_time] [datetime] NULL,
    PRIMARY KEY CLUSTERED
(
[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
    ) ON [PRIMARY]
    GO
/****** Object:  Table [dbo].[sys_log]    Script Date: 2021/5/25 9:53:34 ******/
    SET ANSI_NULLS ON
    GO
    SET QUOTED_IDENTIFIER ON
    GO
CREATE TABLE [dbo].[sys_log](
    [id] [varchar](50) NOT NULL,
    [session_id] [varchar](50) NULL,
    [operation_date] [datetime] NULL,
    [operation_user] [varchar](50) NULL,
    [post_data] [varchar](1500) NULL,
    [query_string] [varchar](1500) NULL,
    [uri] [varchar](200) NULL,
    [study_code] [varchar](100) NULL,
    [screening_no] [varchar](100) NULL,
    CONSTRAINT [PK__sys_log__3213E83F3BDED83B] PRIMARY KEY CLUSTERED
(
[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
    ) ON [PRIMARY]
    GO
/****** Object:  Table [dbo].[sys_menu]    Script Date: 2021/5/25 9:53:34 ******/
    SET ANSI_NULLS ON
    GO
    SET QUOTED_IDENTIFIER ON
    GO
CREATE TABLE [dbo].[sys_menu](
    [id] [varchar](255) NOT NULL,
    [code] [varchar](50) NOT NULL,
    [create_time] [datetime] NULL,
    [creator] [nvarchar](50) NULL,
    [deleted] [bit] NULL,
    [icon] [nvarchar](50) NULL,
    [name] [nvarchar](50) NOT NULL,
    [open_type] [nvarchar](50) NOT NULL,
    [parent_id] [nvarchar](50) NULL,
    [sort] [int] NOT NULL,
    [target_url] [nvarchar](200) NULL,
    [update_time] [datetime] NULL,
    [update_user] [nvarchar](50) NULL,
    PRIMARY KEY CLUSTERED
(
[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
    ) ON [PRIMARY]
    GO
/****** Object:  Table [dbo].[sys_permission]    Script Date: 2021/5/25 9:53:34 ******/
    SET ANSI_NULLS ON
    GO
    SET QUOTED_IDENTIFIER ON
    GO
CREATE TABLE [dbo].[sys_permission](
    [id] [varchar](50) NOT NULL,
    [permission_order] [int] NULL,
    [permission_type] [int] NULL,
    [permission_name] [nvarchar](50) NULL,
    [permission_config] [nvarchar](max) NULL,
    [description] [nvarchar](200) NULL,
    [is_deleted] [int] NULL,
    CONSTRAINT [PK_sys_permission] PRIMARY KEY CLUSTERED
(
[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
    ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
    GO
/****** Object:  Table [dbo].[sys_role]    Script Date: 2021/5/25 9:53:34 ******/
    SET ANSI_NULLS ON
    GO
    SET QUOTED_IDENTIFIER ON
    GO
CREATE TABLE [dbo].[sys_role](
    [id] [varchar](50) NOT NULL,
    [role_name] [varchar](50) NULL,
    [description] [nvarchar](200) NULL,
    [is_deleted] [int] NULL,
    CONSTRAINT [PK__sys_role__3213E83F9FEEE0BD] PRIMARY KEY CLUSTERED
(
[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
    ) ON [PRIMARY]
    GO
/****** Object:  Table [dbo].[sys_role_permission]    Script Date: 2021/5/25 9:53:34 ******/
    SET ANSI_NULLS ON
    GO
    SET QUOTED_IDENTIFIER ON
    GO
CREATE TABLE [dbo].[sys_role_permission](
    [id] [varchar](50) NOT NULL,
    [role_id] [varchar](50) NULL,
    [permission_id] [varchar](50) NULL,
    [permission_config] [int] NULL,
    CONSTRAINT [PK_sys_role_permission] PRIMARY KEY CLUSTERED
(
[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
    ) ON [PRIMARY]
    GO
/****** Object:  Table [dbo].[sys_state]    Script Date: 2021/5/25 9:53:34 ******/
    SET ANSI_NULLS ON
    GO
    SET QUOTED_IDENTIFIER ON
    GO
CREATE TABLE [dbo].[sys_state](
    [id] [varchar](50) NOT NULL,
    [state_flow_id] [varchar](50) NOT NULL,
    [code] [nvarchar](50) NOT NULL,
    [name] [nvarchar](100) NOT NULL,
    [start_flag] [int] NOT NULL,
    [control_flag] [varchar](20) NOT NULL,
    CONSTRAINT [PK_SYS_STATE] PRIMARY KEY CLUSTERED
(
[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
    ) ON [PRIMARY]
    GO
/****** Object:  Table [dbo].[sys_state_flow]    Script Date: 2021/5/25 9:53:34 ******/
    SET ANSI_NULLS ON
    GO
    SET QUOTED_IDENTIFIER ON
    GO
CREATE TABLE [dbo].[sys_state_flow](
    [id] [varchar](50) NOT NULL,
    [name] [nvarchar](50) NOT NULL,
    CONSTRAINT [PK_SYS_STATE_FLOW] PRIMARY KEY CLUSTERED
(
[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
    ) ON [PRIMARY]
    GO
/****** Object:  Table [dbo].[sys_state_machine]    Script Date: 2021/5/25 9:53:34 ******/
    SET ANSI_NULLS ON
    GO
    SET QUOTED_IDENTIFIER ON
    GO
CREATE TABLE [dbo].[sys_state_machine](
    [id] [varchar](50) NOT NULL,
    [state_flow_id] [varchar](50) NOT NULL,
    [name] [nvarchar](50) NOT NULL,
    [current_status] [varchar](50) NOT NULL,
    [oper] [varchar](50) NOT NULL,
    [next_status] [varchar](50) NOT NULL,
    [control_flag] [varchar](50) NOT NULL,
    CONSTRAINT [PK_SYS_STATE_MACHINE] PRIMARY KEY CLUSTERED
(
[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
    ) ON [PRIMARY]
    GO
/****** Object:  Table [dbo].[sys_state_oper]    Script Date: 2021/5/25 9:53:34 ******/
    SET ANSI_NULLS ON
    GO
    SET QUOTED_IDENTIFIER ON
    GO
CREATE TABLE [dbo].[sys_state_oper](
    [id] [varchar](50) NOT NULL,
    [state_flow_id] [varchar](50) NOT NULL,
    [code] [varchar](50) NOT NULL,
    [name] [nvarchar](50) NOT NULL,
    CONSTRAINT [PK_SYS_STATE_OPER] PRIMARY KEY CLUSTERED
(
[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
    ) ON [PRIMARY]
    GO
/****** Object:  Table [dbo].[sys_user]    Script Date: 2021/5/25 9:53:34 ******/
    SET ANSI_NULLS ON
    GO
    SET QUOTED_IDENTIFIER ON
    GO
CREATE TABLE [dbo].[sys_user](
    [id] [varchar](50) NOT NULL,
    [user_name] [varchar](50) NULL,
    [password] [varchar](200) NULL,
    [p_name] [nvarchar](50) NULL,
    [mobile_phone] [varchar](20) NULL,
    [email] [varchar](50) NULL,
    [is_deleted] [int] NULL,
    [sponsor] [nvarchar](100) NULL,
    CONSTRAINT [PK__sys_user__3213E83FC0FCC0FE] PRIMARY KEY CLUSTERED
(
[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
    ) ON [PRIMARY]
    GO
/****** Object:  Table [dbo].[sys_user_role]    Script Date: 2021/5/25 9:53:34 ******/
    SET ANSI_NULLS ON
    GO
    SET QUOTED_IDENTIFIER ON
    GO
CREATE TABLE [dbo].[sys_user_role](
    [id] [varchar](50) NOT NULL,
    [user_id] [varchar](50) NULL,
    [role_id] [varchar](50) NULL,
    CONSTRAINT [PK_sys_user_role] PRIMARY KEY CLUSTERED
(
[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
    ) ON [PRIMARY]
    GO
/****** Object:  Table [dbo].[sys_user_study]    Script Date: 2021/5/25 9:53:34 ******/
    SET ANSI_NULLS ON
    GO
    SET QUOTED_IDENTIFIER ON
    GO
CREATE TABLE [dbo].[sys_user_study](
    [id] [varchar](50) NOT NULL,
    [user_id] [varchar](50) NULL,
    [study_id] [varchar](50) NULL,
    CONSTRAINT [PK_sys_user_study] PRIMARY KEY CLUSTERED
(
[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
    ) ON [PRIMARY]
    GO
/****** Object:  Table [dbo].[tm_entity]    Script Date: 2021/5/25 9:53:34 ******/
    SET ANSI_NULLS ON
    GO
    SET QUOTED_IDENTIFIER ON
    GO
CREATE TABLE [dbo].[tm_entity](
    [id] [int] IDENTITY(1,1) NOT NULL,
    [entity_name] [nvarchar](500) NULL,
    [EName] [nvarchar](50) NULL,
    [semantic_tag_id] [nvarchar](50) NULL,
    [semantic_tag_name] [nvarchar](100) NULL,
    [is_del] [int] NULL,
    [update_time] [datetime] NULL,
    [create_time] [datetime] NULL,
    [remark] [nvarchar](50) NULL,
    CONSTRAINT [PK_tm_entity] PRIMARY KEY CLUSTERED
(
[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
    ) ON [PRIMARY]
    GO
/****** Object:  Table [dbo].[检查字典表]    Script Date: 2021/5/25 9:53:34 ******/
    SET ANSI_NULLS ON
    GO
    SET QUOTED_IDENTIFIER ON
    GO
CREATE TABLE [dbo].[检查字典表](
    [大类] [nvarchar](100) NULL,
    [小类] [nvarchar](100) NULL,
    [项目] [nvarchar](100) NULL,
    [标准编码] [nvarchar](100) NULL,
    [拼音码] [nvarchar](100) NULL,
    [五笔码] [nvarchar](100) NULL
    ) ON [PRIMARY]
    GO
/****** Object:  View [dbo].[v_hosp_drug]    Script Date: 2021/5/25 9:53:34 ******/
    SET ANSI_NULLS ON
    GO
    SET QUOTED_IDENTIFIER ON
    GO


CREATE VIEW [dbo].[v_hosp_drug]
AS
SELECT  [DRUG_CODE] AS id ,
    [DRUG_NAME] AS name,
    [DRUG_SPEC] AS spec,
    [UNITS] AS unit
    --[DRUG_FORM] ,
    --[TOXI_PROPERTY] ,
    --[DOSE_PER_UNIT] ,
    --[DOSE_UNITS] ,
    --[DRUG_INDICATOR] ,
    --[INPUT_CODE] ,
    --[ADMINISTRATION] ,
    --[FREQUENCY] ,
    --[NOTES] ,
    --[PER_AMOUNT] ,
    --[MEMOS] ,
    --[ALLERGEN_CODE] ,
    --[SKIN_TEST] ,
    --[FALL] ,
    --[DANGEROUS] ,
    --[SIMILAR] ,
    --[EXCLUDE_INDICATOR] ,
    --[DISPEN_METHOD] ,
    --[LIMIT_DRUG] ,
    --[LIMIT_DRUG_MEMO] ,
    --[ANTIBIOTIC_LEVEL] ,
    --[ANAESTHESIA_INDICATOR] ,
    --[PSYCHOTROPIC_INDICATOR] ,
    --[CHEMICAL_NAME] ,
    --[BASE_CLASS_NAME] ,
    --[DRUG_PRODUCT_NAME] ,
    --[SKIN_TEST_RESULT] ,
    --[DRUG_REFRIGERATED_FLAG] ,
    --[EASY_MAKE_TOXIC_DRUG_FLAG] ,
    --[OTC_FLAG] ,
    --[GMP_FLAG] ,
    --[COMPOUND_FLAG] ,
    --[ANTIBAC_INDEX] ,
    --[NEW_DRUG_FLAG] ,
    --[ANALEPTIC_DRUG_FLAG] ,
    --[SUM_RECEIVE_FLAG] ,
    --[TUMOUR_DRUG_FLAG] ,
    --[INSULIN_FLAG] ,
    --[ALLERGY_TEST_DRUG_FLAG] ,
    --[PRECIOUS_DRUG_FLAG] ,
    --[INHOSP_PREPARATION_FLAG] ,
    --[OUTSIDE_HOSPITAL_DRUG] ,
    --[BASE_DIR_FLAG] ,
    --[PRIORITY_MONITOR_DRUG] ,
    --[NANEGOTION_DRUG_FLAG] ,
    --[MEDICARE_FLAG] ,
    --[TUMOUR_DRUG_LEVEL] ,
    --[PRINT_FORM] ,
    --[TARGETED_DRUG_FLAG] ,
    --[CREATE_DATE] ,
    --[DRUG_CATEG_CODE]
FROM    CQZL.dbo.dict_drug;
GO
/****** Object:  View [dbo].[v_hosp_icd]    Script Date: 2021/5/25 9:53:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[v_hosp_icd]
as
select id='id1',code='code1',name='name1',feed_app_code='weining',feed_app_name='卫宁',hos_code='01'
union all
select id='id2',code='code2',name='name2',feed_app_code='weining',feed_app_name='卫宁',hos_code='01'
union all
select id='id3',code='code3',name='name3',feed_app_code='weining',feed_app_name='卫宁',hos_code='01'
union all
select id='id4',code='code4',name='name4',feed_app_code='weining',feed_app_name='卫宁',hos_code='01'
union all
select id='id5',code='code5',name='name5',feed_app_code='fuyou',feed_app_name='妇幼',hos_code='01'
    GO
/****** Object:  View [dbo].[v_report_hj]    Script Date: 2021/5/25 9:53:34 ******/
SET ANSI_NULLS ON
    GO
    SET QUOTED_IDENTIFIER ON
    GO










CREATE VIEW [dbo].[v_report_hj]
AS

SELECT  [t1].[id] ,
    [t1].[study_id] ,
    [t3].[NAME] AS [study_name] ,
    [t1].[subject_id] ,
    t1.oper,
    [t1].[oper_user] ,
    [t4].[p_name] AS [oper_person] ,
    [t1].[oper_time] ,
    oper + '了' + ( CASE WHEN t2.screening_no IS NOT NULL
    AND t2.screening_no <> ''
    THEN '受试者' + t2.screening_no + '的'
    ELSE ''
    END ) + t1.module
    + ( CASE WHEN t1.oper_desc IS NOT NULL
    AND t1.oper_desc <> '' THEN '，' + t1.oper_desc
    ELSE ''
    END ) AS oper_desc
FROM    [eGCP].[dbo].[check_mark] t1
    LEFT JOIN [eGCP].[dbo].[subject_info] t2 ON t2.empi = t1.subject_id
    LEFT JOIN [CQZL].[dbo].[gcp_group_dict] t3 ON t3.CODE = t1.study_id
    LEFT JOIN [eGCP].[dbo].[sys_user] t4 ON t4.user_name = t1.oper_user;





GO
/****** Object:  View [dbo].[v_report_study_monthly]    Script Date: 2021/5/25 9:53:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[v_report_study_monthly] as
    with monthly as
    (
    select convert(nvarchar(7),getdate(),121) as currmonth,convert(nvarchar(7),dateadd(month,1,getdate()),121) as nextmonth
    union all
    select convert(nvarchar(7),dateadd(month,-1,getdate()),121) as currmonth,convert(nvarchar(7),dateadd(month,0,getdate()),121) as nextmonth
    union all
    select convert(nvarchar(7),dateadd(month,-2,getdate()),121) as currmonth,convert(nvarchar(7),dateadd(month,-1,getdate()),121) as nextmonth
    union all
    select convert(nvarchar(7),dateadd(month,-3,getdate()),121) as currmonth,convert(nvarchar(7),dateadd(month,-2,getdate()),121) as nextmonth
    union all
    select convert(nvarchar(7),dateadd(month,-4,getdate()),121) as currmonth,convert(nvarchar(7),dateadd(month,-3,getdate()),121) as nextmonth
    union all
    select convert(nvarchar(7),dateadd(month,-5,getdate()),121) as currmonth,convert(nvarchar(7),dateadd(month,-4,getdate()),121) as nextmonth
    union all
    select convert(nvarchar(7),dateadd(month,-6,getdate()),121) as currmonth,convert(nvarchar(7),dateadd(month,-5,getdate()),121) as nextmonth
    union all
    select convert(nvarchar(7),dateadd(month,-7,getdate()),121) as currmonth,convert(nvarchar(7),dateadd(month,-6,getdate()),121) as nextmonth
    union all
    select convert(nvarchar(7),dateadd(month,-8,getdate()),121) as currmonth,convert(nvarchar(7),dateadd(month,-7,getdate()),121) as nextmonth
    union all
    select convert(nvarchar(7),dateadd(month,-9,getdate()),121) as currmonth,convert(nvarchar(7),dateadd(month,-8,getdate()),121) as nextmonth
    union all
    select convert(nvarchar(7),dateadd(month,-10,getdate()),121) as currmonth,convert(nvarchar(7),dateadd(month,-9,getdate()),121) as nextmonth
    union all
    select convert(nvarchar(7),dateadd(month,-11,getdate()),121) as currmonth,convert(nvarchar(7),dateadd(month,-10,getdate()),121) as nextmonth
)
SELECT monthly.currmonth,count(distinct study.code) as studycount,count(distinct study_inc.code) as studyinccount
FROM monthly
         left join [dbo].[study_info] study on study.creation_time <monthly.nextmonth+'-01'
    left join [dbo].[study_info] study_inc on study_inc.creation_time>=monthly.currmonth+'-01' and study_inc.creation_time <monthly.nextmonth+'-01'
group by monthly.currmonth
    GO
SET ANSI_PADDING ON
    GO
/****** Object:  Index [IX_dcm_proc_state]    Script Date: 2021/5/25 9:53:34 ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_dcm_proc_state] ON [dbo].[dcm_proc_state]
(
	[patient_id] ASC,
	[pacs_no] ASC,
	[study_id] ASC,
	[screening_no] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_dcm_proc_state_1]    Script Date: 2021/5/25 9:53:34 ******/
CREATE NONCLUSTERED INDEX [IX_dcm_proc_state_1] ON [dbo].[dcm_proc_state]
(
	[state] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_sponsor_enterprise_id]    Script Date: 2021/5/25 9:53:34 ******/
CREATE NONCLUSTERED INDEX [idx_sponsor_enterprise_id] ON [dbo].[dic_sponsor]
(
	[master_data_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_sponsor_tenant_id]    Script Date: 2021/5/25 9:53:34 ******/
CREATE NONCLUSTERED INDEX [idx_sponsor_tenant_id] ON [dbo].[dic_sponsor]
(
	[tenant_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_kb_drug_hosp_map_hospid]    Script Date: 2021/5/25 9:53:34 ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_kb_drug_hosp_map_hospid] ON [dbo].[kb_drug_hosp_map]
(
	[hosp_drug_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_kb_drug_hosp_map_itemid]    Script Date: 2021/5/25 9:53:34 ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_kb_drug_hosp_map_itemid] ON [dbo].[kb_drug_hosp_map]
(
	[drug_item_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_study_quality_control_med_log]    Script Date: 2021/5/25 9:53:34 ******/
CREATE NONCLUSTERED INDEX [IX_study_quality_control_med_log] ON [dbo].[study_quality_control_med_log]
(
	[study_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dcm_proc_state] ADD  DEFAULT ((0)) FOR [state]
    GO
ALTER TABLE [dbo].[dcm_proc_state] ADD  DEFAULT (getdate()) FOR [insert_dttm]
    GO
ALTER TABLE [dbo].[study_quality_control_subject] ADD  DEFAULT ((0)) FOR [confirmed_result]
    GO
ALTER TABLE [dbo].[sys_state_flow] ADD  DEFAULT (newid()) FOR [id]
    GO
ALTER TABLE [dbo].[sys_state_oper] ADD  DEFAULT (newid()) FOR [id]
    GO
/****** Object:  StoredProcedure [dbo].[PageEntity]    Script Date: 2021/5/25 9:53:34 ******/
    SET ANSI_NULLS ON
    GO
    SET QUOTED_IDENTIFIER ON
    GO
CREATE proc [dbo].[PageEntity]
	--@Tables nvarchar(512), --表名,多张表是请使用 tA a inner join tB b On a.AID = b.AID
	--@PK nvarchar(128)='',    --主键，可以带表头 a.AID
	@Sort nvarchar(512) = 'id', --排序字段
	@PageIndex int = 1,    --开始页码
	@PageSize int = 10,        --页大小
	@Fields nvarchar(1024) = '*',--读取字段
	@Where nvarchar(1024) = NULL,--Where条件
	@RecordCount int output --返回总条数
AS

DECLARE @strFilter nvarchar(4000)
declare @sql nvarchar(4000)
IF @Where IS NOT NULL AND @Where != ''
BEGIN
   SET @strFilter = ' WHERE ' + @Where + ' '
END
ELSE
BEGIN
   SET @strFilter = ''
END


IF @PageIndex < 1
  SET @PageIndex = 1

if @PageIndex = 1 --第一页提高性能
begin
  set @sql = 'select top ' + str(@PageSize) +' '+@Fields+ '  from eGCP.[dbo].[tm_entity](nolock) '  + @strFilter + ' ORDER BY  '+ @Sort
  print @sql
end
else
begin
	DECLARE @START_ID varchar(50)	--页开始索引
	DECLARE @END_ID varchar(50)		--页结束索引
	SET @START_ID = convert(varchar(50),(@PageIndex - 1) * @PageSize + 1)
	SET @END_ID = convert(varchar(50),@PageIndex * @PageSize)

	set @sql =  ' SELECT '+@Fields+
				' FROM '+
				' ('+
					' SELECT ROW_NUMBER() OVER(ORDER BY '+@Sort+') AS rownum, '+@Fields+
					' FROM eGCP.[dbo].[tm_entity](nolock) ' +@strFilter+
				' ) AS D'+
				' WHERE rownum BETWEEN '+@START_ID+' AND ' +@END_ID
END

EXEC (@sql)

--总条数
set @recordCount=0;
set @sql = N'SELECT  @recordCount=Count(1) FROM  eGCP.[dbo].[tm_entity](nolock) ' +  @strFilter
EXEC sp_executesql @sql,N'@recordCount int out',@RecordCount out

GO
/****** Object:  StoredProcedure [dbo].[Paging_all]    Script Date: 2021/5/25 9:53:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[Paging_all]
	@Tables nvarchar(512), --表名,多张表是请使用 tA a inner join tB b On a.AID = b.AID
	@PK nvarchar(128)='',    --主键，可以带表头 a.AID
	@Sort nvarchar(512) = '', --排序字段
	@PageIndex int = 1,    --开始页码
	@PageSize int = 10,        --页大小
	@Fields nvarchar(1024) = '*',--读取字段
	@Where nvarchar(1024) = NULL,--Where条件
	@RecordCount int output --返回总条数
AS

DECLARE @strFilter nvarchar(4000)
declare @sql nvarchar(4000)
IF @Where IS NOT NULL AND @Where != ''
BEGIN
   SET @strFilter = ' WHERE ' + @Where + ' '
END
ELSE
BEGIN
   SET @strFilter = ''
END

if @Sort = ''
  set @Sort = @PK + ' DESC '

IF @PageIndex < 1
  SET @PageIndex = 1

if @PageIndex = 1 --第一页提高性能
begin
  set @sql = 'select top ' + str(@PageSize) +' '+@Fields+ '  from ' + @Tables + ' ' + @strFilter + ' ORDER BY  '+ @Sort
  print @sql
end
else
begin
	DECLARE @START_ID varchar(50)	--页开始索引
	DECLARE @END_ID varchar(50)		--页结束索引
	SET @START_ID = convert(varchar(50),(@PageIndex - 1) * @PageSize + 1)
	SET @END_ID = convert(varchar(50),@PageIndex * @PageSize)

	set @sql =  ' SELECT '+@Fields+
				' FROM '+
				' ('+
					' SELECT ROW_NUMBER() OVER(ORDER BY '+@Sort+') AS rownum, '+@Fields+
					' FROM '+@Tables+' ' +@strFilter+
				' ) AS D'+
				' WHERE rownum BETWEEN '+@START_ID+' AND ' +@END_ID +' ORDER BY '+@Sort
END

EXEC (@sql)

--总条数
set @recordCount=0;
set @sql = N'SELECT  @recordCount=Count(1) FROM ' + @Tables + @strFilter
EXEC sp_executesql @sql,N'@recordCount int out',@RecordCount out

GO
/****** Object:  StoredProcedure [dbo].[sp_RefreshQualityControl]    Script Date: 2021/5/25 9:53:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_RefreshQualityControl]
	@id NVARCHAR(100)
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX)='',@sql_text NVARCHAR(MAX),@studyCode NVARCHAR(100),@result NVARCHAR(500)
SELECT @studyCode=study_code,@sql_text=sql_text FROM study_quality_control WHERE id=@id
    SET @sql='INSERT INTO study_quality_control_log(id,quality_control_id,study_code,sql_text,result_status,result_message,exec_dt)
VALUES(NEWID(),'''+@id+''','''+@studyCode+''','''+REPLACE(@sql_text,'''','''''')+''',1,('+REPLACE(@sql_text,'select *','select distinct si.empi')+' FOR XML PATH('''')),GETDATE())'
BEGIN TRY
EXEC(@sql)
END TRY
BEGIN CATCH
INSERT INTO study_quality_control_log(id,quality_control_id,study_code,sql_text,result_status,result_message,exec_dt)
		VALUES(NEWID(),@id,@studyCode,@sql,0,ERROR_MESSAGE(),GETDATE())
END CATCH

SET @sql='MERGE study_quality_control_subject AS TARGET
USING ('+REPLACE(@sql_text,'select *','select distinct si.empi,'''+@studyCode+''' as study_code')+') AS SOURCE
ON (TARGET.empi = SOURCE.empi AND TARGET.study_code = SOURCE.study_code AND TARGET.quality_control_id = '''+@id+''')
WHEN NOT MATCHED BY TARGET THEN
    INSERT (empi,study_code,confirmed,quality_control_id,update_date)
    VALUES (SOURCE.empi,'''+@studyCode+''',0,'''+@id+''',GETDATE());'
BEGIN TRY
EXEC(@sql)
END TRY
BEGIN CATCH
INSERT INTO study_quality_control_log(id,quality_control_id,study_code,sql_text,result_status,result_message,exec_dt)
		VALUES(NEWID(),@id,@studyCode,@sql,0,ERROR_MESSAGE(),GETDATE())
END CATCH

END
GO
/****** Object:  StoredProcedure [dbo].[sp_RefreshStudySubject]    Script Date: 2021/5/25 9:53:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_RefreshStudySubject]
	@code NVARCHAR(100)
AS
BEGIN
	--添加招募开始时间
UPDATE dbo.study_info SET recruit_start_dttm = GETDATE() WHERE code = @code AND recruit_start_dttm IS NULL;

DECLARE @sql NVARCHAR(MAX),@collectionSql NVARCHAR(MAX)='',@id NVARCHAR(255),@type INT,@sqlTxt NVARCHAR(500),@sqlTxtPossible NVARCHAR(500)
	DECLARE outCursor CURSOR FAST_FORWARD FOR
SELECT id,type,sql_txt,sql_txt_possible FROM study_rule WHERE study_code=@code ORDER BY type,seq

    OPEN outCursor
	FETCH NEXT FROM outCursor INTO @id,@type,@sqlTxt,@sqlTxtPossible
    WHILE @@FETCH_STATUS = 0
BEGIN
		SET @sql='delete study_rule_subject where rule_id='''+@id+''';insert into study_rule_subject select '''+@id+''',empi,1 from ('+@sqlTxt+') tb;'
		IF(@type=1)
BEGIN
			IF(@collectionSql='') SET @collectionSql='select empi from study_rule_subject where rule_id='''+@id+'''';
ELSE SET @collectionSql=@collectionSql+'
InterSect
select empi from study_rule_subject where rule_id='''+@id+''''
END
ELSE SET @collectionSql=@collectionSql+'
except
select empi from study_rule_subject where rule_id='''+@id+''''
		SET @sql=@sql+ISNULL('insert into study_rule_subject select '''+@id+''',empi,2 from ('+@sqlTxtPossible+') tb2;','')
		EXEC(@sql)
		FETCH NEXT FROM outCursor INTO @id,@type,@sqlTxt,@sqlTxtPossible
END
CLOSE outCursor
    DEALLOCATE outCursor
	EXEC('delete study_subject where code='''+@code+''';
insert into study_subject select '''+@code+''',empi,max(type)
from study_rule_subject where rule_id in (select id from study_rule where study_code='''+@code+''') and empi in ('+@collectionSql+') group by empi;')
END
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'check_mark', @level2type=N'COLUMN',@level2name=N'oper'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'11-待下载，12-待PETCT下载，10-下载成功，19-下载失败，21-待脱敏，20-脱敏成功，29-脱敏失败，31-待上传，30-上传成功，39-上传失败，90-删除成功，99-删除失败' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'dcm_proc_state', @level2type=N'COLUMN',@level2name=N'state'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'招募开始时间' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'study_info', @level2type=N'COLUMN',@level2name=N'recruit_start_dttm'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'状态流ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sys_state_flow', @level2type=N'COLUMN',@level2name=N'id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'状态流名称' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sys_state_flow', @level2type=N'COLUMN',@level2name=N'name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'状态操作ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sys_state_oper', @level2type=N'COLUMN',@level2name=N'id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'状态流ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sys_state_oper', @level2type=N'COLUMN',@level2name=N'state_flow_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'状态操作Code' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sys_state_oper', @level2type=N'COLUMN',@level2name=N'code'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'状态操作名称' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sys_state_oper', @level2type=N'COLUMN',@level2name=N'name'
GO
USE [master]
GO
ALTER DATABASE [eGCP] SET  READ_WRITE
GO
