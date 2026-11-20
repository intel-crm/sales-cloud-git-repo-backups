/****************************************************************************************
* Class Name  :   PMP_StaticConstants_MasterData
* Version     : 1.0 
* Created Date: 2nd Jan,2019
* Description : Class to store static constants and which can be reused 
*               in otherclasses instead of hardcoding.
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------
* Sangeetha Ganta          02/01/2019               Original Version. To hold Constants 
*                                                   used in Master Data files
* Sangeetha Ganta          02/26/2019               Updated to add Tool Tip in category
* Sabgeetha Ganta          03/26/2019               User Story US301406. PIM translation
*******************************************************************************************/

public class PMP_StaticConstants_MasterData {
    
    //Constants for Apex Class 'Core_PMP_ParseCategoryJSON'
    public static final String Test_Category_Hierarchy = 'PMP_Category_Hierarchy_Test';
    public static final String Category_Hierarchy_English= 'Hierarchy_English';
    public static final String Category_Hierarchy_Chinese='Hierarchy_Chinese';
    public static final String Category_Hierarchy_Japanese='Hierarchy_Japanese';
    public static final String Child_Identifier = 'Child Identifier';
    public static final String Child_Name = 'Child Name';
    public static final String Child_Description = 'Child Description';
    public static final String Child_Image_URL = 'Child Image URL';
    public static final String Sequence = 'Sequence';
    public static final String Is_Active='Is_Active';
    public static final String Selection_Type = 'Selection Type';
    public static final String Radio = 'Radio';
    public static final String Radiobutton = 'Radiobutton';
    public static final String Category_PIMId = 'NPP_01_TYPE';
    public static final String Application_PIMId = 'NPP_01_APP';
    public static final String Industry_PIMId = 'NPP_01_Industry';
    public static final String Label = 'Label';
    public static final String Parent_Identifier = 'Parent Identifier';
    public static final String Intel_Segment = 'Intel Segment';
    public static final String Spec_Identifier = 'Spec Identifier';
    public static final String Client_Computing_PIMId = 'Intel_Segments_Client_Computing';
    public static final String Data_Center_PIMId = 'Intel_Segments_Data_Center';
    public static final String Embedded_IoT_PIMId = 'Intel_Segments_Embedded_IoT';
    public static final String Programmable_Logic_PIMId = 'Intel_Segments_Field_Programmable_Gate_Array';
    public static final String Business_Segments_PIMId = 'Intel_Segments_NPP_01';
    public static final String Spec_Value = 'Spec Value';
    public static final String Yes = 'Yes';
    public static final String Client = 'Client';
    public static final String Personal_Computers = 'Personal Computers';
    public static final String Server = 'Server';
    public static final String IoT = 'IoT';
    public static final String ProgrammableLogic = 'Field Programmable Gate Array';
    public static final String Comma_Symbol = ',';
    public static final String SemiColon_Symbol = ';';
    public static final String Core_PMP_ParseCategoryJSON_Exception_Message = 'Error occured from class Core_PMP_ParseCategoryJSON due to ';
    public static final String PMP_CategoryController_Exception_Message='Error occured from class PMP_CategoryController due to';
    public static final String Chipsets = 'Chipsets';
    public static final String ChipSets_Attribute = 'ChipSets_Attribute';
    public static final String ChildCategories = 'ChildCategories';
    public static final String Level = 'Level';
    public static final String leaf = 'leaf';
    public static final String specValueLevel5 = '5'; //Added by Manasa
    public static final Integer specValueLevel2 = 2; //Added by Manasa
    public static final Integer level3 = 3;
    public static final String specValueLevel3 = '3'; //Added by Manasa
    public static final String Checkbox = 'Checkbox';
    public static final String ParentName = 'ParentName';
    public static final String ParentIdentifier = 'ParentIdentifier';
    public static final String SpecRawValue = 'SpecRawValue';
    public static final String SpecDisplayValue ='SpecDisplayValue';
    public static final String SpecValueSequence = 'SpecValueSequence';
    public static final String Processor = 'Processors';
    public static final String Geography = 'Geography'; //Added by Manasa
    public static final String Technology = 'Technology'; //Added by Manasa
    public static final String Processors_Attribute = 'Processors_Attribute';
    public static final String Off_Roadmap = 'Off_Roadmap';
    public static final String Core_PMP_Processor_CreateJunctionData_Exception_Message = 'Error occured from class Core_PMP_Processor_CreateJunctionData due to ';
    public static final String Features = 'Features';
    public static final String Mandatory_for_Category = 'Mandatory for Category';
    public static final String Preset_Values = 'Preset Values';
    public static final String Identifier = 'Identifier';
    public static final String Values = 'Values';
    public static final String Check = 'Check';
    public static final String Level_1 = 'Level 1';
    public static final String Level_2 = 'Level 2';
    public static final String Level_3= 'Level 3';
    public static final String Level_4= 'Level 4';
    public static final String Pipe_Symbol = '|';
    public static final String Specification_Hierarchy = 'Specification_Hierarchy';
    public static final String Test_Specification_Hierarchy = 'Test_Specification_Hierarchy';
    public static final String Type = 'Type';
    public static final String Core_PMP_ParseSpecificationJSON_Exception_Message ='Error occured from class ParseSpecificationJSON due to ';
    public static final String Test_Junction_Hierarchy = 'Test_Junction_Hierarchy';
    public static final String Colon_Symbol = ':';
    public static final String Core_PMP_CreateJunctionData_Exception_Message = 'Error occured from class Core_PMP_CreateJunctionData due to ';
    public static final String GeoRegion_PIMId = 'NPP_GeographicCoverage';//Added by Manasa
    public static final String IntelTech_PIMId = 'NPP_IntelTechnologies';//Added by Manasa
    public static final String Processor_PIMId = 'NPP_Processors';
    public static final String Core_PMP_ParseProcessorJSON_Exception_Message = 'Error occured from class Core_PMP_ParseProcessorJSON due to ';
    public static final String Chipsets_PIMId = 'NPP_Chipsets';
    public static final String Core_PMP_ChipSet_CreateJunctionData_Exception_Message = 'Error occured from class Core_PMP_ChipSet_CreateJunctionData due to ' ;
    public static final String FPGA_PIMId = 'NPP_FPGA';
    public static final String FPGA_Attribute = 'FPGA_Attribute';
    public static final String FPGA = 'Intel® FPGAs';
    public static final String Core_PMP_ParseFpgaJSON_Exception_Message = 'Error occured from class Core_PMP_ParseFpgaJSON due to ';
    public static final String Core_PMP_FPGA_CreateJunctionData_Exception_Message = 'Error occured from class Core_PMP_FPGA_CreateJunctionJSON due to ';
    public static final String Tool_Tip = 'Tool Tip';
    public static final String Intel_Segments_NPP_01_Busines_Segments = 'Intel_Segments_NPP_01_Busines_ Segments';
    public static final String NPP_Is_Active = 'NPP_Is_Active';
    public static final String Product_Catalog_URL = 'Product_Catalog_URL'; // Added by Manasa
    public static final String Image_URL = 'Image_URL'; // Added by Manasa
    public static final String SpecIsActive = 'SpecIsActive'; // Added by Manasa
    public static final String Auto_Populated_From_PIM = 'Auto-populated from PIM';
    public static final String Chinese_Chipsets = '芯片组';
    public static final String Japanese_Chipsets = 'チップセット';
    public static final String Chinese_JSON='zh_CN';
    public static final String Japanese_JSON='ja_JP';
    public static final String English_JSON='en_US';
    public static final String Chinese_Processors = '处理器';
    public static final String Japanese_Processors = 'プロセッサー';
    public static final String Chinese_Geography = ''; //Added by Manasa
    public static final String Japanese_Geography = ''; // Added by Manasa
    public static final String Chinese_IntelTech = 'Technology'; //Added by Manasa
    public static final String Japanese_IntelTech = 'Technology'; // Added by Manasa
    public static final String Approved = 'Approved';
    public static final String Published = 'Published';
    public static final String Processor_Spec_Value = 'Processor';
    public static final String GeoRegion_Spec_Value = 'Geography';//Added by Manasa
    public static final String IntelTech_Spec_Value = 'Technology';//Added by Manasa
    public static final String Chipset_Spec_Value = 'Chipset';
    public static final String Other_Spec_Value = 'Other';
    public static final String FPGA_Attribute_Test = 'PMP_FPGA_Attribute_Test';
    public static final String Processors_Attribute_Test = 'PMP_Processors_Attribute_Test';
    public static final String Geo_Attribute_English_Test = 'Geo_Attribute_English_Test'; //Added by Manasa
    public static final String Intel_Technology_Attribute_English_Test = 'Intel_Technology_Attribute_English_Test'; //Added by Manasa
    public static final String Chipsets_Attribute_Test = 'PMP_Chipsets_Attribute_Test';
    public static final String Attributes_Test = 'PMP_Attributes_Test';
    public static final String Status = 'Status';
    public static final String No = 'No'; //Added By lalit
    public static final Integer Zero = 0;
    public static final String Child_Mandatory_Flag = 'Child_Mandatory_Flag';
    public static final String Intel_Only_Content='Intel Only Content';//Added by Tarangini to check Intel Only Offerings
    public static final String Public_Content = 'Public Content';//Addded by Tarangini to check Intel Only Offerings
    public static final String Restriction_Level = 'Restriction_Level';
    public static final String IPQualityMetricPIMId = 'IPQualityMetricsLevel1';
    public static final String BoardQualityMetricPIMId = 'BoardQualityMetricsLevel1';
    public static final String Partner_Content = 'Partner Content';//Addded by Vardaan  to check Partner Offerings
    public static final String Rejected = 'Rejected';//Addded by Vardaan  to check Partner Offerings       
}