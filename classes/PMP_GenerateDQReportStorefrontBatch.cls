/****************************************************************************************************************************************
* Class Name  : PMP_GenerateDQReportStorefrontBatch 
* Version     : 1.0 
* Created Date: 22/08/2022 
* Modification Log :
*
* Developer                           Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Yashasvi Aggarwal                 22/08/2022            This batch class is used to generate DQ reports for Storefront, batch size should be always 1
*****************************************************************************************************************************************/
global class PMP_GenerateDQReportStorefrontBatch implements Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'Select Id,PMP_Company_Information_Language_Nm__c,Name,PMP_Account_Tag_Line__c,PMP_Account_Dsc__c,PMP_IPA_Badge_Tier_Txt__c,' +
                       'PMP_Partner_Benefit_Type__c,PMP_Benefit_Update_Ind__c,PMP_Partner_Segment_Nm__c,PMP_Partner_Program_nm__c,PMP_Account_Specialty__c,PMP_Company_Lifecycle_Status_Nm__c' +
                       ' from PMP_Company__c';
        
        return Database.getQueryLocator(query);   
    }
    
    global void execute(Database.BatchableContext bc, List<sObject> scope){
        if(scope !=null){
            List<PMP_Company__c> publishedPartnerList = new List<PMP_Company__c>();
            List<PMP_Company__c> translationPartnerList = new List<PMP_Company__c>();
            for(PMP_Company__c pc : (List<PMP_Company__c>)scope)
            {
                if(pc.PMP_Company_Lifecycle_Status_Nm__c =='Published')
                {
                    publishedPartnerList.add(pc);
                }
                if(pc.PMP_Company_Lifecycle_Status_Nm__c =='Draft' || pc.PMP_Company_Lifecycle_Status_Nm__c =='Admin Review' 
                   || pc.PMP_Company_Lifecycle_Status_Nm__c =='Update Required')
                {
                    translationPartnerList.add(pc);
                }
            }
            if(!publishedPartnerList.isEmpty())
            {
                PMP_GenerateDQReportUtility.getCoveoIssueMPIRecords(publishedPartnerList);
                PMP_GenerateDQReportUtility.getOPIDIssueMPIReccords(publishedPartnerList);
                PMP_GenerateDQReportUtility.getStorefrontImageIssueRecords(publishedPartnerList);
            }
            if(!translationPartnerList.isEmpty())
            {
                PMP_GenerateDQReportUtility.getPartnerTranslationRecords(translationPartnerList);
            }                
        }     
    }   
    
    global void finish(Database.BatchableContext bc){
        //IPA2.0 - As part of TWC729-7977 commented the entire class
        //Database.executeBatch(new PMP_GenerateDQReportOfferingBatch(),1);  
    } 
}