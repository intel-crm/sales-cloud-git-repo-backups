public with sharing class CSF_Product_InboundStagingTriggerHelper {	
    public static void populateMMattributesFields (List<Product_Inbound_Staging__c> inboundRecords) {
        List<Product_Inbound_Staging__c> inboundRecordsFiltered = new List<Product_Inbound_Staging__c>();
        Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
        boolean mmIdBlankSwitch = false; // This switch is used to enable MMID overwrite logic. If MMID attributes are blank, then we would not override the exisitng values for L5 record. However, there is no impact on L4 Level insertion.
        if(mapFunctionalityNameTriggerExecution.containsKey('AllowMmidBlankLogic') && mapFunctionalityNameTriggerExecution.get('AllowMmidBlankLogic').Core_Active__c){
            mmIdBlankSwitch = true;
        }
        
        
        for (Product_Inbound_Staging__c inboundStaging : inboundRecords) { 
            if (inboundStaging.Core_Hierarchy_ID__c == '43' && String.isNotBlank(inboundStaging.L5_mmid__c)) {
                inboundRecordsFiltered.add(inboundStaging);                
            }// added by shubhra
            else if(mmIdBlankSwitch == true &&  inboundStaging.Core_Hierarchy_ID__c == '43' && String.isBlank(inboundStaging.L5_mmid__c)){
                inboundStaging.Is_MMID_Blank__c=true;
            }
        }
        
        Map<String,Product_fields_mapping__mdt> configMap = new Map<String,Product_fields_mapping__mdt>();
        List<Product_fields_mapping__mdt> mmidAttributeMetadata = new List<Product_fields_mapping__mdt>();
        
        for (Product_fields_mapping__mdt mapping : Product_fields_mapping__mdt.getall().Values()){
            if(mapping.Type__c=='Level Configuration' &&  mapping.Product_Org__c == 'Sales' && mapping.Level__c=='5' && mapping.Hierarchy_ID__c=='43'){
                if(!configMap.containsKey(mapping.Product_Type_EMP_Id__c)){
                    configMap.put(mapping.Product_Type_EMP_Id__c, mapping);
                }
            }
            else if(mapping.Type__c=='MMID Attribute'){
                mmidAttributeMetadata.add(mapping);
            }
            
        }
        
        for (Product_Inbound_Staging__c inboundStaging : inboundRecordsFiltered) {
            List<String> mmIds  = inboundStaging.L5_mmid__c.split(';');
            Product_fields_mapping__mdt salesConfig = configMap.get(inboundStaging.level_1_epm_id__c);
            Map<String,Product_Inbound_Staging__c> mmAttributeMap = new Map<String,Product_Inbound_Staging__c>();
            Product_Inbound_Staging__c inbStngRecord=new Product_Inbound_Staging__c();
            
            for (String mmId: mmIds) { 
                Product_Inbound_Staging__c inboundStagingTmp = new Product_Inbound_Staging__c();
                if(inboundStaging.Restriction_Code__c != null){
                    for (String code : inboundStaging.Restriction_Code__c.split(';')) {
                        List<String> codeSplit = code.split('-');
                        if(codeSplit != null && !codeSplit.isEmpty() && codeSplit[0] == mmId){
                            inboundStagingTmp.Restriction_Code__c = codeSplit[1];
                        }    
                    }
                }
                
                
                for (Product_fields_mapping__mdt mapping: mmidAttributeMetadata) {
                    if (inboundStaging.get(mapping.Inbound_staging_field__c) != null) {
                        for (String attr : ((String)inboundStaging.get(mapping.Inbound_staging_field__c)).split(';')) {
                            List<String> attrSplit = attr.split('-');
                            if(attrSplit != null && !attrSplit.isEmpty() && attrSplit[0] == mmId){
                                inboundStagingTmp.put(mapping.Inbound_staging_field__c , attr.remove(attrSplit[0]+'-'));
                            }    
                        }
                    }
                }
                mmAttributeMap.put(mmId,inboundStagingTmp);
            }
            
            if(!mmAttributeMap.isEmpty()){
                for (String mmId : mmAttributeMap.keySet()) {
                    Product_Inbound_Staging__c inboundStagingTmp = mmAttributeMap.get(mmId);
                        Product_Inbound_Staging__c inbStngRec=updateWRFields(inboundStaging, inboundStagingTmp, salesConfig, mmidAttributeMetadata,mmid);
                        inbStngRecord=updateWORFields(inbStngRec, inboundStagingTmp, mmidAttributeMetadata);
                    
                }
            }
            removeDuplicateEntries(inbStngRecord, mmidAttributeMetadata);
        }
    }
    
    //update WR Fields
    public static Product_Inbound_Staging__c updateWRFields(Product_Inbound_Staging__c inboundStaging, Product_Inbound_Staging__c inboundStagingTmp, Product_fields_mapping__mdt salesConfig, List<Product_fields_mapping__mdt> mmidAttributeMetadata,String mmId) {
        if (salesConfig != null  && inboundStagingTmp!=null && inboundStagingTmp.Restriction_Code__c != null && salesConfig.Restriction_Code__c != null){
            if (Integer.valueOf(inboundStagingTmp.Restriction_Code__c) <= Integer.valueOf(salesConfig.Restriction_Code__c)) {
                if(inboundStaging.L5_mmid_WR__c == null || !inboundStaging.L5_mmid_WR__c.containsIgnoreCase(mmId)){
                    inboundStaging.L5_mmid_WR__c = inboundStaging.L5_mmid_WR__c == null ? mmId :inboundStaging.L5_mmid_WR__c +';'+mmId;
                }
                for (Product_fields_mapping__mdt mapping: mmidAttributeMetadata) {
                    if(inboundStagingTmp.get(mapping.Inbound_staging_field__c) != null){
                        inboundStaging.put(mapping.Inbound_staging_field_WR__c ,inboundStaging.get(mapping.Inbound_staging_field_WR__c) == null ? inboundStagingTmp.get(mapping.Inbound_staging_field__c) : inboundStaging.get(mapping.Inbound_staging_field_WR__c) +';'+inboundStagingTmp.get(mapping.Inbound_staging_field__c));
                    }
                }
            }
        }
        return inboundStaging;
    }
    
    //update WOR Fields
    public static Product_Inbound_Staging__c updateWORFields(Product_Inbound_Staging__c inboundStaging, Product_Inbound_Staging__c inboundStagingTmp, List<Product_fields_mapping__mdt> mmidAttributeMetadata) {
        for (Product_fields_mapping__mdt mapping: mmidAttributeMetadata) {
            if(inboundStagingTmp.get(mapping.Inbound_staging_field__c) != null){
                inboundStaging.put(mapping.Inbound_staging_field_WOR__c ,inboundStaging.get(mapping.Inbound_staging_field_WOR__c) == null ? inboundStagingTmp.get(mapping.Inbound_staging_field__c) : inboundStaging.get(mapping.Inbound_staging_field_WOR__c) +';'+inboundStagingTmp.get(mapping.Inbound_staging_field__c));
            }
        }
        return inboundStaging;
    } 
    
    
    
    // Code to remove duplicate from rolled-up value
    public static void removeDuplicateEntries(Product_Inbound_Staging__c inboundStaging, List<Product_fields_mapping__mdt> mmidAttributeMetadata) {
        for (Product_fields_mapping__mdt mapping : mmidAttributeMetadata) {
            if (inboundStaging.get(mapping.Inbound_staging_field_WR__c) != null) {
                inboundStaging.put(mapping.Inbound_staging_field_WR__c, Product_Utility.removeDuplicateEntries((String) (inboundStaging.get(mapping.Inbound_staging_field_WR__c))));
            }
            if (inboundStaging.get(mapping.Inbound_staging_field_WOR__c) != null) {
                inboundStaging.put(mapping.Inbound_staging_field_WOR__c, Product_Utility.removeDuplicateEntries((String) (inboundStaging.get(mapping.Inbound_staging_field_WOR__c))));
            }
        }
    }
}