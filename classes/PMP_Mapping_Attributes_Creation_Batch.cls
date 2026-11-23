public with sharing class PMP_Mapping_Attributes_Creation_Batch implements Database.Batchable<sObject> {
    public List<Core_Log_Entry__c> logEntriesMPattrMappings = new List<Core_Log_Entry__c>();
    public Set<Id> companyIds = new Set<Id>();
    public PMP_Mapping_Attributes_Creation_Batch(){}
    public PMP_Mapping_Attributes_Creation_Batch(Set<Id> recordIds){
        companyIds.addAll(recordIds);		
    }
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'select PMP_Marketing_Profile_Id__c,PMP_Account_Specialty__c, PMP_Partner_Segment_Nm__c,PMP_Partner_Program_nm__c,PMP_IPA_Badge_Tier_Txt__c from pmp_company__c';
        String whereCondition='';        
        if(!companyIds.isEmpty() && companyIds.size()>0){
			whereCondition = ' where id in :companyIds';
            query+=whereCondition;            
        }
        return Database.getQueryLocator(query);        
    }
    
    public void execute(Database.BatchableContext BC, List<PMP_Company__c> strfntLst){        
        
        List<Id> mpAttributesMappingLst = new List<Id>();
        Set<Id> deleteFailedRecIds = new Set<Id>();
        
        try{
            if(!strfntLst.isEmpty() ){
                for(PMP_Marketing_Profile_Attributes_Mapping__c mappingRecord : [
                    select Id, Name, PMP_Marketing_Profile_Id__c, PMP_Partner_Role__c, PMP_Partner_Segment__c, PMP_Partner_Specialty__c, PMP_Partner_Tier__c from PMP_Marketing_Profile_Attributes_Mapping__c 
                    where PMP_Marketing_Profile_Id__c in :strfntLst]){
                        mpAttributesMappingLst.add(mappingRecord.Id);
                    }
                
                if(!mpAttributesMappingLst.isEmpty()){
                    Database.DeleteResult[] delRes =  Database.delete(mpAttributesMappingLst, false);  
                }
                // passing pmp_company__c record ids to insert new records
                PMP_AccountBenefitPartnerUtility.InsertCompanyAttributeMappingRecords(strfntLst);
            }    
        }catch(Exception ex){logEntriesMPattrMappings.add(new Core_Log_Entry__c(Core_Message__c = ex.getMessage(), Core_Origin__c = 'PMP_Batch_MP_Attributes_Mapping.execute', Core_Severity__c = 'High', Core_When__c=System.Now(), Core_Project__c = 'IPA', Core_sObjectId__c = null));
        }finally{
            if(!logEntriesMPattrMappings.isEmpty() && logEntriesMPattrMappings.size()>0){insert logEntriesMPattrMappings;}
        }
    }
    public void finish(Database.BatchableContext BC){
        System.debug('Batch Job Finished');
    }    
}