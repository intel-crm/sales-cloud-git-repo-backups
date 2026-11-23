global class DummyClass_InsertInboundtoStg implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String ipaas = '123';
        String query= 'Select Id,level_1_epm_id__c,level_2_epm_id__c,level_3_epm_id__c,level_4_epm_id__c,level_5_epm_id__c,level_1_epm_name__c,level_2_epm_name__c,level_3_epm_name__c,level_4_epm_name__c,level_5_epm_name__c,Core_Hierarchy_ID__c  from Product_Inbound_Staging__c where iPaaS_Load_ID__c =:ipaas';
        return Database.getQueryLocator(query);
       
    }
    global void execute(Database.BatchableContext bc, List<Product_Inbound_Staging__c> inboundrec){
        
        List<Core_Products_Staging__c> StgList =new List<Core_Products_Staging__c>();
        if(!inboundrec.isEmpty() && inboundrec.size()>0){
            System.debug('InboundRecord==>'+inboundrec);
            for(Product_Inbound_Staging__c inb:inboundrec){
               Core_Products_Staging__c stgrec= new Core_Products_Staging__c();
                stgrec.Core_Hierarchy_ID__c=inb.Core_Hierarchy_ID__c;
                stgrec.Core_Product_Type_EPM_ID__c=inb.level_1_epm_id__c;
                stgrec.Core_Product_Family_EPM_ID__c=inb.level_2_epm_id__c;
                stgrec.Core_Product_Series_EPM_ID__c=inb.level_3_epm_id__c;
                stgrec.Core_Product_Group_EPM_ID__c=inb.level_4_epm_id__c;
                stgrec.Core_Product_Name_EPM_ID__c=inb.level_5_epm_id__c;
                stgrec.Core_Product_Type__c=inb.level_1_epm_name__c;
                stgrec.Core_Product_Family__c=inb.level_2_epm_name__c;
                stgrec.Core_Product_Series__c=inb.level_3_epm_name__c;
                stgrec.Core_Product_Group__c=inb.level_4_epm_name__c;
                stgrec.Core_Product_Name__c=inb.level_5_epm_name__c;
                stgrec.Core_Unique_ID__c=inb.level_5_epm_id__c+';'+inb.level_4_epm_id__c+';'+inb.level_3_epm_id__c+';'+inb.level_2_epm_id__c+';'+inb.level_1_epm_id__c;
                stgrec.Core_Product_Org__c ='Sales';
                stgrec.iPaaS_Load_ID__c='123';
                System.debug('StagingRecord==>'+stgrec);
                StgList.add(stgrec);
                System.debug('StagingRecordList==>'+StgList);
            }
        }
        if(!StgList.isEmpty()){
            
            insert StgList;
        }
        
    }    
    global void finish(Database.BatchableContext bc){
        
    }    
}