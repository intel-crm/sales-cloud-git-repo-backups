public class Contact_Handler{
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
        // if(InterestedPartyRec.Contact__c == ContactRec.id){
        //      if((oldMap.get(ContactRec.id).Core_IPS_Email_Opt_Out__c <> ContactRec.Core_IPS_Email_Opt_Out__c )||(oldMap.get(ContactRec.id).Core_IPS_Active__c <> ContactRec.Core_IPS_Active__c ))
               //     {
         public static void InactivateInterestedParties(Set<ID> contIdSet){
             List<Core_IPS_Case_Interested_Party__c> interestedPartiesList = [Select id,Active__c,Type__c,Contact__c,Contact__r.Core_IPS_Active__c,Contact__r.id,Contact__r.Core_IPS_Email_Opt_Out__c from Core_IPS_Case_Interested_Party__c where Contact__c IN : contIdSet limit 4999 FOR UPDATE  ];
             List<Core_IPS_Case_Interested_Party__c> IPUpdateList = New List<Core_IPS_Case_Interested_Party__c>();
             List<Core_IPS_Case_Interested_Party__c> IPUpdateList1 = New List<Core_IPS_Case_Interested_Party__c>();
        
                 for(Core_IPS_Case_Interested_Party__c InterestedPartyRec:  interestedPartiesList){
                      if(InterestedPartyRec.Contact__r.Core_IPS_Active__c == false && InterestedPartyRec.Active__c == true)
                      {
                          InterestedPartyRec.Active__c = false;
                          IPUpdateList.add(InterestedPartyRec);
                      }
                      else if(InterestedPartyRec.Contact__r.Core_IPS_Active__c  == true) 
                      {
                          if(InterestedPartyRec.Contact__r.Core_IPS_Email_Opt_Out__c )
                          {
                              if(InterestedPartyRec.Active__c == true){
                                InterestedPartyRec.Active__c = false;
                              }
                          }else{
                              if(InterestedPartyRec.Active__c == false)
                                 InterestedPartyRec.Active__c = true;
                          }                         
                          IPUpdateList.add(InterestedPartyRec);
                          
                      }
                        system.debug(IPUpdateList.size());    
            }
               
        if(IPUpdateList.size()>0 && IPUpdateList != null){
           // Core_CaseTrigger_Dispatcher.recursivetrigger1=false;
           //update IPUpdateList;
           Integer count=0;
           if(IPUpdateList!=null && IPUpdateList.size()>0){
             for(Integer i = IPUpdateList.size()-1 ; i >=0; i--){ 
                 IPUpdateList1.add(IPUpdateList.remove(i));
                 count++;
                    if(count==50 || IPUpdateList.size()==0 ){
                     Core_IPS_UpdateIPlst updateIPList=new Core_IPS_UpdateIPlst(IPUpdateList1);
                    ID jobID = System.enqueueJob(updateIPList);
                    IPUpdateList1.clear();
                    count=0;
                     }
                    }
           }
        //   Core_IPS_UpdateIPlst updateIPList=new Core_IPS_UpdateIPlst(IPUpdateList);
        //   ID jobID = System.enqueueJob(updateIPList);
        //  system.debug(jobID);
          
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
        List<Core_IPS_Case_Interested_Party__c> IPUpdateList = new List<Core_IPS_Case_Interested_Party__c>();
        
        for(Contact ContactRec: TrgNew){
            for(Core_IPS_Case_Interested_Party__c InterestedPartyRec: InterestedPartiesList){
                if(InterestedPartyRec.Contact__c == ContactRec.id){
                    if(((oldMap.get(ContactRec.id).Core_IPS_Email_Opt_Out__c <> ContactRec.Core_IPS_Email_Opt_Out__c ) && (ContactRec.Core_IPS_Active__c == true))
                       || (oldMap.get(ContactRec.id).Core_IPS_Active__c <> ContactRec.Core_IPS_Active__c )&& (ContactRec.Core_IPS_Active__c == true)){ //added for US113986 
                           if(ContactRec.Core_IPS_Email_Opt_Out__c) {
                               InterestedPartyRec.Active__c = false;
                           }else{
                               InterestedPartyRec.Active__c = true;
                           }                         
                           IPUpdateList.add(InterestedPartyRec);
                       }
                }
            }
        }
        if(IPUpdateList.size()>0 && IPUpdateList != null)
            update IPUpdateList; 
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
    public static void InactivateProjectMembers(List<Contact> newContact, Map<Id, Contact> oldContact){
        if(newContact <> null && newContact.size()>0){
            List<Core_IPS_Project_Member__c> ProjectMemberstoUpdate = new List<Core_IPS_Project_Member__c>();
            List<Id> contactIds = new List<Id>();
            for(Contact contact: newContact){
                if(oldContact.get(contact.id).Core_IPS_Active__c == true && contact.Core_IPS_Active__c == false){
                    contactIds.add(contact.id);
                }
            }
            if(contactIds <> null && contactIds.size()>0){
                Map<Id,User> userMap = new Map<Id,User>([Select id from User where contactid IN: contactIds]);
                if(userMap.keySet() <> null && userMap.keySet().size()>0){
                    List<Core_IPS_Project_Member__c> projectMembers = [Select id,Core_User__c,Core_Status__c,Core_IPS_Project__c from Core_IPS_Project_Member__c where Core_Status__c='Active'  and Core_IPS_Contact__c IN: contactIds and Core_User__c IN: userMap.keySet()];
                    for(Core_IPS_Project_Member__c PM: ProjectMembers){
                        PM.Core_Status__c = 'Inactive';
                        ProjectMemberstoUpdate.add(PM);
                    }
                    update ProjectMemberstoUpdate;
                }
            }
        }
    }
}