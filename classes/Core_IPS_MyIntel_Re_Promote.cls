/*********************************************
* Name : Core_IPS_MyIntel_Re_Promote 
* Author : Popcornapps
* Date Created : 04 July 2021
* Description : This class will call queueable apex class when we manually Re-Promte case when myintel outbound message is failed.
* Test Class : Core_IPS_MyIntel_3_0_Test
* @User Story: US1046605
************************************************/
Global without sharing class Core_IPS_MyIntel_Re_Promote {
    
    /* This method will be called from clasic when JS Button is clicked. 
* Author : Popcornapps
**/
    webservice Static void retryMechForCase(Id recordId){
        prepareDataForQueableClass(recordId);
    } 
    
    /* This method will be called from Lightning when Button is clicked. 
* Author : Popcornapps
**/
    @auraEnabled
    public static void retryCallFromLightning(Id recordId){
        prepareDataForQueableClass(recordId);
        
    }
    
    /* Description : method to get deatils of outbound message based on record ID and calling queueable apex class. 
* Author : Popcornapps
**/
    public Static void prepareDataForQueableClass(Id recordId){
        try{
            String operationType = '';
	    List<Case> caseList = new List<Case>();
	    Core_IPS_MyIntel_Outbound_Message__c myintelOutMsg;    
            //FLS check added -Venugopal
            if(Core_IPS_MyIntel_Outbound_Message__c.SObjectType.getDescribe().isAccessible()){
                 myintelOutMsg = [Select Id,Name,Core_IPS_Operation_Type__c,Core_IPS_Case_ID__c From Core_IPS_MyIntel_Outbound_Message__c Where Id =:recordId Limit 1];
            }
                if(myintelOutMsg != null){
                operationType = myintelOutMsg.Core_IPS_Operation_Type__c;
                if(myintelOutMsg.Core_IPS_Case_ID__c != null && myintelOutMsg.Core_IPS_Case_ID__c != ''){
                    List<String> caseIdsList = (myintelOutMsg.Core_IPS_Case_ID__c).split(', ');
                    List<Id> CaseIds =(List<Id>)JSON.deserialize(JSON.serialize(caseIdsList), List<String>.class);
                    //FLS check added-Venugopal
                    if(Case.SObjectType.getDescribe().isAccessible()){
                    caseList=[Select Id,Core_IPS_Project_Case__c From Case Where Id IN:CaseIds];
                    }
                    Set<Id> projectIds = new Set<Id>();
                    for(Case cs :caseList){
                        projectIds.add(cs.Core_IPS_Project_Case__c); 
                    }
                    List<Core_IPS_Project_Member__c> prjmemList = new List<Core_IPS_Project_Member__c>();
                    prjmemList =[SELECT Core_IPS_Contact__r.Email, Core_IPS_Contact__r.Core_Enterprise_Id__c, Core_IPS_Project__c FROM Core_IPS_Project_Member__c WHERE Core_IPS_Project__c IN: projectIds];
                    if(prjmemList != null){
                        System.enqueueJob(new Core_IPS_MyIntel_3_0(CaseIds,operationType,prjmemList));
                    }
                }
            }
        }
        catch(Exception ex){Core_Log_Entry.logEntryWithDetails('SFDC','IPS',null,'warn','IPS MyIntel Integration issue','Exception occured.',null,'Case',null);}
    }
    
}