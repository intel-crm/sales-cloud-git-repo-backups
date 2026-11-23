/**************************************************************************************
Apex Class Name : PMP_Batch_Group_Management
Version     : 1.0 
Created Date: 20th may, 2019
Description : Creating a public group(if not present) for partner account, adding the appropriate members to the group based on their 
contact entitlemnets and removing the members based contact entitlement removal 
* Modification Log :
* Developer                 Date                     Description
* ----------------------------------------------------------------------------
* Raushan                  20/05/2019               Original Version
*************************************************************************************/

public class PMP_Batch_Group_Management {
     
    static final String CORE_MP_STR = System.Label.PMP_Group_Name_Prefix;
    static final String COMPLETE_STR = 'Complete';
    static final String ALL_PARTNERS_ODM_GROUP = System.Label.PMP_Group_All_Partner_Users_ODM;
    static final String ALL_PARTNERS_NON_ODM_GROUP = System.Label.PMP_Group_All_Partner_Users_Non_ODM;
    
    /* Send a refined list of Partner Accounts excluding the ones which doesn't have any
* contact entitlements
* */
    private static List<Account> refinePartnerAccounts(List<Account> allPartnerAccounts, Set<Id> accId){
        
        List<Account> refinedPartnerAccs = new List<Account>();
        Set<Id> allIntelAccounts = new Set<Id>();
        Map<Id, Set<Id>> partnerAccToIntelAccounts = new Map<Id, Set<Id>> ();
        String partnerAccRecTypeId = System.Label.PMP_Partner_Account_Record_Type_Id;
        
        if(accId !=null && !accId.isEmpty()){
            for(Core_Account_Group_Member__c allPartnerAccGroup:[SELECT Id, Core_Partner_Account_Id__c,Core_MDA_Ind__c, 
                                                                 Core_Intel_Account_Id__c FROM Core_Account_Group_Member__c 
                                                                 WHERE Core_Partner_Account_Id__c IN:accId AND Core_MDA_Ind__c=true AND Core_Inactive_Ind__c=false ]){
                                                                     
                                                                     if(partnerAccToIntelAccounts.get(allPartnerAccGroup.Core_Partner_Account_Id__c) != null){
                                                                         partnerAccToIntelAccounts.get(allPartnerAccGroup.Core_Partner_Account_Id__c).add(allPartnerAccGroup.Core_Intel_Account_Id__c);                                             
                                                                         allIntelAccounts.add(allPartnerAccGroup.Core_Intel_Account_Id__c);
                                                                     }else{
                                                                         partnerAccToIntelAccounts.put(allPartnerAccGroup.Core_Partner_Account_Id__c, 
                                                                                                       new Set<Id>{allPartnerAccGroup.Core_Intel_Account_Id__c});
                                                                         allIntelAccounts.add(allPartnerAccGroup.Core_Intel_Account_Id__c);
                                                                     }                                               
                                                                 }
            
            Map<Id, Map<Id, Id>> IntelAccountIdToCotactIds = new Map<Id, Map<Id, Id>> ();
            
            if(!allIntelAccounts.isEmpty()){
                for(Contact intelAccContact : [Select Id,AccountId from Contact where AccountId in :allIntelAccounts]){
                    
                    if(IntelAccountIdToCotactIds.get(intelAccContact.AccountId) != null){
                        IntelAccountIdToCotactIds.get(intelAccContact.AccountId).put(intelAccContact.Id,intelAccContact.Id);                                             
                    }else{
                        IntelAccountIdToCotactIds.put(intelAccContact.AccountId, 
                                                      new Map<Id,Id>{intelAccContact.Id=>intelAccContact.Id});
                    }            
                }
            }
            
            Map<Id, Set<Id>> partnerAccToIntelAccContactIds = new Map<Id, Set<Id>>();
            for(Id partnerAccId : partnerAccToIntelAccounts.keySet()){
                
                Set<Id> intelAccounts = partnerAccToIntelAccounts.get(partnerAccId);
                if(intelAccounts != null){
                    for(Id intelAccId : intelAccounts){
                        
                        if(intelAccId != null && IntelAccountIdToCotactIds.get(intelAccId) != null){
                            partnerAccToIntelAccContactIds.put(partnerAccId, IntelAccountIdToCotactIds.get(intelAccId).keySet());
                        }
                        
                    }//end of 2nd for loop
                }
                
            }// end of 1st for loop
           
            List<id> allIntelAccContactIds = new List<id>(); 
            for(Set<Id> intelAccContactIds : partnerAccToIntelAccContactIds.values()){
                allIntelAccContactIds.addAll(intelAccContactIds);
            }
            
            List<String> lstEntitlementIds = new List<String>();
            
            /******** Fetching MP entitlemet ids from custom label*********/
            List<Core_Entitlement__c> entitlementDetails = new List<Core_Entitlement__c>();
            String Core_Entitlement_Id_Label = System.Label.PMP_External_Entitlement_Ids;
            
            if(!Test.isRunningTest()){
                lstEntitlementIds = Core_Entitlement_Id_Label.split(';');
            }else{
                //Querying Entitlement Detail
                entitlementDetails = [SELECT Id, Name, Core_Display_Name__c FROM Core_Entitlement__c];
                for(Core_Entitlement__c coreEntitlement : entitlementDetails){
                    lstEntitlementIds.add(coreEntitlement.Id);
                }
            }
            
            Map<Id, Boolean> contactIdToEntStatus = new Map<Id, Boolean>();
            
            if(allIntelAccContactIds != null && !allIntelAccContactIds.isEmpty()
               && lstEntitlementIds != null && !lstEntitlementIds.isEmpty()){
                   
                   Map<Id, Boolean> partnerAccToIgnoreStatus = new Map<Id, Boolean>();
                   for(Account partnerAccount : allPartnerAccounts){
                       partnerAccToIgnoreStatus.put(partnerAccount.Id, true);
                   }
                   
                   /********Getting all contact entitlements for mp related entitlements and for allpartnercontact **********/
                   List<Core_Contact_Entitlement__c> conEntList = [SELECT Id,Core_Contact_Id__c,Core_Entitlement_Id__c,Core_Status__c, 
                                                                   Core_Selected__c FROM Core_Contact_Entitlement__c
                                                                   WHERE Core_Status__c = :COMPLETE_STR AND Core_Selected__c = true 
                                                                   AND Core_Entitlement_Id__c = :lstEntitlementIds 
                                                                   AND Core_Contact_Id__c IN :allIntelAccContactIds];
                   
                   for(Core_Contact_Entitlement__c contactEnt :conEntList){
                       if(contactEnt.Core_Contact_Id__c != null)
                           contactIdToEntStatus.put(contactEnt.Core_Contact_Id__c, true);
                   }
                   
                   for(Id partnerAccId : partnerAccToIntelAccContactIds.keySet()){
                       Set<Id> intelAccContactIds = partnerAccToIntelAccContactIds.get(partnerAccId);
                       for(Id contactId : intelAccContactIds){
                           if(contactIdToEntStatus.keySet() != null && contactIdToEntStatus.containskey(contactId)){
                               partnerAccToIgnoreStatus.put(partnerAccId, false);
                           }  
                       }
                   }
                   
                   Set<Id> refinedAccountIds = new Set<Id>();
                   for(Id  partnerAccId : partnerAccToIgnoreStatus.keySet()){
                       if(partnerAccToIgnoreStatus.get(partnerAccId) != null
                          && partnerAccToIgnoreStatus.get(partnerAccId) == false){
                              refinedAccountIds.add(partnerAccId);
                          }
                   }
                   
                   if(refinedAccountIds != null  && !refinedAccountIds.isEmpty()){
                       refinedPartnerAccs = [SELECT Id,Name,Core_PMP_Membership_Change_Ind__c FROM Account 
                                             WHERE RecordTypeId =:partnerAccRecTypeId 
                                             and Core_PMP_Membership_Change_Ind__c=true
                                             and Id in :refinedAccountIds];  
                   }
               }
            
        }
        
        return refinedPartnerAccs;
    }
    
    /*******Method to remove Partner User from the Public Groups if Inactive Indicator is checked for the associated Intel Account of the contact*************/
    public static void deletePublicGrpMembers(){
        
        Set<Id> allIntelAccounts1 = new Set<Id>();
        Map<Id, Set<Id>> partnerAccToIntelAccounts1 = new Map<Id, Set<Id>> ();
        
        for(Core_Account_Group_Member__c allPartnerAccGroup:[SELECT Id, Core_Partner_Account_Id__c, 
                                                             Core_Intel_Account_Id__c FROM Core_Account_Group_Member__c 
                                                             WHERE Core_Inactive_Ind__c =: true
                                                             AND Core_Partner_Account_Id__r.Core_PMP_Membership_Change_Ind__c = :true ]){
                                                                 
                                                                 
                                                                 if(partnerAccToIntelAccounts1.get(allPartnerAccGroup.Core_Partner_Account_Id__c) != null){
                                                                     partnerAccToIntelAccounts1.get(allPartnerAccGroup.Core_Partner_Account_Id__c).add(allPartnerAccGroup.Core_Intel_Account_Id__c);                                             
                                                                     allIntelAccounts1.add(allPartnerAccGroup.Core_Intel_Account_Id__c);
                                                                 }else{
                                                                     partnerAccToIntelAccounts1.put(allPartnerAccGroup.Core_Partner_Account_Id__c, 
                                                                                                    new Set<Id>{allPartnerAccGroup.Core_Intel_Account_Id__c});
                                                                     allIntelAccounts1.add(allPartnerAccGroup.Core_Intel_Account_Id__c);
                                                                 }                                               
                                                             }
        
        List<Contact> contacts = [Select Id,AccountId from Contact where AccountId in :allIntelAccounts1];
        List<Id> contactIds = new List<Id>();
        for(Contact con : contacts ){
            contactIds.add(con.Id);
        }
        List<Id> userIds = new List<Id>();
        
        for(User user : [Select Id,Name,ContactId From User Where ContactId IN :contactIds]){
            userIds.add(user.Id);
        }
        String soqlQuery = 'SELECT id,RelatedId,Name,DeveloperName FROM Group where';
        
        List<Group> groups = new List<Group>();
        List<String> groupNames = new List<String>();
        String grpName = null;
        String soqlQuery1;
        Set<String> setDynamicGrpNames = new Set<String>();
        for(Id partnerAccId : partnerAccToIntelAccounts1.keySet()){
            grpName = CORE_MP_STR + partnerAccId;
            groupNames.add(grpName);      //grpName
            String grpNames = String.valueOf('%' + String.escapeSingleQuotes(grpname) + '%');
            setDynamicGrpNames.add(grpNames);
            
        }
        if(setDynamicGrpNames.size() >= 1){
            soqlQuery = soqlQuery + ' DeveloperName LIKE :setDynamicGrpNames';
        }
       
        
        if(groupNames != null && !groupNames.isEmpty()){
            
            groups = Database.query(String.escapeSingleQuotes(soqlQuery)); //soqlQuery
            //groups = Database.query(soqlQuery);
            Set<Id> groupIdsToBeCleaned = new Set<Id>();
            for(Group groupRec : groups){
                groupIdsToBeCleaned.add(groupRec.Id); 
            }
            
            if(groupIdsToBeCleaned != null && !groupIdsToBeCleaned.isEmpty()){
                List<GroupMember> toBeDeletedGrpMembers  = [Select Id,GroupId,UserOrGroupID from GroupMember 
                                                            where  GroupId IN :groupIdsToBeCleaned
                                                            and UserOrGroupID in :userIds];
                if(toBeDeletedGrpMembers != null && !toBeDeletedGrpMembers.isEmpty()){
                    Database.delete(toBeDeletedGrpMembers);
                }
            }
        }
    }
     /*******Creation of Lead Segment based public Groups*************/ 
    public static void createSegmentBasedPublicGroup(Map<Id,Set<Id>> partnerAccToPartnerUserMap, Map<Id,Id> pagIdToIntelAccIdMap,
                                                     List<Contact> allPartnerContacts){
                                                         
                                                         String ldrEntId = System.Label.Core_Lead_Development_Representative ;
                                                         Set<Id> userIds = new Set<Id>();
                                                         for(Set<Id> userId : partnerAccToPartnerUserMap.Values()){
                                                             userIds.addAll(userId);
                                                         }
                                                         
                                                         Set<Id> contactIds = new Set<Id>();
                                                         Map<Id, Id> partnerUserIdToContactIdToMap = new Map<Id, Id>();
                                                         for(User u:[Select Id,Name,ContactId  From User Where Id IN:userIds]) {
                                                             contactIds.add(u.ContactId);
                                                             partnerUserIdToContactIdToMap.put(u.Id, u.ContactId);
                                                         }
                                                         
                                                         Set<Id> allPartnercontactIds = new Set<Id>();
                                                         Set<Id> nonLDRIntelAccIds = new Set<Id>();
                                                         for(Contact contactRec : allPartnerContacts) {
                                                             allPartnercontactIds.add(contactRec.Id);
                                                             nonLDRIntelAccIds.add(contactRec.AccountId);
                                                         }
                                                        
                                                         Map<Id,Set<Id>> partnerAccToContactsMap = new Map<Id,Set<Id>>();
                                                         for(Id partnerAccId : partnerAccToPartnerUserMap.KeySet()){
                                                             Set<Id> partnerUserIds = partnerAccToPartnerUserMap.get(partnerAccId);
                                                             if(partnerUserIds != null){
                                                                 Set<Id> tempContactIds = new Set<Id>();
                                                                 for(Id partnerUserId : partnerUserIds){
                                                                     if(partnerUserIdToContactIdToMap.get(partnerUserId) != null)
                                                                         tempContactIds.add(partnerUserIdToContactIdToMap.get(partnerUserId));
                                                                 }
                                                                 partnerAccToContactsMap.put(partnerAccId, tempContactIds);
                                                             }
                                                         }
                                                         
                                                         //Getting all contact entitlements for LDR entitlement and for allpartnercontact
                                                         List<Core_Contact_Entitlement__c> conEntList = [SELECT Id,Core_Contact_Id__c,Core_Entitlement_Id__c,Core_Status__c,
                                                                                                         Core_Selected__c FROM Core_Contact_Entitlement__c
                                                                                                         WHERE Core_Status__c = :COMPLETE_STR AND Core_Selected__c = true 
                                                                                                         AND Core_Entitlement_Id__c = :ldrEntId 
                                                                                                         AND Core_Contact_Id__c IN :contactIds];
                                                       
                                                          Map<Id,Set<Id>> partnerAccToContactsWithLDRMap = new Map<Id,Set<Id>>();
                                                        
                                                         //Getting all the MDA accounts under the partner accounts found above
                                                         Map<Id, Set<Id>> partnerAccToIntelAccMap = new Map<Id, Set<Id>>();
                                                                                                                  
                                                         for(Core_Account_Group_Member__c allPartnerAccGroup :[SELECT Id, Core_Partner_Account_Id__c,Core_MDA_Ind__c, 
                                                                                                               Core_Intel_Account_Id__c FROM Core_Account_Group_Member__c 
                                                                                                               WHERE Core_Intel_Account_Id__c IN :nonLDRIntelAccIds AND Core_Inactive_Ind__c=false]){
                                                                                                                   if(partnerAccToIntelAccMap.get(allPartnerAccGroup.Core_Partner_Account_Id__c) != null  && allPartnerAccGroup.Core_Intel_Account_Id__c != null){
                                                                                                                       partnerAccToIntelAccMap.get(allPartnerAccGroup.Core_Partner_Account_Id__c).add(allPartnerAccGroup.Core_Intel_Account_Id__c);                                                
                                                                                                                   }else{
                                                                                                                       partnerAccToIntelAccMap.put(allPartnerAccGroup.Core_Partner_Account_Id__c, new Set<Id>());
                                                                                                                       partnerAccToIntelAccMap.get(allPartnerAccGroup.Core_Partner_Account_Id__c).add(allPartnerAccGroup.Core_Intel_Account_Id__c);
                                                                                                                   }                                                
                                                                                                               }
                                                                                                                   
                                                                                                                                                                        
                                                         
                                                         for(Id partnerAccId : partnerAccToContactsMap.keySet()){
                                                             Set<Id> partnerContactIds = partnerAccToContactsMap.get(partnerAccId);
                                                             if(partnerContactIds != null){
                                                                 
                                                                 Set<Id> tempContactsWithLDR = new Set<Id>();
                                                               
                                                                 for(Id partnerContactId : partnerContactIds){
                                                                     for(Core_Contact_Entitlement__c conEnt : conEntList){
                                                                         if(conEnt.Core_Contact_Id__c != null && conEnt.Core_Contact_Id__c == partnerContactId){
                                                                             tempContactsWithLDR.add(partnerContactId);
                                                                         }
                                                                     }
                                                                      }
                                                                 partnerAccToContactsWithLDRMap.put(partnerAccId, tempContactsWithLDR);
                                                                 
                                                             }
                                                         }
                                                         
                                                         Set<Id> allContactIdsWithLDR = new Set<Id>();
                                                         for(Id partnerAccId : partnerAccToContactsWithLDRMap.KeySet()){
                                                             Set<Id> contactsWithLDR = partnerAccToContactsWithLDRMap.get(partnerAccId);
                                                             if(contactsWithLDR != null){
                                                                 allContactIdsWithLDR.addAll(contactsWithLDR);
                                                             }
                                                         }
                                                     
                                                         Map<Id, String> contactIdToContactSegmentMap = new Map<Id, String>();
                                                         
                                                         if(!allContactIdsWithLDR.isEmpty()){
                                                             List<Contact> contactList = [Select Id, Core_IPA_Contact_Segment__c  from Contact where Id in :allContactIdsWithLDR];
                                                             
                                                             if(!contactList.isEmpty()){
                                                                 for(Contact contactRec : contactList){
                                                                     if(contactRec.Core_IPA_Contact_Segment__c != null){
                                                                         contactIdToContactSegmentMap.put(contactRec.Id, contactRec.Core_IPA_Contact_Segment__c);
                                                                     }
                                                                 }
                                                             }
                                                         }
                                                   
                                                         Map<Id, Set<String>> partnerAccIdToContactSegmentsMap = new Map<Id, Set<String>>();
                                                         
                                                         for(Id partnerAccId : partnerAccToContactsWithLDRMap.KeySet()){
                                                             Set<Id> contactsWithLDR = partnerAccToContactsWithLDRMap.get(partnerAccId);
                                                             Set<String> allSegmentsSet = new Set<String>();
                                                             if(contactsWithLDR != null){
                                                                 for(Id contactRecordId : contactsWithLDR){
                                                                     if(contactRecordId !=null && contactIdToContactSegmentMap.get(contactRecordId) != null){
                                                                         String tempSegment = contactIdToContactSegmentMap.get(contactRecordId);
                                                                         if(tempSegment != null){
                                                                             List<String> segmentList = tempSegment.split(';');
                                                                             if(segmentList != null && segmentList.size() > 0){
                                                                                 allSegmentsSet.addAll(segmentList);
                                                                             }
                                                                         }
                                                                     }
                                                                 }
                                                             }
                                                             if(!allSegmentsSet.isEmpty()){
                                                                 partnerAccIdToContactSegmentsMap.put(partnerAccId, allSegmentsSet);
                                                             }
                                                         }
                                                      
                                                         List<Group> segmentGroupToBeInserted = new List<Group>();
                                                         for(Id partnerAccId : partnerAccIdToContactSegmentsMap.KeySet()){
                                                             Set<String> contactsSegmentSet = partnerAccIdToContactSegmentsMap.get(partnerAccId);
                                                             if(contactsSegmentSet != null){
                                                                 for(String contactSegment : contactsSegmentSet){
                                                                     String groupName = CORE_MP_STR+partnerAccId+'_'+contactSegment;
                                                                     if(groupName != null && groupName.length() > 40){
                                                                         groupName = groupName.substring(0,40);
                                                                     }
                                                                     
                                                                    groupName = groupName.replaceAll( '\\s+', '_');
                                                                    Group groupRec= new Group(Name=groupName, DeveloperName=groupName, DoesIncludeBosses=false);
                                                                     segmentGroupToBeInserted.add(groupRec);
                                                                 }           
                                                             }
                                                         }
                                                      
                                                         if(segmentGroupToBeInserted != null && !segmentGroupToBeInserted.isEmpty()){
                                                             Database.SaveResult[] dbSaveResult = Database.insert(segmentGroupToBeInserted, false);
                                                           }
                             /*******Logics to add Partner Users to Lead Segment based Public Groups*************/ 
                                                           Set<Id> allldrContIds = new Set<Id>(); 
                                                         for(Set<Id> ldrContIds: partnerAccToContactsWithLDRMap.values()){
                                                             allldrContIds.addAll(ldrContIds);
                                                         } 
                                                         
                                                         List<User> ldrusrs = new List<User>();
                                                         List<Id> ldrusrIds = new List<Id>();
                                                         ldrusrs = [Select Id,Name,ContactId  From User Where ContactId IN:allldrContIds];
                                                         for(User user : ldrusrs){
                                                             ldrusrIds.add(user.Id);
                                                         }
                                                         
                                                         Set<Id> ldrconIds = new Set<Id>();
                                                         Map<Id, Id> ldrPartUserIdToLdrConIdMap = new Map<Id, Id>();
                                                         for(User u:[Select Id,Name,ContactId,AccountId  From User Where Id IN:ldrusrIds]) {
                                                             ldrconIds.add(u.ContactId);
                                                             ldrPartUserIdToLdrConIdMap.put(u.Id, u.ContactId );
                                                            
                                                         }
                                                         
                                                         Map<Id, Set<String>> ldrPartUsrToSegmentMap = new Map<Id, Set<String>>();
                                                         for(Id usId : ldrPartUserIdToLdrConIdMap.keySet()){
                                                             Id conIdWithLDrEnt = ldrPartUserIdToLdrConIdMap.get(usId);
                                                             Set<String> allSegmentsSet = new Set<String>();
                                                             if(conIdWithLDrEnt !=null && contactIdToContactSegmentMap.get(conIdWithLDrEnt) != null){
                                                                 String tempSegment = contactIdToContactSegmentMap.get(conIdWithLDrEnt);
                                                                 if(tempSegment != null){
                                                                     List<String> segmentList = tempSegment.split(';');
                                                                     if(segmentList != null && segmentList.size() > 0){
                                                                         allSegmentsSet.addAll(segmentList);
                                                                     }
                                                                 }
                                                             }
                                                             
                                                             if(!allSegmentsSet.isEmpty()){
                                                                 ldrPartUsrToSegmentMap.put(usId, allSegmentsSet);
                                                                 
                                                             }
                                                             
                                                         }
                                                         
                                                         
                                                          //Calling removeMembersFromLdrGroups method                                           
                                                         removeMembersFromLdrGroups(allPartnerContacts,allPartnercontactIds);
                                                         //Calling removePartUserFromPAGGroups method
                                                         removePartUserFromPAGGroups(allPartnerContacts,allPartnercontactIds);
                                                         //Calling removeMembersFromAdminPublicGroups method
                                                         removeMembersFromAdminPublicGroups(allPartnerContacts,allPartnercontactIds);
                                                         //Calling removeMembersFromEmpPublicGroups method
                                                         removeMembersFromEmpPublicGroups(allPartnerContacts, allPartnercontactIds);
                                                         Set<String> ldrSegmentValues = new Set<String>();
                                                         Map<String,Set<Id>> grpDevNameToUserIdMap = new Map<String,Set<Id>>();
                                                         List<String> grpDevNames = new List<String>();
                                                         for(Id partnerAccId : partnerAccIdToContactSegmentsMap.KeySet()){
                                                             for(Id ldrUser:ldrPartUsrToSegmentMap.keySet()){
                                                                 ldrSegmentValues = ldrPartUsrToSegmentMap.get(ldrUser);
                                                                 for(String segment:ldrSegmentValues){
                                                                     String groupName = CORE_MP_STR+partnerAccId+'_'+segment;
                                                                     if(groupName != null && groupName.length() > 40){
                                                                         groupName = groupName.substring(0,40);
                                                                     }
                                                                     
                                                                     groupName = groupName.replaceAll( '\\s+', '_');
                                                                     grpDevNames.add(groupName);
                                                                     if(partnerAccToPartnerUserMap.get(partnerAccId).Contains(ldrUser)){
                                                                     if(grpDevNameToUserIdMap.get(groupName) !=null){
                                                                         grpDevNameToUserIdMap.get(groupName).add(ldrUser);
                                                                     }else{
                                                                         grpDevNameToUserIdMap.put(groupName,new Set<Id>{ldrUser});
                                                                     }
                                                                    }
                                                                     
                                                                 }
                                                             }
                                                         }
                                                         
                                                         Map<String,Id> grpDevNameToGrpIdMap = new Map<String,Id>();
                                                         Map<Id,Set<Id>> grpIdToGrpUserMap = new Map<Id,Set<Id>>();
                                                         for(Group grp:[Select Id, DeveloperName from Group where DeveloperName in:grpDevNames]){
                                                             grpDevNameToGrpIdMap.put(grp.DeveloperName,grp.Id);
                                                         }
                                                         
                                                         for(String grpName:grpDevNameToGrpIdMap.keySet()){
                                                             Id grpId = grpDevNameToGrpIdMap.get(grpName);
                                                             Set<Id> users = grpDevNameToUserIdMap.get(grpName);
                                                             grpIdToGrpUserMap.put(grpId,users);
                                                         }
                                                         
                                                          List<GroupMember> groupMemberList = new List<GroupMember>();
                                                         for(Id grpId:grpIdToGrpUserMap.keySet()){
                                                             Set<Id> userToBeAdded = grpIdToGrpUserMap.get(grpId);
                                                             if(userToBeAdded!=null){
                                                                 for(Id usr:userToBeAdded){
                                                                     GroupMember gm = new GroupMember();
                                                                     gm.GroupId = grpId;
                                                                     gm.UserOrGroupId = usr;
                                                                     groupMemberList.add(gm);
                                                                 }
                                                             }
                                                           }
                                                         
                                                           if(groupMemberList!=null && !groupMemberList.isEmpty()){
                                                             Database.insert(groupMemberList);
                                                         }
                                                      
                                                       }
     /******* Removal of members from ldr groups*************/    
    private static void removeMembersFromLdrGroups(List<Contact> allPartnerContacts,Set<Id> allPartnercontactIds){
        String ldrEntId = System.Label.Core_Lead_Development_Representative ;
        Set<Id> ldrContactId = new Set<Id>();
        Set<Id> nonldrContactId = new Set<Id>();
       
        List<Core_Contact_Entitlement__c> conEntList = [SELECT Id,Core_Contact_Id__c,Core_Entitlement_Id__c,Core_Status__c,
                                                        Core_Selected__c FROM Core_Contact_Entitlement__c
                                                        WHERE Core_Status__c = :COMPLETE_STR  
                                                        AND Core_Entitlement_Id__c = :ldrEntId 
                                                        AND Core_Contact_Id__c IN :allPartnercontactIds];
        for(Core_Contact_Entitlement__c conEntRec:conEntList){
            if(conEntRec.Core_Selected__c==true){
                ldrContactId.add(conEntRec.Core_Contact_Id__c);
                
            }else if(conEntRec.Core_Selected__c==false){
                nonldrContactId.add(conEntRec.Core_Contact_Id__c);
            }
        }
        
        
        Map<Id,Set<Id>> accIdToLdrContactIdMap = new Map<Id,Set<Id>>();
        for(Contact conRec:allPartnerContacts){
            
            for(Id nonLdrConId:nonldrContactId){
                
                if(conRec.Id==nonLdrConId){
                    
                    if(accIdToLdrContactIdMap.get(conRec.AccountId) != null){
                        accIdToLdrContactIdMap.get(conRec.AccountId).add(conRec.Id);                                             
                        
                    }else{
                        accIdToLdrContactIdMap.put(conRec.AccountId, 
                                                   new Set<Id>{conRec.Id});
                        
                    } 
                }
            }
        }
        Map<Id,Set<Id>> partnerAccToIntelAccMap = new Map<Id,Set<Id>>();
        for(Core_Account_Group_Member__c allPartnerAccGroup :[SELECT Id, Core_Partner_Account_Id__c,Core_MDA_Ind__c, 
                                                              Core_Intel_Account_Id__c FROM Core_Account_Group_Member__c 
                                                              WHERE Core_Intel_Account_Id__c IN :accIdToLdrContactIdMap.keySet() AND Core_Inactive_Ind__c=false]){
                                                                                                                       
            if(partnerAccToIntelAccMap.get(allPartnerAccGroup.Core_Partner_Account_Id__c) != null  && allPartnerAccGroup.Core_Intel_Account_Id__c != null){
                partnerAccToIntelAccMap.get(allPartnerAccGroup.Core_Partner_Account_Id__c).add(allPartnerAccGroup.Core_Intel_Account_Id__c);                                                
            }else{
                partnerAccToIntelAccMap.put(allPartnerAccGroup.Core_Partner_Account_Id__c, new Set<Id>{allPartnerAccGroup.Core_Intel_Account_Id__c});
                                                                      
            }                                                
        }
        Map<Id,Set<Id>> partnerAccIdToLdrContactIdsMap = new Map<Id,Set<Id>>();
        for(Id partnerAccId:partnerAccToIntelAccMap.keySet()){
            Set<Id> intelAccIds = partnerAccToIntelAccMap.get(partnerAccId);
            for(Id accId:intelAccIds){
                for(Id ldrAcc:accIdToLdrContactIdMap.keySet()){
                    if(accId == ldrAcc){
                        if(partnerAccIdToLdrContactIdsMap.get(partnerAccId) != null  && partnerAccId!= null){
                            partnerAccIdToLdrContactIdsMap.get(partnerAccId).addAll(accIdToLdrContactIdMap.get(ldrAcc));                                                
                        }else{
                            partnerAccIdToLdrContactIdsMap.put(partnerAccId, accIdToLdrContactIdMap.get(ldrAcc));
                            
                        }
                    }
                }
                
            }
        }
        Set<Id> nonldrUserIds = new Set<Id>();
        for(User u:[SELECT Id,ContactId FROM User WHERE ContactId IN:nonldrContactId]){
            nonldrUserIds.add(u.Id);
        }
        Map<Id,String> partnerAccIdToSegmentGroupMap = new Map<Id,String>();
        List<String> segmentGrpNames = new List<String>();
        List<Group> allSegmentGrpNames = new List<Group>();
        Set<Id> grpIds = new Set<Id> ();
        Set<String> pmpGroups = new Set<String>();
        
        String soqlQuery = 'SELECT Id,Name,DeveloperName FROM Group WHERE';
        for(Id partnerAccId:partnerAccIdToLdrContactIdsMap.keySet()){
            String segmentGrpName = CORE_MP_STR + partnerAccId + '_%';
            segmentGrpNames.add(segmentGrpName);
            partnerAccIdToSegmentGroupMap.put(partnerAccId,segmentGrpName);
        }
        
        soqlQuery = soqlQuery + ' DeveloperName LIKE :segmentGrpNames';
        
        if(segmentGrpNames!=null && !segmentGrpNames.isEmpty()){
                 allSegmentGrpNames= Database.query(soqlQuery);
                
            }
        
        for(Group grp:allSegmentGrpNames){
            grpIds.add(grp.Id);
        }
        List<GroupMember> listGm  = [Select Id,GroupId,UserOrGroupID FROM GroupMember WHERE GroupId IN :grpIds AND UserOrGroupID in :nonldrUserIds];
                //Delete partners from the Segments
                 if(!listGm.isEmpty()){
                      Database.delete(listGm, false);
                 }
        /******************** Logic to delete users when segment is being deleted******************/
       
        
        Map<Id,Id> intelAccountIdPartnerAccountIdMap = new Map<Id,Id>();
        for(Core_Account_Group_Member__c pag : [SELECT Id, Core_Partner_Account_Id__c, Core_Intel_Account_Id__c, Core_Partner_Account_Id__r.Core_PMP_Membership_Change_Ind__c
                                                                     FROM Core_Account_Group_Member__c WHERE Core_Partner_Account_Id__r.Core_PMP_Membership_Change_Ind__c = true AND Core_Inactive_Ind__c=false]){
                intelAccountIdPartnerAccountIdMap.put(pag.Core_Intel_Account_Id__c, pag.Core_Partner_Account_Id__c);
            }
        
        Map<Id, Set<String>> contactIdSegmentSetMap = new Map<Id, Set<String>>();
        //Fetch all the Contacts  from the Accounts fetched above and which has the LDR set to true - Create the contactIdSegmentSetMap
            for(Contact contactRecord : [SELECT Id, AccountId, Core_IPA_Contact_Segment__c FROM Contact WHERE AccountId IN :intelAccountIdPartnerAccountIdMap.keySet() AND Id IN :ldrContactId]){
                //Create the contactIdSegmentSetMap
                Set<String> groupNameSet = new Set<String>();
                if(contactRecord.Core_IPA_Contact_Segment__c!=null ){
                    
                
                    for(String strContactSegment: contactRecord.Core_IPA_Contact_Segment__c.split(';')){
                                    //Append the PMP + account Id with the Contact Segment to form the group
                             String groupName = CORE_MP_STR + intelAccountIdPartnerAccountIdMap.get(contactRecord.AccountId) + '_' + strContactSegment;
                             if(groupName != null && groupName.length() > 40){
                                         groupName = groupName.substring(0,40);
                                         groupNameSet.add(groupName);
                                     }
                                   
                    }
                }
                
                groupNameSet.add('PMP_' + intelAccountIdPartnerAccountIdMap.get(contactRecord.AccountId));//Main Group
                if(groupNameSet.size() > 0){
                                contactIdSegmentSetMap.put(contactRecord.Id, groupNameSet);
                    }
            }
        
        Set<Id> allContactId = new Set<Id>();
        //Fetch all the Users associated to the Contacts fetched above
        Map<Id, Id> userIdContactIdMap = new Map<Id, Id>();
        for(User userRecord : [SELECT Id, ContactId  FROM User WHERE ContactId IN :contactIdSegmentSetMap.keySet()]){//contactIdSegmentSetMap.keySet() //allContactId
                userIdContactIdMap.put(userRecord.Id, userRecord.ContactId);
            
                }
           
        List<GroupMember> grpMems = new List<GroupMember>();

        //Fetch all the Groups where the Users fetched above is a part of taking into factor the Contact Segment
        for(GroupMember gm : [SELECT Id, GroupId, Group.DeveloperName, UserOrGroupId FROM GroupMember WHERE UserOrGroupId IN :userIdContactIdMap.keySet() AND 
                                                                                                                        Group.DeveloperName LIKE 'PMP_%']){//S1, S2, S3, Main
                        String contactId = userIdContactIdMap.get(gm.UserOrGroupId);//Fetching the Contact
                        Set<String> groupNameStringSet = contactIdSegmentSetMap.get(contactId);//Fetching the Group Names from the Contact                                                       
                        if(!groupNameStringSet.contains(gm.Group.DeveloperName)){
                                       // groupMemberIdSet.add(gm.Id);
                                       grpMems.add(gm);
                        }
                        
                }
        
        if(grpMems.size() > 0){
                        delete grpMems;
        }
                
    }
    
    /******* Removal of Partner User from PAG groups on removal of MP Contact Entitlements from Contact*************/    
    private static void removePartUserFromPAGGroups(List<Contact> allPartnerContacts,Set<Id> allPartnercontactIds){
        String Core_Entitlement_Id_Label = System.Label.PMP_External_Entitlement_Ids;
         List<String> lstEntitlementIds = Core_Entitlement_Id_Label.split(';');
         Set<Id> contactIdWithEnt = new Set<Id>();
         Set<Id> contactIdWithoutEnt = new Set<Id>();
       
        List<Core_Contact_Entitlement__c> conEntList = [SELECT Id,Core_Contact_Id__c,Core_Entitlement_Id__c,Core_Status__c,
                                                        Core_Selected__c FROM Core_Contact_Entitlement__c
                                                        WHERE Core_Status__c = :COMPLETE_STR  
                                                        AND Core_Entitlement_Id__c IN :lstEntitlementIds 
                                                        AND Core_Contact_Id__c IN :allPartnercontactIds];
        for(Core_Contact_Entitlement__c conEntRec:conEntList){
            if(conEntRec.Core_Selected__c==true){
                contactIdWithEnt.add(conEntRec.Core_Contact_Id__c);
                
            }else if(conEntRec.Core_Selected__c==false){
                contactIdWithoutEnt.add(conEntRec.Core_Contact_Id__c);
            }
        }
        
        Map<Id,Set<Id>> accIdTocontactIdWithEntMap = new Map<Id,Set<Id>>();
        for(Contact conRec:allPartnerContacts){
              for(Id ConIdWithoutEnt:contactIdWithoutEnt){ 
                  if(conRec.Id==ConIdWithoutEnt){ 
                    if(accIdTocontactIdWithEntMap.get(conRec.AccountId) != null){
                     accIdTocontactIdWithEntMap.get(conRec.AccountId).add(conRec.Id);                                             
                        
                    }else{
                        accIdTocontactIdWithEntMap.put(conRec.AccountId, 
                                                   new Set<Id>{conRec.Id});
                        
                    } 
                }
            }
        }
          
        Map<Id,Set<Id>> partnerAccToIntelAccMap = new Map<Id,Set<Id>>();
        for(Core_Account_Group_Member__c allPartnerAccGroup :[SELECT Id, Core_Partner_Account_Id__c,Core_MDA_Ind__c, 
                                                              Core_Intel_Account_Id__c FROM Core_Account_Group_Member__c 
                                                              WHERE Core_Intel_Account_Id__c IN :accIdTocontactIdWithEntMap.keySet() AND Core_Inactive_Ind__c=false]){
                                                                                                                       
      if(partnerAccToIntelAccMap.get(allPartnerAccGroup.Core_Partner_Account_Id__c) != null  && allPartnerAccGroup.Core_Intel_Account_Id__c != null){
        partnerAccToIntelAccMap.get(allPartnerAccGroup.Core_Partner_Account_Id__c).add(allPartnerAccGroup.Core_Intel_Account_Id__c);                                                
      }else{
        partnerAccToIntelAccMap.put(allPartnerAccGroup.Core_Partner_Account_Id__c, new Set<Id>{allPartnerAccGroup.Core_Intel_Account_Id__c});
                                                                      
      }                                                
    }
      
        Map<Id,Set<Id>> partnerAccIdToConIdWithEntMap = new Map<Id,Set<Id>>();
        for(Id partnerAccId:partnerAccToIntelAccMap.keySet()){
            Set<Id> intelAccIds = partnerAccToIntelAccMap.get(partnerAccId);
            for(Id accId:intelAccIds){
                for(Id entAcc:accIdTocontactIdWithEntMap.keySet()){
                    if(accId == entAcc){
                        if(partnerAccIdToConIdWithEntMap.get(partnerAccId) != null  && partnerAccId!= null){
                            partnerAccIdToConIdWithEntMap.get(partnerAccId).addAll(accIdTocontactIdWithEntMap.get(entAcc));                                                
                        }else{
                            partnerAccIdToConIdWithEntMap.put(partnerAccId, accIdTocontactIdWithEntMap.get(entAcc));
                            
                        }
                    }
                }
                
            }
        }  
           
          Set<Id> nonEntUserIds = new Set<Id>();
        for(User u:[SELECT Id,ContactId FROM User WHERE ContactId IN:contactIdWithoutEnt]){
            nonEntUserIds.add(u.Id);
        }
        Map<Id,String> partnerAccIdToGroupMap = new Map<Id,String>();
        List<String> publicGrpNames = new List<String>();
        Set<Id> grpIds = new Set<Id> ();
       
        for(Id partnerAccId:partnerAccIdToConIdWithEntMap.keySet()){
            String publicGrpName = CORE_MP_STR + partnerAccId;
            publicGrpNames.add(publicGrpName);
            partnerAccIdToGroupMap.put(partnerAccId,publicGrpName);
        }
        
            for(Group grp:[SELECT Id, DeveloperName FROM Group where DeveloperName IN: publicGrpNames]){
            grpIds.add(grp.Id);
        }
        List<GroupMember> listGm  = [Select Id,GroupId,UserOrGroupID FROM GroupMember WHERE GroupId IN :grpIds AND UserOrGroupID in :nonEntUserIds];                                             
                     if(!listGm.isEmpty()){
                      Database.delete(listGm, false);
                 }
    }
     /*******Logics to Sharing Partner Account with Partner Account Group*************/ 
    private static void sharePartAccWithPartAcGrp( Map<Id,Id> partnerAccIdToGroupId){
        List<AccountShare> sharePartAccountWithAccGroups  = new List<AccountShare>();
        for(Id partAccId : partnerAccIdToGroupId.keySet()){
            if(partnerAccIdToGroupId.get(partAccId) != null){
                AccountShare sharePartAccountWithAccGroup = new AccountShare();
                sharePartAccountWithAccGroup.AccountId = partAccId;
                
                sharePartAccountWithAccGroup.UserOrGroupId = partnerAccIdToGroupId.get(partAccId);
                sharePartAccountWithAccGroup.AccountAccessLevel = 'read';
                sharePartAccountWithAccGroup.OpportunityAccessLevel = 'read';
                sharePartAccountWithAccGroups.add(sharePartAccountWithAccGroup);
            }
        } 
        /******* Calling enqueueJob method *************/ 
        System.enqueueJob(new PMPBatchQueueableClass(sharePartAccountWithAccGroups));
    } 
     /******* Implementation of Queueable Interface to PMPBatchQueueableClass*************/ 
    public class PMPBatchQueueableClass implements Queueable {
        
        List<AccountShare> records;
        
        public PMPBatchQueueableClass(List<AccountShare> records) {
            this.records = records;
        }
        
        public void execute(QueueableContext context) {
            try{
                Database.SaveResult[] srList = Database.insert(records, false);
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                    }
                    
                }
            }catch(Exception terrException){
                System.debug('exception getMessage = '+ terrException.getMessage());
            }
        }
    }
     
    /***Method to create Public Group if there is at least one Partner Admin/Employee MP Entitlement is associated with the associated contact of the intel Account**/
    public static void createPartAdminEntBasedPublicGroup(Map<Id,Set<Id>> partnerAccToPartnerUserMap,List<Contact> allPartnerContacts){
         System.debug('partnerAccToPartnerUserMap 764='+partnerAccToPartnerUserMap);
         System.debug('allPartnerContacts 764='+allPartnerContacts);
         String empEntId = System.Label.Core_Employee ;
         String employee = System.Label.PMP_Group_Name_Suffix_Employee;
         String partAdminEntId = System.Label.Core_Partner_Admin ;
         String lead = System.Label.PMP_Group_Name_Suffix_Leads;
         
         
         Set<Id> userIds = new Set<Id>();
         for(Set<Id> userId : partnerAccToPartnerUserMap.Values()){
             userIds.addAll(userId);
         }
         /** Map of Partner User Ids with Contact Ids ****/
         Set<Id> setContactIds = new Set<Id>();
         Map<Id, Id> mapPartnerUserIdToContactId = new Map<Id, Id>();
         for(User u:[Select Id,Name,ContactId  From User Where Id IN:userIds]) {
             setContactIds.add(u.ContactId);
             mapPartnerUserIdToContactId.put(u.Id, u.ContactId);
         }
         
        /** Map of Partner Account Id with Contact Ids ***/
         Map<Id,Set<Id>> mapPartnerAccToContacts = new Map<Id,Set<Id>>();
         for(Id partnerAccId : partnerAccToPartnerUserMap.KeySet()){
             Set<Id> partnerUserIds = partnerAccToPartnerUserMap.get(partnerAccId);
             if(partnerUserIds != null){
                 Set<Id> tempContactIds = new Set<Id>();
                 for(Id partnerUserId : partnerUserIds){
                     if(mapPartnerUserIdToContactId.get(partnerUserId) != null)
                         tempContactIds.add(mapPartnerUserIdToContactId.get(partnerUserId));
                 }
                 mapPartnerAccToContacts.put(partnerAccId, tempContactIds);
             }
         }
         System.debug('mapPartnerAccToContacts 797='+mapPartnerAccToContacts);
    /****Getting all contact entitlements for Partner Admin/Employee entitlement and for allPartnercontact ***/
         List<Core_Contact_Entitlement__c> conEntList = [SELECT Id,Core_Contact_Id__c,Core_Entitlement_Id__c,Core_Status__c,
                                                            Core_Selected__c FROM Core_Contact_Entitlement__c
                                                            WHERE Core_Status__c = :COMPLETE_STR AND Core_Selected__c = TRUE 
                                                            AND (Core_Entitlement_Id__c = :partAdminEntId OR Core_Entitlement_Id__c = :empEntId)
                                                            AND Core_Contact_Id__c IN :setContactIds];
          
          /**** Map of Partner Account Id with Partner Admin Entitlement associated Contact Ids ****/
          Map<Id,Set<Id>> mapPartnerAccToContactsWithPartAdmin = new Map<Id,Set<Id>>();
          
          /**** Map of Partner Account Id with Employee Entitlement associated Contact Ids ****/
          Map<Id,Set<Id>> mapPartnerAccToContactsWithEmployee = new Map<Id,Set<Id>>();
                                                                                                            
         
         for(Id partnerAccId : mapPartnerAccToContacts.keySet()){
             Set<Id> partnerContactIds = mapPartnerAccToContacts.get(partnerAccId);
             if(partnerContactIds != null){
                 Set<Id> setContactsWithPartAdmin = new Set<Id>();
                 Set<Id> setContactsWithEmployee = new Set<Id>();
                 for(Id partnerContactId : partnerContactIds){
                     for(Core_Contact_Entitlement__c conEnt : conEntList){
                     
                         if(conEnt.Core_Contact_Id__c != null && conEnt.Core_Contact_Id__c == partnerContactId && 
                         conEnt.Core_Entitlement_Id__c == partAdminEntId){
                             setContactsWithPartAdmin.add(partnerContactId);
                         }
                         if(conEnt.Core_Contact_Id__c != null && conEnt.Core_Contact_Id__c == partnerContactId && conEnt.Core_Entitlement_Id__c == empEntId){
                             setContactsWithEmployee.add(partnerContactId);
                         }
                     }
                      }
                 System.debug('setContactsWithPartAdmin829'+setContactsWithPartAdmin);
                 System.debug('setContactsWithEmployee 829'+setContactsWithEmployee);
             mapPartnerAccToContactsWithPartAdmin.put(partnerAccId, setContactsWithPartAdmin);
             mapPartnerAccToContactsWithEmployee.put(partnerAccId, setContactsWithEmployee);
             }
         }
         
         
         List<Group> groupToBeInserted = new List<Group>();
         /*** Creation of Public Groups based on Partner Admin *****/ 
         for(Id partnerAccId : mapPartnerAccToContactsWithPartAdmin.KeySet()){
               if(!mapPartnerAccToContactsWithPartAdmin.isEmpty() && mapPartnerAccToContactsWithPartAdmin.get(partnerAccId).size() > 0){
                   String groupName = CORE_MP_STR+partnerAccId+'_'+lead;
                Group groupRec= new Group(Name=groupName, DeveloperName=groupName, DoesIncludeBosses=false);
                     groupToBeInserted.add(groupRec);
                 }
         }
            /*** Creation of Public Groups based on Employee MP Entitlement ****/
        for(Id partnerAccId : mapPartnerAccToContactsWithEmployee.KeySet()){
            	if(!mapPartnerAccToContactsWithEmployee.isEmpty() && mapPartnerAccToContactsWithEmployee.get(partnerAccId).size() > 0){
                   String groupName = CORE_MP_STR+partnerAccId+'_'+employee;
                Group groupRec= new Group(Name=groupName, DeveloperName=groupName, DoesIncludeBosses=false);
                     groupToBeInserted.add(groupRec);
                 }
        	}
              /* if(!mapPartnerAccToContactsWithEmployee.isEmpty() && mapPartnerAccToContactsWithEmployee.get(partnerAccId).size() > 0){
                   String groupName = CORE_MP_STR+partnerAccId+'_'+employee;
                Group groupRec= new Group(Name=groupName, DeveloperName=groupName, DoesIncludeBosses=false);
                     groupToBeInserted.add(groupRec);
                 }*/               
         //}
         /**** List of Public Groups to be inserted *****/
                 if(groupToBeInserted != null && !groupToBeInserted.isEmpty()){
             Database.SaveResult[] dbSaveResult = Database.insert(groupToBeInserted, false);
           }
         /*******Logics to add Partner Users to Partner Admin/Employee Entitlement based Public Groups*************/ 
         
         Set<Id> setAdminContIds = new Set<Id>(); 
         for(Set<Id> adminContIds: mapPartnerAccToContactsWithPartAdmin.values()){
            
             setAdminContIds.addAll(adminContIds);
         }
         
         Set<Id> setEmpContIds = new Set<Id>(); 
         for(Set<Id> empContIds: mapPartnerAccToContactsWithEmployee.values()){
             setEmpContIds.addAll(empContIds);
         }
         
         List<User> lstAdminUsrs = new List<User>();
         List<Id> lstAdminUsrIds = new List<Id>();
         lstAdminUsrs = [Select Id,Name,ContactId  From User Where ContactId IN:setAdminContIds];
         for(User user : lstAdminUsrs){
             lstAdminUsrIds.add(user.Id);
         }
         List<User> lstEmpUsrs = new List<User>();
         List<Id> lstEmpUsrIds = new List<Id>();
         lstEmpUsrs = [Select Id,Name,ContactId  From User Where ContactId IN:setEmpContIds];
         for(User user : lstEmpUsrs){
             lstEmpUsrIds.add(user.Id);
         }
         
         /**** Map of Admin User Id with Contact Id *****/
         Map<Id, Id> mapAdminPartUserIdToAdminConId = new Map<Id, Id>();
         for(User u:[Select Id,Name,ContactId,AccountId  From User Where Id IN:lstAdminUsrIds]) {
             mapAdminPartUserIdToAdminConId.put(u.Id, u.ContactId );
            
         }
         
         /**** Map of Employee User Id with Contact Id *****/
         Map<Id, Id> mapEmpPartUserIdToEmpConId = new Map<Id, Id>();
         for(User u:[Select Id,Name,ContactId,AccountId  From User Where Id IN:lstEmpUsrIds]) {
             mapEmpPartUserIdToEmpConId.put(u.Id, u.ContactId );
            
         }
         
         Map<String,Set<Id>> mapGrpDevNameToUserId = new Map<String,Set<Id>>();
         List<String> lstGrpDevNames = new List<String>();
         /*** Map of Public Group's developer name to Admin User Id ****/
         for(Id partnerAccId : mapPartnerAccToContactsWithPartAdmin.KeySet()){
         for(Id adminUser:mapAdminPartUserIdToAdminConId.keySet()){
             
          String groupName = CORE_MP_STR+partnerAccId+'_'+lead;
                     lstGrpDevNames.add(groupName);
              if(partnerAccToPartnerUserMap.get(partnerAccId).Contains(adminUser)){
                     if(mapGrpDevNameToUserId.get(groupName) !=null){
                         mapGrpDevNameToUserId.get(groupName).add(adminUser);
                     }else{
                         mapGrpDevNameToUserId.put(groupName,new Set<Id>{adminUser});
                     }
                  }
                }
             } 
             System.debug('mapGrpDevNameToUserId 921 ='+mapGrpDevNameToUserId);
           /*** Map of Public Group's developer name to Employee User Id ****/
         for(Id partnerAccId : mapPartnerAccToContactsWithEmployee.KeySet()){
         for(Id empUserId:mapEmpPartUserIdToEmpConId.keySet()){
             
          String groupName = CORE_MP_STR+partnerAccId+'_'+employee;
                     lstGrpDevNames.add(groupName);
              if(partnerAccToPartnerUserMap.get(partnerAccId).Contains(empUserId)){
                     if(mapGrpDevNameToUserId.get(groupName) !=null){
                         mapGrpDevNameToUserId.get(groupName).add(empUserId);
                     }else{
                         mapGrpDevNameToUserId.put(groupName,new Set<Id>{empUserId});
                     }
                  }
                }
             }
             System.debug('mapGrpDevNameToUserId 937 ='+mapGrpDevNameToUserId);
         /*** Map of Public Group's developer name to group Id ****/
         Map<String,Id> mapGrpDevNameToGrpId = new Map<String,Id>();
         Map<Id,Set<Id>> mapGrpIdToGrpUser = new Map<Id,Set<Id>>();
         for(Group grp:[Select Id, DeveloperName from Group where DeveloperName in:lstGrpDevNames]){
             mapGrpDevNameToGrpId.put(grp.DeveloperName,grp.Id);
         }
        System.debug('mapGrpDevNameToGrpId 944='+mapGrpDevNameToGrpId);
         for(String grpName:mapGrpDevNameToGrpId.keySet()){
             Id grpId = mapGrpDevNameToGrpId.get(grpName);
             Set<Id> users = mapGrpDevNameToUserId.get(grpName);
             mapGrpIdToGrpUser.put(grpId,users);
         }
         /*** Creation of Group Members to be inserted ****/
          List<GroupMember> lstGroupMemberList = new List<GroupMember>();
          for(Id grpId:mapGrpIdToGrpUser.keySet()){
             Set<Id> userToBeAdded = mapGrpIdToGrpUser.get(grpId);
             if(userToBeAdded!=null){
                 for(Id usr:userToBeAdded){
                     GroupMember gm = new GroupMember();
                     gm.GroupId = grpId;
                     gm.UserOrGroupId = usr;
                     lstGroupMemberList.add(gm);
                 }
             }
           }
        System.debug('lstGroupMemberList 963='+lstGroupMemberList);
           if(lstGroupMemberList!=null && !lstGroupMemberList.isEmpty()){
             Database.insert(lstGroupMemberList);
         }
      
       }
     
     
    /******* Removal of Partner User from PAG groups on removal of Partner Admin MP Entitlements from Contact*************/
    private static void removeMembersFromAdminPublicGroups(List<Contact> allPartnerContacts,Set<Id> allPartnercontactIds){
         String partAdminEntId = System.Label.Core_Partner_Admin ;
         String lead = System.Label.PMP_Group_Name_Suffix_Leads;
         Set<Id> adminContactId = new Set<Id>();
         Set<Id> nonAdminContactId = new Set<Id>();
       
        List<Core_Contact_Entitlement__c> conEntList = [SELECT Id,Core_Contact_Id__c,Core_Entitlement_Id__c,Core_Status__c,
                                                        Core_Selected__c FROM Core_Contact_Entitlement__c
                                                        WHERE Core_Status__c = :COMPLETE_STR  
                                                        AND Core_Entitlement_Id__c = :partAdminEntId 
                                                        AND Core_Contact_Id__c IN :allPartnercontactIds];
        for(Core_Contact_Entitlement__c conEntRec:conEntList){
            if(conEntRec.Core_Selected__c==true){
                adminContactId.add(conEntRec.Core_Contact_Id__c);
                
            }else if(conEntRec.Core_Selected__c==false){
                nonAdminContactId.add(conEntRec.Core_Contact_Id__c);
            }
        }
        
        Map<Id,Set<Id>> accIdToAdminContactIdMap = new Map<Id,Set<Id>>();
        for(Contact conRec:allPartnerContacts){
            
            for(Id nonAdminConId:nonAdminContactId){
                
                if(conRec.Id==nonAdminConId){
                    
                    if(accIdToAdminContactIdMap.get(conRec.AccountId) != null){
                        accIdToAdminContactIdMap.get(conRec.AccountId).add(conRec.Id);                                             
                        
                    }else{
                        accIdToAdminContactIdMap.put(conRec.AccountId, 
                                                   new Set<Id>{conRec.Id});
                        
                    } 
                }
            }
        }
        Map<Id,Set<Id>> partnerAccToIntelAccMap = new Map<Id,Set<Id>>();
        for(Core_Account_Group_Member__c allPartnerAccGroup :[SELECT Id, Core_Partner_Account_Id__c,Core_MDA_Ind__c, 
                                                              Core_Intel_Account_Id__c FROM Core_Account_Group_Member__c 
                                                              WHERE Core_Intel_Account_Id__c IN :accIdToAdminContactIdMap.keySet() AND Core_Inactive_Ind__c=false]){
                                                                                                                       
            if(partnerAccToIntelAccMap.get(allPartnerAccGroup.Core_Partner_Account_Id__c) != null  && allPartnerAccGroup.Core_Intel_Account_Id__c != null){
                partnerAccToIntelAccMap.get(allPartnerAccGroup.Core_Partner_Account_Id__c).add(allPartnerAccGroup.Core_Intel_Account_Id__c);                                                
            }else{
                partnerAccToIntelAccMap.put(allPartnerAccGroup.Core_Partner_Account_Id__c, new Set<Id>{allPartnerAccGroup.Core_Intel_Account_Id__c});
                                                                      
            }                                                
        }
        Map<Id,Set<Id>> partnerAccIdToAdminContactIdsMap = new Map<Id,Set<Id>>();
        for(Id partnerAccId:partnerAccToIntelAccMap.keySet()){
            Set<Id> intelAccIds = partnerAccToIntelAccMap.get(partnerAccId);
            for(Id accId:intelAccIds){
                for(Id ldrAcc:accIdToAdminContactIdMap.keySet()){
                    if(accId == ldrAcc){
                        if(partnerAccIdToAdminContactIdsMap.get(partnerAccId) != null  && partnerAccId!= null){
                            partnerAccIdToAdminContactIdsMap.get(partnerAccId).addAll(accIdToAdminContactIdMap.get(ldrAcc));                                                
                        }else{
                            partnerAccIdToAdminContactIdsMap.put(partnerAccId,accIdToAdminContactIdMap.get(ldrAcc));
                            
                        }
                    }
                }
                
            }
        }
        Set<Id> nonAdminUserIds = new Set<Id>();
        for(User u:[SELECT Id,ContactId FROM User WHERE ContactId IN:nonAdminContactId]){
            nonAdminUserIds.add(u.Id);
        }
        Map<Id,String> partnerAccIdToGroupMap = new Map<Id,String>();
        List<String> GrpNames = new List<String>();
        Set<Id> grpIds = new Set<Id> ();
        for(Id partnerAccId:partnerAccIdToAdminContactIdsMap.keySet()){
        String GrpName = CORE_MP_STR + partnerAccId + '_' + lead ;
        GrpNames.add(GrpName);
        partnerAccIdToGroupMap.put(partnerAccId,GrpName);
        }
        
        for(Group grp:[SELECT Id, DeveloperName FROM Group where DeveloperName IN: GrpNames]){
            grpIds.add(grp.Id);
        }
        List<GroupMember> listGm  = [Select Id,GroupId,UserOrGroupID FROM GroupMember WHERE GroupId IN :grpIds AND UserOrGroupID in :nonAdminUserIds];                                             
                     if(!listGm.isEmpty()){
                      Database.delete(listGm, false);
                 }
    } 
    
    /******* Removal of Partner User from PAG groups on removal of Employee MP Entitlements from Contact*************/
    private static void removeMembersFromEmpPublicGroups(List<Contact> allPartnerContacts,Set<Id> allPartnercontactIds){
		 String empEntId = System.Label.Core_Employee ;
         String employee = System.Label.PMP_Group_Name_Suffix_Employee;
         Set<Id> empContactId = new Set<Id>();
         Set<Id> nonEmpContactId = new Set<Id>();
       
        List<Core_Contact_Entitlement__c> conEntList = [SELECT Id,Core_Contact_Id__c,Core_Entitlement_Id__c,Core_Status__c,
                                                        Core_Selected__c FROM Core_Contact_Entitlement__c
                                                        WHERE Core_Status__c = :COMPLETE_STR  
                                                        AND Core_Entitlement_Id__c = :empEntId 
                                                        AND Core_Contact_Id__c IN :allPartnercontactIds];
        for(Core_Contact_Entitlement__c conEntRec:conEntList){
            if(conEntRec.Core_Selected__c==true){
                empContactId.add(conEntRec.Core_Contact_Id__c);
                
            }else if(conEntRec.Core_Selected__c==false){
                nonEmpContactId.add(conEntRec.Core_Contact_Id__c);
            }
        }
        
        Map<Id,Set<Id>> mapAccIdToNonEmpContactId = new Map<Id,Set<Id>>();
        for(Contact conRec:allPartnerContacts){
            
            for(Id nonEmpConId:nonEmpContactId){
                
                if(conRec.Id==nonEmpConId){
                    
                    if(mapAccIdToNonEmpContactId.get(conRec.AccountId) != null){
                        mapAccIdToNonEmpContactId.get(conRec.AccountId).add(conRec.Id);                                             
                        
                    }else{
                        mapAccIdToNonEmpContactId.put(conRec.AccountId, 
                                                   new Set<Id>{conRec.Id});
                        
                    } 
                }
            }
        }
        Map<Id,Set<Id>> mapPartnerAccToIntelAcc = new Map<Id,Set<Id>>();
        for(Core_Account_Group_Member__c allPartnerAccGroup :[SELECT Id, Core_Partner_Account_Id__c,Core_MDA_Ind__c, 
                                                              Core_Intel_Account_Id__c FROM Core_Account_Group_Member__c 
                                                              WHERE Core_Intel_Account_Id__c IN :mapAccIdToNonEmpContactId.keySet() AND Core_Inactive_Ind__c=false]){
                                                                                                                       
            if(mapPartnerAccToIntelAcc.get(allPartnerAccGroup.Core_Partner_Account_Id__c) != null  && allPartnerAccGroup.Core_Intel_Account_Id__c != null){
                mapPartnerAccToIntelAcc.get(allPartnerAccGroup.Core_Partner_Account_Id__c).add(allPartnerAccGroup.Core_Intel_Account_Id__c);                                                
            }else{
                mapPartnerAccToIntelAcc.put(allPartnerAccGroup.Core_Partner_Account_Id__c, new Set<Id>{allPartnerAccGroup.Core_Intel_Account_Id__c});
                                                                      
            }                                                
        }
        Map<Id,Set<Id>> mapPartnerAccIdToNonEmpContactIds = new Map<Id,Set<Id>>();
        for(Id partnerAccId:mapPartnerAccToIntelAcc.keySet()){
            Set<Id> lstIntelAccIds = mapPartnerAccToIntelAcc.get(partnerAccId);
            for(Id accId:lstIntelAccIds){
                for(Id nonEmpAcc:mapAccIdToNonEmpContactId.keySet()){
                    if(accId == nonEmpAcc){
                        if(mapPartnerAccIdToNonEmpContactIds.get(partnerAccId) != null  && partnerAccId!= null){
                            mapPartnerAccIdToNonEmpContactIds.get(partnerAccId).addAll(mapAccIdToNonEmpContactId.get(nonEmpAcc));                                                
                        }else{
                            mapPartnerAccIdToNonEmpContactIds.put(partnerAccId,mapAccIdToNonEmpContactId.get(nonEmpAcc));
                            
                        }
                    }
                }
                
            }
        }
        Set<Id> nonEmpUserIds = new Set<Id>();
        for(User u:[SELECT Id,ContactId FROM User WHERE ContactId IN:nonEmpContactId]){
            nonEmpUserIds.add(u.Id);
        }
        Map<Id,String> partnerAccIdToGroupMap = new Map<Id,String>();
        List<String> lstGrpNames = new List<String>();
        Set<Id> grpIds = new Set<Id> ();
        for(Id partnerAccId:mapPartnerAccIdToNonEmpContactIds.keySet()){
        String GrpName = CORE_MP_STR + partnerAccId + '_' + employee ;
        lstGrpNames.add(GrpName);
        partnerAccIdToGroupMap.put(partnerAccId,GrpName);
        }
        
        for(Group grp:[SELECT Id, DeveloperName FROM Group where DeveloperName IN: lstGrpNames]){
            grpIds.add(grp.Id);
        }
        List<GroupMember> listGm  = [Select Id,GroupId,UserOrGroupID FROM GroupMember WHERE GroupId IN :grpIds AND UserOrGroupID in :nonEmpUserIds];                                             
                     if(!listGm.isEmpty()){
                      Database.delete(listGm, false);
                 }
    } 
    
    
     private static Set<Id> getOdmIntelAccountIds(Set<Id> mdaAccounts){
        
        Set<Id> OdmAccId = new Set<Id>();   
        
        String bizOrgLabelValues = System.Label.PMP_Biz_Org_ODM_Values ;
        List<String> bizOrgLabelValuesSplit = bizOrgLabelValues.split(';');
        
            for(Account odmPartner: [SELECT Id,Name,Core_Account_Type__c FROM Account WHERE Id IN:mdaAccounts]){
                for(String typeVal:bizOrgLabelValuesSplit){
                    if(odmPartner.Core_Account_Type__c != null && odmPartner.Core_Account_Type__c.contains(typeVal)){
                        OdmAccId.add(odmPartner.Id);
                        break;
                    }
            
                }
            }
          return OdmAccId;        
    }
    
    private static List<Account> fetchNonOdmIntelAccounts(Set<Id> mdaAccounts){
        List<Account> nonOdm = new List<Account>();
        
        //fetching ODM values from label
        String bizOrgLabelValues = System.Label.PMP_Biz_Org_ODM_Values ;
        List<String> bizOrgLabelValuesSplit = bizOrgLabelValues.split(';');
        for(String typeVal:bizOrgLabelValuesSplit){
            
        }
        boolean isODMAcc = false;
        for(Account nonOdmPartner: [SELECT Id,Name,Core_Account_Type__c FROM Account WHERE Id IN:mdaAccounts]){
            isODMAcc = false;
            for(String typeVal:bizOrgLabelValuesSplit){
                if(nonOdmPartner.Core_Account_Type__c.contains(typeVal)){
                       isODMAcc = true;
                        break;
                   }
            }    
                   if(nonOdmPartner.Core_Account_Type__c == null || !isODMAcc || String.isBlank(nonOdmPartner.Core_Account_Type__c)){
                       nonOdm.add(nonOdmPartner);
                       }
             }
        return nonOdm;
    }
    
    private static Set<Id> fetchODMPartnerAccountIds(Set<Id> accId, Set<Id> mdaAccounts, Set<Id> OdmAccId){
        
        Set<Id> odmPartnerId= new Set<Id>();
        for(Core_Account_Group_Member__c allPartnerAccGroups:[SELECT Id, Core_Partner_Account_Id__c, Core_Intel_Account_Id__c 
                                                              FROM Core_Account_Group_Member__c 
                                                              WHERE Core_Intel_Account_Id__c IN:OdmAccId]){//odmPartner
                                                                  odmPartnerId.add(allPartnerAccGroups.Core_Partner_Account_Id__c);                                              
                                                                  
                                                              }
        return odmPartnerId;
    }
    
    private static Set<Id> fetchNonODMPartnerAccountIds(Set<Id> accId, Set<Id> mdaAccounts, List<Account> nonOdmPartner){
        
        Set<Id> nonOdmPartnerId = new Set<Id>();
        
        for(Core_Account_Group_Member__c allPartnerAccGroups:[SELECT Id, Core_Partner_Account_Id__c, Core_Intel_Account_Id__c 
                                                              FROM Core_Account_Group_Member__c 
                                                              WHERE Core_Intel_Account_Id__c IN:nonOdmPartner]){
                                                                  nonOdmPartnerId.add(allPartnerAccGroups.Core_Partner_Account_Id__c);                                              
                                                                  
                                                              }
        return nonOdmPartnerId;
        
    }
    
    //insert scenario
    public static void insertPublicGroupMembership(){
        
        Map<Id,Set<Id>> intelAccIdToUserIdMap = new Map<Id,Set<Id>>();
        Map<Id,Id> intelAccIdToPartnerAccIdMap = new Map<Id,Id>();
        Map<Id,Set<Id>> partnerAccToPartnerUserMap = new Map<Id,Set<Id>>();
        Map<Id,Id> pagIdToIntelAccIdMap = new Map<Id,Id>();
        Map<Id,String> quriedGrpIdToDevNameMap = new Map<Id,String>();
        Map<Id,Id> partnerAccIdToGroupId = new Map<Id,Id>();
        Map<String,Id> devNameToGroupIdMap = new Map<String,Id>();
        
        List<String> grpDevNames = new List<String>();
        Set<Id> accId = new Set<Id>();
        List<String> lstEntitlementIds = new List<String>();
        List<Account> allPartnerAccount = new List<Account>();
        
        try{    
            /********Getting The partner account record type from label**********/
            String partnerAccRecTypeId = System.Label.PMP_Partner_Account_Record_Type_Id;
            
            /********Querying all The partner accounts where the flag has been updated **********/
            allPartnerAccount = [SELECT Id,Name,Core_PMP_Membership_Change_Ind__c FROM Account 
                                 WHERE RecordTypeId =:partnerAccRecTypeId 
                                 and Core_PMP_Membership_Change_Ind__c=true];
            
            /********Getting all Partner Account ids in context **********/    
            for(Account acc:allPartnerAccount){
                accId.add(acc.id);
            }
            
            
            /********Removing the Partner Account which doesn't have any single entitlements **********/
            allPartnerAccount = refinePartnerAccounts(allPartnerAccount,accId);
            
            Set<Id> mdaAccounts = new Set<Id>();
            Set<Id> accIdWithAssociation = new Set<Id>();
            Set<Id> accIdWithOutAssociation = new Set<Id>();
            
            accIdWithOutAssociation.addAll(accId);
            //Getting all the MDA accounts under the partner accounts found above
            for(Core_Account_Group_Member__c allPartnerAccGroups:[SELECT Id, Core_Partner_Account_Id__c,Core_MDA_Ind__c, 
                                                                  Core_Intel_Account_Id__c FROM Core_Account_Group_Member__c 
                                                                  WHERE Core_Partner_Account_Id__c IN:accId AND Core_MDA_Ind__c=true AND Core_Inactive_Ind__c=false ]){
                                                                      
                                                                      mdaAccounts.add(allPartnerAccGroups.Core_Intel_Account_Id__c); 
                                                                      accIdWithAssociation.add(allPartnerAccGroups.Core_Partner_Account_Id__c);                                                 
                                                                      
                                                                  }
            for(Id acctId : accIdWithAssociation){
                accIdWithOutAssociation.remove(acctId);
            }
            List<String> groupNames = new List<String>();
            String grpName = null;
            for(Id partnerAccId:accIdWithOutAssociation){
                grpName = CORE_MP_STR+partnerAccId;
                groupNames.add(grpName);
            }
            
            if(groupNames != null && !groupNames.isEmpty()){
                
                List<Group> groupsToBeRemoved = [Select Id, DeveloperName from Group where DeveloperName in :groupNames];
                
                Set<Id> groupIdsToBeRemoved = new Set<Id> ();
                for(Group groupRec : groupsToBeRemoved){
                    if(groupRec.Id != null)
                        groupIdsToBeRemoved.add(groupRec.Id);
                }
                
                if(!groupIdsToBeRemoved.isEmpty()){
                     List<GroupMember> listGm  = [Select Id,GroupId,UserOrGroupID from GroupMember where GroupId IN :groupIdsToBeRemoved];
                    if(listGm != null && !listGm.isEmpty()){
                       Database.delete(listGm);
                    }  
                }  
            }
            
             /********Getting all Intel Account ids whose type is ODM **********/    
            Set<Id> OdmAccId = getOdmIntelAccountIds(mdaAccounts);
            
            /********Getting all Partner Account ids for the ODM Intel Accounts found above **********/    
            Set<Id> odmPartnerId= fetchODMPartnerAccountIds(accId, mdaAccounts, OdmAccId);
            
            /********Getting all Intel Account ids whose type is Non-ODM **********/    
            List<Account> nonOdmPartner = fetchNonOdmIntelAccounts(mdaAccounts);
            
            /********Getting all Partner Account ids for the Non-ODM Intel Accounts found above **********/ 
            Set<Id> nonOdmPartnerId= fetchNonODMPartnerAccountIds(accId, mdaAccounts, nonOdmPartner);
            
            /********Iterating account group members for partner account ids **********/
            for(Core_Account_Group_Member__c allPartnerAccGroups:[SELECT Id, Core_Partner_Account_Id__c, Core_Intel_Account_Id__c 
                                                                  FROM Core_Account_Group_Member__c 
                                                                  WHERE Core_Partner_Account_Id__c IN:accId AND Core_Inactive_Ind__c=false]){
                                                                      
                                                                      //Map of Intel account id to partner account id 
                                                                      intelAccIdToPartnerAccIdMap.put(allPartnerAccGroups.Core_Intel_Account_Id__c,allPartnerAccGroups.Core_Partner_Account_Id__c);
                                                                      
                                                                      // Map of Account group member to Intel account                                            
                                                                      pagIdToIntelAccIdMap.put(allPartnerAccGroups.Id,allPartnerAccGroups.Core_Intel_Account_Id__c);   
                                                                      
                                                                  }
                        
            /******** Fetching MP entitlemet ids from custom label*********/
            List<Core_Entitlement__c> entitlementDetails = new List<Core_Entitlement__c>();
            String Core_Entitlement_Id_Label = System.Label.PMP_External_Entitlement_Ids;
            
            if(!Test.isRunningTest()){
                lstEntitlementIds = Core_Entitlement_Id_Label.split(';');
            }else{
                //Querying Entitlement Detail
                entitlementDetails = [SELECT Id, Name, Core_Display_Name__c FROM Core_Entitlement__c];
                for(Core_Entitlement__c coreEntitlement : entitlementDetails){
                    lstEntitlementIds.add(coreEntitlement.Id);
                }
            }
            
            /********Querying all partner contacts for intel accounts **********/
            List<Contact> allPartnerContact = [SELECT Id,AccountId FROM Contact WHERE AccountId IN:pagIdToIntelAccIdMap.values()];
            
            /********Getting all contact entitlements for mp related entitlements and for allpartnercontact **********/
            List<Core_Contact_Entitlement__c> conEntList = [SELECT Id,Core_Contact_Id__c,Core_Entitlement_Id__c,Core_Status__c, 
                                                            Core_Selected__c FROM Core_Contact_Entitlement__c
                                                            WHERE Core_Status__c = :COMPLETE_STR AND Core_Selected__c = true 
                                                            AND Core_Entitlement_Id__c in :lstEntitlementIds 
                                                            AND Core_Contact_Id__c IN :allPartnerContact];
            Set<Id> contactsId = new Set<Id>();
            
            //Getting all the contact ids from contact entitlements
            for(Core_Contact_Entitlement__c conIds:conEntList){
                contactsId.add(conIds.Core_Contact_Id__c);
            }
            
            // Getting partner users for intel accounts 
            for(User partnerUser: [SELECT Id, Name, ContactId, AccountId FROM User 
                                   WHERE ContactId IN :contactsId 
                                   AND AccountId IN :pagIdToIntelAccIdMap.values()]){
                                       
                                       if(intelAccIdToUserIdMap.containsKey(partnerUser.AccountId)){   
                                           //Map of intel account id to partner user
                                           intelAccIdToUserIdMap.get(partnerUser.AccountId).add(partnerUser.Id);
                                       }
                                       else{
                                           intelAccIdToUserIdMap.put(partnerUser.AccountId, new Set<Id>{partnerUser.Id});
                                       }
                                   }
            //Iterating on intel account ids and preparing a map for partner account id partner user map
            for(Id intelAccId : intelAccIdToPartnerAccIdMap.keyset()){
                
                Id partnerAccId =  intelAccIdToPartnerAccIdMap.get(intelAccId);
                if(partnerAccId != null && !partnerAccToPartnerUserMap.containsKey(partnerAccId) 
                   && intelAccIdToUserIdMap.get(intelAccId)!=null){
                       
                       Set<Id> tempUserIds = new Set<Id>();
                       tempUserIds.addAll(intelAccIdToUserIdMap.get(intelAccId));
                       if(tempUserIds!=null){
                           partnerAccToPartnerUserMap.put(partnerAccId, tempUserIds);
                       }   
                   }else{
                       
                       Set<Id> tempUserIds = partnerAccToPartnerUserMap.get(partnerAccId);
                       if(intelAccIdToUserIdMap.get(intelAccId)!=null && partnerAccId!=null){
                           tempUserIds.addAll(intelAccIdToUserIdMap.get(intelAccId));
                           partnerAccToPartnerUserMap.put(partnerAccId, tempUserIds);
                       }
                   }
            }
            
            String publicGroupName = '';
            List<String> publicGroupNameToBeAdded = new List<String>();
            
            //Forming Public group name
            for(Id partnerAccountId : partnerAccToPartnerUserMap.keyset()){ // partnerAccIdToPagId
                publicGroupName = CORE_MP_STR + partnerAccountId;
                publicGroupNameToBeAdded.add(publicGroupName); 
            }
            
            //Calling createPublicGroups method
            List<Group> queriedGrps = createPublicGroups(publicGroupNameToBeAdded);
            
            for(Group queriedGroup : queriedGrps){
                //Map Of Group Id to Group dev name 
                quriedGrpIdToDevNameMap.put(queriedGroup.Id, queriedGroup.developerName);
                devNameToGroupIdMap.put(queriedGroup.developerName, queriedGroup.Id);
            }
            
            //Calling  createSegmentBasedPublicGroup method
            createSegmentBasedPublicGroup(partnerAccToPartnerUserMap, pagIdToIntelAccIdMap, allPartnerContact);
            
            //Calling createPartAdminEntBasedPublicGroup method
            createPartAdminEntBasedPublicGroup(partnerAccToPartnerUserMap, allPartnerContact);
            
            //Calling populatePublicGroupMembers method
            List<GroupMember> groupMemberList = populatePublicGroupMembers(queriedGrps, partnerAccToPartnerUserMap,
                                                                           odmPartnerId,nonOdmPartnerId,
                                                                           partnerAccIdToGroupId,devNameToGroupIdMap);
           
            //Clean odm accounts from non-odm and non-odm from odm
            cleanODMNonODMGroupMembership(allPartnerAccount, accId, OdmAccId, odmPartnerId, nonOdmPartner, nonOdmPartnerId);
        }catch(Exception e){
            String exceptionMessage = e.getTypeName() + ': ' + e.getMessage() + ', ' + e.getStackTraceString();
        } 
    }
    
    private static void cleanODMNonODMGroupMembership(List<Account> allPartnerAccount, Set<Id> accId, 
                                                      Set<Id> OdmAccId, Set<Id> odmPartnerId, 
                                                      List<Account> nonOdmPartner, Set<Id> nonOdmPartnerId){
                                                          //ALL_PARTNERS_ODM_GROUP
                                                          cleanODMGroupMembership(nonOdmPartnerId, odmPartnerId, false);
                                                          //ALL_PARTNERS_NON_ODM_GROUP
                                                          cleanODMGroupMembership(nonOdmPartnerId, odmPartnerId, true);
                                                          
                                                      }
    
    private static void cleanODMGroupMembership(Set<Id> nonOdmPartnerId, Set<Id> odmPartnerId, Boolean isODM){
        
        List<String> nonODMGroupDevNames = new List<String>();
        List<String> odmGroupDevNames = new List<String>();
        String groupId =  '';
        
        if(!isODM){
            for(Id nonODMPartRecId : nonOdmPartnerId){
                groupId =  CORE_MP_STR + nonODMPartRecId;
                nonODMGroupDevNames.add(groupId);
            }
        }else{
            for(Id odmPartRecId : odmPartnerId){
                groupId =  CORE_MP_STR + odmPartRecId;
                odmGroupDevNames.add(groupId);
            }
        }
        
        if(!isODM){
            List<Group> allNonODMGroups =[SELECT Id,DeveloperName,Name FROM Group WHERE DeveloperName IN :nonODMGroupDevNames];
            Set<Id> nonODMGroupIds = new Set<Id>();
            for(Group nonODMGroup : allNonODMGroups){
                nonODMGroupIds.add(nonODMGroup.Id);                  
            }
            
            List<GroupMember> nonEligibleNonODMGrpMembers  = [Select Id,UserOrGroupID,GroupId from 
                                                              GroupMember where UserOrGroupID IN :nonODMGroupIds
                                                              and GroupId = :ALL_PARTNERS_ODM_GROUP];
            if(nonEligibleNonODMGrpMembers != null && !nonEligibleNonODMGrpMembers.isEmpty()){
                Database.delete(nonEligibleNonODMGrpMembers, false);
            }
        }else{
            List<Group> allODMGroups =[SELECT Id,DeveloperName,Name FROM Group WHERE DeveloperName IN :odmGroupDevNames];
            Set<Id> odmGroupIds = new Set<Id>();
            for(Group odmGroup : allODMGroups){
                odmGroupIds.add(odmGroup.Id);                  
            }
            List<GroupMember> nonEligibleODMGrpMembers  = [Select Id,UserOrGroupID,GroupId from 
                                                           GroupMember where UserOrGroupID IN :odmGroupIds
                                                           and GroupId = :ALL_PARTNERS_NON_ODM_GROUP];
            if(nonEligibleODMGrpMembers != null && !nonEligibleODMGrpMembers.isEmpty()){
                Database.delete(nonEligibleODMGrpMembers, false);
            }
        }   
    }
    
     private static void updatePublicGrpMembers(){
        
        List<Account> allPartnerAccount = new List<Account>();
        
        try{
            /********Getting The partner account record type from label**********/
            String partnerAccRecTypeId = System.Label.PMP_Partner_Account_Record_Type_Id;
            
            /********Querying all The partner accounts where the flag has been updated **********/
            allPartnerAccount = [SELECT Id,Name,Core_PMP_Membership_Change_Ind__c FROM Account 
                                 WHERE RecordTypeId =:partnerAccRecTypeId 
                                 and Core_PMP_Membership_Change_Ind__c=true];
            
            List<Id>  partnerAccIds = new List<Id>();
            /********Getting all Partner Account ids in context **********/    
            for(Account acc:allPartnerAccount){
                partnerAccIds.add(acc.id);
            }
            
            Set<Id> probableUncheckedMdaPartnerAccounts = new Set<Id>();
            
            //Getting all the MDA accounts under the partner accounts found above
            for(Core_Account_Group_Member__c allPartnerAccGroup :[SELECT Id, Core_Partner_Account_Id__c,Core_MDA_Ind__c, 
                                                                  Core_Intel_Account_Id__c FROM Core_Account_Group_Member__c 
                                                                  WHERE Core_Partner_Account_Id__c IN :partnerAccIds
                                                                  AND Core_MDA_Ind__c = false AND Core_Inactive_Ind__c=false ]){
                                                                      probableUncheckedMdaPartnerAccounts.add(allPartnerAccGroup.Core_Partner_Account_Id__c);                                                 
                                                                      
                                                                  }
            
            Map<Id, Boolean> MDAPartnerAccountCheckMap = new Map<Id, Boolean>();
            //Getting all the MDA accounts under the partner accounts found above
            for(Core_Account_Group_Member__c allPartnerAccGroup :[SELECT Id, Core_Partner_Account_Id__c,Core_MDA_Ind__c, 
                                                                  Core_Intel_Account_Id__c FROM Core_Account_Group_Member__c 
                                                                  WHERE Core_Partner_Account_Id__c IN :probableUncheckedMdaPartnerAccounts
                                                                  AND Core_MDA_Ind__c = true AND Core_Inactive_Ind__c=false ]){
                                                                      
                                                                      if(allPartnerAccGroup.Core_Partner_Account_Id__c != null)               
                                                                          MDAPartnerAccountCheckMap.put(allPartnerAccGroup.Core_Partner_Account_Id__c, true);
                                                                      
                                                                  }
            Set<Id> uncheckedMdaPartnerAccounts = new Set<Id>();
            for(Id probablePartAccId : probableUncheckedMdaPartnerAccounts){
                if(MDAPartnerAccountCheckMap != null && MDAPartnerAccountCheckMap.keySet() != null
                   && !MDAPartnerAccountCheckMap.keySet().contains(probablePartAccId)){
                       uncheckedMdaPartnerAccounts.add(probablePartAccId);
                   }
            }
            
            List<String> grpDevNames = new List<String>();
            String grpId = '';
            
            for(Id partnerAccId : uncheckedMdaPartnerAccounts){
                if(partnerAccId !=null){
                    grpId = CORE_MP_STR + partnerAccId;
                    grpDevNames.add(grpId); 
                }
            }      
            
            if(grpDevNames != null && !grpDevNames.isEmpty()){
                
                List<Group> groupsToBeRemoved = [Select Id, DeveloperName from Group where DeveloperName in :grpDevNames];
                
                Set<Id> groupIdsToBeRemoved = new Set<Id> ();
                for(Group groupRec : groupsToBeRemoved){
                    if(groupRec.Id != null)
                        groupIdsToBeRemoved.add(groupRec.Id);
                }
                
                if(!groupIdsToBeRemoved.isEmpty()){
                    List<GroupMember> ListGM  = [Select Id,GroupId,UserOrGroupID from GroupMember where UserOrGroupId IN :groupIdsToBeRemoved];
                    if(ListGM != null && !ListGM.isEmpty()){
                        Database.delete(ListGM);
                    }  
                }  
            }
            
            
        }catch(Exception updateException){
            System.debug('updateException = '+ updateException.getMessage());
        }
        
    }
    
    public static void updatePublicGroupMembership(){
        insertPublicGroupMembership();
        updatePublicGrpMembers();
        deletePublicGrpMembers();
    }
    
    /********Method for public Group Creation **********/
    public static List<Group> createPublicGroups(List<String> publicGroupNameToBeAdded){
        List<Group> allPublicGroup = new List<Group>();
        List<String> grpDevNames = new List<String>();
        List<Group> publicGroupToBeInserted = new List<Group>();
        List<Group>  queriedGrps =new List<Group>();
        try
        {
            //Querying public group for group to be inserted
            allPublicGroup =[SELECT Id,DeveloperName,Name FROM Group WHERE DeveloperName IN :publicGroupNameToBeAdded];
            
            for(String publicGroup:publicGroupNameToBeAdded){
                
                if(!grpDevNames.contains(publicGroup)){
                    Group grp = new Group(); 
                    grp.Name = publicGroup; 
                    grp.DeveloperName  = publicGroup;
                    grp.DoesIncludeBosses = false;
                    publicGroupToBeInserted.add(grp);
                } 
            }
            
            //Inserting public group
            if(publicGroupToBeInserted !=  null && !publicGroupToBeInserted.isEmpty()){
                map < string, Database.Error[] > errorsMap = new map < string, Database.Error[] > ();
                
                Database.saveResult[] srlist=Database.insert(publicGroupToBeInserted, false);
                
                for (integer i = 0; i < srlist.size(); i++) {
                    database.saveResult sr = srlist.get(i);
                    if (!sr.isSuccess()) {
                        // inserting Exception error records 
                        errorsMap.put(publicGroupToBeInserted[i].Name , sr.getErrors());
                    }
                    
                }
            }
            
            queriedGrps = [SELECT Id,DeveloperName,Name FROM Group where DeveloperName IN :publicGroupNameToBeAdded];
        }
        catch(Exception e){
            String exceptionMessage = e.getTypeName() + ': ' + e.getMessage() + ', ' + e.getStackTraceString();
            // inserting the Error into LogEntry object
        } 
        return queriedGrps;
    }
     
     public static List<GroupMember> populatePublicGroupMembers(List<Group> queriedGrps, 
                                                               Map<Id,Set<Id>> partnerAccToPartnerUserMap,
                                                               Set<Id> odmPartnerId,Set<Id> nonOdmPartnerId, 
                                                               Map<Id,Id> partnerAccIdToGroupId,Map<String,Id> devNameToGroupIdMap){
                                                                    List<GroupMember> groupMemberList = new List<GroupMember>();
                                                                   Set<Id> grpIds = new Set<Id>();
                                                                   List<String> grpDevNames = new List<String>();
                                                                    Map<Id,String> quriedGrpIdToDevNameMap = new Map<Id,String>();
                                                                    try{
                                                                       Integer strLen = CORE_MP_STR.length();
                                                                       if(queriedGrps != null){
                                                                           for(Group grp : queriedGrps){
                                                                               grpDevNames.add(grp.DeveloperName);
                                                                               quriedGrpIdToDevNameMap.put(grp.Id,grp.DeveloperName);
                                                                           }
                                                                       }
                                                                        
                                                                        for(Id groupInserted: quriedGrpIdToDevNameMap.keyset()){
                                                                           
                                                                           Set<Id> userIds = new Set<Id>();
                                                                           if(quriedGrpIdToDevNameMap.get(groupInserted) != null){
                                                                               userIds = partnerAccToPartnerUserMap.get(quriedGrpIdToDevNameMap.get(groupInserted).subString(strLen));
                                                                           }
                                                                           if(userIds != null && !userIds.isEmpty()){
                                                                               for(Id userId : userIds){
                                                                                   GroupMember gm = new GroupMember();
                                                                                   gm.GroupId = groupInserted;
                                                                                   gm.UserOrGroupId = userId;
                                                                                   groupMemberList.add(gm);
                                                                               }
                                                                           }
                                                                       }
                                                                        
                                                                        /********* Forming PartnerAccIdToGroupId Map************/
                                                                       for(String devName : quriedGrpIdToDevNameMap.values()){
                                                                           partnerAccIdToGroupId.put(devName.subString(strLen),devNameToGroupIdMap.get(devName));
                                                                       }
                                                                         sharePartAccWithPartAcGrp(partnerAccIdToGroupId);
                                                                        
                                                                         /********* Hierarchy for all partners odm group************/
                                                                       
                                                                       for(Id OdmId : odmPartnerId){
                                                                           GroupMember odmMember = new GroupMember();
                                                                           odmMember.GroupId = ALL_PARTNERS_ODM_GROUP;
                                                                           odmMember.UserOrGroupId = partnerAccIdToGroupId.get(OdmId);
                                                                           groupMemberList.add(odmMember);
                                                                           }
                                                                       
                                                                        /********* Hiererchy for all partners non odm group************/
                                                                       for(Id nonOdmId : nonOdmPartnerId){
                                                                           GroupMember nonOdmMember = new GroupMember();
                                                                           nonOdmMember.GroupId = ALL_PARTNERS_NON_ODM_GROUP;
                                                                           nonOdmMember.UserOrGroupId = partnerAccIdToGroupId.get(nonOdmId);
                                                                           groupMemberList.add(nonOdmMember);
                                                                           }
                                                                         //Inserting group members
                                                                       if(groupMemberList != null && !groupMemberList.isEmpty()){
                                                                           map < string, Database.Error[] > errorsMap = new map < string, Database.Error[] > ();
                                                                           
                                                                           Database.saveResult[] srlist=Database.insert(groupMemberList,False);
                                                                           for (integer i = 0; i < srlist.size(); i++) {
                                                                               database.saveResult sr = srlist.get(i);
                                                                               if (!sr.isSuccess()) {
                                                                                   // inserting Exception error records 
                                                                                   errorsMap.put(groupMemberList[i].GroupId , sr.getErrors());
                                                                               }
                                                                               
                                                                           }
                                                                           
                                                                       }
                                                                       
                                                                   }
                                                                   
                                                                   catch(Exception e){
                                                                       String exceptionMessage = e.getTypeName() + ': ' + e.getMessage() + ', ' + e.getStackTraceString();
                                                                         
                                                                   } 
                                                                   return groupMemberList;
                                                               }
                                                           }