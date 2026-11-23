/*-------------------------------------------------------------------------------------------
Apex Class  : Core_LeadHandlerforSLA
Version     : 1.0 
Created Date: 11 Nov 2018
Function    : Class to check whether the user is in Custom setting or Not
Modification Log :
* Developer                  Date                   Description
* --------------------------------------------------------------------------- -                 
* MadhuSudhan            11/11/2018              Original Version
* Mahesh                 3/25/2019               US314046-Block selection of existing opportunity while converting a lead
--------------------------------------------------------------------------------------------*/


public class Core_LeadHandlerforSLA {
    
    /*
* Method name  : CheckListedOwnerorNotUpdate
* Description  : Check if the updated owner is in custom setting or Not
* Return Type  : VOID
* Parameter    : List Trigger.new,Trigger.Old
*/
    
    //Ensure that the trigger is running only once opportunity mapping
    public static boolean isExistingOpportunity = true;
    
   
    
    public static void CheckListedOwnerorNotOnUpdate(List<Lead> listNew,List<Lead> listOld){
        
        List<Lead> leaddetails=listNew;
        system.debug('leaddetails'+leaddetails);
        List<Core_SLA_Listed_Users__c> SLAUSers= [Select Name,Email__c,Core_WWID__c from Core_SLA_Listed_Users__c ];
        
        Set<String> EmailSet = new Set<String>();  
        for (Core_SLA_Listed_Users__c rv : Core_SLA_Listed_Users__c.getAll().values()) {
            if(rv.Core_WWID__c!=null){
                EmailSet.add(rv.Core_WWID__c);
            }
        }        
        system.debug('EmailSet'+EmailSet);
        
        for(lead l : leaddetails){
            if(EmailSet.contains(l.Core_User_WWID__c)){
                l.Core_SLA_Listed_User__c=true;
            }else{
                l.Core_SLA_Listed_User__c=false;
            }
        }
    }
    
    
    /*
* Method name  : CheckListedOwnerorNot
* Description  : Check if the Lead owner is in custom setting or Not
* Return Type  : VOID
* Parameter    : List Trigger.new,Trigger.Old
*/
    
    public static void CheckListedOwnerorNot(List<Lead> listNew){
        List<Lead> leaddetails=listNew;
        system.debug('leaddetails'+leaddetails);
        List<Core_SLA_Listed_Users__c> SLAUSers= [Select Name,Email__c,Core_WWID__c from Core_SLA_Listed_Users__c ];
        
        Set<String> EmailSet = new Set<String>();  
        for (Core_SLA_Listed_Users__c rv : Core_SLA_Listed_Users__c.getAll().values()) {
            EmailSet.add(rv.Core_WWID__c);
        }        
        system.debug('EmailSet'+EmailSet);
        
        for(lead l : leaddetails){
            system.debug('email'+l.Core_User_WWID__c);
            if(EmailSet.contains(l.Core_User_WWID__c)){
                l.Core_SLA_Listed_User__c=true;
            }else{
                l.Core_SLA_Listed_User__c=false;
            }
        }     
    }
    
    
    //US314046-Block selection of existing opportunity while converting a lead
    /*
* Method name  : BlockOppConvertforExitOpp
* Description  : This Method used to block selecting existing Opportunity on Lead Conversion.
* Return Type  : void
* Parameter    : List<Lead> listNew.
*/ 
    
    public static void BlockOppConvertforExitOpp(List<Lead> listNew){
        system.debug('*****Leadfromtestclass'+listNew);
        
        
        Set<Id> OppIds = new Set<Id>(); 
        
        for(Lead lead : listNew) {
            system.debug('*******ConvertedStatus'+lead.IsConverted);
            if (lead.IsConverted) {
                OppIds.add(lead.convertedOpportunityId);
            }
        }
        
        Id PartnerRecordTypeId=[Select id from Recordtype where Name = 'Partner Lead'][0].id;
        Map<Id,Opportunity> OppIdLeadIdMap = new Map<Id,Opportunity>([select Id,CreatedDate,Core_Lead_Id__c  from Opportunity WHERE Id IN :OppIds]);
        String BlockOppOnConvertMesg = Label.Core_BlockOpp_OnConvert;
        if(OppIdLeadIdMap.size() > 0){
            for(Lead L : listNew){
                if(L.RecordtypeId !=PartnerRecordTypeId && L.ConvertedOpportunityId <> null && L.isConverted && OppIdLeadIdMap.get(L.ConvertedOpportunityId).Core_Lead_Id__c <> null && OppIdLeadIdMap.get(L.ConvertedOpportunityId).Core_Lead_Id__c <> L.Core_lead_Id__c){
                    L.addError(BlockOppOnConvertMesg);
                }
            }
        }
           
    
    }
}