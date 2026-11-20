/***************************************************************************************************************************************
Apex Class Name     : PRM_CGCA_Trigger_Utility 
Version             : 1.0
Created Date        : March 2020
Function            : PRM_CGCA_Trigger_Utility for trigger PRM_CGCA_Trigger_Handler 
Maximum Batch Size  : 
Modification Log    :
* Developer                         Date                           Description
* ------------------------------------------------------------------------------------------------------------------------------------
* Srishty                        17-June-2020                     US695552-Create trigger on contact group contact association
* Sonali						 02-July-2020					  US704039- End date should be set when flag is inactive in the Contact Group Contact Association.
*************************************************************************************************************************************/

public without sharing class PRM_CGCA_Trigger_Utility {
    //This method will update Message Log inactive/active for corresponding conatct Ids with all cgca record as inactive/active.
    public static void checkInactiveContactGroupAssociations(List<PRM_Contact_Group_Contact_Association__c> cgcaList,Map<Id,PRM_Contact_Group_Contact_Association__c> oldcgcaMap){
        Set<Id> contactInactiveSet =new Set<Id>();//Set of contact IDs for all cgca record made inactive 
        Set<Id> contactInactiveTemporarySet =new Set<Id>();//Temporary set of inactive set of contact Ids from cgca
        for(PRM_Contact_Group_Contact_Association__c cgca:cgcaList){
            if(cgca.PRM_InActive_Ind__c && !oldcgcaMap.get(cgca.Id).PRM_InActive_Ind__c){//CGCA made inactive.
                contactInactiveSet.add(cgca.PRM_Contact_Id__c);
            }
        }//Loop ends here.
        contactInactiveTemporarySet.addAll(contactInactiveSet);
        updateMessageLogInactive(contactInactiveTemporarySet,contactInactiveSet);//calling method to inactivate message log. 
    }
    //Inactive Message Log
    private static void updateMessageLogInactive(Set<Id>contactInactiveTemporarySet ,Set<Id>contactInactiveSet ){
        List<PRM_Message_Log__c> msgLogUpdateList =new List<PRM_Message_Log__c>();//List of Message Log record needs to updated as Inactive
        for(PRM_Contact_Group_Contact_Association__c cgca: [Select Id,PRM_Contact_Id__c 
                                                            from PRM_Contact_Group_Contact_Association__c 
                                                            where PRM_Contact_Id__c IN:contactInactiveTemporarySet 
                                                            AND PRM_InActive_Ind__c=false]){
                                                                contactInactiveSet.remove(cgca.PRM_Contact_Id__c);   
                                                            }//Loop ends here.
        
        for(PRM_Message_Log__c msgLog : [Select Id,PRM_InActive_Ind__c 
                                         from PRM_Message_Log__c 
                                         where PRM_InActive_Ind__c=false 
                                         AND PRM_Contact_Id__c IN: contactInactiveSet]) {
                                             msgLog.PRM_Inactive_Ind__c=true;
                                             msgLogUpdateList.add(msgLog); 
                                         }//Loop ends here.  
        if(!msgLogUpdateList.isEmpty()){
            update msgLogUpdateList;//updating Message Log as inactive
        }
    }
    
    /* *****************************************************************************************************************************************
    * author:      Sonali Mehetre      
    * Date:        02/07/2020
    * Parameters:  list<PRM_Contact_Group_Contact_Association__c> newCgcaList, map<id,PRM_Contact_Group_Contact_Association__c> oldCgcaMap 
    * Return:      Void
    * Description: This method is used to update Start Date and End Date after updating CGCA record with active/Inactive indicator manully.
    ****************************************************************************************************************************************** */
    
    public static void updateStartandEndDates(List<PRM_Contact_Group_Contact_Association__c> newCgcaList,Map<Id,PRM_Contact_Group_Contact_Association__c> oldCgcaMap){        
        for(PRM_Contact_Group_Contact_Association__c cgca : newCgcaList){
            PRM_Contact_Group_Contact_Association__c cgcaOld ; 
            if(oldCgcaMap!=null && oldCgcaMap.size()>0) {cgcaOld =  oldCgcaMap.get(cgca.id) ;}
            if((oldCgcaMap==null) || (!oldCgcaMap.containskey(cgca.Id)||(cgcaOld.PRM_InActive_Ind__c != cgca.PRM_InActive_Ind__c)&&(cgca.PRM_InActive_Ind__c==False))){
                cgca.PRM_Start_Date_Dt__c= system.today();
                if((cgca.PRM_End_Date_Dt__c!=Null)&&(cgca.PRM_End_Date_Dt__c<=system.today())){ 
                    cgca.PRM_End_Date_Dt__c=Null;
                }   
            }
            else if(((oldCgcaMap!=null && oldCgcaMap.size()>0)&&(cgcaOld.PRM_InActive_Ind__c != cgca.PRM_InActive_Ind__c)&&(cgca.PRM_InActive_Ind__c==true))){
                if((cgca.PRM_End_Date_Dt__c==null) ||(cgca.PRM_End_Date_Dt__c>system.today())){
                    cgca.PRM_End_Date_Dt__c=system.today();
                }
            }   
        }       
    }        
}