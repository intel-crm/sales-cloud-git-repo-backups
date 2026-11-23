/**************************************************************************************
Apex Class Name : Core_Company_Information_Assignment
Version     : 1.0 
Created Date: 20th may, 2019
Description : Helper class for PMP_CompanyInformationTriggerHandler
* Modification Log :
* Developer                 Date                     Description
* ----------------------------------------------------------------------------
* Sandip                  20/05/2019               Original Version
*************************************************************************************/
public class PMP_Company_Info_Sharing {

    static final LoggingLevel logLevel = LoggingLevel.DEBUG;
    static final String CORE_MP_STR = System.Label.PMP_Group_Name_Prefix;  
    static final String RECORD_SHARE_ACCESS_LEVEL_EDIT = 'Edit';
    static final String RECORD_SHARE_ACCESS_LEVEL_READ = 'Read';
    static final String USER_PREFIX_ID = '005';
    static final String GROUP_PREFIX_ID = '00G';
    
    /******************Method To share company info records**********************/
    public static void shareCompanyInfoRecords(List<PMP_Company__c> oldCompanyInfoList, 
                                                   List<PMP_Company__c> newCompanyInfoList){
   
        // If Trigger is isInsert
        if(Trigger.isInsert != null && Trigger.isInsert){
            //Calling method shareBasedOnCompanyInfoAccount where sharing is happening based on the company info account
            shareBasedOnCompanyInfoAccount(/*oldCompanyInfoList,*/ newCompanyInfoList);
        }
        
                                                       
        // If Trigger is Update                                               
        if(Trigger.isUpdate != null && Trigger.isUpdate){
            
            //List of company info record where owner is changed
            List<PMP_Company__c> revisedOldCompanyInfoOwnerBased = new List<PMP_Company__c> ();
            
            //List of company info record where account is changed
            List<PMP_Company__c> revisedOldCompanyInfoAccBased = new List<PMP_Company__c> ();
            List<PMP_Company__c> listCompanyInfo = new List<PMP_Company__c>();
            
            Map<Id, PMP_Company__c> newMapForCompanyInfo = (Map<Id, PMP_Company__c>)Trigger.newMap;
            
            for(PMP_Company__c oldCompany : oldCompanyInfoList){
                
                if(oldCompany.Id != null && newMapForCompanyInfo != null && newMapForCompanyInfo.keySet() != null
                   && newMapForCompanyInfo.keySet().contains(oldCompany.Id)){
                       
                       if(newMapForCompanyInfo.get(oldCompany.Id) != null){
                           PMP_Company__c tempPMPCompanyInfo = newMapForCompanyInfo.get(oldCompany.Id);
                           User internalUser = [SELECT Id,Name,ProfileId,Profile.Name FROM User Where Id=:tempPMPCompanyInfo.OwnerId]; 
                           if(internalUser.Profile.Name !='Partner'){
                               listCompanyInfo.add(tempPMPCompanyInfo);
               					 
            				}
                           
                               if(tempPMPCompanyInfo != null && tempPMPCompanyInfo.OwnerId != null){
                                   if(tempPMPCompanyInfo.OwnerId != oldCompany.OwnerId){
                                          //List of company info record where owner is changed
                                          revisedOldCompanyInfoOwnerBased.add(tempPMPCompanyInfo); 
                                      
                                   }
                           		}
     
                           
                           //Check for if Account has changed
                           if(tempPMPCompanyInfo != null && tempPMPCompanyInfo.PMP_Account_Id__c != null){
                               if(tempPMPCompanyInfo.PMP_Account_Id__c != oldCompany.PMP_Account_Id__c){
                                      //List of company info record where account is changed
                                      revisedOldCompanyInfoAccBased.add(tempPMPCompanyInfo); 
                               }
                           }

                       }
                   }
            }
            
            if(listCompanyInfo!=null){
                     //listCompanyInfo.add(tempPMPCompanyInfo);
               		shareBasedOnCompanyInfoAccount(listCompanyInfo);
            	}
            // Sharing Based on owner
            if(revisedOldCompanyInfoOwnerBased != null && !revisedOldCompanyInfoOwnerBased.isEmpty()){
                	// Calling method shareBasedOnOwnerShip where sharing is happeningbased on company info record owner
                	shareBasedOnOwnerShip(revisedOldCompanyInfoOwnerBased);
            	}
                    
            
            // Sharing Based on company info
            if(revisedOldCompanyInfoAccBased != null && !revisedOldCompanyInfoAccBased.isEmpty()){
                	// Calling method shareBasedOnOwnerShip where sharing is happeningbased on company info record owner
                    shareBasedOnCompanyInfoAccount(revisedOldCompanyInfoAccBased);
            	}
            
            
        }
                                                     
    }
    
    /************************ Method to share company info record based company account*******************/
    private static void shareBasedOnCompanyInfoAccount(List<PMP_Company__c> newCompanyInfoList){
                                                  
        // Map of company information record to their account
        Map<PMP_Company__c, Id> companyInfoRecordToAccIdMap = new Map<PMP_Company__c, Id>();
		
        // code block to form a map of company information record to their account
        for(PMP_Company__c companyInfo : newCompanyInfoList){
              companyInfoRecordToAccIdMap.put(companyInfo , companyInfo.PMP_Account_Id__c);
        	}
        
        //get all the Partner Accounts attached to the Account(s)                       
        if(companyInfoRecordToAccIdMap != null && !companyInfoRecordToAccIdMap.isEmpty()) {
                        
        	// Map of account id to partner account id map
            Map<Id, Id> accIdToPartnerAccIdMap = new Map<Id, Id>();
            
            for(Core_Account_Group_Member__c coreAccGrpMember : [SELECT Core_MDA_Ind__c, Core_Partner_Account_Id__c, Core_Intel_Account_Id__c 
                 				FROM Core_Account_Group_Member__c where Core_Intel_Account_Id__c in : companyInfoRecordToAccIdMap.values()]){
                     
                  accIdToPartnerAccIdMap.put(coreAccGrpMember.Core_Intel_Account_Id__c,coreAccGrpMember.Core_Partner_Account_Id__c);
            	}

            //Map of partner account to set of company info record which is suppose to be share with that pag.
            Map<Id, Set<PMP_Company__c>> partnerAccIdToCompanyInfoRecordsMap = new Map<Id, Set<PMP_Company__c>>();
            
            for(PMP_Company__c companyInfoRecord : companyInfoRecordToAccIdMap.keySet()){
                Id accountId = companyInfoRecordToAccIdMap.get(companyInfoRecord);
                
                if(accountId != null){
                    Id partnerAccId = accIdToPartnerAccIdMap.get(accountId);
                    if(partnerAccId != null){
                        if(partnerAccIdToCompanyInfoRecordsMap.get(partnerAccId) == null){
                            
                           Set<PMP_Company__c> companyInfoRecords = new Set<PMP_Company__c>();
                           companyInfoRecords.add(companyInfoRecord);
                           partnerAccIdToCompanyInfoRecordsMap.put(partnerAccId, companyInfoRecords);
                            
                        }else if(partnerAccIdToCompanyInfoRecordsMap.get(partnerAccId) != null){
                            
                            Set<PMP_Company__c> companyInfoRecords = partnerAccIdToCompanyInfoRecordsMap.get(partnerAccId);
                            if(!companyInfoRecords.isEmpty()){
                                companyInfoRecords.add(companyInfoRecord);
                                //Map of partnerAccId to the their company info record
                                partnerAccIdToCompanyInfoRecordsMap.put(partnerAccId, companyInfoRecords); 
                            }
                        }
                    }
                }
            }//End of for
            
            String publicGroupName = '';
            Set<String> publicGroupNameToBeAddedSet = new Set<String>();
            
            //Creating the list of public group names for the groups that are to be created
            if(accIdToPartnerAccIdMap != null && !accIdToPartnerAccIdMap.isEmpty()){
                for(Id partnerAccountId : accIdToPartnerAccIdMap.values()){
                    publicGroupName = CORE_MP_STR + partnerAccountId;
                    publicGroupNameToBeAddedSet.add(publicGroupName); 
                }
            }
            
            if(publicGroupNameToBeAddedSet != null && !publicGroupNameToBeAddedSet.isEmpty()){
                
                List<String> publicGroupNameToBeAdded = new List<String>();
                publicGroupNameToBeAdded.addAll(publicGroupNameToBeAddedSet);
                
                //Create the needed public group(s) if it doesn't exist
                List<Group> queriedGrps = PMP_Batch_Group_Management.createPublicGroups(publicGroupNameToBeAdded);
            
                Map<String, Id> groupDevNameToGrpId = new Map<String, Id>();
                
 				// Create a map of public group developer name to corresponding group id
                for(Group groupRec : queriedGrps){
                	groupDevNameToGrpId.put(groupRec.DeveloperName , groupRec.Id);
                    
                }
            
                Map<Id, Set<PMP_Company__c>> groupIdToCompanyInfoRecords = new Map<Id, Set<PMP_Company__c>>();
                // Creating a Map of group id to Company info Records to list out the set of company info ids that 
                // will be added under a group
                for(Id partnerAccId : partnerAccIdToCompanyInfoRecordsMap.keySet()){
                    
                    Set<PMP_Company__c> compayInfoRecords = partnerAccIdToCompanyInfoRecordsMap.get(partnerAccId);
                    
                    if(compayInfoRecords != null && !compayInfoRecords.isEmpty()){
                        String groupDevName = CORE_MP_STR + partnerAccId;
                        
                        if(!String.isBlank(groupDevName)){
                           	Id grpIdRec = groupDevNameToGrpId.get(groupDevName);
                           if(grpIdRec != null){
                               
                             	groupIdToCompanyInfoRecords.put(grpIdRec, compayInfoRecords);
                               
                           }       
                        }
                    }
                }
				//Check if groupIdToCompanyInfoRecords is not null then call createSharingRecords method
                if(groupIdToCompanyInfoRecords != null && !groupIdToCompanyInfoRecords.isEmpty()){
                  	createSharingRecords(groupIdToCompanyInfoRecords);
                    
                    //Get old company info record
                    List<PMP_Company__c> oldCompanyInfoList = (List<PMP_Company__c>)Trigger.old;
                    
                    //Check if oldCompanyInfoList is not null then call deleteSharingRecords method
                    if(oldCompanyInfoList != null && !oldCompanyInfoList.isEmpty()){
                        
                        deleteSharingRecords(groupIdToCompanyInfoRecords, oldCompanyInfoList);
                        
                    }  
                }	

            }
            
        }//end of if
        
    }// end of method
    
    /***************************** Method to share company info record based on the owner************************/
    
    private static void shareBasedOnOwnerShip(List<PMP_Company__c> oldCompanyInfoList){
    
		
        //Set<ID> setAccId = new Set<ID>();
        Map<PMP_Company__c, Id> companyInfoToOwnerUserIdMap = new Map<PMP_Company__c, Id>();
        //Form a map of company Info record to their owner
        for(PMP_Company__c companyInfo : oldCompanyInfoList){ // newCompanyInfoList
              companyInfoToOwnerUserIdMap.put(companyInfo , companyInfo.OwnerId);
        }
        
        Map<Id, Id> accIdToUserIdMap = new Map<Id, Id>();
        
        //Form a map of intel account id to user map
        for(User ownerUser: [SELECT AccountId,Id  FROM User where Id in :companyInfoToOwnerUserIdMap.values()]){
            //setAccId.add(ownerUser.AccountID); // Get All AccountIds
            accIdToUserIdMap.put(ownerUser.AccountID, ownerUser.Id);
        }

        
        Map<Id, Id> accIdToPartnerAccIdMap = new Map<Id, Id>();
        //Forming a map of intel account id to their partner account
        for(Core_Account_Group_Member__c coreAccGrpMember : [SELECT Core_MDA_Ind__c, Core_Partner_Account_Id__c, Core_Intel_Account_Id__c 
                							FROM Core_Account_Group_Member__c where Core_Intel_Account_Id__c in : accIdToUserIdMap.keySet()]){
                                                
            	accIdToPartnerAccIdMap.put(coreAccGrpMember.Core_Intel_Account_Id__c,coreAccGrpMember.Core_Partner_Account_Id__c);
        }
        

        Map<Id, Set<Id>> partnerAccIdUserIdsMap = new Map<Id, Set<Id>> ();
        // Code block to form a map of partner aaccount to their partner users under it
        for(Id accId : accIdToPartnerAccIdMap.keySet()){
            
            Id partnerAccId = accIdToPartnerAccIdMap.get(accId);
            
            if(partnerAccIdUserIdsMap.get(partnerAccId) == null){
                Set<Id> userIds = new Set<Id>();
                
                if(accIdToUserIdMap.get(accId) != null){
                    userIds.add(accIdToUserIdMap.get(accId));
                    partnerAccIdUserIdsMap.put(partnerAccId,userIds);
                }
                
                
                
            }else{
                if(accIdToUserIdMap.get(accId) != null){
                    partnerAccIdUserIdsMap.get(partnerAccId).add(accIdToUserIdMap.get(accId));
                }
            }
            
        }// end of for loop

        String publicGroupName = '';
        List<String> publicGroupNameToBeAdded = new List<String>();
        For(Id partnerAccountId : partnerAccIdUserIdsMap.keyset()){
            publicGroupName = CORE_MP_STR + partnerAccountId;
            publicGroupNameToBeAdded.add(publicGroupName); 
        }
         
        //Create the public group if it doesn't exist
        List<Group> queriedGrps = PMP_Batch_Group_Management.createPublicGroups(publicGroupNameToBeAdded);
                
        
        Map<Id, Set<PMP_Company__c>> partnerAccIdToCompanyInfoIdsMap = new Map<Id, Set<PMP_Company__c>>();
        
		//Code block to form a map of partner account to company info record associated with it
        for(PMP_Company__c compnayInfo : companyInfoToOwnerUserIdMap.keySet()){
            Id userId = companyInfoToOwnerUserIdMap.get(compnayInfo);
            
            for(Id partnerAccId : partnerAccIdUserIdsMap.keySet()){
                Set<Id> userIds = partnerAccIdUserIdsMap.get(partnerAccId);
                
                for(Id userIdRec : userIds){
                    
                    if(userIdRec == userId){
                        
                        if(partnerAccIdToCompanyInfoIdsMap.get(partnerAccId) == null){
                           Set<PMP_Company__c> companyInfoRecords = new Set<PMP_Company__c>();
                           companyInfoRecords.add(compnayInfo);
                           partnerAccIdToCompanyInfoIdsMap.put(partnerAccId, companyInfoRecords);
                        }else if(partnerAccIdToCompanyInfoIdsMap.get(partnerAccId) != null){
                            Set<PMP_Company__c> companyInfoRecords = partnerAccIdToCompanyInfoIdsMap.get(partnerAccId);
                            if(!companyInfoRecords.isEmpty()){
                                companyInfoRecords.add(compnayInfo);
                                partnerAccIdToCompanyInfoIdsMap.put(partnerAccId, companyInfoRecords); 
                            }
                        }
                    }
                }
            }
            
        }//End of loop


        Map<String, Id> groupDevNameToGrpId = new Map<String, Id>();
        //form a map of group dev name to their group id
        for(Group groupRec : queriedGrps){
           groupDevNameToGrpId.put(groupRec.DeveloperName , groupRec.Id);
        }
        
        Map<Id, Set<PMP_Company__c>> groupIdToCompanyInfoRecords = new Map<Id, Set<PMP_Company__c>>();
        //Code block to form a map of GroupId to company info record
        for(Id partnerAccId : partnerAccIdToCompanyInfoIdsMap.keySet()){
            Set<PMP_Company__c> compayInfoRecords = partnerAccIdToCompanyInfoIdsMap.get(partnerAccId);
            if(compayInfoRecords != null && !compayInfoRecords.isEmpty()){
                String groupDevName = CORE_MP_STR + partnerAccId;
                if(!String.isBlank(groupDevName)){
                   Id grpIdRec = groupDevNameToGrpId.get(groupDevName);
                   if(grpIdRec != null){
                     groupIdToCompanyInfoRecords.put(grpIdRec, compayInfoRecords);   
                   }       
                }
            }
        }//End of loop
		
        //Calling CreateSharingRecords Method the share company info record with the particular group
        createSharingRecords(groupIdToCompanyInfoRecords);
        
        List<PMP_Company__c> oldCompanyInfoListToBeDeleted = (List<PMP_Company__c>)Trigger.old;
        //Calling delete sharing records to delete sharing of old company info records who are eligible
        if(oldCompanyInfoList != null && !oldCompanyInfoList.isEmpty()){
            
            deleteSharingRecords(groupIdToCompanyInfoRecords, oldCompanyInfoListToBeDeleted);
            
         }
    }
    
    
    /*********************** Method to delete sharing of company info record who are eligible to be deleted**********************/
    
    private static void deleteSharingRecords(Map<Id, Set<PMP_Company__c>> groupIdToCompanyInfoRecords, List<PMP_Company__c> oldCompanyInfoList){
        

        List<PMP_Company__Share> partCompanyInfoDeleteList = new List<PMP_Company__Share>();
        List<PMP_Company__Share> finalCompanyInfoDeleteList = new List<PMP_Company__Share>();
        Map<Id, Id> accIdToPartnerAccIdMap = new Map<Id, Id>();
        Set<Id> allGroupIds = new Set<Id>(); 
        //Map<PMP_Company__c, Id> companyInfoIdToGrpId = new Map<PMP_Company__c, Id>();
        Map<Id, String> grpIdToGroupDevName = new Map<Id, String>();
        Set<PMP_Company__c> allCompanyInfoIds = new Set<PMP_Company__c>();
        
        //Forming a map of company info to thier group id
        for(Id groupId : groupIdToCompanyInfoRecords.keySet()){
            Set<PMP_Company__c> tempCompanyInfoIds = groupIdToCompanyInfoRecords.get(groupId);
            allCompanyInfoIds.addAll(tempCompanyInfoIds);
            
        }
        
       
        //Get Company info delete list        
        if(groupIdToCompanyInfoRecords !=null && !groupIdToCompanyInfoRecords.isEmpty()){
            
            partCompanyInfoDeleteList = [Select AccessLevel,Id,ParentId,RowCause,UserOrGroupId FROM PMP_Company__Share
                                        where ParentId in :allCompanyInfoIds];
            
        }
       
        List<Id> groupIds = new List<Id>();
        for(PMP_Company__Share partCompanyInfoDeleteRec : partCompanyInfoDeleteList){
            if(partCompanyInfoDeleteRec.UserOrGroupId != null)
            	groupIds.add(partCompanyInfoDeleteRec.UserOrGroupId);
        }
        
        List<Group> queriedGrps = [SELECT Id,DeveloperName,Name FROM Group where Id in :groupIds];
        
        // Create a map of public group developer name to corresponding group id
        for(Group groupRec : queriedGrps){
            if(groupRec.Id != null && groupRec.DeveloperName != null)
            	grpIdToGroupDevName.put(groupRec.Id, groupRec.DeveloperName);
        }
		
        Map<Id, PMP_Company__Share> groupIdToSharingRecMap = new Map<Id, PMP_Company__Share>();
        
        for(PMP_Company__Share pmpCompanyShare : partCompanyInfoDeleteList){
        	
            String tempGroupId = pmpCompanyShare.UserOrGroupId;

            if(tempGroupId != null && groupIdToCompanyInfoRecords != null && !tempGroupId.startsWith(USER_PREFIX_ID) 
              && tempGroupId.startsWith(GROUP_PREFIX_ID) && grpIdToGroupDevName != null 
              && grpIdToGroupDevName.get(tempGroupId) != null 
              && grpIdToGroupDevName.get(tempGroupId).startsWith(CORE_MP_STR)
              && !groupIdToCompanyInfoRecords.keySet().contains(tempGroupId)){
                
                //Map of groupId to their sharing record
                groupIdToSharingRecMap.put(tempGroupId, pmpCompanyShare);
                  
            }
        }
		
        
        finalCompanyInfoDeleteList = groupIdToSharingRecMap.values();
     	
        if(finalCompanyInfoDeleteList != null){
            String jsonString = json.serialize(finalCompanyInfoDeleteList);
            //Calling unSharePartnerCompanyInfo method to delete the sharing
        	unSharePartnerCompanyInfo(jsonString);
        } 
    }
    
    /********************** Method to create sharing records **********************************************/
    private static void createSharingRecords(Map<Id, Set<PMP_Company__c>> groupIdToCompanyInfoRecords){
        
       
        List<PMP_Company__Share> partCompanyInfoShareList = new List<PMP_Company__Share>();

        if(groupIdToCompanyInfoRecords !=null && !groupIdToCompanyInfoRecords.isEmpty()){
            for(Id groupIdRecord : groupIdToCompanyInfoRecords.keySet()){
                Set<PMP_Company__c> companyInfoRecords = groupIdToCompanyInfoRecords.get(groupIdRecord);
                if(companyInfoRecords != null && !companyInfoRecords.isEmpty()){
                    for(PMP_Company__c companyInfoRecordId : companyInfoRecords){
                        
                        if(companyInfoRecordId.PMP_Is_Published_Ind__c==true){
                              PMP_Company__Share partCompanyInfoShare = new PMP_Company__Share();
                              partCompanyInfoShare.AccessLevel  = RECORD_SHARE_ACCESS_LEVEL_READ;
                              partCompanyInfoShare.UserOrGroupId  = groupIdRecord;
                              partCompanyInfoShare.ParentId = companyInfoRecordId.Id;
                              partCompanyInfoShareList.add(partCompanyInfoShare);
                        }
                        else if(companyInfoRecordId.PMP_Is_Working_Copy_Ind__c==true){
                            System.debug('Working Copy ='+companyInfoRecordId.PMP_Is_Working_Copy_Ind__c);
                             PMP_Company__Share partCompanyInfoShare = new PMP_Company__Share();
                             partCompanyInfoShare.AccessLevel  = RECORD_SHARE_ACCESS_LEVEL_EDIT;
                             partCompanyInfoShare.UserOrGroupId  = groupIdRecord;
                             partCompanyInfoShare.ParentId = companyInfoRecordId.Id;
                             partCompanyInfoShareList.add(partCompanyInfoShare); 
                        }
                        
                    }
                }
            }
        }
        
       
       String jsonString = json.serialize(partCompanyInfoShareList);
       //Calling sharePartnerCompanyInfo method to share company info record
       sharePartnerCompanyInfo(jsonString);
        
        
    }
    /**************************Method to create company share record*****************************/
    @future
    private static void sharePartnerCompanyInfo(String jsonString){
        
        List<PMP_Company__Share> partCompanyInfoShareList 
                = (List<PMP_Company__Share>)Json.deserialize(jsonString,List<PMP_Company__Share>.class);
        

        if(partCompanyInfoShareList != null && !partCompanyInfoShareList.isEmpty()){
            Database.SaveResult[] srList = Database.insert(partCompanyInfoShareList, false);
        
            // Iterate through each returned result
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully inserted account. Account ID: ' + sr.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Account fields that affected this error: ' + err.getFields());
                    }
                }
            }
        }
        
    }
    
   /**************************Method to Delete company share record*****************************/ 
    @future
    private static void unSharePartnerCompanyInfo(String jsonString){
        List<PMP_Company__Share> partCompanyInfoDeleteShareList 
                = (List<PMP_Company__Share>)Json.deserialize(jsonString,List<PMP_Company__Share>.class);

        if(partCompanyInfoDeleteShareList != null && !partCompanyInfoDeleteShareList.isEmpty())
            Database.delete(partCompanyInfoDeleteShareList, false);
    }
}