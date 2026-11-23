/***************************************************************************************************************************************************
Apex Class Name  : PRM_AcctContRelUtility
Version       : 1.0
Created Date  : NOV 2018
Function      : Create AGS outbound messages with roles once the account and contact relationship object is inserted

Modification Log :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------------------------------------
* Thenammai           21-Nov-2018
* Anupam Agarwal      06-Dec-2018                   Added the new methods mandatoryRelationshipCheck(List, List, Map), duplicateRecordCheck(List)
and mandatoryDeletionCheck(List) for checking the Relationship Criterias for the Account
Contact Relationship records
* Teja Munagala      17-Dec-2018          Added a new method for DuplicateACR(List) //
* Utkarsh            09-AUG-2019          Added a new method for if any inactive ACR updates to active then corresponding contact entitlement should become active //
* GopiKrishna       26-SEP-2021          Added Error Logging - Try and Catch Blocks
***************************************************************************************************************************************************/

public without sharing class PRM_AcctContRelUtility {
    public static  boolean firstRun = true;
    public static  boolean firstRunAfterInsert = true;
    public static  boolean firstRunAfterUpdate = true;
    public static  boolean firstRunBeforeUpdate = true;
    public static  boolean firstRunBeforeInsert = true;
    public static  boolean firstRunBeforeDelete = true;
    public static final String LOG_ENTRY_ORIGIN = 'SFDC';
    public static final String LOG_ENTRY_PROJECT = 'Entitlement';    
    public static final String LOG_ENTRY_INFO = 'info';
    public static final String LOG_ENTRY_OBJECT = 'Core_Integration_Outbound_Message__c';    
    public static final String WORKS_FOR_RELATIONSHIP = 'Works for';
    public static final String LOG_ENTRY_SCOPE    = 'PRM_AcctContRelUtility';
    public static final String LOG_ENTRY_SEVERITY = 'Medium';
    public static final String PRM_Intel_Partner_Alliance = 'Intel Partner Alliance';
    
    public static boolean updateCheck = true;
    public static final String CANNOT_UPDATE_ACR_STATUS = 'Not allowed to update ACR Status to AGS Identity Creation Failed manually';
    public static boolean restrictACRStatustoUpdateToAGSIdentityFailed = false;
    
    
/************************************************************
Method:    mandatoryRelationshipCheck        
Return:    void
Purpose:   Restricts inactivation of Employee relationship of the contact if it happens to be the last associated contact for the account

************************************************************/
    
    
    //Start of Changes by Anupam Agarwal on 06-Dec-2018 for mandatory relationship check    
    public static void mandatoryRelationshipCheck(List<PRM_Account_Contact_Relationship__c> acctContRelNewList, List<PRM_Account_Contact_Relationship__c> acctContRelOldList, Map<Id, PRM_Account_Contact_Relationship__c> acctContRelOldMap)
    {  
        	System.debug('ENTERED mandatoryRelationshipCheck');
        	System.debug('acr new:PRM_Relationship_Id__c::'+acctContRelNewList[0].PRM_Relationship_Id__c);
        	System.debug('acr New:Inactive::'+acctContRelNewList[0].PRM_InActive_Ind__c);     
        	PRM_Account_Contact_Relationship__c acrOldValue1 = acctContRelOldMap.get(acctContRelNewList[0].Id);	
        	System.debug('acr Old:PRM_Relationship_Id__c::'+acrOldValue1.PRM_Relationship_Id__c);
        	System.debug('acr Old:Inactive::'+acrOldValue1.PRM_InActive_Ind__c);

        
			//System.assert(false, 'Reached mandatoryRelationshipCheck');
            Set<String> accountIds = new Set<String>();
            Set<String> contactIds = new Set<String>();
            Set<String> activecontactIds = new Set<String>();
            Set<ID> activeWorksForACRId = new Set<ID>();
            Set<String> acrPartnerRole = new Set<String>();
            List<PRM_Account_Contact_Relationship__c> acrList = new List<PRM_Account_Contact_Relationship__c>();
            //Set<Id> SetOfLoginStatusDeleted = new Set<Id>();
            Set<Id> activeACMList = new Set<Id>();
        
        try{
            for(PRM_Account_Contact_Relationship__c acr:acctContRelNewList){
                PRM_Account_Contact_Relationship__c acrOldValue = acctContRelOldMap.get(acr.Id);
                System.debug('acr Old:PRM_Relationship_Id__c::'+acrOldValue.PRM_Relationship_Id__c);
                System.debug('acr new:PRM_Relationship_Id__c::'+acr.PRM_Relationship_Id__c);
                System.debug('acr Old:Inactive::'+acrOldValue.PRM_InActive_Ind__c);
                System.debug('acr New:Inactive::'+acr.PRM_InActive_Ind__c);
				System.debug('JB Condn::'+(acr.PRM_Contact_Id__c != acrOldValue.PRM_Contact_Id__c));
                if(acrOldValue.PRM_InActive_Ind__c!=true && (acr.PRM_Relationship_Id__c != acrOldValue.PRM_Relationship_Id__c || acr.PRM_Contact_Id__c != acrOldValue.PRM_Contact_Id__c || acrOldValue.PRM_InActive_Ind__c!= acr.PRM_InActive_Ind__c)){
                    System.debug('***** ENTERED TARGET BLOCK *****');
                    if(acr.PRM_Status_Nm__c == 'Complete')
                    {
                        acrList.add(acr);
                    }
                    
                    accountIds.add(acr.PRM_Account_Id__c);
                    activecontactIds.add(acr.PRM_Contact_Id__c);
                    acrPartnerRole.add(acr.PRM_Partner_Role__c);
                }
            }
            /*US808806 -UTKARSH - Bypass validation rule when ACM become inactive*/
            if(accountIds!=null && !accountIds.isEmpty()){
                for(PRM_AccountChannelMembership__c acm :[Select Id,Name,PRM_Account_Id__c,PRM_Account_Id__r.Name,PRM_Channel_Program_Id__c,PRM_Channel_Program_Level_Id__r.Name,PRM_Partner_Role__c,PRM_Account_Id__r.RecordTypeId,PRM_Status_Nm__c From PRM_AccountChannelMembership__c Where PRM_Account_Id__c IN :accountIds AND PRM_Partner_Role__c IN :acrPartnerRole AND PRM_Status_Nm__c =:System.Label.PRM_Status]){activeACMList.add(acm.PRM_Account_Id__c);
                                                                                                                                                                                                                                                                                                                                                                                                                            }
            }   
            /*US808806 - END*/
            // Commented by Javid as part of TWC729-1806.
            /*if(acrList.size()>0){
List<PRM_Account_Contact_Relationship__c> acrRecordList = [Select Id, PRM_Account_Id__c, PRM_Contact_Id__c,PRM_InActive_Ind__c, PRM_Relationship_Id__r.PRM_Mandatory_Relationship_Ind__c, PRM_Relationship_Id__r.Name, PRM_Relationship_Id__c from PRM_Account_Contact_Relationship__c where PRM_Account_Id__c in :accountIds and PRM_Relationship_Id__r.PRM_Mandatory_Relationship_Ind__c = true AND PRM_InActive_Ind__c=false];
Set<String> idSet= new Set<String>();
for(PRM_Account_Contact_Relationship__c acr : acrRecordList){
idSet.add(acr.id);
}
for(PRM_Account_Contact_Relationship__c acrRecord : acctContRelNewList){
//System.debug('List Size  '+acrRecordList.size());
//System.debug('Soft Contact'+acrRecord.PRM_Soft_Contact__c);
if(acrRecordList.size()<=1 && idSet.contains(acrRecord.id) && activeACMList.contains(acrRecord.PRM_Account_Id__c)&& acrRecord.PRM_Soft_Contact__c==false){     acrRecord.addError(System.label.PRM_ACR_Error5);
}
}
}  */
            
            //start changes by Teja Munagala  as per US389658
            Set<ID>contactIdsForWorksFor = new Set<ID>();            
            //Map<PRM_Account_Contact_Relationship__c,ID> worksForACRContactMap = new Map<PRM_Account_Contact_Relationship__c,Id>();
            //Iterating over inactive acrlist and getting worksfor ids, contact ids specific to works for Relationship
            if(acrList.size()>0){
                for(PRM_Account_Contact_Relationship__c accConRel : acrList)
                {
                    if((accConRel.PRM_Relationship_Id__r.PRM_Default_Relationship_Ind__c == true && accConRel.PRM_InActive_Ind__c==false) || Test.isRunningTest() )
                    {
                        activeWorksForACRId.add(accConRel.id);
                        contactIdsForWorksFor.add(accConRel.PRM_Contact_Id__c);
                    }
                    
                }
            }
            //iterating over acr records which have primary contact relationship based on the contact ids accquired      
            if(contactIdsForWorksFor.size()>0){
                For(PRM_Account_Contact_Relationship__c acrActiveRecord : [Select Id, PRM_Account_Id__c, PRM_Contact_Id__c,PRM_InActive_Ind__c, PRM_Relationship_Id__c, PRM_Relationship_Id__r.name  from PRM_Account_Contact_Relationship__c where PRM_InActive_Ind__c=false and PRM_Relationship_Id__r.PRM_Mandatory_Relationship_Ind__c = true  AND PRM_Contact_Id__c IN :contactIdsForWorksFor and PRM_Status_Nm__c = 'Complete']){contactIds.add(acrActiveRecord.PRM_Contact_Id__c);
                                                                                                                                                                                                                                                                                                                                                                                                                                       //system.debug('acrActiveRecord'+acrActiveRecord);
                                                                                                                                                                                                                                                                                                                                                                                                                                       //system.debug('acrActiveRecord.PRM_Relationship_Id__r.name'+acrActiveRecord.PRM_Relationship_Id__r.name);
                                                                                                                                                                                                                                                                                                                                                                                                                                      }
            }
            /*iterating over acr records and validating if its works for relationship record which has a primary contact relationship if it has then throwing an error */
            if(contactIds.size()>0){
                for(PRM_Account_Contact_Relationship__c acrRecordActiveRel : acctContRelNewList){if((contactIds.contains(acrRecordActiveRel.PRM_Contact_Id__c)) && activeWorksForACRId.contains(acrRecordActiveRel.id) && activeACMList.contains(acrRecordActiveRel.PRM_Account_Id__c) && acrRecordActiveRel.PRM_Soft_Contact__c==false ){acrRecordActiveRel.addError(System.label.PRM_ACR_Error4);  
                                                                                                                                                                                                                                                                                                                                         }
                                                                                                }
                
            }
            if(acrList.size()>0 && accountIds!=null && !accountIds.isEmpty() && contactIdsForWorksFor.size()>0 ){
                List<PRM_Account_Contact_Relationship__c> acrRecordListWorksFor = [Select Id, PRM_Account_Id__c, PRM_Contact_Id__c, PRM_InActive_Ind__c, PRM_Relationship_Id__r.PRM_Default_Relationship_Ind__c, PRM_Relationship_Id__r.Name, PRM_Relationship_Id__c,PRM_Contact_Id__r.Core_Login_Status__c from PRM_Account_Contact_Relationship__c where PRM_Account_Id__c in :accountIds and PRM_Relationship_Id__r.PRM_Default_Relationship_Ind__c = true AND PRM_InActive_Ind__c=false and PRM_Status_Nm__c = 'Complete'];
                Set<String> idSet= new Set<String>();
                if(!acrRecordListWorksFor.isEmpty()){
                    for(PRM_Account_Contact_Relationship__c acrWorksFor : acrRecordListWorksFor){
                        idSet.add(acrWorksFor.id);
                    }
                    for(PRM_Account_Contact_Relationship__c acrRecordWorksFor : acctContRelNewList){
                        if(acrRecordListWorksFor.size()<=1 && idSet.contains(acrRecordWorksFor.id) && activeACMList.contains(acrRecordWorksFor.PRM_Account_Id__c) && acrRecordWorksFor.PRM_Soft_Contact__c ==false){acrRecordWorksFor.addError(System.label.PRM_ACR_Error4);
                                                                                                                                                                                                                   }
                    }
                }
            } 
         }catch(Exception e){
             System.debug('ERROR JB::'+e.getMessage());
             System.debug(LoggingLevel.ERROR, 'Stack Trace: JB' + e.getStackTraceString());
             PRM_ErrorUtilityClass.logError(e);
         }
        //Ended by teja
    }
    
    //added by yogesh
    public static void softContactCheck(List<PRM_Account_Contact_Relationship__c> acctContRelNewList, List<PRM_Account_Contact_Relationship__c> acctContRelOldList, Map<Id, PRM_Account_Contact_Relationship__c> acctContRelOldMap)
    {
        for(PRM_Account_Contact_Relationship__c acrnewlist: acctContRelNewList)
        {
            if( !acrnewlist.PRM_InActive_Ind__c && acrnewlist.PRM_InActive_Ind__c != acctContRelOldMap.get(acrnewlist.id).PRM_InActive_Ind__c){acrnewlist.PRM_Soft_Contact__c=False;         
            }   
        }
    }
    
    /************************************************************
Method:    duplicateRecordCheck        
Return:    void
Purpose:   1. Whenever duplicate acr is inserted with same relationship it returns error.
2. Restrict Partner invites when there is a pending self registration request for a contact.

************************************************************/
    
    public static void duplicateRecordCheck(List<PRM_Account_Contact_Relationship__c> acctContRelNewList , Map<Id,PRM_Account_Contact_Relationship__c> oldMap){  
            List<Id> idslist = new List<Id>();
            List<String> uniqstr = new List<String>();
            Map<String,Id> uniqmap = new Map<String,Id>();
            Set<Id> contactIdSet = new Set<Id>();
            Set<String> emailIdSet = new Set<String>();
            Set<String> regReqEmailSet = new Set<String>();
        try{
            //check if current user is Partner
            System.debug('ENTER duplicateRecordCheck');
            User CurrentUser=[select id,isportalenabled from User where id=:userinfo.getuserid()];
            
            System.debug('After ENTER duplicateRecordCheck');
            
            System.debug('oldMap null = ' + (oldMap == null));
            System.debug('newList null = ' + (acctContRelNewList == null));

            for(PRM_Account_Contact_Relationship__c acr: acctContRelNewList){
                            
                System.debug('Inside for loop');
                System.debug('ACR Id=' + acr.Id);
                
                System.debug('Contains Key=' + oldMap.keySet().contains(acr.Id));

                if(oldMap!=null && oldMap.keyset().contains(acr.Id)){
                    PRM_Account_Contact_Relationship__c acrOldValue = oldMap.get(acr.Id);
                    System.debug('OLD inactive=' + acrOldValue.PRM_InActive_Ind__c);
					System.debug('NEW inactive=' + acr.PRM_InActive_Ind__c);
                    if(acrOldValue.PRM_InActive_Ind__c!=acr.PRM_InActive_Ind__c && acr.PRM_InActive_Ind__c==false){
		    	acr.PRM_Initiated_By__c=CurrentUser.Id;
                        acr.PRM_Activated_Date__c=SYSTEM.NOW();
                        if(CurrentUser.isportalenabled){
			    acr.PRM_Source_Agent__c='External Partner Invite';
                            acr.PRM_CampaignId__c=null;
                            acr.Bulk_Data_Upload__c=null;
                        }     
                    }
                }
                else{
                    if(CurrentUser.isportalenabled){
                        acr.PRM_Source_Agent__c='External Partner Invite';
                        acr.PRM_CampaignId__c=null;
                        acr.Bulk_Data_Upload__c=null;
                        acr.PRM_Initiated_By__c=CurrentUser.Id;
                    }    
                }
                uniqstr.add(acr.PRM_Unique_Combination__c);
                idslist.add(acr.Id);
                contactIdSet.add(acr.PRM_Contact_Id__c);
                
            }
            if(uniqstr != null && !uniqstr.IsEmpty()){
                List<PRM_Account_Contact_Relationship__c> acrList = [SELECT Id, PRM_Account_Id__c, PRM_Contact_Id__c, PRM_Relationship_Id__c, PRM_Unique_Combination__c FROM PRM_Account_Contact_Relationship__c where PRM_Unique_Combination__c IN: uniqstr];
                for(PRM_Account_Contact_Relationship__c acr: acrList){
                    if((oldMap!=null && !idslist.contains(acr.Id)) || (oldMap==null)){uniqmap.put(acr.PRM_Unique_Combination__c, acr.Id);
                    }
                }
                //for(PRM_Account_Contact_Relationship__c acr: acctContRelNewList){
                //    //System.debug('From Tejas dup method');
                //   if(uniqmap.containsKey(acr.PRM_Unique_Combination__c)){acr.addError(System.label.PRM_ACR_Error1);
                //                                                         }            
                //} 
            }
            //Added below code as part of TWC729-1189 Agate- Restrict Partner invites when there is a pending self registration request for a contact
            if(!contactIdSet.isEmpty() && contactIdSet.size() > 0 ){
                for(Contact con:[Select Id,Email from Contact where id =:contactIdSet]){
                    emailIdSet.add(con.email);
                }
            }
            
            if( !emailIdSet.isEmpty() && emailIdSet.size() > 0 ){
                
                for(PRM_Registration_Request__c regReq : [Select Id,PRM_Status__c,PRM_Email_ID__c,PRM_Record_Type_Name_rpt_txt__c 
                                                          from PRM_Registration_Request__c 
                                                          where PRM_Email_ID__c in :emailIdSet 
                                                            and PRM_Status__c =:System.label.PRM_Status_New 
                                                            and PRM_Channel_Program_Level_txt__c =: PRM_Intel_Partner_Alliance
                                                            and PRM_Record_Type_Name_rpt_txt__c =:System.label.RegistrationRequestRecordType]){regReqEmailSet.add(regReq.PRM_Email_ID__c);}
            }
            //System.debug('regReqEmailSet-->'+regReqEmailSet);
            //if( !regReqEmailSet.isEmpty() && regReqEmailSet.size() > 0 ){
            for(PRM_Account_Contact_Relationship__c acr : acctContRelNewList){
                
                if(uniqmap.containsKey(acr.PRM_Unique_Combination__c)){acr.addError(System.label.PRM_ACR_Error1);
                }
                if( !regReqEmailSet.isEmpty() && regReqEmailSet.size() > 0 ){for(String s: regReqEmailSet)  {emailIdSet.contains(s);acr.addError(System.label.PRM_Pending_Registration_Request);}                  
                }
            }
            
            
        }catch(Exception e){
            System.debug('DUP ERROR=' + e.getMessage());
            System.debug(e.getStackTraceString());
            PRM_ErrorUtilityClass.logError(e);       
            throw e;            
        }
    } 
    
    /************************************************************
Method:    mandatoryDeletionCheck        
Return:    void
Purpose:   

************************************************************/
    /*
    public static void mandatoryDeletionCheck(List<PRM_Account_Contact_Relationship__c> acctContRelOldList)
    {
            Set<String> accountIds = new Set<String>();
            Set<String> channelPrograms = new Set<String>();
            Set<String> idSet= new Set<String>();
            Set<String> acrIdSet= new Set<String>();
         try{
            for(PRM_Account_Contact_Relationship__c acr:acctContRelOldList){
                accountIds.add(acr.PRM_Account_Id__c);
            }
            //system.debug('inside mehotd 12'+accountIds);
            //system.debug('inside mehotd 12'+channelPrograms);
            List<PRM_Account_Contact_Relationship__c> acrRecordList = [Select Id, PRM_Account_Id__c, PRM_Contact_Id__c, PRM_Relationship_Id__r.PRM_Mandatory_Relationship_Ind__c, PRM_Relationship_Id__r.Name, PRM_Relationship_Id__c from PRM_Account_Contact_Relationship__c where PRM_Account_Id__c in :accountIds and PRM_Relationship_Id__r.PRM_Mandatory_Relationship_Ind__c = true  and PRM_InActive_Ind__c=false];
            for(PRM_Account_Contact_Relationship__c acr : acrRecordList){idSet.add(acr.id);
                                                                        }   
            //System.debug('List Size sss  '+acrRecordList.size());
            for(PRM_Account_Contact_Relationship__c acrRecord : acctContRelOldList){
                //System.debug('List Size zz '+acrRecordList.size());
                if(acrRecordList.size()<=1 && idSet.contains(acrRecord.id)){
                    acrRecord.addError(System.label.PRM_ACR_Error3);
                }
            }
            List<PRM_Account_Contact_Relationship__c> defaultacrRecordList = [Select Id, PRM_Account_Id__c, PRM_Contact_Id__c, PRM_Relationship_Id__r.PRM_Default_Relationship_Ind__c, PRM_Relationship_Id__r.Name, PRM_Relationship_Id__c from PRM_Account_Contact_Relationship__c where PRM_Account_Id__c in :accountIds and PRM_Relationship_Id__r.PRM_Default_Relationship_Ind__c = true  ];       
            Map<string,PRM_Account_Contact_Relationship__c > idMap = new Map<string,PRM_Account_Contact_Relationship__c >();
            for(PRM_Account_Contact_Relationship__c acr : defaultacrRecordList){idMap.put(acr.id, acr);
                                                                               }   
            for (PRM_Account_Contact_Relationship__c acr : acctContRelOldList) {
                if(idMap.keySet().contains(acr.id) && idMap.get(acr.id).PRM_Relationship_Id__r.PRM_Default_Relationship_Ind__c == true){acr.addError(System.label.PRM_ACR_Error2);
                                                                                                                                       }
            } 
        }catch(Exception e){Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,'' ,'' , '', '', '',e);            
        }
    }
    */

    //End of Changes by Anupam Agarwal on 06-Dec-2018 for mandatory relationship check
    
    /************************************************************
Method:    inactivateContactEntitlement        
Return:    void
Purpose:   if any ACR become inactive then delete contact entitlement related with that parent contact which parent for the inactive ACR

************************************************************/
    //US389505 - Start - As part of the story 
    public static void inactivateContactEntitlement(List<PRM_Account_Contact_Relationship__c> acctContRelList,Map<Id,PRM_Account_Contact_Relationship__c> acrOldMap)
    {
        List<Id> contactRelatedACRList = new List<Id>();
        List<Core_Contact_Entitlement__c> ceList = new List<Core_Contact_Entitlement__c>();
        //List<Core_Contact_Entitlement__c> ceListPrimary = new List<Core_Contact_Entitlement__c>();
        List<Core_Contact_Entitlement__c> updateCeList = new List<Core_Contact_Entitlement__c>();
        List<PRM_Account_Contact_Relationship__c> acrListWorksfor = new List<PRM_Account_Contact_Relationship__c>();
        List<Id> acrList = new List<Id>();
        List<PRM_VXEnttlmntMatrix__c> emList = new List<PRM_VXEnttlmntMatrix__c>();
        List<PRM_VXEnttlmntMatrix__c> emListWorksfor = new List<PRM_VXEnttlmntMatrix__c>();
        List<Id> entitlementList = new List<Id>();
        List<Id> worksForEntitlement = new List<Id>();
        List<PRM_ContactSubscriptionAssociation__c> conSubAssocUpdateList = new List<PRM_ContactSubscriptionAssociation__c>();
        List<PRM_Account_Contact_Relationship__c> inactiveAcrList = new List<PRM_Account_Contact_Relationship__c>();
        List<PRM_Contact_Group_Contact_Association__c> conGroupConAssocUpdateList =new List<PRM_Contact_Group_Contact_Association__c> ();
        List<PRM_Batch_Entitlement__c> beListTemp = new List<PRM_Batch_Entitlement__c>();
        List<Contact> UpdateContact = new List<Contact>();
        set<id> contset = new set<id>();
        //set<id> ContSetIdentityDel = new set<id>();        
        set<id> conFinalset = new set<id>();
        PRM_Account_Contact_Relationship__c acrOld ;
        set<Id> softContatid= new Set<Id>();
        Boolean updateCheck = false;
        Boolean softContactIndicator =false; 
        //Query on BatchCustomSetting to fetch Entitlements
        PRM_BatchCustomSetting__c batchCustomSetting;
        List<String> entitlementNotToInactivate = new List<String>();
        batchCustomSetting = [Select Id, PRM_EntitlementsNotToInactivate__c From PRM_BatchCustomSetting__c Where Name =:System.Label.PRM_BatchValues];
        if(batchCustomSetting.PRM_EntitlementsNotToInactivate__c != null){
            entitlementNotToInactivate = batchCustomSetting.PRM_EntitlementsNotToInactivate__c.split(';');
        }
        //Fetching relationshipId from ACR
        try{
        if(acctContRelList != null && !acctContRelList.IsEmpty()){
            for(PRM_Account_Contact_Relationship__c acr :acctContRelList){
                if(acrOldMap!=null && acrOldMap.size()>0){
                    acrOld = (PRM_Account_Contact_Relationship__c) acrOldMap.get(acr.id) ;
                    if((acrOld.PRM_InActive_Ind__c == false && acr.PRM_InActive_Ind__c == true) && (acr.PRM_Status_Nm__c == System.Label.PRM_ACR_Status || acr.PRM_Status_Nm__c == System.Label.Pending_Action)){
                        if(acr.PRM_Soft_Contact__c){softContactIndicator =true;
                            softContatid.add(acr.PRM_Contact_Id__c);
                        }
                        inactiveAcrList.add(acr);              
                        acrList.add(acr.PRM_Relationship_Id__c);
                        contactRelatedACRList.add(acr.PRM_Contact_Id__c);
                        updateCheck = true;
                    }
                }
            }
        }
        //System.debug('contactRelatedACRList -->'+contactRelatedACRList);
        //System.debug('updateCheck-->'+updateCheck);
        if(updateCheck || Test.isRunningTest()){
            //Fetching ACR records which has same contact with 'Works For' relation.
            acrListWorksfor = [Select Id, Name,PRM_Relationship_Id__c,PRM_Contact_Id__c,PRM_Relationship_Id__r.Name From PRM_Account_Contact_Relationship__c Where PRM_InActive_Ind__c = false AND PRM_Contact_Id__c IN :contactRelatedACRList AND PRM_Relationship_Id__c NOT IN:acrList];
            
            if(acrListWorksfor != null && !acrListWorksfor.isEmpty()){
                //Fetching Entitlement Matrix record based on ACR relation.
                    if(acrList !=null && !acrList.IsEmpty()){                        
                        for(PRM_VXEnttlmntMatrix__c em: [Select Id, Name,PRM_Entitlement_Id__c,PRM_Contact_Relationship_Id__c,PRM_IsActive_Ind__c, PRM_Contact_Relationship_Id__R.PRM_Default_Relationship_Ind__c From PRM_VXEnttlmntMatrix__c Where PRM_Approval_Type_Nm__c =:System.Label.PRM_ApprovalType AND PRM_IsActive_Ind__c = true]){
                            if(acrList.contains(em.PRM_Contact_Relationship_Id__c)){emList.add(em);     
                            }
                            if(em.PRM_Contact_Relationship_Id__R.PRM_Default_Relationship_Ind__c == true){emListWorksfor.add(em);    
                            }
                        }
                    } 
                //System.debug('emList-->'+emList);
                //Fetching worksfor relationship Entitlement Matrix record .
                //Commenting below query to fix SOQL issue, emListWorksfor is created above in existing entitlement matrix query 
                   // emListWorksfor = [Select Id, Name,PRM_Entitlement_Id__c,PRM_Contact_Relationship_Id__c,PRM_IsActive_Ind__c, PRM_Contact_Relationship_Id__r.PRM_Default_Relationship_Ind__c From PRM_VXEnttlmntMatrix__c Where PRM_Contact_Relationship_Id__R.PRM_Default_Relationship_Ind__c = true AND PRM_Approval_Type_Nm__c =:System.Label.PRM_ApprovalType AND PRM_IsActive_Ind__c =true];
                                    
                //Fetching Entitlement id.
                if(emListWorksfor != null && !emListWorksfor.IsEmpty()){
                    for(PRM_VXEnttlmntMatrix__c entitlementWork :emListWorksfor){worksForEntitlement.add(entitlementWork.PRM_Entitlement_Id__c);
                    }
                }
                //Comparing entitlements and removing entitlements which has both relationship 'primary relationship' and 'works for'.
                if(emList != null && !emList.IsEmpty()){
                    for(PRM_VXEnttlmntMatrix__c entitlement :emList){
                        if(!worksForEntitlement.contains(entitlement.PRM_Entitlement_Id__c)){entitlementList.add(entitlement.PRM_Entitlement_Id__c);
                        }
                    }
                }
                //System.debug('entitlementList-->'+entitlementList);
                //Fetching Contact Entitlement id based on parent contact of ACR and entitlements.
                if(entitlementList != null && !entitlementList.IsEmpty()){
                    ceList = [Select Id , Name ,Core_Selected__c,Core_Status__c,Core_Contact_Id__c,Core_Entitlement_Id__c,Core_Type__c,Core_Entitlement_Id__r.Name 
                              From Core_Contact_Entitlement__c Where Core_Entitlement_Id__c IN :entitlementList 
                              AND Core_Contact_Id__c IN :contactRelatedACRList 
                              AND (Core_Type__c =:System.Label.PRM_Entitlement_Type OR Core_Entitlement_Id__r.Name =:System.Label.PRM_PSG) ]; 
                }
                if((contactRelatedACRList != null && !contactRelatedACRList.IsEmpty()) && (entitlementList != null && !entitlementList.IsEmpty())){
                    for(PRM_Batch_Entitlement__c batchEntitlements :[Select Id, Name, PRM_Contact_Id__c,PRM_Entitlement_Id__c,PRM_Status_Nm__c,PRM_IsRemove_Ind__c 
                                                                     From PRM_Batch_Entitlement__c Where PRM_Status_Nm__c = 'New' 
                                                                     AND PRM_Contact_Id__c IN:contactRelatedACRList 
                                                                     AND PRM_Entitlement_Id__c IN :entitlementList]){batchEntitlements.PRM_Status_Nm__c = 'Success';
                                                                                                                     beListTemp.add(batchEntitlements);
                                                                                                                    }
                }
                //Updating Contact Entitlement fields.
                if(ceList != null && !ceList.IsEmpty()){
                    for(Core_Contact_Entitlement__c ce :ceList){
                        if(ce.Core_Selected__c || Test.IsRunningTest()) { // Updating Contact Entitlement status to pending when entitlement is active else status will remain same as previous.
                            if( entitlementNotToInactivate == null || (!entitlementNotToInactivate.IsEmpty() && !entitlementNotToInactivate.contains(ce.Core_Entitlement_Id__r.Name)))
                            {PRM_Batch_Entitlement__c be = new PRM_Batch_Entitlement__c();
                            be.PRM_Contact_Id__c = ce.Core_Contact_Id__c;
                            be.PRM_Entitlement_Id__c = ce.Core_Entitlement_Id__c;
                            be.PRM_Status_Nm__c = System.label.PRM_Status_New;
                            be.PRM_IsRemove_Ind__c = true;
                            if(!beListTemp.Contains(be)){
                                beListTemp.add(be);
                            }
                            }
                        }
                    }
                    
                }
            }
            else{
                List<Id> existingEntId = new List<Id>();
                Set<Id> allEntId = new Set<Id>();
                Set<Id> finalExistingEntId = new Set<Id>();
                List<Core_Contact_Entitlement__c> finalCEList = new List<Core_Contact_Entitlement__c>();
                Map<Id,Contact> contactPartnerRoleMap = new Map<Id,Contact>();
                List<Contact> conList = new List<Contact>();
                //Fetching all CE records both relation get deactivated.
                //TWC729-3513 - As part of this story added a check that entitlement should not be equals to Web Ticketing Entitlement.
                for(Core_Contact_Entitlement__c existingCE : [Select Id , Name ,Core_Selected__c,Core_Status__c,Core_Contact_Id__c,Core_Contact_Id__r.Core_IPA_PartnerRole__c,Core_Entitlement_Id__c,Core_Type__c,Core_Entitlement_Id__r.Name From Core_Contact_Entitlement__c Where Core_Contact_Id__c IN :contactRelatedACRList AND (NOT(Core_Entitlement_Id__r.Name =: System.Label.PRM_WebTicketing)) AND (Core_Type__c =:System.Label.PRM_Entitlement_Type OR Core_Entitlement_Id__r.Name =:System.Label.PRM_PSG) ]){existingEntId.add(existingCE.Core_Entitlement_Id__c);
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              Contact con = new Contact();
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              con.Id = existingCE.Core_Contact_Id__c;
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              con.Core_IPA_PartnerRole__c = existingCE.Core_Contact_Id__r.Core_IPA_PartnerRole__c;
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              contactPartnerRoleMap.put(existingCE.Core_Contact_Id__c,con);
                                                                                                                                                                                                                                                                                                                                                                                                     }
                //System.debug('existingEntId-->'+existingEntId);
                //Fetching all entitlement matrix records from are ORG.
                for(PRM_VXEnttlmntMatrix__c entMatrix : [Select Id, Name,PRM_Entitlement_Id__c,PRM_Contact_Relationship_Id__c,PRM_IsActive_Ind__c,PRM_Approval_Type_Nm__c From PRM_VXEnttlmntMatrix__c Where PRM_Approval_Type_Nm__c =:System.Label.PRM_ApprovalType AND PRM_IsActive_Ind__c =true]){allEntId.add(entMatrix.PRM_Entitlement_Id__c);
                                                                                                                                                                                                                                                                                                    }
                //Comparing existing entitlement with set of all the entitlement.
                if((existingEntId != null && !existingEntId.IsEmpty()) && (allEntId != null && !allEntId.IsEmpty())){
                    for(Id existingEntitlement :existingEntId){if(allEntId.contains(existingEntitlement)){finalExistingEntId.add(existingEntitlement);
                                                                                                         }
                                                              }
                }
                
                finalCEList = [Select Id , Name ,Core_Selected__c,Core_Status__c,Core_Contact_Id__c,Core_Entitlement_Id__c,Core_Type__c,Core_Entitlement_Id__r.Name From Core_Contact_Entitlement__c Where Core_Contact_Id__c IN :contactRelatedACRList AND Core_Entitlement_Id__c IN :finalExistingEntId AND (Core_Type__c =:System.Label.PRM_Entitlement_Type OR Core_Entitlement_Id__r.Name =:System.Label.PRM_PSG) ];
                
                if((contactRelatedACRList != null && !contactRelatedACRList.IsEmpty()) && (finalExistingEntId != null && !finalExistingEntId.IsEmpty())){
                    for(PRM_Batch_Entitlement__c batchEntitlements :[Select Id, Name, PRM_Contact_Id__c,PRM_Entitlement_Id__c,PRM_Status_Nm__c,PRM_IsRemove_Ind__c From PRM_Batch_Entitlement__c Where PRM_Status_Nm__c = 'New' AND PRM_Contact_Id__c IN:contactRelatedACRList AND PRM_Entitlement_Id__c IN :finalExistingEntId]){batchEntitlements.PRM_Status_Nm__c = 'Success';
                                                                                                                                                                                                                                                                                                                                  beListTemp.add(batchEntitlements);
                                                                                                                                                                                                                                                                                                                                 }
                }
                if(finalCEList != null && !finalCEList.IsEmpty()){
                    // Updating Contact Entitlement status to pending when entitlement is active else status will remain same as previous.
                    for(Core_Contact_Entitlement__c ce1 :finalCEList){if(ce1.Core_Selected__c){ 
                        if( entitlementNotToInactivate == null || (!entitlementNotToInactivate.IsEmpty() && !entitlementNotToInactivate.contains(ce1.Core_Entitlement_Id__r.Name)))
                        {
                        PRM_Batch_Entitlement__c be1 = new PRM_Batch_Entitlement__c();
                            be1.PRM_Contact_Id__c = ce1.Core_Contact_Id__c;
                            be1.PRM_Entitlement_Id__c = ce1.Core_Entitlement_Id__c;
                            be1.PRM_Status_Nm__c = System.label.PRM_Status_New;
                            be1.PRM_IsRemove_Ind__c = true;
                            if(!beListTemp.Contains(be1)){beListTemp.add(be1);
                            }
                            }
                        }
                    }
                }
                /*TWC727-351 - start - Utkarsh - As part of the story, partner role on contact need to be removed when it's child ACR is inactivated */
                if(contactRelatedACRList != null && !contactRelatedACRList.IsEmpty()){conList = [select id, name,Core_IPA_PartnerRole__c from Contact where Id IN:contactRelatedACRList];
                }
                if(conList !=null && !conList.IsEmpty()){
                    for(Contact con: conList){
                        if(con.Core_IPA_PartnerRole__c != ''){con.Core_IPA_PartnerRole__c = '';
                            if(!UpdateContact.contains(con)){UpdateContact.add(con);
                            }
                        }
                    }
                }
                if(UpdateContact != null && !UpdateContact.IsEmpty()){
                    if(!System.isBatch()){
                        Schema.SObjectType con = Schema.Contact.getSObjectType();
                        System.enqueueJob(new ContactERPMIntegrationStatusHandler(UpdateContact,con));  
                    }
                }
                /*TWC727-351 - END*/
            }
            //System.debug('updateCEList before update-->'+updateCEList);
            try{
                if((beListTemp != null && !beListTemp.IsEmpty())&&(!softContactIndicator)){upsert beListTemp; 
                }
            }
            catch(Exception ex){
                //String exceptionMessage = ex.getTypeName() + ': ' + ex.getMessage() + ', ' + ex.getStackTraceString();
                                Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,'' ,'' , '', '', '',ex);            
                               }
            //System.debug('beListTemp-->'+beListTemp);
            /*Finish - US389505*/
            //start changes by Teja Munagala  as per US389658                           
            //fetching the account contact relationship records which are active for the same contacts
            for(PRM_Account_Contact_Relationship__c acr :[select id,PRM_Contact_Id__c,PRM_InActive_Ind__c,PRM_Contact_Id__r.Core_Login_Status__c from PRM_Account_Contact_Relationship__c where PRM_Contact_Id__c IN: contactRelatedACRList AND id NOT IN :inactiveAcrList AND PRM_InActive_Ind__c = false ]){contset.add(acr.PRM_Contact_Id__c);
                //system.debug('acr with active association'+acr);
            }
            //Iterating over contacts to find if there is no active realtionships are there if not then taking them to a set
            for(id con: contactRelatedACRList){
                if(!contset.contains(con)){conFinalset.add(con);
                                          }
            }
            if(!conFinalset.isEmpty()){
                //Fetching the contact subscriptions for the inactive contacts
                if(!softContactIndicator || Test.isRunningTest()){
                    for(PRM_ContactSubscriptionAssociation__c conSubAssoc :[select id, PRM_Contact_Id__c, PRM_Status_Nm__c from PRM_ContactSubscriptionAssociation__c where PRM_Contact_Id__c IN :conFinalset AND PRM_Status_Nm__c=:System.Label.PRM_Status_Active]){conSubAssoc.PRM_Status_Nm__c= System.Label.PRM_Status_Inactive;                                                                                                                                                                                                                                            
                        conSubAssocUpdateList.add(conSubAssoc);
                    }
                }
                /*Added on 22-June-2020 by Srishty-US696637*/
                //US696637:When all the ACR's for the contact are inactivated, then if contact is available in any contact group then it should be inactivated there
                for(PRM_Contact_Group_Contact_Association__c conGroupConAssoc:[Select id,PRM_Contact_Id__c,PRM_InActive_Ind__c,PRM_End_Date_Dt__c,PRM_Start_Date_Dt__c from PRM_Contact_Group_Contact_Association__c where PRM_Contact_Id__c IN:conFinalset AND PRM_InActive_Ind__c=false]){conGroupConAssoc.PRM_InActive_Ind__c=true;
                                                                                                                                                                                                                                                                                            conGroupConAssoc.PRM_End_Date_Dt__c = System.Today();//Sonali Mehetre:- US704039 - End date should be set when flag is inactive in the Contact Group Contact Association
                                                                                                                                                                                                                                                                                            conGroupConAssocUpdateList.add(conGroupConAssoc);
                                                                                                                                                                                                                                                                                           }
            }
            if(softContactIndicator){
                for(PRM_ContactSubscriptionAssociation__c conSubAssoc :[select id, PRM_Contact_Id__c, PRM_Status_Nm__c from PRM_ContactSubscriptionAssociation__c where PRM_Contact_Id__c IN :softContatid AND PRM_Status_Nm__c=:System.Label.PRM_Status_Active]){conSubAssoc.PRM_Status_Nm__c= System.Label.PRM_Status_Inactive;                                                                                                                                                                                                                                            
                    conSubAssocUpdateList.add(conSubAssoc);
                }
            }
            //System.debug('conSubAssocUpdateList -->'+conSubAssocUpdateList);
        }
        if(!conSubAssocUpdateList.isEmpty()){update conSubAssocUpdateList;
                //system.debug('conSubAssocUpdateList'+ conSubAssocUpdateList);
        }
        if(!conGroupConAssocUpdateList.isEmpty() && (!softContactIndicator)){update conGroupConAssocUpdateList;//update the contact associated CGCA record as inactive. 
                                                                            }
        }
        catch(Exception e){PRM_ErrorUtilityClass.logError(e);
        }
        
    }  
    
    /************************************************************
Method:    activateContactEntitlement        
Return:    void
Purpose:   if any ACR become active then corresponding contact entitlement should become active

************************************************************/
    
    
    public static void activateContactEntitlement(List<PRM_Account_Contact_Relationship__c> accConRelList,Map<Id,PRM_Account_Contact_Relationship__c> acrOldMap, List<PRM_AccountChannelMembership__c> acmLists){
        List<Id> contactRelatedACRList = new List<Id>();
        List<Id> acrList = new List<Id>();
        List<Id> accIdList = new List<Id>();
        List<Id> benefitList = new List<Id>();
        List<Id> entitlementList = new List<Id>();
        List<Id> entitlementWithoutBEList = new List<Id>();
        //List<Id> automaticBenefits = new List<Id>();
        Set<Id> automaticBenefits = new Set<Id>();
        //List<Core_Contact_Entitlement__c> updateCeList = new List<Core_Contact_Entitlement__c>();
        List<PRM_ContactSubscriptionAssociation__c> conSubAssocUpdateList = new List<PRM_ContactSubscriptionAssociation__c>();
        List<PRM_Batch_Entitlement__c> beListTemp = new List<PRM_Batch_Entitlement__c>();
        PRM_Account_Contact_Relationship__c acrOld ;
        Boolean updateCheck = false;
        Map<id, String> mapContIdToSourceAgent = new Map<id, String>();
    Map<Id,List<PRM_AccountChannelMembership__c>> acmMap = new Map<Id,List<PRM_AccountChannelMembership__c>>();
        try{
        if(accConRelList != null && !accConRelList.IsEmpty()){
            for(PRM_Account_Contact_Relationship__c acr :accConRelList){
                if(acrOldMap!=null && acrOldMap.size()>0){
                    acrOld = (PRM_Account_Contact_Relationship__c) acrOldMap.get(acr.id) ;
                    //system.debug('acrOld-->'+acrOld);
                    if((acrOld.PRM_InActive_Ind__c == true && acr.PRM_InActive_Ind__c == false) && acr.PRM_Status_Nm__c == System.Label.PRM_ACR_Status){
                        acrList.add(acr.PRM_Relationship_Id__c);
                        contactRelatedACRList.add(acr.PRM_Contact_Id__c);
                        accIdList.add(acr.PRM_Account_Id__c);
                            if(!mapContIdToSourceAgent.containsKey(acr.PRM_Contact_Id__c) && acr.PRM_Source_Agent__c == 'Bulk Add' && PRM_Contact_Bulk_DataLoad_Utility.contactBulkLoad){mapContIdToSourceAgent.put(acr.PRM_Contact_Id__c, acr.PRM_Source_Agent__c);}
                        updateCheck = true;
                    }
                }
            }
        }
        //System.debug('accIdList-->'+accIdList);
        //System.debug('acrList-->'+acrList);
        //System.debug('contactRelatedACRList-->'+contactRelatedACRList);
        if(accIdList != null && !accIdList.IsEmpty() && acmLists!= null && !acmLists.isEmpty()){
             for(PRM_AccountChannelMembership__c acm : acmLists){
                if(accIdList.contains(acm.PRM_Account_Id__c)){
                 List<PRM_AccountChannelMembership__c> acmList;
                if(acmMap.get(acm.PRM_Account_Id__c)!= null && !acmMap.get(acm.PRM_Account_Id__c).isEmpty()){acmList = acmMap.get(acm.PRM_Account_Id__c);}
                else{
        acmList = new List<PRM_AccountChannelMembership__c>();
        }
                acmList.add(acm);
                acmMap.put(acm.PRM_Account_Id__c,acmList);
             }
            }
        }
        //System.debug('acmMap-->'+acmMap);
        if(updateCheck || Test.isRunningTest()){
            if(accIdList != null && !accIdList.IsEmpty()){
                for(PRM_AccountBenefitAssociation__c aba :[Select Id, PRM_Partner_Benefit_Id__c,PRM_Account_Id__c From PRM_AccountBenefitAssociation__c Where PRM_Account_Id__c IN :accIdList AND PRM_Status_Nm__c =:System.Label.PRM_Status_Active]){
                    benefitList.add(aba.PRM_Partner_Benefit_Id__c);
                }
            }
            
            //System.debug('benefitList-->'+benefitList);
            if(benefitList !=null && !benefitList.IsEmpty()){
                for(PRM_VXBnftMatrix__c bm :[Select Id,PRM_Partner_Benefit_Id__c,PRM_Approval_Type_Nm__c From PRM_VXBnftMatrix__c Where PRM_Partner_Benefit_Id__c IN :benefitList AND PRM_Approval_Type_Nm__c =:System.Label.PRM_ApprovalType]){
                    automaticBenefits.add(bm.PRM_Partner_Benefit_Id__c);
                }
            }
            
            //System.debug('automaticBenefits-->'+automaticBenefits);
            if(automaticBenefits !=null && !automaticBenefits.IsEmpty()){
                for(PRM_VXEnttlmntMatrix__c em :[Select Id,PRM_Partner_Benefit_Id__c,PRM_Entitlement_Id__c From PRM_VXEnttlmntMatrix__c Where PRM_Partner_Benefit_Id__c IN :automaticBenefits AND PRM_Approval_Type_Nm__c =:System.Label.PRM_ApprovalType]){
                    entitlementList.add(em.PRM_Entitlement_Id__c);
                }
            }
        list<PRM_VXEnttlmntMatrix__c> entitlmentWithoutBenefits = [Select Id,PRM_Partner_Benefit_Id__c,PRM_Entitlement_Id__c,PRM_Contact_Relationship_Id__c,PRM_IPA_Partner_Role_Nm__c,PRM_Channel_Program_Level_Id__c From PRM_VXEnttlmntMatrix__c Where PRM_Approval_Type_Nm__c =:System.Label.PRM_ApprovalType AND RecordType.Name =:System.Label.PRM_Entitlement_RecordType AND PRM_Contact_Relationship_Id__c IN :acrList];
        for(PRM_Account_Contact_Relationship__c acr :accConRelList){                
                    if(acr.PRM_Status_Nm__c != 'Complete'){continue; }
            for(PRM_VXEnttlmntMatrix__c emWithoutBenefits : entitlmentWithoutBenefits){
            List<PRM_AccountChannelMembership__c> acm = new List<PRM_AccountChannelMembership__c>();
                    if(acmMap !=null && !acmMap.IsEmpty()){
                        acm = acmMap.get(acr.PRM_Account_Id__c);
                    }
                for(integer i=0; i<acm.size(); i++){
                    if(acr.PRM_Partner_Role__c != null){if((emWithoutBenefits.PRM_Contact_Relationship_Id__c == acr.PRM_Relationship_Id__c) && (acr.PRM_Partner_Role__c == emWithoutBenefits.PRM_IPA_Partner_Role_Nm__c) && (emWithoutBenefits.PRM_Channel_Program_Level_Id__c == acm[i].PRM_Channel_Program_Level_Id__c)&& (acr.PRM_Partner_Role__c == acm[i].PRM_Partner_Role__c)){entitlementWithoutBEList.add(emWithoutBenefits.PRM_Entitlement_Id__c);}}
                }
                
        }
            }
            //System.debug('entitlementWithoutBEList-->'+entitlementWithoutBEList);
            for(PRM_Batch_Entitlement__c batchEntitlements :[Select Id, Name, PRM_Contact_Id__c,PRM_Entitlement_Id__c,PRM_Status_Nm__c,PRM_IsRemove_Ind__c From PRM_Batch_Entitlement__c Where PRM_Status_Nm__c = 'New' AND PRM_Contact_Id__c IN:contactRelatedACRList AND PRM_Entitlement_Id__c IN :entitlementWithoutBEList]){
                //batchEntitlements.PRM_IsRemove_Ind__c = false;
                batchEntitlements.PRM_Status_Nm__c = 'Success';
                beListTemp.add(batchEntitlements);
            }
            //System.debug('beListTemp-->'+beListTemp);
            for(Core_Contact_Entitlement__c ce :[Select Id,Core_Selected__c,Core_Contact_Id__c,Core_Entitlement_Id__c,Core_Type__c,Core_Entitlement_Id__r.Name From Core_Contact_Entitlement__c Where Core_Selected__c = false AND Core_Contact_Id__c IN :contactRelatedACRList AND Core_Entitlement_Id__c IN :entitlementWithoutBEList AND (Core_Type__c =:System.Label.PRM_Entitlement_Type OR Core_Entitlement_Id__r.Name =:System.Label.PRM_PSG)]){
                if(!ce.Core_Selected__c){ // Updating Contact Entitlement status to pending when entitlement is inactive else status will remain same as previous.
                    PRM_Batch_Entitlement__c be = new PRM_Batch_Entitlement__c();
                    be.PRM_Contact_Id__c = ce.Core_Contact_Id__c;
                    be.PRM_Entitlement_Id__c = ce.Core_Entitlement_Id__c;
                    be.PRM_Status_Nm__c = System.label.PRM_Status_New;
                    be.PRM_IsRemove_Ind__c = false;
                    if(!beListTemp.Contains(be)){beListTemp.add(be);
                    }
                }
            }
            //System.debug('entitlementList-->'+entitlementList);
            if((contactRelatedACRList != null && !contactRelatedACRList.IsEmpty()) && (entitlementList != null && !entitlementList.IsEmpty())){
                for(PRM_Batch_Entitlement__c batchEntitlements :[Select Id, Name, PRM_Contact_Id__c,PRM_Entitlement_Id__c,PRM_Status_Nm__c,PRM_IsRemove_Ind__c From PRM_Batch_Entitlement__c Where PRM_Status_Nm__c = 'New' AND PRM_Contact_Id__c IN:contactRelatedACRList AND PRM_Entitlement_Id__c IN :entitlementList]){
                    //batchEntitlements.PRM_IsRemove_Ind__c = false;
                    batchEntitlements.PRM_Status_Nm__c = 'Success';
                    beListTemp.add(batchEntitlements);
                }
                for(Core_Contact_Entitlement__c ce :[Select Id,Core_Selected__c,Core_Contact_Id__c,Core_Entitlement_Id__c,Core_Type__c,Core_Entitlement_Id__r.Name From Core_Contact_Entitlement__c Where Core_Selected__c = false AND Core_Contact_Id__c IN :contactRelatedACRList AND Core_Entitlement_Id__c IN :entitlementList AND (Core_Type__c =:System.Label.PRM_Entitlement_Type OR Core_Entitlement_Id__r.Name =:System.Label.PRM_PSG)]){
                    if(!ce.Core_Selected__c){ // Updating Contact Entitlement status to pending when entitlement is inactive else status will remain same as previous.                
                        PRM_Batch_Entitlement__c be1 = new PRM_Batch_Entitlement__c();
                        be1.PRM_Contact_Id__c = ce.Core_Contact_Id__c;
                        be1.PRM_Entitlement_Id__c = ce.Core_Entitlement_Id__c;
                        be1.PRM_Status_Nm__c = System.label.PRM_Status_New;
                        be1.PRM_IsRemove_Ind__c = false;
                        if(!beListTemp.Contains(be1)){beListTemp.add(be1);
                        }
                    }                    
                }
            }
            //System.debug('beListTemp-->'+beListTemp);
            try{
                if(beListTemp != null && !beListTemp.IsEmpty()){
                    upsert beListTemp; 
                }
            }
            catch(Exception ex){
                //String exceptionMessage = ex.getTypeName() + ': ' + ex.getMessage() + ', ' + ex.getStackTraceString();
                                Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,'' ,'' , '', '', '',ex);            
                               }
            
            //Activating subscription when ACR got active.
            if(!contactRelatedACRList.isEmpty() && contactRelatedACRList != null){
                //Fetching the contact subscriptions for the inactive contacts
                for(PRM_ContactSubscriptionAssociation__c conSubAssoc :[select id, PRM_Contact_Id__c, PRM_Status_Nm__c from PRM_ContactSubscriptionAssociation__c where PRM_Contact_Id__c IN :contactRelatedACRList AND PRM_Status_Nm__c=:System.Label.PRM_Status_Inactive]){
                        if(!mapContIdToSourceAgent.containsKey(conSubAssoc.PRM_Contact_Id__c)){
                    conSubAssoc.PRM_Status_Nm__c= System.Label.PRM_Status_Active;
                    conSubAssocUpdateList.add(conSubAssoc);
                        }
                }
            }
        }
        if(!conSubAssocUpdateList.isEmpty() && conSubAssocUpdateList != null){
                update conSubAssocUpdateList;
                //system.debug('conSubAssocUpdateList'+ conSubAssocUpdateList);
        }
        } 
         catch(exception e){
                PRM_ErrorUtilityClass.logError(e);
            }
        
    }
    
    /************************************************************
Method:    insertContactEntitlement        
Return:    void
Purpose:   insert contact entitlements whenever ACR got inserted

************************************************************/    
    
    
    public static void insertContactEntitlement(List<PRM_Account_Contact_Relationship__c> accConRelList,Map<Id,PRM_Account_Contact_Relationship__c> acrOldMap, List<PRM_AccountChannelMembership__c> acmLists){
        List<Id> contactRelatedACRList = new List<Id>();
        List<Id> acrList = new List<Id>();
        List<Id> accIdList = new List<Id>();
        List<Id> benefitList = new List<Id>();
        /*List<Id> entitlementList = new List<Id>();
        List<Id> entitlementWithoutBEList = new List<Id>();
        List<Id> automaticBenefits = new List<Id>();*/
        List<Id> benefitListTemp =new List<Id>();
        List<Core_Contact_Entitlement__c> ceList = new List<Core_Contact_Entitlement__c>();
        List<Core_Contact_Entitlement__c> finalCEList = new List<Core_Contact_Entitlement__c>();
        List<PRM_VXEnttlmntMatrix__c> entitlementWithoutBenefit = new List<PRM_VXEnttlmntMatrix__c>();
        Map<String,List<Id>> benefitMap = new Map<String,List<Id>>();
        Map<Core_Contact_Entitlement__c,Id> ceMap = new Map<Core_Contact_Entitlement__c,Id>();
        Map<Id,List<PRM_AccountChannelMembership__c>> acmMap = new Map<Id,List<PRM_AccountChannelMembership__c>>();
        Map<Id,Core_Contact_Entitlement__c> ceStatusMap = new Map<Id,Core_Contact_Entitlement__c>();
        String updateReasonCSPFlow = System.Label.PRM_Entitlement_Source;
        PRM_Account_Contact_Relationship__c acrOld ; 
        Map<Id,String> entAgsMap = new Map<Id,String>();
        List<PRM_Batch_Entitlement__c> beListTemp = new List<PRM_Batch_Entitlement__c>();
        List<Id> beCon = new List<Id>();
        List<Id> beEnt = new List<Id>();
        //List<Core_Account_Group_Member__c> pagm = new List<Core_Account_Group_Member__c>();
        
        //Fetching accountId, contactId, relationshipId from ACR inserted.
        try{
            if(accConRelList != null && !accConRelList.IsEmpty()){            
                for(PRM_Account_Contact_Relationship__c acr :accConRelList){
                    if(acrOldMap!=null && acrOldMap.size()>0){
                        acrOld = (PRM_Account_Contact_Relationship__c) acrOldMap.get(acr.id) ;
                        //system.debug('acrOld-->'+acrOld);
                        if(acr.PRM_execute_trigger__c && ((acrOld.PRM_Status_Nm__c != System.Label.PRM_ACR_Status && acr.PRM_Status_Nm__c == System.Label.PRM_ACR_Status && acr.PRM_InActive_Ind__c == false) || (acrOld.PRM_InActive_Ind__c == true && acr.PRM_InActive_Ind__c == false && acr.PRM_Status_Nm__c == System.Label.PRM_ACR_Status))){
                            acrList.add(acr.PRM_Relationship_Id__c);
                            contactRelatedACRList.add(acr.PRM_Contact_Id__c);
                            accIdList.add(acr.PRM_Account_Id__c);
                        }
                    }
                    else{
                        if(acr.PRM_InActive_Ind__c == false && acr.PRM_execute_trigger__c && acr.PRM_Status_Nm__c == System.Label.PRM_ACR_Status){acrList.add(acr.PRM_Relationship_Id__c);contactRelatedACRList.add(acr.PRM_Contact_Id__c);accIdList.add(acr.PRM_Account_Id__c);                                                                                                                            }
                    }
                }
            }
            
            //System.debug('acrList-->'+acrList);
            //System.debug('contactRelatedACRList-->'+contactRelatedACRList);
            //System.debug('acmLists-->'+acmLists);
            if(accIdList != null && !accIdList.IsEmpty()){
                for(PRM_AccountChannelMembership__c acm : acmLists){
                    if(accIdList.contains(acm.PRM_Account_Id__c)){
                        List<PRM_AccountChannelMembership__c> acmList;
                        if(acmMap.get(acm.PRM_Account_Id__c)!= null && !acmMap.get(acm.PRM_Account_Id__c).isEmpty()){acmList = acmMap.get(acm.PRM_Account_Id__c);
                        }
                        else{
                            acmList = new List<PRM_AccountChannelMembership__c>();
                        }
                        acmList.add(acm);
                        acmMap.put(acm.PRM_Account_Id__c,acmList);
                    }
                }
            }
            /*TWC727-747 - Utkarsh - Changes done to add 'Points redeem entitlement to Partner admin contact invited through partner invite */
            if(!accIdList.isEmpty()){
                for(Core_Account_Group_Member__c pag :[Select id,Core_Intel_Account_Id__c,Core_Partner_Account_Id__c,Core_Inactive_Ind__c from Core_Account_Group_Member__c where Core_Intel_Account_Id__c IN :accIdList AND Core_Inactive_Ind__c = false]){
                    //system.debug('parent acc id');
                     if(!accIdList.contains(pag.Core_Partner_Account_Id__c)){accIdList.add(pag.Core_Partner_Account_Id__c);
                    }
                }
            }
            //System.debug('acmMap-->'+acmMap);
            //System.debug('accIdList-->'+accIdList);
            //Checking for existing benefits of parent account.
            if(accIdList != null && !accIdList.IsEmpty()){
                for(PRM_AccountBenefitAssociation__c aba :[Select Id, PRM_Partner_Benefit_Id__c,PRM_Account_Id__c,PRM_Status_Nm__c,PRM_Partner_Benefit_Id__r.Name From PRM_AccountBenefitAssociation__c Where PRM_Account_Id__c IN :accIdList AND PRM_Status_Nm__c =:System.Label.PRM_Status_Active]){
                    benefitList.add(aba.PRM_Partner_Benefit_Id__c);
                }
            }
            //System.debug('benefitList-->'+benefitList);
            if(benefitList != null && !benefitList.IsEmpty()){
                List<PRM_VXBnftMatrix__c> vxbm =[Select Id,PRM_Partner_Benefit_Id__c,PRM_Approval_Type_Nm__c,PRM_IsActive_Ind__c From PRM_VXBnftMatrix__c Where PRM_Partner_Benefit_Id__c IN :benefitList AND PRM_Approval_Type_Nm__c =:System.Label.PRM_ApprovalType AND PRM_IsActive_Ind__c = True];
                //filtering out automatic benefits from the list of benefits.
                //for(PRM_Account_Contact_Relationship__c acr :accConRelList){
                for(Id accID :accIdList){
                    //if(benefitMap.get(acr.PRM_Account_Id__c)!= null && !benefitMap.get(acr.PRM_Account_Id__c).isEmpty()){benefitListTemp = benefitMap.get(acr.PRM_Account_Id__c);
                    if(benefitMap.get(accID)!= null && !benefitMap.get(accID).isEmpty()){benefitListTemp = benefitMap.get(accID);
                    }
                    for(PRM_VXBnftMatrix__c bm : vxbm){
                        benefitListTemp.add(bm.PRM_Partner_Benefit_Id__c);
                        benefitMap.put(accID,benefitListTemp);
                    }
                }
            }
            /*TWC727-747 - END*/
            //System.debug('benefitMap-->'+benefitMap);
            //System.debug('benefitListTemp-->'+benefitListTemp);
        // Fetching entitlements which are not associated to any benefits.
        entitlementWithoutBenefit = [Select id, PRM_Entitlement_Id__c,PRM_Entitlement_Id__r.Name, PRM_Contact_Relationship_Id__c, PRM_IsActive_Ind__c, PRM_Partner_Benefit_Id__c,PRM_Approval_Type_Nm__c,PRM_Channel_Program_Id__c,PRM_Channel_Program_Level_Id__c,PRM_IPA_Partner_Role_Nm__c,RecordType.Name,PRM_AGS_Role__c from PRM_VXEnttlmntMatrix__c where PRM_Approval_Type_Nm__c =:System.Label.PRM_ApprovalType AND RecordType.Name =:System.Label.PRM_Entitlement_RecordType AND PRM_IsActive_Ind__c = True AND PRM_IPA_Partner_Role_Nm__c != null];
        
        //Checking for multiple entitlements on single benefits.
        Map<Id,List<PRM_VXEnttlmntMatrix__c>> benefitEntitlementMap = new Map<Id,List<PRM_VXEnttlmntMatrix__c>>();
            if(!benefitListTemp.isEmpty()){
                for(PRM_VXEnttlmntMatrix__c em1 :[Select Id,PRM_Partner_Benefit_Id__c,PRM_Entitlement_Id__c,PRM_Contact_Relationship_Id__c,PRM_IPA_Partner_Role_Nm__c,PRM_Approval_Type_Nm__c,PRM_IsActive_Ind__c,PRM_AGS_Role__c,PRM_Entitlement_Id__r.Name From PRM_VXEnttlmntMatrix__c Where (PRM_Partner_Benefit_Id__c IN :benefitListTemp) AND PRM_Approval_Type_Nm__c = 'Automatic' AND PRM_IsActive_Ind__c = True AND PRM_IPA_Partner_Role_Nm__c != null]){
                    List<PRM_VXEnttlmntMatrix__c> entitlements = new List<PRM_VXEnttlmntMatrix__c>();
                    if(benefitEntitlementMap.get(em1.PRM_Partner_Benefit_Id__c)!= null && !benefitEntitlementMap.get(em1.PRM_Partner_Benefit_Id__c).isEmpty()){entitlements = benefitEntitlementMap.get(em1.PRM_Partner_Benefit_Id__c);
                                                                                                                                                              }
                    entitlements.add(em1);
                    benefitEntitlementMap.put(em1.PRM_Partner_Benefit_Id__c,entitlements);
                }
            }
            if(accIdList != null && !accIdList.IsEmpty()){
                List<Account> accounts = [Select Id, Name From Account Where Id IN:accIdList]; 
                Map<Id,List<PRM_VXEnttlmntMatrix__c>> accEntitlementsMap= new Map<Id,List<PRM_VXEnttlmntMatrix__c>>();
                for(Account acc :accounts){
                    List<Id> accBenefits = new List<Id>();
                    accBenefits = benefitMap.get(acc.Id);
                    if(accBenefits != null && !accBenefits.IsEmpty()){
                        List<PRM_VXEnttlmntMatrix__c> accEntitlements = new List<PRM_VXEnttlmntMatrix__c>();
                        if(accEntitlementsMap.get(acc.Id)!= null && !accEntitlementsMap.get(acc.Id).isEmpty()){accEntitlements = accEntitlementsMap.get(acc.Id);
                                                                                                              }
                        for(integer i=0; i<accBenefits.size(); i++){
                            List<PRM_VXEnttlmntMatrix__c> benfitEntitlements = new List<PRM_VXEnttlmntMatrix__c>();
                            benfitEntitlements = benefitEntitlementMap.get(accBenefits[i]);
                            if(benfitEntitlements != null && !benfitEntitlements.IsEmpty()){
                                accEntitlements.addAll(benfitEntitlements);
                            }
                        }
                        accEntitlementsMap.put(acc.Id, accEntitlements);
                    }
                }
                //Assigning contact entitlements.
                for(PRM_Account_Contact_Relationship__c acr :accConRelList){
                    if(acr.PRM_Status_Nm__c != 'Complete'){continue; 
                    }
                    List<PRM_VXEnttlmntMatrix__c> entitlements = new List<PRM_VXEnttlmntMatrix__c>();
                    //List<string> partnerRole = new List<string>();
                    entitlements = accEntitlementsMap.get(acr.PRM_Account_Id__c);
                    if(entitlements != null && !entitlements.IsEmpty() && acr.PRM_Partner_Role__c != null){ // Assigning entitlements based on the benefits.
                        for(integer i=0; i<entitlements.size(); i++){
                            if(entitlements[i].PRM_Contact_Relationship_Id__c == acr.PRM_Relationship_Id__c && (acr.PRM_Partner_Role__c == entitlements[i].PRM_IPA_Partner_Role_Nm__c)){
                                entAgsMap.put(entitlements[i].PRM_Entitlement_Id__c,entitlements[i].PRM_AGS_Role__c);
                                Core_Contact_Entitlement__c ce = new Core_Contact_Entitlement__c();
                                ce.Core_Contact_Id__c = acr.PRM_Contact_Id__c;
                                ce.Core_Entitlement_Id__c = entitlements[i].PRM_Entitlement_Id__c;
                                ce.Core_Selected__c = true;
                                ce.Core_From_Source__c = false;
                                // avoid SOQL 101 exception in existing entitlement trigger code
                                
                                if(!Test.isRunningTest()){ ce.Core_Data_Loaded__c = true;
                                                          ce.Core_DontNotify__c = false;}
                                if(entitlements[i].PRM_AGS_Role__c == '' || entitlements[i].PRM_AGS_Role__c == null){
                                    ce.Core_From_Source__c = true;
                                }
                                if(!ceList.Contains(ce)){
                                    ceList.add(ce);
                                }
                            }
                        }
                    }
                    // Assigning default entitlements.
                    for(PRM_VXEnttlmntMatrix__c em :entitlementWithoutBenefit){
                        List<PRM_AccountChannelMembership__c> acm = new List<PRM_AccountChannelMembership__c>();
                        if(acmMap !=null && !acmMap.IsEmpty()){
                            acm = acmMap.get(acr.PRM_Account_Id__c);
                        }
                        for(integer i=0; i<acm.size(); i++){
                            if(acr.PRM_Partner_Role__c != null){
                                if((em.PRM_Contact_Relationship_Id__c == acr.PRM_Relationship_Id__c) && (acr.PRM_Partner_Role__c == em.PRM_IPA_Partner_Role_Nm__c) && (em.PRM_Channel_Program_Level_Id__c == acm[i].PRM_Channel_Program_Level_Id__c) && (acr.PRM_Partner_Role__c == acm[i].PRM_Partner_Role__c)){
                                    entAgsMap.put(em.PRM_Entitlement_Id__c,em.PRM_AGS_Role__c);
                                    Core_Contact_Entitlement__c ce1 = new Core_Contact_Entitlement__c();
                                    ce1.Core_Contact_Id__c = acr.PRM_Contact_Id__c;
                                    ce1.Core_Entitlement_Id__c = em.PRM_Entitlement_Id__c;
                                    ce1.Core_Selected__c = true;
                                    //ce1.Core_Status__c = System.Label.PRM_Status_Pending;
                                    ce1.Core_Data_Loaded__c = true;
                                    ce1.Core_DontNotify__c = false;
                                    ce1.Core_From_Source__c = false;
                                    if(em.PRM_AGS_Role__c == '' || em.PRM_AGS_Role__c == null){
                                        ce1.Core_From_Source__c = true;
                                    }
                                    if(!ceList.Contains(ce1)){
                                        ceList.add(ce1);
                                    }
                                }
                            }
                        }
                    }
                }
            }
            //Checking for existing Contact Entitlements.
            // Core_Type__c = 'Entitlement'
            if(contactRelatedACRList.size()>0 && !contactRelatedACRList.isEmpty()){
                for(Core_Contact_Entitlement__c ce : [Select Id, Name,Core_Selected__c,Core_Entitlement_Id__c,Core_Contact_Id__c,Core_Status__c,Core_Data_Loaded__c,Core_DontNotify__c,Core_Type__c,Core_Source__c,Core_From_Source__c From Core_Contact_Entitlement__c Where Core_Contact_Id__c IN :contactRelatedACRList]){
                    Core_Contact_Entitlement__c newCe = new Core_Contact_Entitlement__c();
                    newCe.Core_Contact_Id__c = ce.Core_Contact_Id__c;
                    newCe.Core_Entitlement_Id__c = ce.Core_Entitlement_Id__c;
                    newCe.Core_Selected__c = true;
                    newCe.Core_Data_Loaded__c = true;
                    newCe.Core_DontNotify__c = false;
                    newCe.Core_From_Source__c = ce.Core_From_Source__c;
                    ceMap.put(newCe, ce.Id);
                    ceStatusMap.put(ce.Id,ce);
                }
            }
            //System.debug('ceMap-->'+ceMap);
            //System.debug('ceStatusMap-->'+ceStatusMap);
            for(Core_Contact_Entitlement__c ce :ceList){
                //System.debug('inside for CE-->'+ce);
                updateCheck = false;
                beCon.add(ce.Core_Contact_Id__c);
                beEnt.add(ce.Core_Entitlement_Id__c);
                if(ceMap.containsKey(ce)){ce.Id = ceMap.get(ce); 
                                          Core_Contact_Entitlement__c contEnt = ceStatusMap.get(ce.Id);
                                          if(contEnt.Core_Source__c == '' && contEnt.Core_Source__c == null){ ce.Core_Source__c = updateReasonCSPFlow;
                                                                                                             updateCheck = true;
                                                                                                            }
                                          if(!contEnt.Core_Selected__c){ce.Core_Selected__c = true;
                                                                        if((entAgsMap != null && !entAgsMap.IsEmpty()) && (entAgsMap.get(ce.Core_Entitlement_Id__c) != '' && entAgsMap.get(ce.Core_Entitlement_Id__c) != null)){ce.Core_Status__c = 'Pending'; 
                                                                                                                                                                                                                               }
                                                                        updateCheck = true;
                                                                       }
                                          if(updateCheck){finalCEList.add(ce);
                                                         }
                                         }
                else{
                    ce.Core_Selected__c = true; //Inserting Entitlements.
                    if(ce.Core_Source__c == null && ce.Core_Source__c == ''){ ce.Core_Source__c = updateReasonCSPFlow;
                                                                            }
                    if((entAgsMap != null && !entAgsMap.IsEmpty()) && (entAgsMap.get(ce.Core_Entitlement_Id__c) != '' && entAgsMap.get(ce.Core_Entitlement_Id__c) != null)){ce.Core_Status__c = 'Pending'; 
                                                                                                                                                                           }
                    finalCEList.add(ce);
                }
            }
            //System.debug('finalCEList-->'+finalCEList);
            if((beCon != null && !beCon.IsEmpty()) && (beEnt != null && !beEnt.IsEmpty())){ // Updating batch entitlement records.
                for(PRM_Batch_Entitlement__c batchEntitlements :[Select Id, Name, PRM_Contact_Id__c,PRM_Entitlement_Id__c,PRM_Status_Nm__c,PRM_IsRemove_Ind__c From PRM_Batch_Entitlement__c Where PRM_Status_Nm__c = 'New' AND PRM_Contact_Id__c IN:beCon AND PRM_Entitlement_Id__c IN :beEnt]){batchEntitlements.PRM_Status_Nm__c = 'Success';
                                                                                                                                                                                                                                                                                                 beListTemp.add(batchEntitlements);
                                                                                                                                                                                                                                                                                                }
            }
            if(finalCEList != null && !finalCEList.IsEmpty()){
                for(Core_Contact_Entitlement__c ce :finalCEList){ // Inserting batch entitlement records.
                    PRM_Batch_Entitlement__c be = new PRM_Batch_Entitlement__c();
                    be.PRM_Contact_Id__c = ce.Core_Contact_Id__c;
                    be.PRM_Entitlement_Id__c = ce.Core_Entitlement_Id__c;
                    be.PRM_Status_Nm__c = System.label.PRM_Status_New;
                    if(!beListTemp.Contains(be)){
                        beListTemp.add(be);
                    }
                }
            }
            if(beListTemp != null && !beListTemp.IsEmpty()){
                upsert beListTemp;
            }
        }
        catch(Exception e){PRM_ErrorUtilityClass.logError(e);
        }
        
    }
    /* *****************************************************************************************************************************************
* author:      Tejasree      
* Date:        23/04/2020
* Parameters:  list<PRM_Account_Contact_Relationship__c> lstOfACR, map<id,PRM_Account_Contact_Relationship__c> mapOldACRById 
* Return:      Void
* UserStory:   US632447
* Description: This method is used to update Start Date and End Date fields of AccountContactRelationship Object on insertion and inActivation in ACR 
****************************************************************************************************************************************** */   
    public static void updateStartandEndDates(List<PRM_Account_Contact_Relationship__c> acrList,Map<Id,PRM_Account_Contact_Relationship__c> oldMap){
        try{        
            for(PRM_Account_Contact_Relationship__c  acr: acrList){
                PRM_Account_Contact_Relationship__c  acrOld ; 
                if(oldMap!=null && oldMap.size()>0) {acrOld = (PRM_Account_Contact_Relationship__c)oldMap.get(acr.id) ;}
                //For insertion of new ACR records        
                //Filtering the records based on below conditions during ACR Update 
                if(((oldMap==null) && (acr.PRM_InActive_Ind__c==false) && (acr.PRM_Status_Nm__c == System.Label.PRM_ACR_Status)) || 
                   ((oldMap!=null && oldMap.size()>0)&&((acrOld.PRM_InActive_Ind__c != acr.PRM_InActive_Ind__c)&&(acr.PRM_Status_Nm__c == System.Label.PRM_ACR_Status) ||((acrOld.PRM_Status_Nm__c!=acr.PRM_Status_Nm__c) && (acr.PRM_Status_Nm__c ==System.Label.PRM_ACR_Status)))))
                {
                    //During Activation or ReActivation of ACR record based on below conditions, set Start Date and End Date accordingly
                    if(acr.PRM_InActive_Ind__c==false){  
                        acr.PRM_Start_Date_Dt__c= system.today(); 
                        if((acr.PRM_End_Date_Dt__c!=Null)&&(acr.PRM_End_Date_Dt__c<=system.today())){ acr.PRM_End_Date_Dt__c=Null;
                                                                                                     //System.debug('End date after assignment' +acr.PRM_End_Date_Dt__c);
                                                                                                    }                                              
                    }
                    //Assigning EndDate value to the date when ACR is Deactivated.
                    else if((acr.PRM_InActive_Ind__c==true)&&((acr.PRM_End_Date_Dt__c==null) ||(acr.PRM_End_Date_Dt__c>system.today()))){acr.PRM_End_Date_Dt__c=system.today();
                    }
                }  
            }    
        }catch(Exception e){
            PRM_ErrorUtilityClass.logError(e);            
        }
    } 
    
    /************************************************************
Method:    emailForPrimaryContact        
Return:    void
Purpose:   Email to primary contact when such inactive operation of ACR happen

************************************************************/
    
    public static void emailForPrimaryContact(Map<id,sObject> oldMap, Map<id,sObject> newMap){
        try{
            Id profileId=userinfo.getProfileId();
            String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
            //system.debug('ProfileName :- '+profileName);
            
            if(String.isNotEmpty(profileName) && profileName.toUpperCase() != System.Label.PRM_INTEGRATION_PROFILE.toUpperCase()){
                PRM_EmailToPrimaryContact.sendEmailToAllPrimaryContact(oldMap,newMap,null,false, true);
            }
        }catch(Exception e){PRM_ErrorUtilityClass.logError(e);}
    }
    
    
    public class InputParamsValues{
        String accountId;
        String contactId;
    }
    
    /************************************************************
Method:    autoPopulateContactSegment        
Return:    void
Purpose:   Update the Contact Segment on contact based on the partner role of associated contact

************************************************************/
    
    
    public static void autoPopulateContactSegment(List<PRM_Account_Contact_Relationship__c> acctContRelNewList){      
            String accountPartnerSegment;
            String contactPartnerSegment;            
            Map<String,String> segTypeMap = new Map<String,String>();
            Set<String> contactIds = new Set<String>();           
            //Set<Id> conRelIds = new Set<Id>();
            List<Contact> contList = new List<Contact>();
            List<Account> accList = new List<Account>();
        	Set<Id> ipaAccountIdSet = new Set<Id>();
        
           try{
            if(acctContRelNewList != null){
                for(PRM_Account_Contact_Relationship__c acr:acctContRelNewList){                            
                    contactIds.add(acr.PRM_Contact_Id__c);
                    if(acr.PRM_Status_Nm__c == 'Complete' && System.label.PRM_IPA_ContactRelationships.contains(acr.PRM_Relationship_Id__c)){ipaAccountIdSet.add(acr.PRM_Account_Id__c);    }
                }
            }
            if(contactIds!=null && !contactIds.isEmpty()){
                List<Contact> conlst= new List<Contact>();
                Set<Id> accIds = new Set<Id>();
                contList = [Select id, name,Core_IPA_Contact_Segment__c,Core_IPA_PartnerRole__c,AccountId from Contact where id in :contactIds];                
                for(PRM_PartnerRoleTypeMappings__mdt segTypeReq : [Select Id,PRM_Partner_Role__c,PRM_Partner_Segment__c from PRM_PartnerRoleTypeMappings__mdt where PRM_Partner_Segment__c != null]){
                    segTypeMap.put(segTypeReq.PRM_Partner_Role__c,segTypeReq.PRM_Partner_Segment__c);
                }                
                //System.debug('segTypeMap--->'+segTypeMap);                 
                for(Contact con : contList){            
                    accIds.add(con.AccountId);
                    for(String str : segTypeMap.keyset()){
                        if(str.equals(con.Core_IPA_PartnerRole__c)){ 
                            accountPartnerSegment = segTypeMap.get(str); 
                            contactPartnerSegment =segTypeMap.get(str);
                        }
                    }
                    if(String.isBlank(con.Core_IPA_Contact_Segment__c)){con.Core_IPA_Contact_Segment__c = contactPartnerSegment;
                    }else {
                        List<String> contactsegList = (con.Core_IPA_Contact_Segment__c).split(';');
                        if(!contactsegList.contains(contactPartnerSegment)){con.Core_IPA_Contact_Segment__c = con.Core_IPA_Contact_Segment__c+';'+ contactPartnerSegment;
                        }
                    }
                    conlst.add(con); 
                }
                if(conlst.size()>0){
                    Database.update(conlst,false);
                }
                //System.debug('conlist-->'+conlst);
                if(accIds!=null && !accIds.isEmpty()){
                    List<Account> existingAccountList = [Select Id,Core_Intel_Partner_Alliance_PartnerGroup__c, Core_IPA_Partner_Role__c,Core_IPA_Partner_Segment__c from Account where Id IN : accIds ];                    
                    for(Account Acc : existingAccountList){                        
                        if(String.isBlank(acc.Core_IPA_Partner_Segment__c)){acc.Core_IPA_Partner_Segment__c = accountPartnerSegment;
                        }else {
                            List<String> partnersegList = (acc.Core_IPA_Partner_Segment__c).split(';');
                            if(!partnersegList.contains(accountPartnerSegment)){   acc.Core_IPA_Partner_Segment__c = acc.Core_IPA_Partner_Segment__c+';'+ accountPartnerSegment;
                            }
                        }
                        if(ipaAccountIdSet.contains(acc.id)){acc.Core_Intel_Partner_Alliance_PartnerGroup__c = true;   
                        }
                        accList.add(acc);
                    } 
                    if(accList.size()>0){
                        Database.update(accList,false);
                    }
                }
            }
            
        }catch(Exception e){PRM_ErrorUtilityClass.logError(e);
        }
    }
    
    /************************************************************
Method:    suppressEmail        
Return:    void
Purpose:   Whenever suppress email is checked to true, It creates email handler records to supress the email in the respective event

************************************************************/ 
    
    //Added by Vijay(Agate Team) as a part Suppress Email functionality from Userstory TWC729-174
    public static void suppressEmail(List<PRM_Account_Contact_Relationship__c> acctContRelList, map<Id, PRM_Account_Contact_Relationship__c> oldMap){
        //Map<Id,String> conIdConEmailMap = new Map<Id,String>();
        List<PRM_Email_Handler__c> emailHandlerRecordsToInsert= new List<PRM_Email_Handler__c>();    
        try{
            for(PRM_Account_Contact_Relationship__c acr :acctContRelList){
                PRM_Account_Contact_Relationship__c oldAcr = oldMap!= null && oldMap.containsKey(acr.Id) ? oldMap.get(acr.Id) : null;
                if((oldAcr == null && acr.PRM_Suppress_Email__c) 
                    || (oldAcr != null && acr.PRM_Suppress_Email__c != oldAcr.PRM_Suppress_Email__c && acr.PRM_Suppress_Email__c) 
                ){           
                PRM_Email_Handler__c emailHandler = new PRM_Email_Handler__c();
                emailHandler.PRM_Contact__c =acr.PRM_Contact_Id__c;          
                emailHandler.PRM_Event__c = acr.PRM_Source_Agent__c != null ? acr.PRM_Source_Agent__c : 'Partner Invite';
                emailHandler.PRM_Email_Handler_Status__c = 'Requested For Suppression';
                emailHandler.PRM_Suppress_Email__c = true;
                emailHandlerRecordsToInsert.add(emailHandler);
                //System.debug('Contact Email-->'+acr.PRM_Contact_Id__r.email);
                //acr.PRM_Status_Reason_Txt__c=UserInfo.getName()+' '+' has opted for Suppress Email In this Transaction';
                }
                //System.debug('emailHandlerRecordsToInsert'+emailHandlerRecordsToInsert);
                }
             if(emailHandlerRecordsToInsert.size()>0 && !emailHandlerRecordsToInsert.isEmpty()){
                    insert emailHandlerRecordsToInsert;//Insert first Handler Record
            }
        }catch(Exception e){
            PRM_ErrorUtilityClass.logError(e);
        }
    }
    
    /************************************************************
Method:    updateSuppressEmail        
Return:    void
Purpose:   Reset the suppress email indicator when inactive indicator/status of ACR is updated

************************************************************/    
    
    public static void updateSuppressEmail(List<PRM_Account_Contact_Relationship__c> acrList,Map<Id,PRM_Account_Contact_Relationship__c> oldMap){
        try{
        for(PRM_Account_Contact_Relationship__c acr :acrList){
            PRM_Account_Contact_Relationship__c acrOld ; 
            if(oldMap!=null && !oldMap.isEmpty()) {
                acrOld = (PRM_Account_Contact_Relationship__c) oldMap.get(acr.id) ;
            }
            if(acrOld != null && ((acrOld.PRM_InActive_Ind__c == false && acr.PRM_InActive_Ind__c == true && acrOld.PRM_Suppress_Email__c==true) || (acrOld.PRM_Suppress_Email__c==true && acrOld.PRM_Status_Nm__c=='Pending Action' && acr.PRM_Status_Nm__c=='Complete'))){acr.PRM_Suppress_Email__c =false;acr.PRM_Status_Reason_Txt__c='';}
        }
        }
        catch(Exception e){PRM_ErrorUtilityClass.logError(e);}
    }
    
    /************************************************************
Method:    restrictContactAssociatedSystemAcc        
Return:    void
Purpose:   Restricting contact associated with system account and return an error to move a contact to right account

************************************************************/
    
    public static void restrictContactAssociatedSystemAcc(List<PRM_Account_Contact_Relationship__c> acctContRelList){
        Set<id>SysAccIdSet=new Set<id>();
        //Set<id> accountIdSet = new Set<id>();
        
        Map<String,Core_Intel_System_Accounts__mdt> mapSysAcc = Core_Intel_System_Accounts__mdt.getAll();
        
        try{
        for(String keySetString : mapSysAcc.keySet()){
            SysAccIdSet.add(mapSysAcc.get(keySetString).AccountId__c);
            
        }
        for(PRM_Account_Contact_Relationship__c acr :acctContRelList){
            
            if( acr.PRM_Account_Id__c != null && SysAccIdSet!=null && SysAccIdSet.contains(acr.PRM_Account_Id__c)){  acr.addError(System.label.PRM_ACR_SystemAccError);                }
        }    
        }catch(Exception e){PRM_ErrorUtilityClass.logError(e);}
    }
    
    // This method will restrict user to update the ACR Status to 'AGS Identity Creation Failed' manually 
    /* public static void restrictACRStatusUpdateToAGSIdentityCreationFailed(List<PRM_Account_Contact_Relationship__c> acrList,Map<Id,PRM_Account_Contact_Relationship__c> oldMap){
for(PRM_Account_Contact_Relationship__c  acr: acrList){
PRM_Account_Contact_Relationship__c  acrOld ; 
if(oldMap!=null && oldMap.size()>0) {
acrOld = (PRM_Account_Contact_Relationship__c)oldMap.get(acr.id);
if(acrOld.PRM_Status_Nm__c != acr.PRM_Status_Nm__c && acr.PRM_Status_Nm__c == System.label.PRM_ACR_Status_AGS_Identity_Creation_Failed){
acr.addError(CANNOT_UPDATE_ACR_STATUS);
}
}    
}
}   */
    
}