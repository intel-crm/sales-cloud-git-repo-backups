public with sharing class Contact_Handler{ // Vanuability changes --- tushar
     public static Boolean skipQueueable = false; // global bypass flag
/***************************************************************************************************
Version     : 1.0 
Created Date: 23 Nov 2015
Function    : This method executes and deactivate the Project Members.   
Input Parameters: List<Id>
Output Parameters: None
Transactions: 
Description: This method Inactivates the Project Member Records associated to the Present Contact        
Number of Queries Within this Method: 1
Number of Queries in Loop: 0
Number of Queries from Called methods: 0
Number of times called: Once for trigger execution
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* JRK                        11/23/2015              Created    
****************************************************************************************************/ 
 //  US209289 --start-- chaged method for bulkification and merged the condition of ReactivateInterestedParties --- by-- vamsi--- orion-- Nov-15-2018 
   // public static void InactivateInterestedParties(List<Contact> TrgNew,Map<Id,Contact> oldMap){
     //for(Contact ContactRec: conslst){
        // if(interestedPartyRec.Contact__c == ContactRec.id){
        //      if((oldMap.get(ContactRec.id).Core_IPS_Email_Opt_Out__c <> ContactRec.Core_IPS_Email_Opt_Out__c )||(oldMap.get(ContactRec.id).Core_IPS_Active__c <> ContactRec.Core_IPS_Active__c ))
               //     {
         public static void InactivateInterestedParties(Set<ID> contIdSet){
             if(Core_IPS_SkipTriggerHandler.skipQueueable){
                 return;
             }
            List<Core_IPS_Case_Interested_Party__c> interestedPartiesList;
            if (Schema.sObjectType.Core_IPS_Case_Interested_Party__c.fields.Active__c.isAccessible() &&
            Schema.sObjectType.Core_IPS_Case_Interested_Party__c.fields.Type__c.isAccessible() &&
            Schema.sObjectType.Core_IPS_Case_Interested_Party__c.fields.Contact__c.isAccessible() &&
            Core_IPS_Case_Interested_Party__c.SObjectType.getDescribe().isAccessible()){
                interestedPartiesList = [Select id,Active__c,Type__c,Contact__c,Contact__r.Core_IPS_Active__c,Contact__r.id,Contact__r.Core_IPS_Email_Opt_Out__c from Core_IPS_Case_Interested_Party__c where Case__r.Status !='Closed' and Contact__c IN : contIdSet limit 4999 FOR UPDATE  ];
            }
             List<Core_IPS_Case_Interested_Party__c> iPUpdateList = New List<Core_IPS_Case_Interested_Party__c>();
             List<Core_IPS_Case_Interested_Party__c> iPUpdateList1 = New List<Core_IPS_Case_Interested_Party__c>();
        
                 for(Core_IPS_Case_Interested_Party__c interestedPartyRec:  interestedPartiesList){
                      if(interestedPartyRec.Contact__r.Core_IPS_Active__c == false && interestedPartyRec.Active__c == true)
                      {
                          interestedPartyRec.Active__c = false;
                          iPUpdateList.add(interestedPartyRec);
                      }
                      else if(interestedPartyRec.Contact__r.Core_IPS_Active__c  == true) 
                      {
                          if(interestedPartyRec.Contact__r.Core_IPS_Email_Opt_Out__c )
                          {
                              if(interestedPartyRec.Active__c == true){
                                interestedPartyRec.Active__c = false;
                              }
                          }else{
                              if(interestedPartyRec.Active__c == false)
                                 interestedPartyRec.Active__c = true;
                          }                         
                          iPUpdateList.add(interestedPartyRec);
                          
                      }
                        //System.debug(iPUpdateList.size());    
            }
               
        if(iPUpdateList.size()>0 && iPUpdateList != null){
           // Core_CaseTrigger_Dispatcher.recursivetrigger1=false;
           //update iPUpdateList;
           Integer count=0;
           if(iPUpdateList!=null && iPUpdateList.size()>0){
             for(Integer i = iPUpdateList.size()-1 ; i >=0; i--){ 
                 iPUpdateList1.add(iPUpdateList.remove(i));
                 count++;
                    if(count==50 || iPUpdateList.size()==0 ){
                     Core_IPS_UpdateIPlst updateIPList=new Core_IPS_UpdateIPlst(iPUpdateList1);
                    ID jobID = System.enqueueJob(updateIPList);
                    iPUpdateList1.clear();
                    count=0;
                     }
                    }
           }
        //   Core_IPS_UpdateIPlst updateIPList=new Core_IPS_UpdateIPlst(iPUpdateList);
        //   ID jobID = System.enqueueJob(updateIPList);
        //  //System.debug(jobID);
          
        }
    }

    /***************************************************************************************************
Version     : 1.0 
Created Date: 23 Nov 2015
Function    : This method executes and deactivate the Project Members. 
Input Parameters: List<Id>
Output Parameters: None
Transactions: 
Description: This method Inactivates the Project Member Records associated to the Present Contact        
Number of Queries Within this Method: 1
Number of Queries in Loop: 0
Number of Queries from Called methods: 0
Number of times called: Once for trigger execution
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* JRK                        11/23/2015              Created    
****************************************************************************************************/ 
  // US209289 --- 1-Nov-2018-- Orion -- vamsi-- commented and merged this method in InactivateInterestedParties method   

   /*  public static void ReactivateInterestedParties(List<Contact> TrgNew, Map<Id,Contact> oldMap){
        List<Core_IPS_Case_Interested_Party__c> InterestedPartiesList = [Select id,Active__c,User__c,Type__c,Contact__c,Contact__r.id from Core_IPS_Case_Interested_Party__c where Contact__c =: TrgNew[0].id];
        List<Core_IPS_Case_Interested_Party__c> iPUpdateList = new List<Core_IPS_Case_Interested_Party__c>();
        
        for(Contact ContactRec: TrgNew){
            for(Core_IPS_Case_Interested_Party__c interestedPartyRec: InterestedPartiesList){
                if(interestedPartyRec.Contact__c == ContactRec.id){
                    if(((oldMap.get(ContactRec.id).Core_IPS_Email_Opt_Out__c <> ContactRec.Core_IPS_Email_Opt_Out__c ) && (ContactRec.Core_IPS_Active__c == true))
                       || (oldMap.get(ContactRec.id).Core_IPS_Active__c <> ContactRec.Core_IPS_Active__c )&& (ContactRec.Core_IPS_Active__c == true)){ //added for US113986 
                           if(ContactRec.Core_IPS_Email_Opt_Out__c) {
                               interestedPartyRec.Active__c = false;
                           }else{
                               interestedPartyRec.Active__c = true;
                           }                         
                           iPUpdateList.add(interestedPartyRec);
                       }
                }
            }
        }
        if(iPUpdateList.size()>0 && iPUpdateList != null)
            update iPUpdateList; 
    }    
    */ 
    /***************************************************************************************************
Version     : 1.0 
Created Date: 23 Nov 2015
Function    : This method executes and deactivate the Project Members. 
Input Parameters: List<Id>
Output Parameters: None
Transactions: 
Description: This method Inactivates the Project Member Records associated to the Present Contact        
Number of Queries Within this Method: 1
Number of Queries in Loop: 0
Number of Queries from Called methods: 0
Number of times called: Once for trigger execution
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* JRK                        11/23/2015              Created    
****************************************************************************************************/ 
  // logic moved to batch class- testing is in progress
    public static void InactivateProjectMembers(List<Contact> newContact, Map<Id, Contact> oldContact){
        if(Core_IPS_SkipTriggerHandler.skipQueueable){
            return;
        }
        if(newContact <> null && newContact.size()>0){
            List<Core_IPS_Project_Member__c> projectMemberstoUpdate = new List<Core_IPS_Project_Member__c>();
            List<Id> contactIds = new List<Id>();
            for(Contact contact: newContact){
                if(oldContact.get(contact.id).Core_IPS_Active__c == true && contact.Core_IPS_Active__c == false){
                    contactIds.add(contact.id);
                }
            }
            if(contactIds <> null && contactIds.size()>0){
                Map<Id,User> userMap = new Map<Id,User>([Select id from User where contactid IN: contactIds]); //query opt US-0048819
                List<Core_IPS_Project_Member__c> projectMembers;
                if(userMap.keySet() <> null && userMap.keySet().size()>0){
                    if (Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_User__c.isAccessible() &&
                        Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_Status__c.isAccessible() &&
                        Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_IPS_Project__c.isAccessible()) {
                        //projectMembers = [Select id,Core_User__c,Core_Status__c,Core_IPS_Project__c from Core_IPS_Project_Member__c where Core_Status__c='Active'  and Core_IPS_Contact__c IN: contactIds and Core_User__c IN: userMap.keySet()];
						//Ganesh Changes
						projectMembers = [Select id,Core_Status__c from Core_IPS_Project_Member__c where Core_Status__c='Active'  and Core_IPS_Contact__c IN: contactIds and Core_User__c IN: userMap.keySet()];
                        
					}
                
                    for(Core_IPS_Project_Member__c pm: ProjectMembers){
                        pm.Core_Status__c = 'Inactive';
                        projectMemberstoUpdate.add(pm);
                    }
                    if(Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_Status__c.isUpdateable()){
                        update projectMemberstoUpdate;
                    }
                }
            }
        }
    } 
}