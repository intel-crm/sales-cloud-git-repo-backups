public class PRD_ProcessInboundProducts implements Database.Batchable<sObject>{
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
       String query = 'Select Id,L4_CodenameText__c, L4_CodenameText_rawValue__c, L4_CoreCount__c, L4_DriveCapacity__c, L4_Filter_Family__c, L4_Filter_Family_rawValue__c, L4_MaxTDP__c, L4_ProductGroup__c, L4_ProductGroup_rawValue__c, L4_VProTechnology__c, L5_CustomCustomerCode__c, L5_CustomIndicator__c, L5_Division_withBracket__c, L5_Division_withoutBracket__c, L5_FamilyName__c, L5_Group_withBracket__c, L5_Group_withoutBracket__c, L5_MaterialStatusCode__c, L5_mmid__c, L5_Opcode__c, L5_OrderingCode__c, level_1_epm_id__c, level_1_epm_name__c, level_2_epm_id__c, level_2_epm_name__c, level_3_epm_id__c, level_3_epm_name__c, level_4_epm_id__c, level_4_epm_name__c, level_5_epm_id__c, level_5_epm_name__c,iPaaS_Load_ID__c from Product_Inbound_Staging__c';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Product_Inbound_Staging__c> products){
        List<Core_Products_Staging__c> stagingRecs = new List<Core_Products_Staging__c>();
        stagingRecs.addAll(PRD_ProcessInboundProductsHelper.createIPSProducts(products));
        stagingRecs.addAll(PRD_ProcessInboundProductsHelper.createFPHs(products));

        if(!stagingRecs.isEmpty()){
            Database.insert(stagingRecs,false);
        }

    }
    
    public void finish(Database.BatchableContext BC){
        
    }

}