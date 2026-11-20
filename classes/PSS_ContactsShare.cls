/*************************************************************************************************************************************************************************
* Class Name  : PSS_ContactsShare 
* Version     : 1.0 
* Created Date: 5/09/2021
* Modification Log :
*
* Developer         Modification Log                    Date                                            Description
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Krishna           M-01    : Original version       5/09/2021                             Class to retrieve IPA contacts for a solution 
**************************************************************************************************************************************************************************/
//IPA2.0: US-TWC729-7976
@isTest
public without sharing class PSS_ContactsShare {

    /**
    * @description Method to search contact based on contactlist and searchkey
    * @param contactList
    * @param  searchKey
    * @return conList
    **/
    /*@AuraEnabled(cacheable=true)
    public static List<Object> searchContact(List<Object> contactList, string searchKey){
        List<String> contactIds = new List<String>();
        List<Object> conList = new List<Object>();
        string searchKeyword = '%' + searchKey + '%';
        List<String> contList = new List<String>();
        List<String> userList = new List<String>();
        if(!contactList.isEmpty() && !String.isBlank(searchKey)){
            for(Object objRecord : contactList){
                Map<String, Object> mapOfContacts =
                    (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(objRecord));
                String recId = String.valueOf(mapOfContacts.get('Id'));
                contList.add(recId);
            }
            if(contList.size() != 0){
                conList = [Select Id,Name,FirstName,LastName,Email 
                           from Contact 
                           where Id IN : contList AND (Name Like : searchKeyword
                                                       OR FirstName Like : searchKeyword
                                                       OR LastName Like : searchKeyword
                                                       OR Email Like : searchKeyword)];
            }
        }
        return conList;
    }*/
    
    /**
    * @description Method to retrive all IPA contacts for a solution
    * @param recordId
    * @return contactList
    **/
    /*@AuraEnabled
    public static List<SObject> retrieveContact(string recordId){
        try {
            List<Contact> contactList;
            List<User> userList = new List<User>();
            Set<Id> userContactId = new Set<Id>();
            Set<Id> intelAccountsId = new Set<Id>();
            Set<Id> contactId = new Set<Id>();
            List<Account> accts;
            Set<Id> surveyContactId = new Set<Id>();
            Set<Id> opidId = new Set<Id>();
            Set<Id> locAccId = new Set<Id>();
            Set<String> accIds = new Set<String>();
            String cmpId;
            

            if(!String.isBlank(recordId)){
                List<ArdiraSurvey__Survey_Result__c> surveyResult = [select id,PSS_Proposal_Name_Txt__c, 
                                                           PSS_Company_Id__c,PSS_Partner_Account_Id__c,PSS_OPID_Account_Id__c,
                                                           ArdiraSurvey__Assigned_To_Contact__c from ArdiraSurvey__Survey_Result__c 
                                                           where id =: recordId];
                if(surveyResult != null && !surveyResult.isEmpty()){
                    for(ArdiraSurvey__Survey_Result__c sresult:surveyResult){
                        surveyContactId.add(sresult.ArdiraSurvey__Assigned_To_Contact__c);
                        if(string.isNotBlank(sresult.PSS_Partner_Account_Id__c)){
                        	locAccId.add(sresult.PSS_Partner_Account_Id__c);
                            intelAccountsId.add(sresult.PSS_Partner_Account_Id__c);//added by kirshna as part of contacts share defect fix.
                        }
                        if(string.isNotBlank(sresult.PSS_OPID_Account_Id__c)){
                        	opidId.add(sresult.PSS_OPID_Account_Id__c);
                            accIds.add(sresult.PSS_OPID_Account_Id__c);
                        }
                        if(string.isNotBlank(sresult.PSS_Company_Id__c)){
                        	cmpId = sresult.PSS_Company_Id__c;
                        }
                    }
                }
                if(cmpId != NULL){
                   for(PMP_OPID_MPI_Rel__c opMPI :[select id,Name,Is_Active__c,PMP_Marketing_Profile_Id__c, PMP_Marketing_Profile_Id__r.Name,PMP_Marketing_Profile_Id__r.PMP_Is_Published_Ind__c,
                                                   PMP_Marketing_Profile_Id__r.PMP_Benefit_Update_Ind__c,PMP_Marketing_Profile_Id__r.PMP_Company_Lifecycle_Status_Nm__c, 
                                                   PMP_One_Partner_ID__c,PMP_One_Partner_ID__r.RecordType.Name from PMP_OPID_MPI_Rel__c where Is_Active__c = true and PMP_Marketing_Profile_Id__r.PMP_Benefit_Update_Ind__c = false and
                                                   PMP_Marketing_Profile_Id__r.PMP_Is_Published_Ind__c = true and 
                                                   PMP_Marketing_Profile_Id__c =:cmpId]){
                                               if(opMPI.PMP_One_Partner_ID__c != NULL) {
                                                  accIds.add(opMPI.PMP_One_Partner_ID__c); 
                                               }  
                                               
                                           }
                //contactList = PSS_PartnersOnSolution.getPartnerContacts(cmpId);

                }
                if( (accIds != null && !accIds.isEmpty()) && (locAccId != null && !locAccId.isEmpty()) ){
                    
                    for(Core_Account_Group_Member__c cagm :[Select Id, Core_Intel_Account_Id__c, Core_Partner_Account_Id__c 
                                                                from Core_Account_Group_Member__c 
                                                                where Core_Partner_Account_Id__c =: accIds OR Core_Intel_Account_Id__c =: accIds]){
                                                                    intelAccountsId.add(cagm.Core_Intel_Account_Id__c);
                                                                }
                    if(!intelAccountsId.isEmpty()){
                        for(PRM_Account_Contact_Relationship__c pcr : [Select Id, PRM_Contact_Id__c,PRM_Account_Id__c,
                                                                           PRM_InActive_Ind__c,PRM_Status_Nm__c from PRM_Account_Contact_Relationship__c 
                                                                           where PRM_Account_Id__c IN :intelAccountsId AND PRM_InActive_Ind__c = false AND 
                                                                           PRM_Status_Nm__c = 'Complete']){
                                                                               contactId.add(pcr.PRM_Contact_Id__c);
                                                                           }
                        if(!contactId.isEmpty()){
                            for(User usr:[Select Id,ContactId,Name from User where ContactId IN:contactId AND isActive = True]){
                                userContactId.add(usr.ContactId);
                            }
                            contactList = [select Id, Name, FirstName, LastName, Email,AccountId from Contact where Id !=: surveyContactId and Id In : userContactId];
                        }
                    }
                }
                else if(opidId.isEmpty() && locAccId != null && !locAccId.isEmpty()){
                    for(PRM_Account_Contact_Relationship__c pcr : [Select Id, PRM_Contact_Id__c,PRM_Account_Id__c,
                                                                       PRM_InActive_Ind__c,PRM_Status_Nm__c from PRM_Account_Contact_Relationship__c 
                                                                       where PRM_Account_Id__c =:locAccId AND PRM_InActive_Ind__c = false AND 
                                                                       PRM_Status_Nm__c = 'Complete']){
                                                                           contactId.add(pcr.PRM_Contact_Id__c);
                                                                       }
                    if(!contactId.isEmpty()){
                        for(User usr:[Select Id,ContactId,Name from User where ContactId IN:contactId]){
                            userContactId.add(usr.ContactId);
                        }
                        contactList = [select Id, Name, FirstName, LastName, Email from Contact where Id !=: surveyContactId and Id In : userContactId];
                    }
                }
            }
            return contactList;
        }
        catch(Exception e){
            throw(e);
        }
    }*/
    
    /**
    * @description Method to retrive shared records for a particular solution
    * @param conList
    * @param recordId
    * @return contactsShared
    **/
    /*@AuraEnabled
    public static List<Object> retrieveShareRecords(List<Contact> conList, string recordId){
        List<ArdiraSurvey__Survey_Result__Share> shareReords;
        List<Contact> contactsShared = new List<Contact>();
        Set<Id> userId = new Set<Id>();
        Set<Id> usr = new Set<Id>();
        Set<Id> conId = new Set<Id>();
        if(!conList.isEmpty() && !String.isBlank(recordId)){
            for(User userRecord : [Select Id,ContactId,Name,Email,FirstName,LastName from User where ContactId IN : conList]){
                userId.add(userRecord.Id);
            }
            if(!userId.isEmpty()){
                for(ArdiraSurvey__Survey_Result__Share share : [Select Id,UserOrGroupId,ParentId,AccessLevel from ArdiraSurvey__Survey_Result__Share 
                                                                where ParentId =:recordId and UserOrGroupId IN : userId]){
                                                                    usr.add(share.UserOrGroupId);
                                                                }
            }
            if(!usr.isEmpty()){
                for(User user :[Select Id,ContactId from User Where Id IN : usr]){
                    conId.add(user.ContactId);
                }
            }
            contactsShared = [Select Id,Name,FirstName,LastName,Email from Contact where Id IN : conId];
        }
        return contactsShared;
    }*/
    
    /**
    * @description Method to share the solution for a lis of users
    * @param contacts
    * @param asrId
    **/
    /*@Auraenabled
    public static List<Object> sharingSolutionRecords(List<Object> contacts,string asrId){
        string recordId = asrId;
        List<String> contactRecord = new List<String>();
        List<Contact> contactRecordsForSolution;
        List<User> userRecords;
        List<ArdiraSurvey__Survey_Result__Share> sharedSolLList;
        List<ArdiraSurvey__Survey_Result__Share> solShareList = new List<ArdiraSurvey__Survey_Result__Share>();
        
        if (!String.isBlank(recordId)){
            contactRecordsForSolution = PSS_ContactsShare.retrieveContact(recordId);
        }
        if(contactRecordsForSolution!= null && !contactRecordsForSolution.isEmpty()){
            userRecords = [select id,ContactId from user where ContactId IN : contactRecordsForSolution];
        }
        system.debug('userRecords :'+userRecords);
        If(userRecords != null && !userRecords.isEmpty()){
            sharedSolLList =[select id,ParentId from ArdiraSurvey__Survey_Result__Share where ParentId =: recordId
                             AND UserOrGroupId IN : userRecords];
            if(sharedSolLList !=null && !sharedSolLList.isempty()){
                delete sharedSolLList;
            }
        }
        system.debug('input Records :'+contacts);
        if(!contacts.isEmpty()){
            List<User> userList;
            List<ArdiraSurvey__Survey_Result__Share> shareList;
            
            for(Object obj : contacts){
                Map<String, Object> mapOfContacts =
                    (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(obj));
                if(!mapOfContacts.isEmpty()){
                    String recId = String.valueOf(mapOfContacts.get('Id'));
                    if(recId != null && recId != ''){
                        contactRecord.add(recId);
                    }
                }
            }
            if(!String.isBlank(recordId)){
                
                if(!contactRecord.isempty()){
                    userList = [select id,ContactId from user where ContactId IN : contactRecord];
                }
                if(!userList.isEmpty()){
                    for(user usr : userList){
                        ArdiraSurvey__Survey_Result__Share solShare = new ArdiraSurvey__Survey_Result__Share();
                        solShare.ParentId = recordId;
                        solShare.UserOrGroupId = usr.id;
                        solShare.AccessLevel ='edit';
                        solShare.RowCause ='Manual';
                        solShareList.add(solShare);
                    }
                }
                System.debug('..solShareList..'+solShareList);
                if(!solShareList.isEmpty()){
                    insert solShareList;
                    insertSoltuionContactAssociationRecords(solShareList,recordId);
                }
            }
        }
        else if(contacts.isEmpty()){
            updateSoltuionContactAssociationRecords(recordId);
        }
        return solShareList;
    }*/

    /**
    * @description Method to upsert a partnercontact association object's record
    * @param solutionResultShareRecords
    * @param solResultId
    **/
    /*public static void insertSoltuionContactAssociationRecords(List<ArdiraSurvey__Survey_Result__Share> solutionResultShareRecords, Id solResultId){
        List<Contact> contactRecordsForSolution;
        List<Id> userIds = new List<Id>();
        List<Id> existingUserIds = new List<Id>();
        PSS_Solution_Contact_Association__c solutionContact;
        PSS_Solution_Contact_Association__c solutionContactExisting;
        Map<Id,User> usersMap = new Map<Id,User>();
                    System.debug('..insertSoltuionContactAssociationRecords..');

        //Map <Id,ArdiraSurvey__Survey_Result__Share > mapShareRecords = new Map <Id, ArdiraSurvey__Survey_Result__Share >();
        List < PSS_Solution_Contact_Association__c > solutionContactAssociations = new List< PSS_Solution_Contact_Association__c >();
        List < PSS_Solution_Contact_Association__c > solutionContactAssociationsExisting = new List< PSS_Solution_Contact_Association__c >();
        Map<String, Id> existingContacts = new Map<String, Id>();
        
        for(PSS_Solution_Contact_Association__c solutionContactRecords : [SELECT Id,Name,PSS_Solution_Name__c,PSS_Assigned_User__c,PSS_Assigned_Contact__c,PSS_Active__c 
                                                                          FROM PSS_Solution_Contact_Association__c WHERE PSS_Solution_Name__c = :solResultId]){
                                                                              existingUserIds.add(solutionContactRecords.PSS_Assigned_User__c);
                                                                              existingContacts.put((solutionContactRecords.PSS_Assigned_User__c + '' + solutionContactRecords.PSS_Assigned_Contact__c), solutionContactRecords.Id);
                                                                          }
        if(!solutionResultShareRecords.isEmpty()){
            System.debug('..solutionContactRecords..'+solutionResultShareRecords);
            for(ArdiraSurvey__Survey_Result__Share solutionResultShare :  solutionResultShareRecords) {
                userIds.add(solutionResultShare.UserOrGroupId); 
            }
            if(!userIds.isEmpty()){
                usersMap = new Map<Id,User>([SELECT Id,ContactId FROM User WHERE ID IN :userIds]);
                
                for(User usr : [Select Id,ContactId from User Where Id IN : userIds]) {
                    String key = usr.Id + '' + usr.ContactId;
                    solutionContact = new PSS_Solution_Contact_Association__c();
                    solutionContact.Id = existingContacts.get(key);
                    solutionContact.PSS_Solution_Name__c = solResultId;
                    solutionContact.PSS_Assigned_User__c = usr.Id;
                    solutionContact.PSS_Assigned_Contact__c = usr.ContactId;
                    solutionContact.PSS_Active__c = true;
                    solutionContactAssociations.add(solutionContact);
                }
            }
            if(!solutionContactAssociations.isempty()){
                upsert solutionContactAssociations;
            }
            if(!existingUserIds.isEmpty() && !userIds.isEmpty()){
                for (PSS_Solution_Contact_Association__c assoc : [SELECT Id,Name,PSS_Solution_Name__c,PSS_Assigned_User__c,PSS_Assigned_Contact__c,PSS_Active__c 
                                                                  FROM PSS_Solution_Contact_Association__c WHERE PSS_Solution_Name__c = :solResultId AND PSS_Assigned_User__c NOT IN : userIds AND PSS_Assigned_User__c IN : existingUserIds]){
                                                                      solutionContactExisting = new PSS_Solution_Contact_Association__c();
                                                                      solutionContactExisting.Id = assoc.Id;
                                                                      solutionContactExisting.PSS_Active__c = false;
                                                                      solutionContactAssociationsExisting.add(solutionContactExisting);
                                                                  }
            }
            if(!solutionContactAssociationsExisting.isempty()){
                update solutionContactAssociationsExisting;
            }
        }
    }*/

    /**
    * @description Method to update a partnercontact association object's record when the sharelist of solution is null
    * @param solResultId
    **/
    /*public static void updateSoltuionContactAssociationRecords(Id solResultId){
        List<Id> existingUserIds = new List<Id>();
        PSS_Solution_Contact_Association__c solutionContactExisting;
        List < PSS_Solution_Contact_Association__c > solutionContactAssociationsExisting = new List< PSS_Solution_Contact_Association__c >();
        for(PSS_Solution_Contact_Association__c solutionContactRecords : [SELECT Id,Name,PSS_Solution_Name__c,
                                                                          PSS_Assigned_User__c,PSS_Assigned_Contact__c,
                                                                          PSS_Active__c
                                                                          FROM PSS_Solution_Contact_Association__c 
                                                                          WHERE PSS_Solution_Name__c = :solResultId]){
                                                                              existingUserIds.add(solutionContactRecords.PSS_Assigned_User__c);
                                                                          }
        if(!existingUserIds.isEmpty()){
            for (PSS_Solution_Contact_Association__c assoc : [SELECT Id,Name,PSS_Solution_Name__c,PSS_Assigned_User__c,PSS_Assigned_Contact__c,PSS_Active__c 
                                                          FROM PSS_Solution_Contact_Association__c WHERE PSS_Solution_Name__c = :solResultId AND PSS_Assigned_User__c IN : existingUserIds]){
                                                              solutionContactExisting = new PSS_Solution_Contact_Association__c();
                                                              solutionContactExisting.Id = assoc.Id;
                                                              solutionContactExisting.PSS_Active__c = false;
                                                              solutionContactAssociationsExisting.add(solutionContactExisting);
                                                          }
            if(!solutionContactAssociationsExisting.isempty()){
                update solutionContactAssociationsExisting;
            }
        }
    }*/
    
    /**
    * @description Method to share the solution for a lis of users
    * @param contacts
    * @param asrId
    **/
    /*@Auraenabled
    public static List<Object> shareSolution(List<Object> contacts,string asrId){
        string recordId = asrId;
        List<String> contactRecord = new List<String>();
        List<Contact> contactRecordsForSolution;
        List<User> userRecords;
        List<ArdiraSurvey__Survey_Result__Share> sharedSolLList;
        List<ArdiraSurvey__Survey_Result__Share> solShareList = new List<ArdiraSurvey__Survey_Result__Share>();
        
        if(!contacts.isEmpty()){
            List<User> userList;
            List<ArdiraSurvey__Survey_Result__Share> shareList;
			
			for(Object obj : contacts){
                Map<String, Object> mapOfContacts =
                    (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(obj));
                if(!mapOfContacts.isEmpty()){
                    String recId = String.valueOf(mapOfContacts.get('Id'));
                    if(recId != null && recId != ''){
                        contactRecord.add(recId);
                    }
                }
            }

            if(!String.isBlank(recordId)){
                
                if(!contactRecord.isempty()){
                    userList = [select id,ContactId from user where ContactId IN : contactRecord];
                    system.debug(userList);
                }
                if(!userList.isEmpty()){
                    for(user usr : userList){
                        ArdiraSurvey__Survey_Result__Share solShare = new ArdiraSurvey__Survey_Result__Share();
                        solShare.ParentId = recordId;
                        solShare.UserOrGroupId = usr.id;
                        solShare.AccessLevel ='edit';
                        solShare.RowCause ='Manual';
                        solShareList.add(solShare);
                    }
                }
                if(!solShareList.isEmpty()){
                    insert solShareList;
                    insertSoltuionContactAssociationRecords(solShareList,recordId);
                }
            }
        }
        else if(contacts.isEmpty()){
            updateSoltuionContactAssociationRecords(recordId);
        }
        return solShareList;
    }*/
    
    
    /**
    * @description Method to retrive all shared contacts for a solution for which we trigger emails
    * @param recordId
    * @return List of sharedContacts
    **/
    /*@AuraEnabled
	 public static List<Object> fetchSharedContactsForSolution(Id solutionId){
		List<PSS_Solution_Contact_Association__c> solutionContactsToEmail = new List<PSS_Solution_Contact_Association__c>();
         List<Contact> contactList = new List<Contact>();
        // CRUD Check
        if(Schema.sObjectType.PSS_Solution_Contact_Association__c.isAccessible()){
            //get all the shared contacts to which we need to send email.
            solutionContactsToEmail = [SELECT Id,PSS_Solution_Name__c,PSS_Assigned_User__c,PSS_Assigned_Contact__c,PSS_Assigned_Contact__r.Name, PSS_Assigned_Contact__r.Email,
                                       PSS_Solution_Name__r.ArdiraSurvey__Assigned_To_Contact__c FROM PSS_Solution_Contact_Association__c
                                       WHERE PSS_Solution_Name__c = :solutionId AND PSS_Active__c =true  AND PSS_Assigned_User__r.IsPortalEnabled= true 
                                       AND  PSS_Assigned_User__r.IsActive=true];
        } 
         for (PSS_Solution_Contact_Association__c con: solutionContactsToEmail){
             if(con.PSS_Assigned_Contact__c!=con.PSS_Solution_Name__r.ArdiraSurvey__Assigned_To_Contact__c){
                 contactList.add(new Contact (Id=con.PSS_Assigned_Contact__c,Email=con.PSS_Assigned_Contact__r.Email));}
         }
		return contactList;
   }*/
}