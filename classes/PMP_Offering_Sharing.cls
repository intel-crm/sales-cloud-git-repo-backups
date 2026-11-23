/**************************************************************************************
    Apex Class Name : Core_Partner_Offering_Assignment
    Version     : 1.0 
    Created Date: 10th may, 2019 
    Description : Helper class for PMP_OfferingTriggerHandler
    * Modification Log :
    * Developer                 Date                        Description
    * ----------------------------------------------------------------------------
    * Sandip/Raushan/Usha                      10/05/2019                  Original Version
    *************************************************************************************/
    public class PMP_Offering_Sharing {

    static final LoggingLevel logLevel = LoggingLevel.DEBUG;
    static final String CORE_MP_STR = System.Label.PMP_Group_Name_Prefix;
    static final String RECORD_SHARE_ACCESS_LEVEL = 'Edit';
    static final String RECORD_SHARE_ACCESS_LEVEL_READ = 'Read';
    static final String PARTNER_CONTENT_VISIBILITY ='Partner Content'; 
    static final String PUBLISHED_Lifecycle_Status ='Published';
    static final String ALL_PARTNERS_ODM_GROUP = System.Label.PMP_Group_All_Partner_Users_ODM;
    static final String ALL_PARTNERS_NON_ODM_GROUP = System.Label.PMP_Group_All_Partner_Users_Non_ODM;
    static final String ALL_PARTNERS_GROUP = System.Label.PMP_Group_All_Partner_Users;
        
    public static void sharePartnerOfferingRecords(List<PMP_Partner_Offering__c> oldOfferingList, 
       List<PMP_Partner_Offering__c> newOfferingList){
           
           if(oldOfferingList != null && !newOfferingList.isEmpty()){
               //shareOfferingRecords(oldOfferingList,newOfferingList);
           }
           
           shareOfferingRecords(oldOfferingList,newOfferingList);
    }


   /***************************************************************************************************** 
    Method Name:   shareOfferingRecords                                          
    @return  :     Void
    Description: To share the partne offering record with pag group 
    ******************************************************************************************************/
    public static void shareOfferingRecords(List<PMP_Partner_Offering__c> oldOfferingList, List<PMP_Partner_Offering__c> newOfferingList){    

        List<Id> offeringIdVals = new List<Id>();
        Set<ID> setAccId=new Set<ID>();
        Map<Id, Id> workingOfferingCopyIdsToOwnerId = new Map<Id, Id>();
        try{
            
                List<PMP_Partner_Offering__Share> partOfferingShareList = new List<PMP_Partner_Offering__Share>();
            
        		//Map of working copy offering to company info id
                Map<Id,Id> workingCopyOfferingIdToCompanyInfoId = new Map<Id,Id>();
            
            	//Map of published copy offering to company info id
                Map<Id,Id> publishedCopyOfferingIdToCompanyInfoId = new Map<Id,Id>();
            
                // Iteration on offering records
                for(PMP_Partner_Offering__c offering : newOfferingList){
                    if(offering.PMP_Partner_Offering_Lifecycle_Status_Nm__c!=PUBLISHED_Lifecycle_Status && offering.PMP_Working_Copy_Id__c==Null){
                        	// working offering copy to owner id
                            workingOfferingCopyIdsToOwnerId.put(offering.Id , offering.OwnerId); 
                        
                        	// working offering copy to companyInfo Id
                            workingCopyOfferingIdToCompanyInfoId.put(offering.Id,offering.PMP_Company_Id__c);
                        	System.debug('workingCopyOfferingIdToCompanyInfoId ='+workingCopyOfferingIdToCompanyInfoId);
                                
                        }
                    
                	//Getting the offering where lifecycle status is published
                    else if(offering.PMP_Partner_Offering_Lifecycle_Status_Nm__c==PUBLISHED_Lifecycle_Status){
                        	//Map of published offering to companyinfo id
                             publishedCopyOfferingIdToCompanyInfoId.put(offering.Id,offering.PMP_Company_Id__c);
                        }
                    
                }
            
              //PI3 Changes
               Map<Id,Id> companyInfoIdToAccId = new Map<Id,Id>();
               Map<Id,Set<Id>> intelAccIdToOfferingId = new Map<Id,Set<Id>>();
               Map<Id,Id> publishedOfferingCompanyInfoIdToAccId = new Map<Id,Id>();
               Map<Id,Set<Id>> intelAccIdToPublishedOfferingId = new Map<Id,Set<Id>>();
                
            //Mapping of working copy company information to intel account id     
            for(PMP_Company__c companyInfoRec:[SELECT Id,PMP_Account_Id__c FROM PMP_Company__c WHERE Id IN:workingCopyOfferingIdToCompanyInfoId.values()]){
                		companyInfoIdToAccId.put(companyInfoRec.Id, companyInfoRec.PMP_Account_Id__c);
                		System.debug('companyInfoIdToAccId ='+companyInfoIdToAccId);
            		}
                
             //Mapping of published copy company information to intel account id     
             for(PMP_Company__c companyInfoRec:[SELECT Id,PMP_Account_Id__c FROM PMP_Company__c WHERE Id IN:publishedCopyOfferingIdToCompanyInfoId.values()]){
                		publishedOfferingCompanyInfoIdToAccId.put(companyInfoRec.Id, companyInfoRec.PMP_Account_Id__c);
            		}
            
           //Iterating working offering and mapping intel account to offeringids
            for(Id offeringId:workingCopyOfferingIdToCompanyInfoId.keySet()){
                
                	Id companyInfoId = workingCopyOfferingIdToCompanyInfoId.get(offeringId);
                	Id intelAccId = companyInfoIdToAccId.get(companyInfoId);
                	
                		if(intelAccIdToOfferingId.get(intelAccId)!=null){
                    		intelAccIdToOfferingId.get(intelAccId).add(offeringId);
                		}else{
                            //intelAccount to working offering id map
                    		intelAccIdToOfferingId.put(intelAccId,new Set<Id>{offeringId});
                		}
                	
            	}
            
                System.debug('intelAccIdToOfferingId ='+intelAccIdToOfferingId);
            
           /************ Set Is Odm true by looking at the mda account biz org type************************/
            
            List<PMP_Partner_Offering__c> odmOfferingToBeUpdated = new List<PMP_Partner_Offering__c>();
            String bizOrgLabelValues = System.Label.PMP_Biz_Org_ODM_Values ;
        	List<String> bizOrgLabelValuesSplit = bizOrgLabelValues.split(';');
            Map<Id,Set<Id>> odmAccountIdToOfferingIdMap = new Map<Id,Set<Id>>();
            System.debug('bizOrgLabelValuesSplit ='+bizOrgLabelValuesSplit);
            
            for(Account acc:[SELECT Id,Name,Core_Account_Type__c FROM Account WHERE Id IN: intelAccIdToOfferingId.keySet()]){
                
                for(String typeVal:bizOrgLabelValuesSplit){
                    	if(acc.Core_Account_Type__c != null && acc.Core_Account_Type__c.contains(typeVal)){
                            if(odmAccountIdToOfferingIdMap.get(acc.Id)!=null){
                            	odmAccountIdToOfferingIdMap.get(acc.Id).addAll(intelAccIdToOfferingId.get(acc.Id));
                        	}else{
                            	odmAccountIdToOfferingIdMap.put(acc.Id,intelAccIdToOfferingId.get(acc.Id));
                        	}
                            break;
                    	}
                	}
                    /*if(bizOrgLabelValuesSplit.contains(acc.Core_Account_Type__c)){
                        system.debug('acc.Core_Account_Type__c ='+acc.Core_Account_Type__c);
                        if(odmAccountIdToOfferingIdMap.get(acc.Id)!=null){
                            odmAccountIdToOfferingIdMap.get(acc.Id).addAll(intelAccIdToOfferingId.get(acc.Id));
                        }else{
                            odmAccountIdToOfferingIdMap.put(acc.Id,intelAccIdToOfferingId.get(acc.Id));
                        }
                    }*/
            	}
            System.debug('odmAccountIdToOfferingIdMap ='+odmAccountIdToOfferingIdMap);
            Set<Id> odmOfferingIds = new Set<Id>();
            for(Set<Id> offeringId:odmAccountIdToOfferingIdMap.Values()){
                odmOfferingIds.addAll(offeringId);
            }
            
            for(PMP_Partner_Offering__c offering: [SELECT Id,Name,PMP_Is_ODM_Ind__c FROM PMP_Partner_Offering__c WHERE Id IN: odmOfferingIds ]){
                offering.PMP_Is_ODM_Ind__c = true;
                odmOfferingToBeUpdated.add(offering);
            }
            
            System.debug('odmOfferingToBeUpdated='+odmOfferingToBeUpdated);
            
            if(odmOfferingToBeUpdated!=null && !odmOfferingToBeUpdated.isEmpty()){
                // Udating is odm flag on offering record
                Update(odmOfferingToBeUpdated);
           	 }
        //Is odm flag set done
        
                // Mapping of intelAccId to published offering id
                for(Id offeringId:publishedCopyOfferingIdToCompanyInfoId.keySet()){
                
                        Id companyInfoId = publishedCopyOfferingIdToCompanyInfoId.get(offeringId);
                        Id intelAccId = publishedOfferingCompanyInfoIdToAccId.get(companyInfoId);
                	
                		if(intelAccIdToPublishedOfferingId.get(intelAccId)!=null){
                    		intelAccIdToPublishedOfferingId.get(intelAccId).add(offeringId);
                		}else{
                            //Intel Account id to published offering id map
                    		intelAccIdToPublishedOfferingId.put(intelAccId,new Set<Id>{offeringId});
                		}
                	
            	}
  
            Map<Id,Id> intelAccIdToPartnerAccId = new Map<Id,Id>();
            
            for(Core_Account_Group_Member__c pagRecord:[SELECT Core_MDA_Ind__c, Core_Partner_Account_Id__c, Core_Intel_Account_Id__c 
                										FROM Core_Account_Group_Member__c where Core_Intel_Account_Id__c 
                                                        IN : intelAccIdToOfferingId.keySet()]){  //offeringIdToIntelAccId.Values()
                    // Intel Account Id to partnerAccId of working copy                                   
                	intelAccIdToPartnerAccId.put(pagRecord.Core_Intel_Account_Id__c,pagRecord.Core_Partner_Account_Id__c); 
                
           		 }
  
            Map<Id,Id> publishedOfferingIntelAccIdToPartnerAccId = new Map<Id,Id>();
                
            // Mapping of published offering intel account id to partner account id
            for(Core_Account_Group_Member__c pagRecord:[SELECT Core_MDA_Ind__c, Core_Partner_Account_Id__c, Core_Intel_Account_Id__c 
                										FROM Core_Account_Group_Member__c where Core_Intel_Account_Id__c 
                                                        IN : intelAccIdToPublishedOfferingId.keySet()]){
                        System.debug('pagRecord ='+pagRecord); 
                        // Intel Account Id to partnerAccId of published copy                                     
                 		publishedOfferingIntelAccIdToPartnerAccId.put(pagRecord.Core_Intel_Account_Id__c,pagRecord.Core_Partner_Account_Id__c); 
                
            }
  
            
            Map<String,Set<Id>> devNameToOfferingIdMap = new Map<String,Set<Id>>();

            for(Id intelAccId:intelAccIdToOfferingId.keySet()){
                Id partAccId = intelAccIdToPartnerAccId.get(intelAccId);
                Set<Id> offeringIds = intelAccIdToOfferingId.get(intelAccId);
                String grpName = null;
                grpName = CORE_MP_STR+partAccId;
                
                for(Id offrId:offeringIds){
                    if(devNameToOfferingIdMap.get(grpName)!=null){
                    	devNameToOfferingIdMap.get(grpName).add(offrId);
                	}else{
                        // Developer name to offering id map for working copy
                    	devNameToOfferingIdMap.put(grpName,new Set<Id>{offrId});
                	}
                }
                
                
            }
            //System.debug('devNameToOfferingIdMap ='+devNameToOfferingIdMap);
            
            // Mapping of developer name to published offering id map
            Map<String,Set<Id>> devNameToPublishedOfferingIdMap = new Map<String,Set<Id>>();

            for(Id intelAccId:intelAccIdToPublishedOfferingId.keySet()){
                Id partAccId = publishedOfferingIntelAccIdToPartnerAccId.get(intelAccId);
                Set<Id> offeringIds = intelAccIdToPublishedOfferingId.get(intelAccId);
                String grpName = null;
                grpName = CORE_MP_STR+partAccId;
                
                for(Id offrId:offeringIds){
                    if(devNameToPublishedOfferingIdMap.get(grpName)!=null){
                    	devNameToPublishedOfferingIdMap.get(grpName).add(offrId);
                	}else{
                        // DeveloperName to published offering id 
                    	devNameToPublishedOfferingIdMap.put(grpName,new Set<Id>{offrId});
                	}
                }
            }

            Map<String,Id> grpDevNameToGrpId = new Map<String,Id>();
            Map<Id,Id> groupIdToOwnerId = new Map<Id,Id>();
            Map<Id,Set<Id>> grpIdToOfferingId = new Map<Id,Set<Id>>();
            
            //For working copy
            for(Group grp:[SELECT Id,DeveloperName FROM Group WHERE DeveloperName IN:devNameToOfferingIdMap.keySet()]){
                grpDevNameToGrpId.put(grp.DeveloperName,grp.Id);
                Set<Id> OfferingId = devNameToOfferingIdMap.get(grp.DeveloperName);
                
                // Group id working Copy id map
                grpIdToOfferingId.put(grp.Id,OfferingId);
            }
            
           
                
            //Mapping of group developer name to group id for published offering
            Map<String,Id> grpDevNameToGrpIdForPublishedOffering = new Map<String,Id>();
            
            //Map of grpid to published offering 
            Map<Id,Set<Id>> grpIdToPublishedOfferingId = new Map<Id,Set<Id>>();
            
            for(Group grp:[SELECT Id,DeveloperName FROM Group WHERE DeveloperName IN:devNameToPublishedOfferingIdMap.keySet()]){
                grpDevNameToGrpIdForPublishedOffering.put(grp.DeveloperName,grp.Id);
                Set<Id> OfferingId = devNameToPublishedOfferingIdMap.get(grp.DeveloperName);
                
                //groupIds where published offering to be shared
                grpIdToPublishedOfferingId.put(grp.Id,OfferingId);
            } 
                
            for(Id grpId:grpIdToPublishedOfferingId.keySet()){
                		Set<Id> offeringId = grpIdToPublishedOfferingId.get(grpId);
                for(Id offrId:offeringId){
                    	PMP_Partner_Offering__Share partOfferingShare = new PMP_Partner_Offering__Share();

                                    partOfferingShare.AccessLevel  = RECORD_SHARE_ACCESS_LEVEL_READ;
                                    partOfferingShare.UserOrGroupId  = GrpId;
                                    partOfferingShare.ParentId = offrId;
                    
                    				//List of published offering has to be shared with pag group
                                    partOfferingShareList.add(partOfferingShare);
                	}
             }
            
             /********************PI3I2 changes***************************************/     
            // Working copy sharing
            for(Id intelAccId:intelAccIdToOfferingId.keySet()){
                	if(intelAccId!=null){

                				Id partnerAccId = intelAccIdToPartnerAccId.get(intelAccId);
                				String groupName = CORE_MP_STR+partnerAccId;
                        		Id GrpId = grpDevNameToGrpId.get(groupName);
                        Set<Id> offeringIds= intelAccIdToOfferingId.get(intelAccId);
                        
                        for(Id offeringId:offeringIds){
                            	PMP_Partner_Offering__Share partOfferingShare = new PMP_Partner_Offering__Share();
                        
                        		if(GrpId	!=null){
                                    partOfferingShare.AccessLevel  = RECORD_SHARE_ACCESS_LEVEL;
                                    partOfferingShare.UserOrGroupId  = GrpId;
                                    partOfferingShare.ParentId = offeringId;
                                    
                                    // List of working copy offering to be shared
                                    partOfferingShareList.add(partOfferingShare);
                        		}
                        		
                        	}
                	 		
                        		
                		}
                	
                
            	}

            //Map<Id,Id> PmpGrpIdToGlobalGrpId  = new Map<Id,Id>();
           // Map<Id,Set<Id>> globalGrpIdToOfferingId = new Map<Id,Set<Id>>();
                     	/*for(GroupMember grpOfGrpMem:[SELECT Id, GroupId, UserOrGroupId FROM GroupMember WHERE UserOrGroupId IN:grpDevNameToGrpId.Values()]){//IN:grpDevNameToGrpId.Values()
                            System.debug('grpOfGrpMem ='+grpOfGrpMem);
                            PmpGrpIdToGlobalGrpId.put(grpOfGrpMem.UserOrGroupId,grpOfGrpMem.GroupId);
                            Set<Id> offeringId = grpIdToOfferingId.get(grpOfGrpMem.UserOrGroupId);
                            System.debug('offeringId inside ='+offeringId);
                            if(globalGrpIdToOfferingId.get(grpOfGrpMem.GroupId)!=null){
                                globalGrpIdToOfferingId.get(grpOfGrpMem.GroupId).addAll(offeringId);
                            }else{
                                 globalGrpIdToOfferingId.put(grpOfGrpMem.GroupId,offeringId);
                            }
                            
                            //globalGrpIdToOfferingId.put(grpOfGrpMem.GroupId,offeringId);
                            System.debug('globalGrpIdToOfferingId inside ='+globalGrpIdToOfferingId);
           		 		}*///End of PI3I2
               //System.debug('globalGrpIdToOfferingId ='+globalGrpIdToOfferingId);
             
            /******************************* Owner Based sharing  ********************************************/
            for(GroupMember grp:[SELECT Id, GroupId, UserOrGroupId FROM GroupMember WHERE UserOrGroupId IN:workingOfferingCopyIdsToOwnerId.values()]){
           			 groupIdToOwnerId.put(grp.GroupId,grp.UserOrGroupId);
       		 	}
                         
        	Map<Id,Id> ownerIdToGrpOfGrpIdsMap= new Map<Id,Id>();
            
        	for(GroupMember grpOfGrp:[SELECT Id, GroupId, UserOrGroupId FROM GroupMember WHERE UserOrGroupId IN:groupIdToOwnerId.keyset()]){
            	ownerIdToGrpOfGrpIdsMap.put(groupIdToOwnerId.get(grpOfGrp.UserOrGroupId),grpOfGrp.GroupId);  
        	}//PI2
            
           String ownerId =null;
       	   String GroupId =null;
            
        List<PMP_Partner_Offering__c> offerings = [SELECT Id,Name, PMP_Partner_Offering_Nm__c FROM PMP_Partner_Offering__c WHERE Id IN:workingCopyOfferingIdToCompanyInfoId.keySet()];
            System.debug('offerings ='+offerings);
        List<PMP_Partner_Offering__c> offeringToBeUpdated = new List<PMP_Partner_Offering__c>();
        
           /* for(Id grpId:globalGrpIdToOfferingId.Keyset()){
                Set<Id> offeringIds = globalGrpIdToOfferingId.get(grpId);
                for(PMP_Partner_Offering__c offeringRecord:offerings){
                    
                    for(Id offeringRecordId:offeringIds){
                        if(offeringRecordId ==offeringRecord.Id){
                            
                        if(grpId ==ALL_PARTNERS_ODM_GROUP){
                            
                            offeringRecord.PMP_Is_ODM_Ind__c = true;
                            offeringToBeUpdated.add(offeringRecord);
                    	}else if(grpId ==ALL_PARTNERS_NON_ODM_GROUP){
                            offeringRecord.PMP_Is_ODM_Ind__c = false;
                            offeringToBeUpdated.add(offeringRecord);
                    }
                            
                        }
                    }
                }
            }*/
            /*System.debug('offeringToBeUpdated='+offeringToBeUpdated);
            if(offeringToBeUpdated!=null && !offeringToBeUpdated.isEmpty()){
                //Update(offeringToBeUpdated);
            }*/
            
            // end of PI3I2 changes
				            
            
        //Get all intel accounts
        List<User> ownerUsers = new List<User>([SELECT AccountId,Id  FROM User where Id in :workingOfferingCopyIdsToOwnerId.values()]); 
        
        Map<Id, Id> accIdToUserIdMap = new Map<Id, Id>();
        
        for(User ownerUser: ownerUsers){
            setAccId.add(ownerUser.AccountID); // Get All AccountIds
            accIdToUserIdMap.put(ownerUser.AccountID, ownerUser.Id);
        }

        //get all the Partner Accounts      
        List<Core_Account_Group_Member__c> partnerAccountGrpmembers = new List<Core_Account_Group_Member__c>(
            [SELECT Core_MDA_Ind__c, Core_Partner_Account_Id__c, Core_Intel_Account_Id__c 
             FROM Core_Account_Group_Member__c where Core_Intel_Account_Id__c in : setAccId]) ;
        
        Map<Id, Id> accIdToPartnerAccIdMap = new Map<Id, Id>();
        for(Core_Account_Group_Member__c coreAccGrpMember : partnerAccountGrpmembers){
            //Account Id to partner Account id map
            accIdToPartnerAccIdMap.put(coreAccGrpMember.Core_Intel_Account_Id__c,coreAccGrpMember.Core_Partner_Account_Id__c);
        }

        Map<Id, Set<Id>> partnerAccIdUserIdsMap = new Map<Id, Set<Id>> ();
        
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
        
        System.debug(logLevel , 'partnerAccIdUserIdsMap = '+ partnerAccIdUserIdsMap);
        String publicGroupName = '';
        List<String> publicGroupNameToBeAdded = new List<String>();
        For(Id partnerAccountId : partnerAccIdUserIdsMap.keyset()){
            publicGroupName = CORE_MP_STR + partnerAccountId;
            publicGroupNameToBeAdded.add(publicGroupName); 
        }
        
        //Create the public group if it doesn't exist
        List<Group> queriedGrps = PMP_Batch_Group_Management.createPublicGroups(publicGroupNameToBeAdded);

        Map<Id, Set<Id>> partnerAccIdToOfferingIdsMap = new Map<Id, Set<Id>>();
        
        for(Id offeringOwnerId : workingOfferingCopyIdsToOwnerId.keySet()){
            Id userId = workingOfferingCopyIdsToOwnerId.get(offeringOwnerId);
            for(Id partnerAccId : partnerAccIdUserIdsMap.keySet()){
                Set<Id> userIds = partnerAccIdUserIdsMap.get(partnerAccId);
                System.debug('userIds ='+userIds);
                for(Id userIdRec : userIds){
                    if(userIdRec == userId){
                        if(partnerAccIdToOfferingIdsMap.get(partnerAccId) == null){
                            Set<Id> offeringIds = new Set<Id>();
                            offeringIds.add(offeringOwnerId);
                            partnerAccIdToOfferingIdsMap.put(partnerAccId,offeringIds);
                        }else if(partnerAccIdToOfferingIdsMap.get(partnerAccId) != null){
                            Set<Id> offeringIds = partnerAccIdToOfferingIdsMap.get(partnerAccId);
                            if(!offeringIds.isEmpty()){
                                offeringIds.add(offeringOwnerId);
                                //partner Account Id to Offering Id map
                                partnerAccIdToOfferingIdsMap.put(partnerAccId,offeringIds); 
                            }
                        }
                    }
                }
            }
            
        }

        Map<String, Id> groupDevNameToGrpId = new Map<String, Id>();
        for(Group groupRec : queriedGrps){
            groupDevNameToGrpId.put(groupRec.DeveloperName , groupRec.Id);
        }
        
        Map<Id, Set<Id>> groupIdToOfferingIds = new Map<Id, Set<Id>>();
        for(Id partnerAccId : partnerAccIdToOfferingIdsMap.keySet()){
            Set<Id> offeringIds = partnerAccIdToOfferingIdsMap.get(partnerAccId);
            if(offeringIds != null && !offeringIds.isEmpty()){
                String groupDevName = CORE_MP_STR + partnerAccId;
                if(!String.isBlank(groupDevName)){
                    Id grpIdRec = groupDevNameToGrpId.get(groupDevName);
                    if(grpIdRec != null){
                        groupIdToOfferingIds.put(grpIdRec, offeringIds);   
                    }       
                }
            }
        }

        //SELECT AccessLevel,Id,IsDeleted,ParentId,RowCause,UserOrGroupId FROM PMP_Partner_Offering__Share
        //List<PMP_Partner_Offering__Share> partOfferingShareList = new List<PMP_Partner_Offering__Share>();
        
        if(groupIdToOfferingIds !=null && !groupIdToOfferingIds.isEmpty()){
            for(Id groupIdRecord : groupIdToOfferingIds.keySet()){
                Set<Id> offeringIds = groupIdToOfferingIds.get(groupIdRecord);
                if(offeringIds != null && !offeringIds.isEmpty()){
                    for(Id offeringRecordId : offeringIds){
                        PMP_Partner_Offering__Share partOfferingShare = new PMP_Partner_Offering__Share();
                        partOfferingShare.AccessLevel  = RECORD_SHARE_ACCESS_LEVEL;
                        partOfferingShare.UserOrGroupId  = groupIdRecord;
                        partOfferingShare.ParentId = offeringRecordId;
                        //offering list to be shared
                        partOfferingShareList.add(partOfferingShare);
                    }
                }
            }
        } // Owner based sharing completed
            
            if(partOfferingShareList != null && !partOfferingShareList.isEmpty()){
               //Inserting partner offering share records
               Database.insert(partOfferingShareList);
            }

            System.debug('Queueable count ='+Limits.getQueueableJobs());
    
    }catch(Exception genException){
        String exceptionMessage = genException.getTypeName() + ': ' + genException.getMessage() + ', ' + genException.getStackTraceString();
        System.debug('##### Exception: ' + exceptionMessage);
                   
        } 
    }
    }