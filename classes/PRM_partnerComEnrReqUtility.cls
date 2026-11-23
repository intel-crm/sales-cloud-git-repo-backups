/***************************************************************************************************************************************
Apex Class Name     : PRM_partnerComEnrReqUtility 
Version             : 1.0
Created Date        : 
Function            : 
Modification Log    :
* Developer                     Date                          Description
*************************************************************************************************************************************/


public with sharing class PRM_partnerComEnrReqUtility {
    public static boolean isCommunityUpdated = false;
    public static boolean isCommunityInserted = false;
    public static boolean isCommunityBeforeUpdated = false;
    public static boolean isTriggerExecuted = true;
    public static boolean requestedInitiatedByCommunity=false;
    public static final string PRM_Status_Approved = 'Approved';
    public static final string PRM_Status_Rejected = 'Rejected';

    
    public static void autoApproveCommunityRequest(List<PRM_Partner_Community_Enrollment_Request__c> lstPartComEnrolReq){               
        List<String> autoApprovePartCom = LabelConfiguration__mdt.getInstance('Auto_Approve_Partner_Communities').Value__c.split(';');
        
        for(PRM_Partner_Community_Enrollment_Request__c eachParComEnrReq :lstPartComEnrolReq){            
            ////System.debug('eachParComEnrReq'+eachParComEnrReq);
         if(eachParComEnrReq.PRM_Status_Nm__c !=PRM_Status_Rejected && autoApprovePartCom.contains(eachParComEnrReq.PRM_Partner_Community_Nm__c)){
                           
                eachParComEnrReq.PRM_Status_Nm__c = PRM_Status_Approved;  
                requestedInitiatedByCommunity =true;
            }           
        }        
        updatePartnerCommunityEnrollementRequestStatus(lstPartComEnrolReq);
  
    }
    
      /**
* @description      : This method is used to update Start Date and End Date fields of PartnerCommunityEnrollmentRequest Object on insertion 
                      and Rejection in PartnerCommunityEnrollmentRequest
* @name             : updateStartandEndDates
* @param            : List<PRM_Partner_Community_Enrollment_Request__c>
* @ Jira Story      : TWC729-2267
* @throws exception : NONE
**/
    public static void updateStartandEndDates (List<PRM_Partner_Community_Enrollment_Request__c> lstPartComEnrolReq){  
           for(PRM_Partner_Community_Enrollment_Request__c eachParComEnrReq :lstPartComEnrolReq){           
            if(eachParComEnrReq.PRM_Status_Nm__c == PRM_Status_Approved ){
                eachParComEnrReq.PRM_Start_Date_Dt__c = System.now();
                if(eachParComEnrReq.PRM_End_Date_Dt__c != Null){
                eachParComEnrReq.PRM_End_Date_Dt__c = Null;
                }
            }
               else if (eachParComEnrReq.PRM_Status_Nm__c == PRM_Status_Rejected ) {
                eachParComEnrReq.PRM_End_Date_Dt__c= System.now();
            }
        }
    }
  // End  
    public static void updatePartnerCommunityEnrollementRequestStatus(List<PRM_Partner_Community_Enrollment_Request__c> lstPartComEnrolReq){        
        List<PRM_Partner_Community_Enrollment_Request__c> parComEnrReqUpdateList = new List<PRM_Partner_Community_Enrollment_Request__c>();
        List<Contact> conUpdateList = new List<Contact>();
        List<Contact> conUpdateListToNew = new List<Contact>(); 
        Map<Id,List<String>> contactParComMap = new Map<Id,List<String>>();
        Map<Id,List<String>> OptOutcontactParComMap = new Map<Id,List<String>>(); 
        Set<Id> contactIdSet = new Set<Id>();
        
        List<String> autoApprovePartCom = LabelConfiguration__mdt.getInstance('Auto_Approve_Partner_Communities').Value__c.split(';');
       
        
        for(PRM_Partner_Community_Enrollment_Request__c eachParComEnrReq :lstPartComEnrolReq){            
            
            contactIdSet.add(eachParComEnrReq.PRM_Contact_Id__c);
            if(eachParComEnrReq.PRM_Status_Nm__c !='Rejected'&& autoApprovePartCom.contains(eachParComEnrReq.PRM_Partner_Community_Nm__c)){
                //System.debug('Inside If Condition');
                if(eachParComEnrReq.PRM_Partner_Community_Nm__c != null && contactParComMap.containsKey(eachParComEnrReq.PRM_Contact_Id__c) ){               
                    contactParComMap.get(eachParComEnrReq.PRM_Contact_Id__c).add(eachParComEnrReq.PRM_Partner_Community_Nm__c);
                }else{
                    contactParComMap.put(eachParComEnrReq.PRM_Contact_Id__c,new List<String>{eachParComEnrReq.PRM_Partner_Community_Nm__c});
                }                           
            }
            if(eachParComEnrReq.PRM_Status_Nm__c =='Rejected'){
                //System.debug('Inside Else If condition');
                if(eachParComEnrReq.PRM_Partner_Community_Nm__c != null && OptOutcontactParComMap.containsKey(eachParComEnrReq.PRM_Contact_Id__c) ){               
                    OptOutcontactParComMap.get(eachParComEnrReq.PRM_Contact_Id__c).add(eachParComEnrReq.PRM_Partner_Community_Nm__c);
                }else{
                    OptOutcontactParComMap.put(eachParComEnrReq.PRM_Contact_Id__c,new List<String>{eachParComEnrReq.PRM_Partner_Community_Nm__c});
                }
            }
        }   
        
       
 		Map<id,Contact> contactsToUpdate = new Map<Id,Contact>();        
        Map<Id,Contact> contactMap = new Map<Id,Contact>([Select Id,Core_IPA_Partner_Community__c from Contact where id in:contactIdSet]);
        
        for(Contact eachCon : contactMap.values()){   
            Set<String> existingContactComm = new Set<String>();
            if(eachCon.Core_IPA_Partner_Community__c != null){
                existingContactComm.addAll(eachCon.Core_IPA_Partner_Community__c.split(';'));
            }
            
            for(String community :autoApprovePartCom){
                if(contactParComMap.containsKey(eachCon.Id) ){
                    if((contactParComMap.get(eachCon.Id)).contains(community)){
                        existingContactComm.add(community);      
                    }
                }
                if(OptOutcontactParComMap.containsKey(eachCon.Id)){
                    if((OptOutcontactParComMap.get(eachCon.Id)).contains(community)){
                        existingContactComm.remove(community);    
                    }
                }
              
                
                List<String> commList = new List<String>();
                commList.addAll(existingContactComm);
               
                eachCon.Core_IPA_Partner_Community__c = String.join(commList, ';'); 
                
                if(eachCon.Core_IPA_Partner_Community__c!=null)  {              
                    contactsToUpdate.put(eachCon.id,eachCon);
                }
            }
        }              
        if(contactsToUpdate!=null&& !contactsToUpdate.isEmpty()){
            update (contactsToUpdate.values());
        }        
    }     
}