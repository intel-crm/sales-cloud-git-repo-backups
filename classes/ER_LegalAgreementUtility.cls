/******************************************************************************************************************************************
Class Name  : ER_LegalAgreementUtility
Version     : 1.0 
Created Date: 05 JULY 2021
Function    : Handles updating Legal agreement criteria to success
Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------      
* Anand TB            		05/07/2021              Original version 
*****************************************************************************************************************************************/


public with Sharing  class ER_LegalAgreementUtility {
    
    /*Commented as part of EBR framework and implemented the logic with Flows
    //Sets LA criteria if LA sent in request matches in SF
    public static void updateLA(List<PRM_Registration_Request__c> regRequest){
        Set<String> allPASet = new Set<String>();
        for(PRM_PartnerAgreement__c pa : [Select Id,Name,PRM_Channel_Program_Id__c,PRM_Language_Codes__c,PRM_Partner_Role__c,PRM_InActive_Ind__c,PRM_Agreement_Cd__c
                                          From PRM_PartnerAgreement__c where PRM_InActive_Ind__c = false])
        {            
            allPASet.add(pa.PRM_Agreement_Cd__c);
        }
        for(PRM_Registration_Request__c rr : regRequest)
        {    
            // Check if record type is not EV
            if(rr.recordTypeID != Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId())
            {
                boolean status = false ;
                //check id status is not rejected and input request has LA and LA criteria is Pending
                if(rr.PRM_Status__c != Label.PRM_Status_Rejected && rr.PRM_Legal_Agreements__c != null && 
                   rr.PRM_Legal_Agreement_Criteria__c == Label.PRM_Pending){
                       if(allPASet.size()>0) {
                           for(String laName : rr.PRM_Legal_Agreements__c.split(';'))
                           {   
                               //Set status to true if input reqest LA matches with SF
                               status = allPASet.contains(laName) ? true : false;                                                          
                           }                           
                       }
                       rr.PRM_Legal_Agreement_Criteria__c = status ? Label.PRM_Success : Label.PRM_Fail;
                   }                
            }            
        }
    }*/
    
    
}