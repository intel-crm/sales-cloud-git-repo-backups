public with sharing class Core_MDF_Inactivate_Bank_Controller{
   
    /* @AuraEnabled 
    public static Map<String,String> getPiklistValues(){ 
        
        Schema.SObjectType objectType = Schema.getGlobalDescribe().get('Core_MDF_Bank__c');
        Map<String,String> MapValueLabel = new Map<String,String>();
        Map<String, SObjectField> fieldMap = objectType.getDescribe().fields.getMap();
        //Schema.SobjectField theField = fieldMap.get('Core_MDF_Inactive_by_Program_nm__c');
        Schema.DescribeFieldResult fieldResult = theField.getDescribe();
        List<Schema.PicklistEntry> values = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry v : values) {
            MapValueLabel.put(v.getLabel(),v.getValue());        
        }       
        System.debug('MapValueLabel'+MapValueLabel);
        return MapValueLabel;
    }   
      
   
    @AuraEnabled
    public static void saveInactiveProgramData(Id bankId,List<String> InactiveProgram, Date InactiveDate){
        Core_MDF_Bank__c bankObj = NULL;
        Set<Id> inactiveBankSet = new Set<Id>();
        List<String> inactiveProgramList = new List<String>();
        List<String> programList = new List<String>();
        // Map of Channel Program Id and Channel Program Name
        Map <String , String> channelProgramNameMap = new Map<String , String>();
        Map <String , String> channelProgramNameIdSetMap = new Map<String, String>();
        try{
            
            bankObj = [SELECT id,Core_MDF_Inactive_by_Program_nm__c,Core_MDF_Inactive_Date_dt__c FROM Core_MDF_Bank__c WHERE id =: bankId LIMIT 1];
            bankObj.Core_MDF_Inactive_Date_dt__c = InactiveDate;
            for(String str : InactiveProgram){
                bankObj.Core_MDF_Inactive_by_Program_nm__c = bankObj.Core_MDF_Inactive_by_Program_nm__c + ';' + str;
            }
            System.debug('bankObj.Core_MDF_Inactive_by_Program_nm__c'+bankObj.Core_MDF_Inactive_by_Program_nm__c);
           
                /** if(bankObj.Core_MDF_Inactive_by_Program_nm__c != NULL && bankObj.Core_MDF_Program__c != NULL){
                    
                    inactiveProgramList = bankObj.Core_MDF_Inactive_by_Program_nm__c.split(Label.Core_MDF_Semicolon);               
                    programList = bankObj.Core_MDF_Program__c.split(Label.Core_MDF_Semicolon);
                    inactiveBankSet.add(bankId);
                    
                }
            
            Map channel program Id to map
            for(Core_MDF_BankProgram_Entitlement_Mapping__mdt bpem : ([SELECT Core_MDF_Bank_Program_Name__c, Core_MDF_Channel_Program__c, Core_MDF_Entitlement_Name__c
                                                                       FROM Core_MDF_BankProgram_Entitlement_Mapping__mdt])){
                                                                           channelProgramNameMap.put(bpem.Core_MDF_Bank_Program_Name__c,bpem.Core_MDF_Channel_Program__c);  
                                                                           for(String pgrm : inactiveProgramList){
                                                                               if(bpem.Core_MDF_Bank_Program_Name__c==pgrm){
                                                                                   channelProgramNameIdSetMap.put(bpem.Core_MDF_Bank_Program_Name__c,bpem.Core_MDF_Channel_Program__c);
                                                                               }
                                                                           }
                                                                       }
            
            
            List<String> claimStatusStrList = Label.Core_MDF_Claim_Status_for_Inactive_Bank.split(';');
            if(claimStatusStrList != NULL && inactiveBankSet != NULL && inactiveProgramList != NULL){
                //Fetching the bank with the inactive selection true and has active and hold claims
                for(String prgm:channelProgramNameIdSetMap.values()){
                    for(PartnerFundClaim pfc : [SELECT Id,Core_MDF_Status__c, Core_MDF_Bank__c
                                                FROM PartnerFundClaim
                                                WHERE Core_MDF_Bank__c =: bankId AND
                                                Core_MDF_Status__c IN :claimStatusStrList AND
                                                Core_MDF_Program__c  =:prgm]){
                                                    //Throwing the error for the bank fetched with active and hold claims
                                                    Trigger.newMap.get(pfc.Core_MDF_Bank__c).addError(Label.Core_MDF_Inactive_Bank_Error);
                                                }
                }
            } */   
             /*update(bankObj);
        }
        catch(Exception e){
            
        }
    } */
}