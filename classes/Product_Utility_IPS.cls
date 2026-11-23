public with sharing class Product_Utility_IPS {
    
    //declare map for storing metadata mappings
    public static Map<String,String> l5_VPH_fieldMappingTable = new Map<String,String>(); 
    public static Map<String,String> l5_VPLCH_fieldMappingTable = new Map<String,String>();
    public static List<String> fieldsExceptionList = label.Product_Fields_Exception_List.split(',');
    public static List<Product_fields_mapping__mdt> mmidAttributeMetadata = new List<Product_fields_mapping__mdt>();
    //Pranjal
    public static Map<String,String> FPH_fieldMappingTable_VPH = new Map<String,String>();  
    public static Map<String,String> FPH_fieldMappingTable_VPLCH = new Map<String,String>();
    //IPS
    public static Map<String,String> IPS_fieldMappingTable_VPH = new Map<String,String>();  
    public static Map<String,String> IPS_fieldMappingTable_VPLCH = new Map<String,String>();
    //IPS Rollup Mappings
    public static List<Product_fields_mapping__mdt> IPS_Rollup_VPH_Mappings = new list<Product_fields_mapping__mdt>(); 
    public static List<Product_fields_mapping__mdt> IPS_Rollup_VPLCH_Mappings = new List<Product_fields_mapping__mdt>(); 
    //Sales Rollup Mappings
    public static List<Product_fields_mapping__mdt> Sales_Rollup_VPH_Mappings = new List<Product_fields_mapping__mdt>(); 
    public static List<Product_fields_mapping__mdt> Sales_Rollup_VPLCH_Mappings = new List<Product_fields_mapping__mdt>(); 
    public static String epm_FPGA = Product_Staging_StaticConstants.FPGA_EPMId;    
    public static Set<String> charLimit255Fields = new Set<String>(Product_Staging_StaticConstants.charLimit255Fields);
    public static List<String> vplchIpsEpmFilter= Label.Product_IPS_VPLCH_Epm_Filter.split(';');
    
    // method to store the metadata mappings for Inbound to Staging to FPH/Product3
    static{
        for (Product_fields_mapping__mdt  mappingRec : Product_fields_mapping__mdt.getall().Values()) {
            if (mappingRec.Inbound_staging_field__c != null && mappingRec.Product_staging_field__c != null && mappingRec.Type__c == 'Mapping' && mappingRec.Product_Org__c =='Sales') {          
                if(mappingRec.Hierarchy_ID__c == Product_Staging_StaticConstants.vphId && mappingRec.Order__c  == null){
                    l5_VPH_fieldMappingTable.put(mappingRec.Product_staging_field__c,mappingRec.Inbound_staging_field__c);                    
                }
            } 
            //Pranjal
            if(mappingRec.Inbound_staging_field__c != null && mappingRec.FPH_Field__c!=null && mappingRec.Type__c=='Mapping' && mappingRec.Product_Org__c=='FPH'){
                if(mappingRec.Hierarchy_ID__c == Product_Staging_StaticConstants.vphId){
                    FPH_fieldMappingTable_VPH.put(mappingRec.Product_staging_field__c,mappingRec.Inbound_staging_field__c);                    
                }
                else if(mappingRec.Hierarchy_ID__c == Product_Staging_StaticConstants.vplchId){
                    FPH_fieldMappingTable_VPLCH.put(mappingRec.Product_staging_field__c,mappingRec.Inbound_staging_field__c);                    
                }
            }
            if(mappingRec.Inbound_staging_field__c != null && mappingRec.Product_staging_field__c !=null && mappingRec.Type__c=='Mapping' && mappingRec.Product_Org__c=='IPS'){
                if(mappingRec.Hierarchy_ID__c == Product_Staging_StaticConstants.vphId){
                    IPS_fieldMappingTable_VPH.put(mappingRec.Product_staging_field__c,mappingRec.Inbound_staging_field__c);                    
                }
                else if(mappingRec.Hierarchy_ID__c == Product_Staging_StaticConstants.vplchId){
                    IPS_fieldMappingTable_VPLCH.put(mappingRec.Product_staging_field__c,mappingRec.Inbound_staging_field__c);                    
                }
            }
            
            if (mappingRec.Type__c=='MMID Attribute') {
                mmidAttributeMetadata.add(mappingRec);
            }
            //IPS Mappings
            if(mappingRec.Product_staging_field__c != null && mappingRec.Inbound_staging_field__c != null && mappingRec.Type__c == 'Rollup'){
                if(mappingRec.Product_Org__c == 'IPS' && mappingRec.Hierarchy_ID__c == Product_Staging_StaticConstants.vphId){
                    IPS_Rollup_VPH_Mappings.add(mappingRec);
                }
                else if(mappingRec.Product_Org__c == 'IPS' && mappingRec.Hierarchy_ID__c == Product_Staging_StaticConstants.vplchId){
                    IPS_Rollup_VPLCH_Mappings.add(mappingRec);
                }
                else if(mappingRec.Product_Org__c == 'Sales' && mappingRec.Hierarchy_ID__c == Product_Staging_StaticConstants.vphId){
                    Sales_Rollup_VPH_Mappings.add(mappingRec);
                }
                else if(mappingRec.Product_Org__c == 'Sales' && mappingRec.Hierarchy_ID__c == Product_Staging_StaticConstants.vplchId){
                    Sales_Rollup_VPLCH_Mappings.add(mappingRec);
                }
            }            
        } 
    }
    /* method to deactivate product based on product status*/
    public static Boolean IsProductDeactivated(Boolean isFPGA, String prodStatus){
        Boolean foundActiveStatusCode = false;
        if(string.isNotBlank(prodStatus)){
            for(string pStatus : prodStatus.split(';')){
                if(isFPGA){
                    if(pStatus  != 'NO' && pStatus  != 'RT' && pStatus  != 'RP' ){
                        foundActiveStatusCode = true ;
                        break;
                    }
                }else{
                    if(pStatus  != 'NO' && pStatus  != 'RT' && pStatus  != 'RP'  && pStatus  != 'OB' ){
                        foundActiveStatusCode = true ;
                        break;
                    }
                }
            }
        }else{ // This means we have not got any inactive code. So we will consider the product as active
            foundActiveStatusCode = true ;
        }              
        return foundActiveStatusCode;                
    }
    
    // method to concatenate all epmIds for an inbound record
    public static String concatenateEpmIds(Core_Products_Staging__c stgRec){
        String uniqueId;
        if(stgRec  != null){ 
            if(stgRec.Core_Hierarchy_ID__c == Product_Staging_StaticConstants.vphId){
                uniqueId = stgRec.Core_Product_Name_EPM_ID__c+';'+stgRec.Core_Product_Group_EPM_ID__c+';'+stgRec.Core_Product_Series_EPM_ID__c+';'+stgRec.Core_Product_Family_EPM_ID__c+';'+stgRec.Core_Product_Type_EPM_ID__c; 
            }
            if(stgRec.Core_Hierarchy_ID__c == Product_Staging_StaticConstants.vplchId){
                uniqueId = stgRec.Core_Product_Name_EPM_ID__c+';'+stgRec.Core_Code_Name_EPM_ID__c+';'+stgRec.Core_Product_Type_EPM_ID__c+';'+stgRec.Core_Platform_Config_EPM_ID__c+';'+stgRec.Core_Platform_EPM_ID__c;   
            }          
        }
        return uniqueId;
    }
    // get the fields using schema for any object
    public static List<String> getObjectFields(String objName){           
        List<String> fields = new List<String>();    
        SObjectType objType = Schema.getGlobalDescribe().get(objName);    
        Map<String,Schema.SObjectField> mfields = objType.getDescribe().fields.getMap();  
        for (Schema.SObjectField sf: mfields.values()) {                
            if(!fieldsExceptionList.contains(String.valueOf(sf))){
                fields.add(String.valueOf(sf));        
            }  
        }                    
        return fields;
    }
    // get OPN i.e. split the string passed and returns the last word
    public static String getOPN(String name){ 
        List<String> lstStr = new List<String>();
        String opnValue;
        if(name != null){
            lstStr = name.split(' ');                         
        }
        if(lstStr.size()>0){
            String opn = lstStr[lstStr.size()-1];            
            if( !opn.isAlpha() && !opn.contains('-')){
                opnValue = opn;
            }
            else if(!opn.isAlpha() && opn.contains('-')){
                if(opn.startsWith('-') && opn.substringAfter('-').isNumeric()){
                    opnValue = '';
                }
                else{
                    opnValue = opn;
                }
            }
            
        }
        else{
            opnValue = '';
        }
        return opnValue;
        
    }    
    // Method to map Inbound fields to Outbound fields
    public static Core_Products_Staging__c processInbStgngMapng(Product_Inbound_Staging__c productLevel, Product_fields_mapping__mdt salesConfig){
        Core_Products_Staging__c stagingRec = new Core_Products_Staging__c();
        if(productLevel != null){                                   
            if(productLevel.Core_Hierarchy_ID__c == Product_Staging_StaticConstants.vphId){
                
                //field mapping using custom metadata -- Product_fields_mapping__mdt. Mapping only for Hierarchy fields ( L1 to L5 fields).
                stagingRec = repeatLogicSales(Product_Staging_StaticConstants.isLevel5,productLevel) ;
                
                //field mapping using custom metadata -- Product_fields_mapping__mdt. All the fields are mapped except the Hierarchy fields ( L1 to L5 fields).
                for(String stageField: l5_VPH_fieldMappingTable.keySet()) {
                    stagingRec.put(stageField, productLevel.get(l5_VPH_fieldMappingTable.get(stageField)));                            
                }     
                if(productLevel.level_1_epm_name__c == system.label.PSG_Product_Type_Identifier){
                    stagingRec.Core_OPN__c = getOPN(stagingRec.Core_Product_Name__c);
                }
            }
            else if(productLevel.Core_Hierarchy_ID__c == Product_Staging_StaticConstants.vplchId ){ 
                stagingRec = repeatLogicSales(Product_Staging_StaticConstants.isLevel5,productLevel) ;   
                stagingRec.iPaaS_Load_ID__c           = productLevel.iPaaS_Load_ID__c; 
                stagingRec.Core_Hierarchy_ID__c       = productLevel.Core_Hierarchy_ID__c;
                stagingRec.Core_Hierarchy_Name__c     = productLevel.Core_Hierarchy_Name__c; 
                if( productLevel.level_3_epm_name__c == system.label.PSG_Product_Type_Identifier){
                    stagingRec.Core_OPN__c = getOPN(stagingRec.Core_Product_Name__c);
                } 
            }
            
            /*if(productLevel.L4_VProTechnology__c == Product_Staging_StaticConstants.yes){
stagingRec.Core_Intel_vPro_Platform_Eligibility__c=True;
} */
            stagingRec.Status_Code__c = productLevel.L4_StatusCode__c;
            stagingRec.Core_Product_Org__c= Product_Staging_StaticConstants.sales;
            //stagingRec.Core_Sales_Visible_Flag__c= true;
            //stagingRec.Core_IsLatest__c=true;   
            stagingRec.Level__c = Product_Staging_StaticConstants.five;                 
            stagingRec.Core_Unique_ID__c= concatenateEpmIds(stagingRec);
            stagingRec.Unique_Value__c = stagingRec.Core_Unique_ID__c+';'+stagingRec.iPaaS_Load_ID__c+';'+ stagingRec.Core_Product_Org__c;
            //String key = stagingRec.Level__c+';'+stagingRec.Core_Hierarchy_ID__c+';'+stagingRec.Core_Product_Type_EPM_ID__c;
            stagingRec.Core_Is_IQR_Visible__c = salesConfig != null && salesConfig.IQR_Visible__c;
            stagingRec.Core_Sales_Visible_Flag__c = stagingRec.Core_Hierarchy_ID__c == '59' ? true : salesConfig != null && salesConfig.Sales_Visible__c;
            
        }   
        return stagingRec;
    }    
    
    public static List<Core_Products_Staging__c> createLevelDatawithRollupSales(Map<String,List<Product_Inbound_Staging__c>> levelDataMap, String levelDownApiName, String hierarchyId, List<Product_Inbound_Staging__c> l4WoL5List,  Product_fields_mapping__mdt salesConfig){
        
        List<Core_Products_Staging__c> prodStagingTobeInserted = new List<Core_Products_Staging__c>();
        List<Product_fields_mapping__mdt> mappings = new List<Product_fields_mapping__mdt>();
        if(hierarchyId == Product_Staging_StaticConstants.vphId && !Sales_Rollup_VPH_Mappings.isEmpty()){
            mappings =  Sales_Rollup_VPH_Mappings;
        }else if(hierarchyId == Product_Staging_StaticConstants.vplchId && !Sales_Rollup_VPLCH_Mappings.isEmpty()){
            mappings = Sales_Rollup_VPLCH_Mappings;
        }
        if (!levelDataMap.isEmpty()) {
            for (String lKey : levelDataMap.keySet()) {
                
                //First L5 product under the current L4
                Product_Inbound_Staging__c level1stRec = levelDataMap.get(lKey)[0];
                
                Core_Products_Staging__c ldownRec = new Core_Products_Staging__c();
                if (hierarchyId == Product_Staging_StaticConstants.vphId) {
                    // L1
                    ldownRec.Core_Product_Type_EPM_ID__c = level1stRec.level_1_epm_id__c;
                    ldownRec.Core_Product_Type__c = level1stRec.level_1_epm_name__c;
                    // L2
                    ldownRec.Core_Product_Family_EPM_ID__c = level1stRec.level_2_epm_id__c;
                    ldownRec.Core_Product_Family__c = level1stRec.level_2_epm_name__c;
                    // L3
                    ldownRec.Core_Product_Series_EPM_ID__c = level1stRec.level_3_epm_id__c;
                    ldownRec.Core_Product_Series__c = level1stRec.level_3_epm_name__c;
                    // L4
                    ldownRec.Core_Product_Name_EPM_ID__c =  level1stRec.level_4_epm_id__c;
                    ldownRec.Core_Product_Name__c = level1stRec.level_4_epm_name__c;
                    
                }
                ldownRec.Level__c = '4';
                ldownRec.Core_Unique_ID__c = level1stRec.level_4_epm_id__c+';'+level1stRec.level_3_epm_id__c+';'+level1stRec.level_2_epm_id__c+';'+level1stRec.level_1_epm_id__c;
                ldownRec.Core_Hierarchy_ID__c = hierarchyId;
                ldownRec.Core_Hierarchy_Name__c = hierarchyId == '43' ? 'Valid Product Hierarchy' : 'Valid Platform Codename Hierarchy';            
                ldownRec.Core_Sales_Visible_Flag__c = true;
                ldownRec.Core_Product_Org__c = 'Sales';
                ldownRec.iPaaS_Load_ID__c = level1stRec.iPaaS_Load_ID__c;
                ldownRec.Unique_Value__c = ldownRec.Core_Unique_ID__c+';'+ldownRec.iPaaS_Load_ID__c+';'+ ldownRec.Core_Product_Org__c;
                String key = ldownRec.Level__c+';'+ldownRec.Core_Hierarchy_ID__c+';'+ldownRec.Core_Product_Type_EPM_ID__c;
                ldownRec.Core_Sales_Visible_Flag__c = salesConfig != null &&  salesConfig.Sales_Visible__c;
                ldownRec.Core_Is_IQR_Visible__c = salesConfig != null && salesConfig.IQR_Visible__c;
                
                for (Product_fields_mapping__mdt mapping : mappings) {
                    String rollupValue = '';
                    for (Product_Inbound_Staging__c prodStaging : levelDataMap.get(lKey)) {
                        String val = prodStaging.get(mapping.Inbound_staging_field__c) != null ? String.valueOf(prodStaging.get(mapping.Inbound_staging_field__c)) : '';
                        if (String.isNotBlank(val)) {
                            for (String str : val.split(';')){
                                //if(!rollupValue.containsIgnoreCase(str)){
                                rollupValue = String.isBlank(rollupValue) ? str : rollupValue+';'+str;
                                //}
                            }
                        }  
                    }
                    
                    if(String.isNotBlank(rollupValue)){
                        ldownRec.put(mapping.Product_staging_field__c,removeDuplicateEntries(rollupValue));
                        //ldownRec.put(mapping.Product_staging_field__c,rollupValue);
                    }
                }
                
                // L4 attributes - Start
                ldownRec.Core_Mem_Amt__c = level1stRec.L4_DriveCapacity__c;
                ldownRec.Core_IsActive__c = true;
                ldownRec.Core_CoreCount__c = level1stRec.L4_CoreCount__c;
                ldownRec.Core_Max_TDP__c = level1stRec.L4_MaxTDP__c;
                ldownRec.Core_StableImagePlatformProgVer_Ind__c = level1stRec.L4_StableImagePlatformProgramVersion__c; //Added by Simran for SIPP
                // added by soundarya                
                //ldownRec.Core_Processor_Number_Ta_Nm__c = level1stRec.L4_ProcessorNumber__c;//Commented as Processor Number moved to MM Attribute
                //ldownRec.Core_Code_Name__c = level1stRec.L4_CodenameText__c; //Commented as Code Name moved to MM Attribute
                ldownRec.Core_Processor_Number_Nm__c = level1stRec.L4_ProcessorNumber__c;
                ldownRec.Core_Vertical_Segment__c = level1stRec.L4_MarketSegment__c;
                ldownRec.Core_Pipeline_Launch_Date__c = level1stRec.L4_LaunchDate__c;
                ldownRec.Core_Intel_vPro_Platform_Eligibility__c = level1stRec.L4_VProTechnology__c;
                ldownRec.Core_Avail_for_New_Designs__c = level1stRec.L4_AdvocatedForNewDesign__c;
                ldownRec.Core_IsActive__c = ldownRec.Core_Product_Status__c != null ? IsProductDeactivated(ldownRec.Core_Product_Type_EPM_ID__c == epm_FPGA,ldownRec.Core_Product_Status__c) : true ;
                if(ldownRec.Core_IsActive__c==false){
                    ldownRec.core_Logging_Type__c='Status_Deactivation';
                }
                ldownRec.Status_Code__c = level1stRec.L4_StatusCode__c;
                ldownRec.Core_Expiration_Date__c=level1stRec.L4_DesignExpirationDate__c;
                // L4 attributes - End
                prodStagingTobeInserted.add(ldownRec);
            }
            
        }
        
        // This list will contains all L4s without any L5 record
        if (l4WoL5List != null && !l4WoL5List.isEmpty()){
            prodStagingTobeInserted.addAll(getL4recordsWithoutL5(hierarchyId,l4WoL5List,salesConfig));
        }
        
        return prodStagingTobeInserted;
    }
    
    public static List<Core_Products_Staging__c> getL4recordsWithoutL5(String hierarchyId, List<Product_Inbound_Staging__c> l4WoL5List,  Product_fields_mapping__mdt salesConfig){
        List<Core_Products_Staging__c> prodStagingTobeInserted = new List<Core_Products_Staging__c>();
        Boolean level5 = false;
        for (Product_Inbound_Staging__c pis: l4WoL5List) {
            Core_Products_Staging__c l4Rec = new Core_Products_Staging__c();
            
            // Repeat logic for Hierarchy fields - L1 to L4
            l4Rec = repeatLogicSales(level5,pis) ;            
            
            // L4 attributes - Start
            l4Rec.Core_Mem_Amt__c = pis.L4_DriveCapacity__c;
            l4Rec.Core_CoreCount__c = pis.L4_CoreCount__c;
            l4Rec.Core_Max_TDP__c = pis.L4_MaxTDP__c;      
            l4Rec.Core_StableImagePlatformProgVer_Ind__c = pis.L4_StableImagePlatformProgramVersion__c; //Added by Simran for SIPP
            //l4Rec.Core_Processor_Number_Ta_Nm__c = pis.L4_ProcessorNumber__c;//Commented as Processor Number moved to MM Attribute
            //l4Rec.Core_Code_Name__c = pis.L4_CodenameText__c; //Commented as Code Name moved to MM Attribute
            l4Rec.Core_Processor_Number_Nm__c = pis.L4_ProcessorNumber__c;
            l4Rec.Core_Vertical_Segment__c = pis.L4_MarketSegment__c;
            l4Rec.Core_Pipeline_Launch_Date__c = pis.L4_LaunchDate__c;
            l4Rec.Core_Intel_vPro_Platform_Eligibility__c = pis.L4_VProTechnology__c;
            l4Rec.Core_Avail_for_New_Designs__c = pis.L4_AdvocatedForNewDesign__c;
            l4Rec.Status_Code__c = pis.L4_StatusCode__c;
            l4Rec.Level__c =  '4';
            l4Rec.Core_Unique_ID__c = l4Rec.Core_Product_Name_EPM_ID__c+';'+l4Rec.Core_Product_Series_EPM_ID__c+';'+l4Rec.Core_Product_Family_EPM_ID__c+';'+l4Rec.Core_Product_Type_EPM_ID__c;
            l4Rec.Core_Hierarchy_ID__c = hierarchyId;
            l4Rec.Core_Hierarchy_Name__c = hierarchyId == '43' ? 'Valid Product Hierarchy' : 'Valid Platform Codename Hierarchy';
            l4Rec.Core_IsActive__c = true;
            l4Rec.Core_Sales_Visible_Flag__c = true;
            l4Rec.Core_Product_Org__c = 'Sales';
            l4Rec.iPaaS_Load_ID__c = pis.iPaaS_Load_ID__c;
            l4Rec.Unique_Value__c = l4Rec.Core_Unique_ID__c+';'+l4Rec.iPaaS_Load_ID__c+';'+ l4Rec.Core_Product_Org__c;
            String key = l4Rec.Level__c+';'+l4Rec.Core_Hierarchy_ID__c+';'+l4Rec.Core_Product_Type_EPM_ID__c;
            l4Rec.Core_Sales_Visible_Flag__c = salesConfig != null &&  salesConfig.Sales_Visible__c;
            l4Rec.Core_Is_IQR_Visible__c = salesConfig != null && salesConfig.IQR_Visible__c;
            l4Rec.Core_IsActive__c = l4Rec.Core_Product_Status__c != null ? IsProductDeactivated(l4Rec.Core_Product_Type_EPM_ID__c == epm_FPGA,l4Rec.Core_Product_Status__c) : true ;
            if(l4Rec.Core_IsActive__c==false){
                l4Rec.core_Logging_Type__c='Status_Deactivation';
            }
            l4Rec.Core_Expiration_Date__c=pis.L4_DesignExpirationDate__c;
            prodStagingTobeInserted.add(l4Rec);
        }
        
        return prodStagingTobeInserted;
    }
    
    public static String removeDuplicateEntries(String str) {
        List<String> spltList = str.split(';');
        Set<String> spltSet = new Set<String>(spltList);
        return String.join(new List<String>(spltSet), ';');
    }
    // Pranjal method to concatenate all epmIds for an inbound record
    public static String concatenateEpmIdsFPH(Core_Products_Staging__c stgRec){
        String uniqueId;
        if(stgRec  != null){            
            uniqueId = stgRec.Core_L5_EPM_ID__c+';'+stgRec.Core_L4_EPM_ID__c+';'+stgRec.Core_L3_EPM_ID__c+';'+stgRec.Core_L2_EPM_ID__c+';'+stgRec.Core_L1_EPM_ID__c;            
        }
        return uniqueId;
    }  
    // Pranjal Method to map Inbound feilds to Outbound fields FPH--
    public static Core_Products_Staging__c processInbStngFPHRecords(Product_Inbound_Staging__c productLevel){
        Core_Products_Staging__c stagingRec = new Core_Products_Staging__c();
        if(productLevel != null){   
            if(productLevel.Core_Hierarchy_ID__c == Product_Staging_StaticConstants.vphId){                             
                for(String stageField: FPH_fieldMappingTable_VPH.keySet()) {
                    stagingRec.put(stageField, productLevel.get(FPH_fieldMappingTable_VPH.get(stageField)));                            
                }
            }
            if(productLevel.Core_Hierarchy_ID__c == Product_Staging_StaticConstants.vplchId){
                for(String stageField: FPH_fieldMappingTable_VPLCH.keySet()) {
                    stagingRec.put(stageField, productLevel.get(FPH_fieldMappingTable_VPLCH.get(stageField)));                            
                }
            }
            if(stagingRec.get('Core_L2_EPM_ID__c')==null||stagingRec.get('Core_L2_EPM_ID__c')==''){
                stagingRec.put('Core_L2_EPM_ID__c',stagingRec.get('Core_L1_EPM_ID__c'));
                stagingRec.put('Core_L3_EPM_ID__c',stagingRec.get('Core_L1_EPM_ID__c'));
                stagingRec.put('Core_L4_EPM_ID__c',stagingRec.get('Core_L1_EPM_ID__c'));
                stagingRec.put('Core_L5_EPM_ID__c',stagingRec.get('Core_L1_EPM_ID__c'));
                stagingRec.put('Core_L2_EPM_Name__c',stagingRec.get('Core_L1_EPM_Name__c'));
                stagingRec.put('Core_L3_EPM_Name__c',stagingRec.get('Core_L1_EPM_Name__c'));
                stagingRec.put('Core_L4_EPM_Name__c',stagingRec.get('Core_L1_EPM_Name__c'));
                stagingRec.put('Core_L5_EPM_Name__c',stagingRec.get('Core_L1_EPM_Name__c'));
            }
            else if(stagingRec.get('Core_L3_EPM_ID__c')==null||stagingRec.get('Core_L3_EPM_ID__c')==''){
                stagingRec.put('Core_L3_EPM_ID__c',stagingRec.get('Core_L2_EPM_ID__c'));
                stagingRec.put('Core_L4_EPM_ID__c',stagingRec.get('Core_L2_EPM_ID__c'));
                stagingRec.put('Core_L5_EPM_ID__c',stagingRec.get('Core_L2_EPM_ID__c'));
                stagingRec.put('Core_L3_EPM_Name__c',stagingRec.get('Core_L2_EPM_Name__c'));
                stagingRec.put('Core_L4_EPM_Name__c',stagingRec.get('Core_L2_EPM_Name__c'));
                stagingRec.put('Core_L5_EPM_Name__c',stagingRec.get('Core_L2_EPM_Name__c'));
            }
            else if(stagingRec.get('Core_L4_EPM_ID__c')==null||stagingRec.get('Core_L4_EPM_ID__c')==''){
                stagingRec.put('Core_L4_EPM_ID__c',stagingRec.get('Core_L3_EPM_ID__c'));
                stagingRec.put('Core_L5_EPM_ID__c',stagingRec.get('Core_L3_EPM_ID__c'));
                stagingRec.put('Core_L4_EPM_Name__c',stagingRec.get('Core_L3_EPM_Name__c'));
                stagingRec.put('Core_L5_EPM_Name__c',stagingRec.get('Core_L3_EPM_Name__c'));
                
            }
            else if(stagingRec.get('Core_L5_EPM_ID__c')==null||stagingRec.get('Core_L5_EPM_ID__c')==''){
                stagingRec.put('Core_L5_EPM_ID__c',stagingRec.get('Core_L4_EPM_ID__c'));
                stagingRec.put('Core_L5_EPM_Name__c',stagingRec.get('Core_L4_EPM_Name__c'));
            }
            stagingRec.Core_Product_Org__c= Product_Staging_StaticConstants.FPH;         
            stagingRec.Core_Unique_ID__c= concatenateEpmIdsFPH(stagingRec);
            stagingRec.Unique_Value__c = stagingRec.Core_Unique_ID__c+';'+stagingRec.iPaaS_Load_ID__c+';'+ stagingRec.Core_Product_Org__c;
        }
        return stagingRec;
    }
    
    // IPS     
    public static List<Core_Products_Staging__c> createLevelDatawithRollupIPS(Map<String,List<Core_Products_Staging__c>> levelDataMap, Integer level, String hierarchyId, Map<String,Product_fields_mapping__mdt> ipsConfigMap){
        List<Core_Products_Staging__c> prodStagingTobeInserted = new List<Core_Products_Staging__c>();         
        Map<String,List<Core_Products_Staging__c>> levelDownDataMap = new Map<String,List<Core_Products_Staging__c>>();
        
        Map<Integer,Boolean> eligibleLevels = new Map<Integer,Boolean>{
            5=>true,
                4=>true,
                3=>true,
                2=>true,
                1=>false
                };
                    
                    // List of attributes to be rolled up for Sales - VPH or VPLCH
                    //List<Product_fields_mapping__mdt> mappings = [SELECT Id,Product_staging_field__c,Inbound_staging_field__c FROM Product_fields_mapping__mdt WHERE Type__c='Rollup' AND Product_Org__c = 'IPS' AND Hierarchy_ID__c=:hierarchyId];
                    List<Product_fields_mapping__mdt> mappings = new List<Product_fields_mapping__mdt>();
        if(hierarchyId == Product_Staging_StaticConstants.vphId && !IPS_Rollup_VPH_Mappings.isEmpty()){
            mappings =  IPS_Rollup_VPH_Mappings;
        }else if(hierarchyId == Product_Staging_StaticConstants.vplchId && !IPS_Rollup_VPLCH_Mappings.isEmpty()){
            mappings = IPS_Rollup_VPLCH_Mappings;
        }
        for (String lKey : levelDataMap.keySet()) {
            
            //First L5 product under the current L4
            Core_Products_Staging__c level1stRec = levelDataMap.get(lKey)[0];
            Core_Products_Staging__c ldownRec = new Core_Products_Staging__c();
            
            ldownRec.Core_Product_Name_EPM_ID__c = (String)level1stRec.get('Core_L'+level+'_EPM_ID__c');
            ldownRec.Core_Product_Name__c = (String)level1stRec.get('Core_L'+level+'_EPM_Name__c');
            
            for (Integer i=1; i<=5;i++) {
                ldownRec.put('Core_L'+i+'_EPM_ID__c', level1stRec.get('Core_L'+i+'_EPM_ID__c'));
                ldownRec.put('Core_L'+i+'_EPM_Name__c', level1stRec.get('Core_L'+i+'_EPM_Name__c'));
            }
            
            ldownRec.Level__c = String.valueOf(level);
            ldownRec.Core_Unique_ID__c = (String)level1stRec.get('Core_L'+level+'_EPM_ID__c');
            ldownRec.Core_Hierarchy_ID__c = hierarchyId;
            ldownRec.Core_Hierarchy_Name__c = hierarchyId == '43' ? 'Valid Product Hierarchy' : 'Valid Platform Codename Hierarchy';
            ldownRec.Core_IsActive__c = true;
            //ldownRec.Core_IPS_Visible_Flag_External__c = ((hierarchyId == '43' && (level == 2 || level == 3)) || (hierarchyId == '59' && (level == 2 || level == 4)));
            ldownRec.Core_Product_Org__c = 'IPS';
            ldownRec.iPaaS_Load_ID__c = level1stRec.iPaaS_Load_ID__c;
            ldownRec.Unique_Value__c = ldownRec.Core_Unique_ID__c+';'+ldownRec.iPaaS_Load_ID__c+';'+ ldownRec.Core_Product_Org__c;
            String key = ldownRec.Level__c+';'+ldownRec.Core_Hierarchy_ID__c;
            ldownRec.Core_Product_Type__c=level1stRec.Core_L1_EPM_ID__c == '98836' ? 'FPGA'+';'+ldownRec.Level__c : null;
            //ldownRec.Core_IPS_Visible_Flag_External__c = ipsConfigMap.containsKey(key) &&  ipsConfigMap.get(key).IPS_Visible_Flag_External__c;
            ldownRec.Core_IPS_Visible_Flag_External__c = ipsConfigMap.containsKey(key) &&  ipsConfigMap.get(key).IPS_Visible_Flag_External__c && ((level1stRec.Core_Hierarchy_ID__c == '43'&&level == 2 && level1stRec.Core_L1_EPM_ID__c!='98836')||(level1stRec.Core_Hierarchy_ID__c == '43'&&level == 3));
            
            
            if (eligibleLevels.get(level)) {
                for (Product_fields_mapping__mdt mapping : mappings) {
                    String rollupValue = '';
                    for (Core_Products_Staging__c prodStaging : levelDataMap.get(lKey)) {
                        String val = String.valueOf(prodStaging.get(mapping.Product_staging_field__c));
                        if (String.isNotBlank(val)) {
                            if (val.contains(';')) {
                                for (String str : val.split(';')){
                                    //if(!rollupValue.containsIgnoreCase(str)){
                                    rollupValue = String.isBlank(rollupValue) ? str : rollupValue+';'+str;
                                    //}
                                }
                            } 
                            if(!(val.contains(';'))/* && !rollupValue.containsIgnoreCase(val)*/){
                                
                                rollupValue = String.isBlank(rollupValue) ? val : rollupValue+';'+val;
                            }
                        }   
                    }
                    
                    
                    if(String.isNotBlank(rollupValue)){
                        String rollupValueUnique = removeDuplicateEntries(rollupValue);
                        
                        if(charLimit255Fields.contains(mapping.Product_staging_field__c) && rollupValueUnique.length()> 255){
                            String rollupValueTrimmed = rollupValueUnique.subString(0,255);
                            
                            ldownRec.put(mapping.Product_staging_field__c,rollupValueTrimmed);
                        } else {
                            
                            ldownRec.put(mapping.Product_staging_field__c,rollupValueUnique);
                        }
                    }
                }
            }
            
            if( hierarchyId == Product_Staging_StaticConstants.vphId ||  ( hierarchyId == Product_Staging_StaticConstants.vplchId ))/*&& !Product_Staging_StaticConstants.vplchIpsFilter.contains(ldownRec.Core_Product_Name_EPM_ID__c)))*/ {
                prodStagingTobeInserted.add(ldownRec);
            }
            
            if(eligibleLevels.containsKey(level-1)){ 
                
                if(!levelDownDataMap.containsKey((String)ldownRec.get('Core_L'+(level-1)+'_EPM_ID__c'))){
                    levelDownDataMap.put((String)ldownRec.get('Core_L'+(level-1)+'_EPM_ID__c'),new List<Core_Products_Staging__c>{ldownRec});
                }
                else{
                    levelDownDataMap.get((String)ldownRec.get('Core_L'+(level-1)+'_EPM_ID__c')).add(ldownRec);
                }
                
            }
        }
        
        if(eligibleLevels.containsKey(level-1)){ 
            prodStagingTobeInserted.addAll(createLevelDatawithRollupIPS(levelDownDataMap,(level-1),hierarchyId,ipsConfigMap));
        }
        
        return prodStagingTobeInserted;
    }
    public static Core_Products_Staging__c processInbStngIPSRecords(Product_Inbound_Staging__c productLevel, Integer level, Map<String,Product_fields_mapping__mdt> ipsConfigMap){
        // List of attributes to be rolled up for IPS - VPH or VPLCH
        //moved to static
        //List<Product_fields_mapping__mdt> mappings = [SELECT Id,Product_staging_field__c,Inbound_staging_field__c FROM Product_fields_mapping__mdt WHERE Type__c='Rollup' AND Product_Org__c = 'IPS' AND Hierarchy_ID__c=:productLevel.Core_Hierarchy_ID__c];
        List<Product_fields_mapping__mdt> mappings = new List<Product_fields_mapping__mdt>();
        if(productLevel.Core_Hierarchy_ID__c == Product_Staging_StaticConstants.vphId && !IPS_Rollup_VPH_Mappings.isEmpty()){
            mappings =  IPS_Rollup_VPH_Mappings;
        }else if(productLevel.Core_Hierarchy_ID__c == Product_Staging_StaticConstants.vplchId && !IPS_Rollup_VPLCH_Mappings.isEmpty()){
            mappings = IPS_Rollup_VPLCH_Mappings;
        }
        Map<Integer,Boolean> eligibleLevels = new Map<Integer,Boolean>{
            5=>true,
                4=>true,
                3=>true,
                2=>true,
                1=>false
                };
                    Core_Products_Staging__c stagingRec = new Core_Products_Staging__c();
        if(productLevel.Core_Hierarchy_ID__c == Product_Staging_StaticConstants.vphId){                             
            for(String stageField: FPH_fieldMappingTable_VPH.keySet()) {
                stagingRec.put(stageField, productLevel.get(FPH_fieldMappingTable_VPH.get(stageField)));                            
            }
            for(String stageField: IPS_fieldMappingTable_VPH.keySet()) {
                stagingRec.put(stageField, productLevel.get(IPS_fieldMappingTable_VPH.get(stageField)));                            
            }
        }
        if(productLevel.Core_Hierarchy_ID__c == Product_Staging_StaticConstants.vplchId){
            for(String stageField: FPH_fieldMappingTable_VPLCH.keySet()) {
                stagingRec.put(stageField, productLevel.get(FPH_fieldMappingTable_VPLCH.get(stageField)));                            
            }
            for(String stageField: IPS_fieldMappingTable_VPLCH.keySet()) {
                stagingRec.put(stageField, productLevel.get(IPS_fieldMappingTable_VPLCH.get(stageField)));                            
            }
        }
        stagingRec.Core_Product_Name_EPM_ID__c = (String)productLevel.get('level_'+level+'_epm_id__c');
        stagingRec.Core_Product_Name__c =  (String)productLevel.get('level_'+level+'_epm_name__c');
        stagingRec.Core_Product_Org__c= 'IPS';         
        stagingRec.Core_Unique_ID__c=  (String)productLevel.get('level_'+level+'_epm_id__c');
        stagingRec.iPaaS_Load_ID__c = productLevel.iPaaS_Load_ID__c;
        
        stagingRec.Level__c = String.valueOf(level);
        stagingRec.Core_Hierarchy_ID__c = productLevel.Core_Hierarchy_ID__c;
        stagingRec.Core_Hierarchy_Name__c = productLevel.Core_Hierarchy_ID__c == '43' ? 'Valid Product Hierarchy' : 'Valid Platform Codename Hierarchy';
        stagingRec.Core_IsActive__c = true;
        //stagingRec.Core_IPS_Visible_Flag_External__c = ((productLevel.Core_Hierarchy_ID__c == '43' && (level == 2 || level == 3)) || (productLevel.Core_Hierarchy_ID__c == '59' && (level == 2 || level == 4)));
        stagingRec.Unique_Value__c = stagingRec.Core_Unique_ID__c+';'+stagingRec.iPaaS_Load_ID__c+';'+ stagingRec.Core_Product_Org__c;
        String key = stagingRec.Level__c+';'+stagingRec.Core_Hierarchy_ID__c;
        stagingRec.Core_Product_Type__c=productLevel.level_1_epm_id__c == '98836' ? 'FPGA'+';'+stagingRec.Level__c : null;
        //stagingRec.Core_IPS_Visible_Flag_External__c = ipsConfigMap.containsKey(key) &&  ipsConfigMap.get(key).IPS_Visible_Flag_External__c ;
        stagingRec.Core_IPS_Visible_Flag_External__c = ipsConfigMap.containsKey(key) &&  ipsConfigMap.get(key).IPS_Visible_Flag_External__c  && ((productLevel.Core_Hierarchy_ID__c == '43'&& level == 2 && productLevel.level_1_epm_id__c!='98836')||(productLevel.Core_Hierarchy_ID__c == '43'&&level == 3));
        
        if (eligibleLevels.containskey(level) &&  eligibleLevels.get(level)) {
            for (Product_fields_mapping__mdt mapping : mappings) {
                stagingRec.put(mapping.Product_staging_field__c,productLevel.get(mapping.Inbound_staging_field__c)); 
            }
        }
        
        return stagingRec;
    }
    
    public static Map<String,Product_fields_mapping__mdt> getSalesConfigurationMap () {
        
        Map<String,Product_fields_mapping__mdt> configMap = new Map<String,Product_fields_mapping__mdt>();
        for (Product_fields_mapping__mdt mapping : Product_fields_mapping__mdt.getall().Values()){
            if(mapping.Type__c=='Level Configuration' &&  mapping.Product_Org__c == 'Sales'){
                if(!configMap.containsKey(mapping.Level__c+';'+mapping.Hierarchy_ID__c+';'+mapping.Product_Type_EMP_Id__c)){
                    configMap.put(mapping.Level__c+';'+mapping.Hierarchy_ID__c+';'+mapping.Product_Type_EMP_Id__c, mapping);
                }
            }
        }
        
        return configMap;
    }
    
    public static Map<String,Product_fields_mapping__mdt> getIPSConfigurationMap () {
        
        Map<String,Product_fields_mapping__mdt> configMap = new Map<String,Product_fields_mapping__mdt>();
        for (Product_fields_mapping__mdt mapping : Product_fields_mapping__mdt.getall().Values()){
            if(mapping.Type__c=='Level Configuration' &&  mapping.Product_Org__c == 'IPS'){
                if(!configMap.containsKey(mapping.Level__c+';'+mapping.Hierarchy_ID__c)){
                    configMap.put(mapping.Level__c+';'+mapping.Hierarchy_ID__c, mapping);
                }
            }
            
        }
        return configMap;        
    } 
    
    public static Core_Products_Staging__c repeatLogicSales(Boolean isLevel5,Product_Inbound_Staging__c pis ){
        
        Core_Products_Staging__c stageRec = new Core_Products_Staging__c();
        if(pis.Core_Hierarchy_ID__c == '43'){
            // L1
            stageRec.Core_Product_Type_EPM_ID__c = pis.level_1_epm_id__c;
            stageRec.Core_Product_Type__c = pis.level_1_epm_name__c;
            // L2
            stageRec.Core_Product_Family_EPM_ID__c = String.isNotBlank(pis.level_2_epm_id__c) ? pis.level_2_epm_id__c :stageRec.Core_Product_Type_EPM_ID__c;
            stageRec.Core_Product_Family__c = String.isNotBlank(pis.level_2_epm_name__c) ? pis.level_2_epm_name__c :stageRec.Core_Product_Type__c;
            // L3
            stageRec.Core_Product_Series_EPM_ID__c = String.isNotBlank(pis.level_3_epm_id__c) ? pis.level_3_epm_id__c :stageRec.Core_Product_Family_EPM_ID__c;
            stageRec.Core_Product_Series__c = String.isNotBlank(pis.level_3_epm_name__c) ? pis.level_3_epm_name__c :stageRec.Core_Product_Family__c;
            
            // L5
            if(isLevel5){
                
                // L4
                stageRec.Core_Product_Group_EPM_ID__c = String.isNotBlank(pis.level_4_epm_id__c) ? pis.level_4_epm_id__c :stageRec.Core_Product_Series_EPM_ID__c;
                stageRec.Core_Product_Group__c	 = String.isNotBlank(pis.level_4_epm_name__c) ? pis.level_4_epm_name__c :stageRec.Core_Product_Series__c;
                //l5
                stageRec.Core_Product_Name_EPM_ID__c = String.isNotBlank(pis.level_5_epm_id__c) ? pis.level_5_epm_id__c :stageRec.Core_Product_Group_EPM_ID__c;
                stageRec.Core_Product_Name__c = String.isNotBlank(pis.level_5_epm_name__c) ? pis.level_5_epm_name__c :stageRec.Core_Product_Group__c;
                
            }else{
                //l4
                stageRec.Core_Product_Name_EPM_ID__c = String.isNotBlank(pis.level_4_epm_id__c) ? pis.level_4_epm_id__c :stageRec.Core_Product_Series_EPM_ID__c;
                stageRec.Core_Product_Name__c = String.isNotBlank(pis.level_4_epm_name__c) ? pis.level_4_epm_name__c :stageRec.Core_Product_Series__c;
                
            }
        }else{
            // L1
            stageRec.Core_Platform_EPM_ID__c = pis.level_1_epm_id__c;
            stageRec.Core_Platform_Name__c = pis.level_1_epm_name__c;
            // L2
            stageRec.Core_Platform_Config_EPM_ID__c = String.isNotBlank(pis.level_2_epm_id__c) ? pis.level_2_epm_id__c :stageRec.Core_Platform_EPM_ID__c;
            stageRec.Core_Platform_Config__c = String.isNotBlank(pis.level_2_epm_name__c) ? pis.level_2_epm_name__c :stageRec.Core_Platform_Name__c;
            // L3
            stageRec.Core_Product_Type_EPM_ID__c = String.isNotBlank(pis.level_3_epm_id__c) ? pis.level_3_epm_id__c :stageRec.Core_Platform_Config_EPM_ID__c;
            stageRec.Core_Product_Type__c = String.isNotBlank(pis.level_3_epm_name__c) ? pis.level_3_epm_name__c :stageRec.Core_Platform_Config__c;
            // L4
            stageRec.Core_Code_Name_EPM_ID__c = String.isNotBlank(pis.level_4_epm_id__c) ? pis.level_4_epm_id__c :stageRec.Core_Product_Type_EPM_ID__c;
            stageRec.Core_Code_Name__c = String.isNotBlank(pis.level_4_epm_name__c) ? pis.level_4_epm_name__c :stageRec.Core_Product_Type__c;
            //l5
            stageRec.Core_Product_Name_EPM_ID__c = String.isNotBlank(pis.level_5_epm_id__c) ? pis.level_5_epm_id__c :stageRec.Core_Code_Name_EPM_ID__c;
            stageRec.Core_Product_Name__c = String.isNotBlank(pis.level_5_epm_name__c) ? pis.level_5_epm_name__c :stageRec.Core_Code_Name__c;
        }
        return stageRec;
    }
    
    
    public static void createLogEntryAndNotifyUser(String message,String ipaasId,String className, Integer QNumber, String ProductName){        
        
        //create log for any class failure
        insert (new Core_Log_Entry__c(
            Core_Details__c = message,
            Core_XID__c = ipaasId,
            Core_Message__c =  className+'-- '+message,
            Core_Severity__c = 'High',
            Core_Project__c='Product',
            Core_Origin__c=className,
            Core_When__c = System.now())
               );
        //to notify users when class is failed
        Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
        if (mapFunctionalityNameTriggerExecution.containsKey('AllowProductErrorNotification') && mapFunctionalityNameTriggerExecution.get('AllowProductErrorNotification').Core_Active__c) {
            Messaging.SingleEmailMessage  mail = new Messaging.SingleEmailMessage ();            
            String[] toAddresses  = Label.ProductSupportEmail.split(';');             
            mail.setToAddresses(toAddresses);
            mail.setSubject('Product Integration: '+className +' Failure Notification');
            String body = 'Hi,<br><br>';
            body += 'This is to notify on the '+ className +' Job Failure. <br><br>';
            body += 'Job Details: <br>';      
            body += 'Error - <b>' + message + '</b>, <br>';  
            body += 'IpaasLoadId - ' + ipaasId + ', <br>';
            if(QNumber != null && ProductName != null){
                body += 'Queueable Number - ' + QNumber + ', <br>'; 
                body += 'Product Name - ' + ProductName + ', <br>';
            }                       
            body += 'Time - ' + system.now() + '.'; 
            mail.setHtmlBody(body);
            Messaging.sendEmail(new Messaging.SingleEmailMessage []{mail},false);
        }                 
    }  
    
    //Added to check IPS VPLCH missing records
    public static List<Core_Products_Staging__c> processInbStngIPSVplchRecords(Map<String,Product_stageQueueable_IPS.InputLevelWrapper> ipsPreProcessMap,  Map<String,Product_fields_mapping__mdt> ipsConfigMap){
        List<Core_Products_Staging__c> stgRecList = new List<Core_Products_Staging__c>();
        Map<String,Core_Products_Staging__c> stgUidRecMap = new Map<String,Core_Products_Staging__c> ();
            system.debug('ipsPreProcessMap size utility>>'+ipsPreProcessMap.size());

            for (Product_fields_mapping__mdt  mappingRec : Product_fields_mapping__mdt.getall().Values()) {
                if(mappingRec.Inbound_staging_field__c != null && mappingRec.FPH_Field__c!=null && mappingRec.Type__c=='Mapping' && mappingRec.Product_Org__c=='FPH'){
                    if(mappingRec.Hierarchy_ID__c == Product_Staging_StaticConstants.vplchId){
                        FPH_fieldMappingTable_VPLCH.put(mappingRec.Product_staging_field__c,mappingRec.Inbound_staging_field__c);                    
                    }
                }
                if(mappingRec.Inbound_staging_field__c != null && mappingRec.Product_staging_field__c !=null && mappingRec.Type__c=='Mapping' && mappingRec.Product_Org__c=='IPS'){
                    if(mappingRec.Hierarchy_ID__c == Product_Staging_StaticConstants.vplchId){
                        IPS_fieldMappingTable_VPLCH.put(mappingRec.Product_staging_field__c,mappingRec.Inbound_staging_field__c);                    
                    }
                }
            }   
        for(String key : ipsPreProcessMap.keyset()){

            Product_Inbound_Staging__c productLevel = ipsPreProcessMap.get(key).record;
            System.debug('productLevel --- '+productLevel);
            Core_Products_Staging__c stagingRec = new Core_Products_Staging__c();            
            String level= ipsPreProcessMap.get(key).Level ;
            System.debug('level --- '+level);
            if(productLevel.Core_Hierarchy_ID__c == Product_Staging_StaticConstants.vplchId){
                for(String stageField: FPH_fieldMappingTable_VPLCH.keySet()) {
                    stagingRec.put(stageField, productLevel.get(FPH_fieldMappingTable_VPLCH.get(stageField)));                            
                }
                for(String stageField: IPS_fieldMappingTable_VPLCH.keySet()) {
                    stagingRec.put(stageField, productLevel.get(IPS_fieldMappingTable_VPLCH.get(stageField)));                            
                }
            }
            stagingRec.Core_Product_Name_EPM_ID__c = (String)productLevel.get('level_'+level+'_epm_id__c');
            stagingRec.Core_Product_Name__c =  (String)productLevel.get('level_'+level+'_epm_name__c');
            stagingRec.Core_Product_Org__c= 'IPS';         
            stagingRec.Core_Unique_ID__c=  (String)productLevel.get('level_'+level+'_epm_id__c');
            stagingRec.iPaaS_Load_ID__c = productLevel.iPaaS_Load_ID__c;    
            stagingRec.Level__c = String.valueOf(level);
            stagingRec.Core_Hierarchy_ID__c = productLevel.Core_Hierarchy_ID__c;
            stagingRec.Core_Hierarchy_Name__c = productLevel.Core_Hierarchy_ID__c == '43' ? 'Valid Product Hierarchy' : 'Valid Platform Codename Hierarchy';
            stagingRec.Core_IsActive__c = true;
            stagingRec.Unique_Value__c = stagingRec.Core_Unique_ID__c+';'+stagingRec.iPaaS_Load_ID__c+';'+ stagingRec.Core_Product_Org__c; 
            String keyFlag = stagingRec.Level__c+';'+stagingRec.Core_Hierarchy_ID__c;
            stagingRec.Core_IPS_Visible_Flag_External__c = ipsConfigMap.containsKey(keyFlag) &&  ipsConfigMap.get(keyFlag).IPS_Visible_Flag_External__c;
            if(!vplchIpsEpmFilter.contains(stagingRec.Core_Unique_ID__c)){
               stgUidRecMap.put(stagingRec.Core_Unique_ID__c,stagingRec);
            }
        }
        
        if(stgUidRecMap.values().size() > 0){
            stgRecList = stgUidRecMap.values();
        }
        return stgRecList;
    }
    @future
    public static void insertLogEntries(String logEntryListString){
        List<Core_Log_Entry__c> LogEntriesToInsert = new List<Core_Log_Entry__c>();
        LogEntriesToInsert = (List<Core_Log_Entry__c>)json.deserialize(logEntryListString,List<Core_Log_Entry__c>.class);
        system.debug('LogEntriesToInsert size --- '+LogEntriesToInsert.size());
        Database.insert(LogEntriesToInsert,false);
    }

}