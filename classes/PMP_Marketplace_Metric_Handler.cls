/**************************************************************************************
Apex Class Name : PMP_PAG_Dashboard_Handler
Version     : 1.0 
Description : Handler class for PMP_PAG_Dashboard_Batch where we are checking all the group related functinalities working properly or not and taking the count of mismatches and displaying on the dashboard 
* Modification Log :
* Developer                 Date                     Description
* ----------------------------------------------------------------------------
* Raushan                                			Original Version
*************************************************************************************/




public without sharing class PMP_Marketplace_Metric_Handler {  //SCRTY_PAG_Dashboard_Handler

	/**************** Method to check public groups are being created or not********************/
    public static void pagGroupValidation(){
        
		//Getting Partner account Id
        String partnerAccRecTypeId = System.Label.PMP_Partner_Account_Record_Type_Id;
        Set<String> partnerGroups = new Set<String>();
        Set<Id> partnerAccIds = new Set<Id>();
		
		// Map of pag dashboard record to sobject
        Map<String,PMP_Marketplace_Metric__c> pagRecNameToObjMap = new Map<String,PMP_Marketplace_Metric__c>();
		
		// Getting Pag Dashboards Record type id
		//Id pagDashboardRecTypeId = Schema.SObjectType.PMP_Marketplace_Metric__c.getRecordTypeInfosByName().get('Pag Dashboards').getRecordTypeId();
		
		
		
		// Forming List of expected pag
        for(Core_Account_Group_Member__c acc:[SELECT Id, Core_Partner_Account_Id__c, Core_MDA_Ind__c, Core_Intel_Account_Id__c, Core_Inactive_Ind__c 
						 FROM Core_Account_Group_Member__c WHERE Core_Partner_Account_Id__c 
                         IN (Select Id FROM Account WHERE RecordTypeId = :partnerAccRecTypeId) AND Core_MDA_Ind__c =true]){ //SELECT Id, Name,RecordTypeId FROM Account WHERE RecordTypeId 		//=:partnerAccRecTypeId
            String grpName =null;
            	if(acc.Core_Partner_Account_Id__c!=null ){
                            grpName = System.Label.PMP_Group_Name_Prefix+acc.Core_Partner_Account_Id__c;
                            partnerAccIds.add(acc.Core_Partner_Account_Id__c);
                            //Expected partner groups
                            partnerGroups.add(grpName);         
               			}
           /* grpName = System.Label.PMP_Group_Name_Prefix+acc.Core_Partner_Account_Id__c;
            partnerAccIds.add(acc.Core_Partner_Account_Id__c);
			//Expected partner groups
            partnerGroups.add(grpName);*/
        }
        System.debug('count of partner account ids ='+partnerAccIds.size());
        System.debug('Count of partner groups ='+partnerGroups.size());
        Set<String> grpDevNames = new Set<String>();
        // Forming List of existing pags
        //for(Group grp:[SELECT Id, DeveloperName FROM Group WHERE DeveloperName LIKE 'PMP_%']){
        for(Group grp:[SELECT Id, DeveloperName FROM Group WHERE DeveloperName LIKE 'PMP_%' order by CreatedDate desc limit 49990]){
            String grpName = grp.DeveloperName;
            grpName = grpName.left(22);
            grpDevNames.add(grpName);

        }
        
		
        List<string> missingGrps=new List<string>();
        Integer countOfMismatch = 0;
        Integer countOfRecProcessed = 0;
        
		// Getting count of missing Group
        for(string grpname : partnerGroups){
            countOfRecProcessed++;
            if(!grpDevNames.contains(grpname)){
                countOfMismatch++;
               // System.debug('missed groups='+grpname);
                missingGrps.add(grpname);
                
            }  
            
        }
        
		// Forming Map of pagdashboard rec to pag dashboard object
		for(PMP_Marketplace_Metric__c getPagRec: [Select Id,Name,PMP_Metric_Nm__c,PMP_Metric_API_Nm__c,PMP_Mismatch_Cnt__c, PMP_Total_Cnt__c From 
                                                  PMP_Marketplace_Metric__c LIMIT 49999] ){
			pagRecNameToObjMap.put(getPagRec.PMP_Metric_API_Nm__c,getPagRec);
		}
			
	    
		List<PMP_Marketplace_Metric__c> dashboardRecToUpdate = new List<PMP_Marketplace_Metric__c>();
		if(pagRecNameToObjMap.containsKey('METRIC_PAG_NOT_CREATED') ){
           
				PMP_Marketplace_Metric__c getPagRec = pagRecNameToObjMap.get('METRIC_PAG_NOT_CREATED');
                getPagRec.PMP_Mismatch_Cnt__c = countOfMismatch;
            	getPagRec.PMP_Total_Cnt__c = countOfRecProcessed;
				dashboardRecToUpdate.add(getPagRec);
            
			
		}
	
		

		
        // Calling checkAcctSharing method
        checkAcctSharing(partnerAccIds,pagRecNameToObjMap,dashboardRecToUpdate);
		//calling odmNonOdmCheck method
        odmNonOdmCheck(partnerAccIds,pagRecNameToObjMap,dashboardRecToUpdate);
		//Calling leadGroupValidation method
		leadGroupValidation(partnerAccIds,pagRecNameToObjMap,dashboardRecToUpdate); 
		// Calling contactSegmentGroupValidation method
        contactSegmentGroupValidation(partnerAccIds,pagRecNameToObjMap,dashboardRecToUpdate); 
		// Calling validateMainGrpUsrs method
        validateMainGrpUsrs(partnerAccIds,pagRecNameToObjMap,dashboardRecToUpdate); 
		
		// Updating dashboard record
		if(dashboardRecToUpdate.size()!=null){
            Database.SaveResult[] results = Database.update(dashboardRecToUpdate, false);
            PMP_Utility.logDmlErrors((Object[]) results, 'PMP_Marketplace_Metric_Handler-pagGroupValidation');
			//Database.update(dashboardRecToUpdate);
		}

    }
	
	
    /*********************************** Method to check the partner account sharing *********************************/
    public static void checkAcctSharing(Set<Id> partnerAccIds, Map<String,PMP_Marketplace_Metric__c> pagRecNameToObjMap,List<											PMP_Marketplace_Metric__c> dashboardRecToUpdate){
        
		// Map of existing partner account
        Map<Id,Set<String>> accIdToGrpName = new Map<Id,Set<String>>();
		
        for(AccountShare acc:[SELECT Id, AccountId, UserOrGroup.Name, AccountAccessLevel FROM AccountShare WHERE AccountId IN:partnerAccIds ]){
            
            
            
                if(accIdToGrpName.get(acc.AccountId)!=null){
                    if(acc.UserOrGroup.Name!=null){
                        
                        accIdToGrpName.get(acc.AccountId).add(acc.UserOrGroup.Name);
                    }
                        
            		}else{
                        if(acc.UserOrGroup.Name!=null){
                            
                        	accIdToGrpName.put(acc.AccountId,new Set<String>{acc.UserOrGroup.Name});
                        }
                        
            	}
            
        }
        
        
		Integer countOfAcctNotShared = 0;
        Integer countOfAcctWronglyShared = 0;
        Integer countOfAcctProcessed = 0;
        
		// Iterated partner Account id
        for(Id accId:accIdToGrpName.keySet()){
            
            countOfAcctProcessed++;
            String accountGrp = null;
            accountGrp =System.Label.PMP_Group_Name_Prefix+accId;
            Set<String> GrpDevName =null;
            GrpDevName = accIdToGrpName.get(accId);
            GrpDevName.addAll(GrpDevName);
            System.debug('GrpDevName ='+GrpDevName);
            
            if(!GrpDevName.contains(accountGrp)){
                countOfAcctNotShared++;
                System.debug('Account which is not shared ='+accId);
            }
            
            for(String str:GrpDevName){
                String accIdFromGrpDevName;
                if(str.startsWith(System.Label.PMP_Group_Name_Prefix)){
                   System.debug('str='+str);
                   accIdFromGrpDevName = str.right(18);
                    
                	if(accId!=accIdFromGrpDevName){
                        countOfAcctWronglyShared++;
                		System.debug('wrong Sharing for account ='+accId);
                    	
           		 	} 
                }
                
            }// End of nested for loop
          
        }// End of for loop
		
		
        // if pagRecNameToObjMap contains PMP_Partner_Acct_Not_Shared then then update the dashboard record
        if(pagRecNameToObjMap.containsKey('METRIC_PARTNER_ACCT_NOT_SHARED') ){
           
  
				PMP_Marketplace_Metric__c getPagRec = pagRecNameToObjMap.get('METRIC_PARTNER_ACCT_NOT_SHARED');
                
                getPagRec.PMP_Mismatch_Cnt__c = countOfAcctNotShared;
            	getPagRec.PMP_Total_Cnt__c = countOfAcctProcessed;
            
				dashboardRecToUpdate.add(getPagRec);
				
            
            
		}
        
		// if pagRecNameToObjMap contains PMP_Partner_Acct_Wrongly_Shared then then update the dashboard record
        if(pagRecNameToObjMap.containsKey('METRIC_PARTNER_ACCT_WRONGLY_SHARED')){
				System.debug('coming in wrong sharing');
				PMP_Marketplace_Metric__c getRec = pagRecNameToObjMap.get('METRIC_PARTNER_ACCT_WRONGLY_SHARED');
				
				getRec.PMP_Mismatch_Cnt__c = countOfAcctWronglyShared;
            	getRec.PMP_Total_Cnt__c = countOfAcctProcessed;
				dashboardRecToUpdate.add(getRec);
				
				
			}
        
    }
    
	
	/**************************************** Validate the page group has the correct users or not*********************************************/
    public static void validateMainGrpUsrs(Set<Id> partnerAccIds, Map<String,PMP_Marketplace_Metric__c> pagRecNameToObjMap,List<											PMP_Marketplace_Metric__c> dashboardRecToUpdate){
        
        Map<Id,Set<Id>> partnerAccIdToIntelAccIds = new Map<Id,Set<Id>>();
        Set<Id> intelAccIds = new Set<Id>();
        
        
        // Creating a map of partner account to set of their intel account
        for(Core_Account_Group_Member__c partnerAcc : [Select Id,Core_Partner_Account_Id__c,Core_Intel_Account_Id__c FROM Core_Account_Group_Member__c WHERE 
                                                        Core_Partner_Account_Id__c IN :partnerAccIds]){  
                                                            
            if(partnerAccIdToIntelAccIds.get(partnerAcc.Core_Partner_Account_Id__c)!=null){
                 partnerAccIdToIntelAccIds.get(partnerAcc.Core_Partner_Account_Id__c).add(partnerAcc.Core_Intel_Account_Id__c);
              }
            else{
                  // Map Of partner accounts to intel accounts
                  partnerAccIdToIntelAccIds.put(partnerAcc.Core_Partner_Account_Id__c,new Set<Id>{partnerAcc.Core_Intel_Account_Id__c});
                }
                                                                
        }//End of for
        
        // Getting all the intelAccount ids in a set
        for(Set<Id> intelAcc:partnerAccIdToIntelAccIds.Values()){
            if(intelAcc!=null){
                intelAccIds.addAll(intelAcc);
            }
        }//end of for
        
        Map<Id,Set<Id>> intelAccIdToContactIds = new Map<Id,Set<Id>>();
        //Fetching all the mp entitlements 
        String Core_Entitlement_Id_Label = System.Label.PMP_External_Entitlement_Ids;
        
        List<String> lstMpEntIds = new List<String>();
        lstMpEntIds = Core_Entitlement_Id_Label.split(';'); 
        
        Set<Id> intelContactIds = new Set<Id>();
        
        //Getting all the intel contact ids in a set
        for(Contact con:[Select Id,Name,AccountId From Contact Where AccountId IN :intelAccIds]){
            intelContactIds.add(con.Id);
        }
        
        // Logic to have a map of intel account to their mp contacts 
        for(Core_Contact_Entitlement__c cont: [SELECT Id, Core_Contact_Id__c,Core_Entitlement_Id__c,Core_Selected__c,Core_Status__c,
                                               Core_Contact_Id__r.AccountId FROM Core_Contact_Entitlement__c WHERE Core_Contact_Id__c 
                                               IN : intelContactIds AND Core_Entitlement_Id__c IN:lstMpEntIds AND Core_Selected__c=true AND 
                                               Core_Status__c='Complete' ]){
                                                   
            
            if(cont!=null){
                if(intelAccIdToContactIds.containsKey(cont.Core_Contact_Id__r.AccountId)){
                	intelAccIdToContactIds.get(cont.Core_Contact_Id__r.AccountId).add(cont.Core_Contact_Id__c);
            	}
            	else{
                    //Intel Accounts to marketplce entitled contactids map 
                intelAccIdToContactIds.put(cont.Core_Contact_Id__r.AccountId,new Set<Id>{cont.Core_Contact_Id__c});
            	}
            }
        }// End of for loop
        
        
        
        Map<Id,Set<Id>> partnerAccToAllConts = new Map<Id,Set<Id>>();
        
        // Logic to have a map of partneraccount to their all mp partner contact ids
        for(Id partnerAccId:partnerAccIdToIntelAccIds.keySet()){
            	Set<Id> allContactIds =new Set<Id>();
                Set<Id> intelAcc =null;
                intelAcc = partnerAccIdToIntelAccIds.get(partnerAccId);
            
            if(intelAcc!=null){
                
                for(Id accId:intelAcc){
                    Set<Id> contactIds =null;
                    contactIds = intelAccIdToContactIds.get(accId);
                    
                    if(contactIds!=null){
                        allContactIds.addAll(contactIds);
                    }
                }
                
                if(allContactIds!=null){
                    //Map of partner Account to all intel contacts under it
                    partnerAccToAllConts.put(partnerAccId,allContactIds);
                    
                }
                //allContactIds = null;
        	} 
        }//End of for
        
        
        Set<Id> conIds = new Set<Id>();
        //Get all the contact ids in a set
        for(Set<Id> conId : partnerAccToAllConts.Values()){
            conIds.addAll(conId);
        }
        
        Map<Id,Id> partnerConToPartnerUserMap = new Map<Id,Id>();
        // Logic to have a map of partner account to all their mp partner users
        for(User u:[Select Id,ContactId FROM User WHERE ContactId IN:conIds]){
            partnerConToPartnerUserMap.put(u.ContactId, u.Id);
        }
        
        Map<String,Set<Id>> partnerAccGrpToPartnerUserMap = new Map<String,Set<Id>>();
        Set<String> partnerGroups = new Set<String>();
        
        // Logic to have a map of expected partner account group with their users
        for(Id partnerAccId:partnerAccToAllConts.keySet()){
            Set<Id> partnerConIds = null;
            partnerConIds = partnerAccToAllConts.get(partnerAccId);
            
            String grpName =null;
            grpName = System.Label.PMP_Group_Name_Prefix+partnerAccId;
            partnerGroups.add(grpName);
            if(partnerConIds!=null){
                Set<Id> userIds = new Set<Id>();
                for(Id conId:partnerConIds){
                    
                    Id userId = partnerConToPartnerUserMap.get(conId);
                    userIds.add(userId);
                    
                }
                
            partnerAccGrpToPartnerUserMap.put(grpName,userIds);
        	}
        }// End of for loop
		
        
        Map<String,Set<Id>> grpNameToGrpUsersMap = new Map<String,Set<Id>>();
        
        // forming a map of existing groups with their groupmembers
        for(GroupMember gm:[SELECT Id, GroupId, Group.Name,UserOrGroupId FROM GroupMember WHERE Group.Name IN :partnerGroups]){
            
            if(gm != null){
                if(grpNameToGrpUsersMap.containsKey(gm.Group.Name)){
                	grpNameToGrpUsersMap.get(gm.Group.Name).add(gm.UserOrGroupId);
            	}
            	else{
                    //GroupName to group users map
                	grpNameToGrpUsersMap.put(gm.Group.Name,new Set<Id>{gm.UserOrGroupId});
            	}
            }
            
        }//end of for loop
        
		Integer CountOfUserNotAddedInPag = 0;
        Integer CountOfNonElgUserAddedInPag = 0;
		Set<Id> allPagUsers = new Set<Id>();
        // Main logic to check whether account has extra user of groups has extra users
        for(String grpName:partnerAccGrpToPartnerUserMap.keySet()){
            
            if(grpNameToGrpUsersMap.containsKey(grpName)){
               Set<Id> acctHasAllExtraUsers = New Set<Id>();
               Set<Id> grpHasAllExtraUsers = New Set<Id>();
               Set<Id> acctHasExtraUsers = partnerAccGrpToPartnerUserMap.get(grpName);
			   allPagUsers.addAll(acctHasExtraUsers);
               Set<Id> grpHasExtraUsers  = grpNameToGrpUsersMap.get(grpName);
                
               acctHasAllExtraUsers.addAll(acctHasExtraUsers);
               grpHasAllExtraUsers.addAll(grpHasExtraUsers);
               
               acctHasAllExtraUsers.removeAll(grpNameToGrpUsersMap.get(grpName));
               grpHasAllExtraUsers.removeAll(partnerAccGrpToPartnerUserMap.get(grpName));

               System.debug('size of grpHasAllExtraUsers= '+grpHasAllExtraUsers.size());
                
                if(acctHasAllExtraUsers.size()!=0){
                    for(Id userId:acctHasAllExtraUsers){
						//CountOfUserNotAddedInPag ++;
						CountOfNonElgUserAddedInPag ++;
                        System.debug('Partner Account =' + grpName.remove(System.Label.PMP_Group_Name_Prefix) +' has extra users ='+userId +' Which are not there in group');
                    }
                    
                }
                
                if(grpHasAllExtraUsers.size()!=0){
                    for(Id userId:grpHasAllExtraUsers){
                        System.debug('Hello');
                        CountOfUserNotAddedInPag ++;
                        //CountOfNonElgUserAddedInPag ++;
                        System.debug('Group =' + grpName +' has extra users ='+userId +' Which are not there in Account');
                    }
                    
                }

            }
        }// End of for loop
        
		
		
		
        
        if(pagRecNameToObjMap.containsKey('METRIC_WRONGLY_ADDED_USER_IN_PARTNER_GRP') ){
           
  
				PMP_Marketplace_Metric__c getPagRec = pagRecNameToObjMap.get('METRIC_WRONGLY_ADDED_USER_IN_PARTNER_GRP');
                
                getPagRec.PMP_Mismatch_Cnt__c = CountOfUserNotAddedInPag;
            	getPagRec.PMP_Total_Cnt__c = allPagUsers.size();
            
				dashboardRecToUpdate.add(getPagRec);
			
            
            
		}
        
        if(pagRecNameToObjMap.containsKey('METRIC_USER_NOT_ADDED_IN_PAG')){
				System.debug('coming in wrong sharing');
				PMP_Marketplace_Metric__c getRec = pagRecNameToObjMap.get('METRIC_USER_NOT_ADDED_IN_PAG');
				
				getRec.PMP_Mismatch_Cnt__c = CountOfNonElgUserAddedInPag;
            	getRec.PMP_Total_Cnt__c = allPagUsers.size();
				dashboardRecToUpdate.add(getRec);
				
				
			}
        
			
        
		
        
        
        // Check Whether the users present in multiple groups
        Set<Id> allPartnerUserIds = new Set<Id>();
        for(Set<Id> userIds:partnerAccGrpToPartnerUserMap.Values()){
            allPartnerUserIds.addAll(userIds);
        }
        Map<Id,Set<String>> userIdToGrpNameMap = new Map<Id,Set<String>>();
        for(GroupMember grpMem: [SELECT Id, Group.Name,GroupId, UserOrGroupId FROM GroupMember Where UserOrGroupId IN :allPartnerUserIds AND Group.Name IN:partnerGroups]){
            
            
            if(userIdToGrpNameMap.containskey(grpMem.UserOrGroupId)){
                userIdToGrpNameMap.get(grpMem.UserOrGroupId).add(grpMem.Group.Name);
            }
            else{
                userIdToGrpNameMap.put(grpMem.UserOrGroupId,new Set<String>{grpMem.Group.Name});
            }
            
        }// End of for loop
        
        // Displaying the users with multiple groups
        for(Id usrId : userIdToGrpNameMap.keySet()){
            Set<String> grpNames = new Set<String>();
            grpNames = userIdToGrpNameMap.get(usrId); 
            
            if(grpNames.size()>1){
                System.debug('User ='+usrId + ' is in following groups ='+grpNames);
            }
        }
        
    }
    
    
    
    /*************************************** Logic to check lead groups are created or not and users are getting added correctly or not******************/
    Public static void leadGroupValidation(Set<Id> partnerAccIds, Map<String,PMP_Marketplace_Metric__c> pagRecNameToObjMap,List<											PMP_Marketplace_Metric__c> dashboardRecToUpdate){
        
        Map<Id,Set<Id>> partnerAccIdToIntelAccIds = new Map<Id,Set<Id>>();
        Set<Id> intelAccIds = new Set<Id>();
        
        
        // Logic to have a map of partner accountids to their intel accounts ids
        for(Core_Account_Group_Member__c partnerAcc : [Select Id,Core_Partner_Account_Id__c,Core_Intel_Account_Id__c FROM Core_Account_Group_Member__c WHERE 
                                                        Core_Partner_Account_Id__c IN :partnerAccIds]){  
                                                            
            if(partnerAccIdToIntelAccIds.get(partnerAcc.Core_Partner_Account_Id__c)!=null){
                 partnerAccIdToIntelAccIds.get(partnerAcc.Core_Partner_Account_Id__c).add(partnerAcc.Core_Intel_Account_Id__c);
              }
            else{
                  // Map Of partner accounts to intel accounts
                  partnerAccIdToIntelAccIds.put(partnerAcc.Core_Partner_Account_Id__c,new Set<Id>{partnerAcc.Core_Intel_Account_Id__c});
                }
                                                                
        }// End of for loop
        
        // Getting all the intel account ids
        for(Set<Id> intelAcc:partnerAccIdToIntelAccIds.Values()){
            if(intelAcc!=null){
                intelAccIds.addAll(intelAcc);
            }
        } //End of for loop
        
        Map<Id,Set<Id>> intelAccIdToPartnerAdminContactIds = new Map<Id,Set<Id>>();
        String partAdminEntId = System.Label.Core_Partner_Admin;
        
        Set<Id> intelContactIds = new Set<Id>();
        // Getting all the contact ids belongs to intel accounts
        for(Contact con:[Select Id,Name,AccountId From Contact Where AccountId IN :intelAccIds]){
            intelContactIds.add(con.Id);
        }
        
        // Logic to have a map of intel account id to their partner admin contacts
        for(Core_Contact_Entitlement__c cont: [SELECT Id, Core_Contact_Id__c,Core_Entitlement_Id__c,Core_Selected__c,Core_Status__c,
                                               Core_Contact_Id__r.AccountId FROM Core_Contact_Entitlement__c WHERE Core_Contact_Id__c 
                                               IN : intelContactIds AND Core_Entitlement_Id__c =:partAdminEntId AND Core_Selected__c=true AND 
                                               Core_Status__c='Complete' ]){
                                                   
            
            if(cont!=null){
                if(intelAccIdToPartnerAdminContactIds.containsKey(cont.Core_Contact_Id__r.AccountId)){
                	intelAccIdToPartnerAdminContactIds.get(cont.Core_Contact_Id__r.AccountId).add(cont.Core_Contact_Id__c);
            	}
            	else{
                    //Intel Accounts to partner Admin contactids map 
                intelAccIdToPartnerAdminContactIds.put(cont.Core_Contact_Id__r.AccountId,new Set<Id>{cont.Core_Contact_Id__c});
            	}
            }
        }// End of for loop
        

        Map<Id,Set<Id>> partnerAccToAllPartnerAdminConts = new Map<Id,Set<Id>>();
        
        // Logic to have a map of partner account to their all partner admin contacts
        for(Id partnerAccId:partnerAccIdToIntelAccIds.keySet()){
                Set<Id> intelAcc =null;
                intelAcc = partnerAccIdToIntelAccIds.get(partnerAccId);
            
            if(intelAcc!=null){
                Set<Id> allContactIds =new Set<Id>();
                for(Id accId:intelAcc){
                    Set<Id> contactIds =null;
                    contactIds = intelAccIdToPartnerAdminContactIds.get(accId);
                    
                    if(contactIds!=null){
                        allContactIds.addAll(contactIds);
                    }
                }
                
                if(allContactIds!=null && !allContactIds.isEmpty() ){
                    //Map of partner Account to all  partner admin intel contacts under it
                    partnerAccToAllPartnerAdminConts.put(partnerAccId,allContactIds);
                    
                }
                
        	} 
        }//End of for
        

        Set<Id> conIds = new Set<Id>();
        for(Set<Id> conId : partnerAccToAllPartnerAdminConts.Values()){
            conIds.addAll(conId);
        }
        
        Map<Id,Id> partnerConToPartnerUserMap = new Map<Id,Id>();
        //Map of partnercontacts to their partner user
        for(User u:[Select Id,ContactId FROM User WHERE ContactId IN:conIds]){
            partnerConToPartnerUserMap.put(u.ContactId, u.Id);
        }
        
        Map<String,Set<Id>> partnerAccGrpToPartnerAdminUserMap = new Map<String,Set<Id>>();
        Set<String> leadGroups = new Set<String>();
        
        // Logic to have a map of expected lead group with their users
        for(Id partnerAccId:partnerAccToAllPartnerAdminConts.keySet()){
            Set<Id> partnerConIds = null;
            partnerConIds = partnerAccToAllPartnerAdminConts.get(partnerAccId);
            
            String grpName =null;
            grpName = System.Label.PMP_Group_Name_Prefix+partnerAccId+'_Leads';
            
            leadGroups.add(grpName);
            if(partnerConIds!=null){
                Set<Id> userIds = new Set<Id>();
                for(Id conId:partnerConIds){
                    
                    Id userId = partnerConToPartnerUserMap.get(conId);
                    userIds.add(userId);
                    
                }
                
            partnerAccGrpToPartnerAdminUserMap.put(grpName,userIds);
        	}
        }// End of for loop
		
        
        /************************check whether all the lead grops are created or not****************************/
        
        Set<String> leadGrpDevNames = new Set<String>();
        for(Group grp:[SELECT Id, DeveloperName FROM Group WHERE DeveloperName LIKE 'PMP_%' limit 1000]){
            String leadGrpName = null;
            String checkLeadStr = null;
            leadGrpName = grp.DeveloperName;
            leadGrpName = leadGrpName.left(28);
            checkLeadStr = leadGrpName.right(5);
            System.debug('leadGrpName ='+leadGrpName);
            if(checkLeadStr =='Leads'){
                
                leadGrpDevNames.add(leadGrpName);
            }
            
			
        }
        
		Integer countOfTotalLeadGroups = 0;
        Integer countOfMissingLeadGroup = 0;
        
        List<string> missingLeadGrps=new List<string>();
        for(string grpname : leadGroups){
            countOfTotalLeadGroups++;
            if(!leadGrpDevNames.contains(grpname)){
                countOfMissingLeadGroup++;
                System.debug('missing lead groups='+grpname);
                leadGrpDevNames.add(grpname);

            }  
            
        }
        
		
       
        
        
        Map<String,Set<Id>> leadGrpNameToGrpUsersMap = new Map<String,Set<Id>>();
        // Logic to have a map of existing lead group with thier group members
        
        
        for(GroupMember gm:[SELECT Id, GroupId, Group.Name,UserOrGroupId FROM GroupMember WHERE Group.Name IN :leadGroups]){
            
            
                if(leadGrpNameToGrpUsersMap.containsKey(gm.Group.Name)){
                	leadGrpNameToGrpUsersMap.get(gm.Group.Name).add(gm.UserOrGroupId);
            	}
            	else{
                    //GroupName to group users map
                	leadGrpNameToGrpUsersMap.put(gm.Group.Name,new Set<Id>{gm.UserOrGroupId});
            	}
          
            
        }//End of for loop
        
        // Logic to check whether group or partner account has extra users
		
		Set<Id> allPagUsers = new Set<Id>();
		Integer countOfNonElgUserInGrp = 0;
		Integer countOfElgUserNotInGrp = 0;
		
       
        for(String grpName:partnerAccGrpToPartnerAdminUserMap.keySet()){
            
            if(leadGrpNameToGrpUsersMap.containsKey(grpName)){ //grpName  //PMP_0010n000011qrAeAAI_Leads
                
                Set<Id> acctHasExtraUsersAll = new Set<Id>();
                Set<Id> leadGrpHasExtraUsersAll = new Set<Id>();
                Set<Id> acctHasExtraUsers = partnerAccGrpToPartnerAdminUserMap.get(grpName);
				allPagUsers.addAll(acctHasExtraUsers);
                Set<Id> leadGrpHasExtraUsers  = leadGrpNameToGrpUsersMap.get(grpName);
               
                acctHasExtraUsersAll.addAll(acctHasExtraUsers);
                leadGrpHasExtraUsersAll.addAll(leadGrpHasExtraUsers);
                acctHasExtraUsersAll.removeAll(leadGrpNameToGrpUsersMap.get(grpName));
                leadGrpHasExtraUsersAll.removeAll(partnerAccGrpToPartnerAdminUserMap.get(grpName));
				
                // If account has extra users which are not there in Group
                if(acctHasExtraUsersAll.size()!=0){
                    for(Id userId:acctHasExtraUsersAll){
						countOfElgUserNotInGrp++;
                        System.debug('Partner Account =' + grpName+' has extra users ='+userId +' Which are not there in lead group');
                    }
                    
                }
                
                // If Group has extra users which are not supposed to be there
                if(leadGrpHasExtraUsersAll.size()!=0){
                    for(Id userId:leadGrpHasExtraUsersAll){
						countOfNonElgUserInGrp ++;
                        System.debug('Group =' + grpName +' has extra users ='+userId +' Which are not there in lead Account');
                    }
                    
                }
                
            }
            
            if(!leadGrpNameToGrpUsersMap.containsKey(grpName)){
                
                countOfElgUserNotInGrp = countOfElgUserNotInGrp + partnerAccGrpToPartnerAdminUserMap.get(grpName).size();
                System.debug('countOfElgUserNotInGrp***** ='+countOfElgUserNotInGrp);
                
            }
        }//End of for
        
        
        // Check Whether the users present in multiple lead groups
        Set<Id> allPartnerUserIds = new Set<Id>();
        for(Set<Id> userIds:partnerAccGrpToPartnerAdminUserMap.Values()){
            allPartnerUserIds.addAll(userIds);
        }
        Map<Id,Set<String>> userIdToGrpNameMap = new Map<Id,Set<String>>();
        // Map of UserId to their group name 
        for(GroupMember grpMem: [SELECT Id, Group.Name,GroupId, UserOrGroupId FROM GroupMember Where UserOrGroupId IN :allPartnerUserIds AND Group.Name IN:leadGroups]){
            
            
            if(userIdToGrpNameMap.containskey(grpMem.UserOrGroupId)){
                userIdToGrpNameMap.get(grpMem.UserOrGroupId).add(grpMem.Group.Name);
            }
            else{
                // Map of UserId to their group name 
                userIdToGrpNameMap.put(grpMem.UserOrGroupId,new Set<String>{grpMem.Group.Name});
            }
            
        }
        
        Integer countOfUserAddedInMultipleLeadGrp = 0;
        //System.debug('userIdToGrpNameMap ='+userIdToGrpNameMap);
        //System.debug('leadgrpusrrrrr ='+userIdToGrpNameMap.get('0050n000002Wiux'));
        // logic to check which user is present in multiple groups
        for(Id usrId : userIdToGrpNameMap.keySet()){
            Set<String> grpNames = new Set<String>();
            grpNames = userIdToGrpNameMap.get(usrId); 
            
            if(grpNames.size()>1){
                  //system.debug('coming in lead multiple grpssssss =');
                  countOfUserAddedInMultipleLeadGrp ++;
                
                  System.debug('User ='+usrId + ' is in following groups ='+grpNames);  

            }
        }
        
		
		List<PMP_Marketplace_Metric__c> pagDashboardRecToUpdate = new List<PMP_Marketplace_Metric__c> ();
        
        if(pagRecNameToObjMap.containsKey('METRIC_LEAD_GRP_NOT_CREATED') ){
           
  
				PMP_Marketplace_Metric__c getPagRec = pagRecNameToObjMap.get('METRIC_LEAD_GRP_NOT_CREATED');
                
                getPagRec.PMP_Mismatch_Cnt__c = countOfMissingLeadGroup;
            	getPagRec.PMP_Total_Cnt__c = countOfTotalLeadGroups;
            
				dashboardRecToUpdate.add(getPagRec);
				pagDashboardRecToUpdate.add(getPagRec);
            
            
		}
        
        if(pagRecNameToObjMap.containsKey('METRIC_USERS_IN_MULTIPLE_LEAD_GRPS')){
				System.debug('coming in wrong sharing');
				PMP_Marketplace_Metric__c getRec = pagRecNameToObjMap.get('METRIC_USERS_IN_MULTIPLE_LEAD_GRPS');
				
				getRec.PMP_Mismatch_Cnt__c = countOfUserAddedInMultipleLeadGrp;
            	getRec.PMP_Total_Cnt__c = allPartnerUserIds.size();
				dashboardRecToUpdate.add(getRec);
				
				pagDashboardRecToUpdate.add(getRec);
				
			}
			System.debug('countOfElgUserNotInGrp ='+countOfElgUserNotInGrp);
			if(pagRecNameToObjMap.containsKey('METRIC_ELIGIBLE_USER_NOT_IN_LEAD_GRPS')){
				System.debug('coming in wrong sharing');
				PMP_Marketplace_Metric__c getRec = pagRecNameToObjMap.get('METRIC_ELIGIBLE_USER_NOT_IN_LEAD_GRPS');
				
				getRec.PMP_Mismatch_Cnt__c = countOfElgUserNotInGrp;
            	getRec.PMP_Total_Cnt__c = allPartnerUserIds.size();
                dashboardRecToUpdate.add(getRec);
				pagDashboardRecToUpdate.add(getRec);
				
			}
			
			if(pagRecNameToObjMap.containsKey('METRIC_NON_ELIGIBLE_USER_IN_LEAD_GRPS')){
				System.debug('coming in wrong sharing');
				PMP_Marketplace_Metric__c getRec = pagRecNameToObjMap.get('METRIC_NON_ELIGIBLE_USER_IN_LEAD_GRPS');
				
				getRec.PMP_Mismatch_Cnt__c = countOfNonElgUserInGrp;
            	getRec.PMP_Total_Cnt__c = allPartnerUserIds.size();
				dashboardRecToUpdate.add(getRec);
				
				
			}
        
    }
    
    
    
    /***************************** check accounts are present in odm or non odm *****************************/
    Public static void odmNonOdmCheck(Set<Id> partnerAccIds, Map<String,PMP_Marketplace_Metric__c> pagRecNameToObjMap,List<										PMP_Marketplace_Metric__c> dashboardRecToUpdate){
        
        Set<Id> intelAccIds = new Set<Id>();
        
        //Getting the biz org type value from label
        String bizOrgLabelValues = System.Label.PMP_Biz_Org_ODM_Values ;
        List<String> bizOrgLabelValuesSplit = bizOrgLabelValues.split(';');
        System.debug('bizOrgLabelValuesSplit ='+bizOrgLabelValuesSplit);
        
        
        
        Set<String> odmAccountIdGrpName = new Set<String>();
        Set<String> nonOdmAccountIdGrpName = new Set<String>();
        
        // Logic to identify odm accounts and non odm accounts present in the system
        for(Core_Account_Group_Member__c partnerAcc : [Select Id,Core_Partner_Account_Id__c,Core_MDA_Ind__c,Core_Intel_Account_Id__c,
                                                       Core_Intel_Account_Id__r.Core_Account_Type__c FROM Core_Account_Group_Member__c WHERE 
                                                       Core_Partner_Account_Id__c IN :partnerAccIds AND Core_MDA_Ind__c =true ]){  
                    boolean isOdmAccount = false;                                        
            for(String typeVal:bizOrgLabelValuesSplit){
                if(partnerAcc.Core_Intel_Account_Id__r.Core_Account_Type__c != null && partnerAcc.Core_Intel_Account_Id__r.Core_Account_Type__c.contains(typeVal)){
                    isOdmAccount =true;
                    break;
                }
            }
                	// logic to have all the expected odm accounts in a system 
                    if(partnerAcc.Core_Intel_Account_Id__r.Core_Account_Type__c != null && isOdmAccount ){
                        
                        String odmDevName = null;
                        odmDevName =System.Label.PMP_Group_Name_Prefix+partnerAcc.Core_Partner_Account_Id__c;
                        //Expected  Groupmemember Name in Odm Group
                        odmAccountIdGrpName.add(odmDevName);
                       
                        
                    }
                    
                    // logic to have all the expected non odm accounts in the system 
                	else {
                        
                        String nonOdmDevName = null;
                        nonOdmDevName = System.Label.PMP_Group_Name_Prefix+partnerAcc.Core_Partner_Account_Id__c;
                        System.debug('nonOdmAccountIds ='+nonOdmDevName);
                        //Expected Groupmemember Name in non odm Group
                    	nonOdmAccountIdGrpName.add(nonOdmDevName);
                        
                	}
                                                              
        }
        
        Set<Id> probableOdmGroupMemIds = new Set<Id>();
        Set<Id> probableNonOdmGroupMemIds = new Set<Id>();
        Set<Id> odmGroupMemberIds = new Set<Id>();
        Set<Id> nonOdmGroupMemberIds = new Set<Id>();
        
        String ALL_PARTNERS_ODM_GROUP = System.Label.PMP_Group_All_Partner_Users_ODM;
        String ALL_PARTNERS_NON_ODM_GROUP = System.Label.PMP_Group_All_Partner_Users_Non_ODM;
        
        //Expected GroupMemberIds there in Odm Groups
        for(Group grp: [Select Id,Name,DeveloperName From Group Where DeveloperName IN:odmAccountIdGrpName]){
            //Expected GroupMemberIds there in Odm Groups
            probableOdmGroupMemIds.add(grp.Id);
        }
        
        //Expected GroupMemberIds added in non odm group
        for(Group grp: [Select Id,Name,DeveloperName From Group Where DeveloperName IN:nonOdmAccountIdGrpName]){
			//Expected GroupMemberIds added in non odm group
            probableNonOdmGroupMemIds.add(grp.Id);
        }
        
        // Logic to have actual odm group member ids present in odm group 
        for(GroupMember odmGrpMem: [SELECT Id, GroupId, UserOrGroupId FROM GroupMember where GroupId =:ALL_PARTNERS_ODM_GROUP]){
            String tempGroupId = null;
            tempGroupId = odmGrpMem.UserOrGroupId; 
            if(tempGroupId.startsWith('00G')){
                // Actual group members ids which are there in odm group
                odmGroupMemberIds.add(odmGrpMem.UserOrGroupId);
            }
            
        }
        
        
        
        Set<String> odmGroupMemberNames = new Set<String>();
        for(GroupMember odmGrpMem: [SELECT Id, Group.Name, UserOrGroupId FROM GroupMember where GroupId IN:odmGroupMemberIds]){
            // Actual Group Member Names in Odm Group
            odmGroupMemberNames.add(odmGrpMem.Group.Name);
        }
        
		 // Logic to have actual non odm group member ids present in non odm group
        for(GroupMember nonOdmGrpMem: [SELECT Id, GroupId, UserOrGroupId FROM GroupMember where GroupId =:ALL_PARTNERS_NON_ODM_GROUP]){
            String tempGroupId = null;
            tempGroupId = nonOdmGrpMem.UserOrGroupId;
            if(tempGroupId.startsWith('00G')){
                // Actual group members ids which are there in odm group
                nonOdmGroupMemberIds.add(nonOdmGrpMem.UserOrGroupId);
            }
            
        }
        
        Set<String> nonOdmGroupNames = new Set<String>();
      	for(GroupMember nonOdmGrpMem: [SELECT Id, Group.Name, UserOrGroupId FROM GroupMember where GroupId IN :nonOdmGroupMemberIds]){
            //Actual group members Names which are there in odm group
            nonOdmGroupNames.add(nonOdmGrpMem.Group.Name);
        }

        
        
		/********************************* If Odm group has extra group members************************************/
		
		Set<Id> totalGrpMemsInOdm = new Set<Id>();
		totalGrpMemsInOdm.addAll(odmGroupMemberIds);
        Set<Id> totalGrpMemsInNonOdm = new Set<Id> ();
		totalGrpMemsInNonOdm.addAll(nonOdmGroupMemberIds);
		
		
        odmGroupMemberIds.removeAll(probableOdmGroupMemIds);

        Integer countOfNonEligibleMemInOdm = 0;
        Integer countOfNonEligibleMemInNonOdm = 0;
        
        if(odmGroupMemberIds.size()>1){
            for(Id grpMem:odmGroupMemberIds){
                    countOfNonEligibleMemInOdm++;
                    System.debug('non eligible group added in odm ='+grpMem);
        		}
        }
        
        /******************** If non Odm group has extra group members**************************/
		
        nonOdmGroupMemberIds.removeAll(probableNonOdmGroupMemIds);
        
        if(nonOdmGroupMemberIds.size()>1){
            for(Id grpMem:nonOdmGroupMemberIds){
                countOfNonEligibleMemInNonOdm++;
            	System.debug('non eligible group added in non odm ='+grpMem);
        	}
        }
 
        /**************** Missing Odm group members*******************/
        
       for(string odmGrpname : odmAccountIdGrpName){
            
            if(!odmGroupMemberNames.contains(odmGrpname)){
                System.debug('missed odm group members='+odmGrpname);
               
            }  
            
        }
        
        /************************** Missing NonOdm group members *************************************/
        for(string nonOdmGrpname : nonOdmAccountIdGrpName){
            
            if(!nonOdmGroupNames.contains(nonOdmGrpname)){
                System.debug('missed non odm group members='+nonOdmGrpname);
               
            }  
            
        }
        
        /****************** Check whether groups are added in odm and non odm both *********************/
        
        Set<Id> allGroupMembers = new Set<Id>();
        Integer countOfGrpInBothOdmAndNonOdm = 0;
	  	allGroupMembers.addAll(totalGrpMemsInOdm);
      	allGroupMembers.addAll(totalGrpMemsInNonOdm);
        Map<Id,Set<String>> grpMemToGrpNameMap = new Map<Id,Set<String>>();
        
        //Map of group member to their group name
        for(GroupMember grpMem: [SELECT Id, Group.Name,GroupId, UserOrGroupId FROM GroupMember Where UserOrGroupId IN :allGroupMembers ]){
            
            
            if(grpMemToGrpNameMap.containskey(grpMem.UserOrGroupId)){
                grpMemToGrpNameMap.get(grpMem.UserOrGroupId).add(grpMem.Group.Name);
            }
            else{
                grpMemToGrpNameMap.put(grpMem.UserOrGroupId,new Set<String>{grpMem.Group.Name});
            }
            
        }

        for(Id grpMem : grpMemToGrpNameMap.keySet()){
            Set<String> grpNames = new Set<String>();
            grpNames = grpMemToGrpNameMap.get(grpMem); 
            // If size of grpNames more than it means group member is present in multiple groups
            if(grpNames.size()>1){
                  countOfGrpInBothOdmAndNonOdm ++;
                  System.debug('Group Member ='+grpMem + ' is in following groups ='+grpNames);  

            }
        }
        
        if(pagRecNameToObjMap.containsKey('METRIC_NON_ELG_PAG_ADDED_IN_ODM') ){

				PMP_Marketplace_Metric__c getPagRec = pagRecNameToObjMap.get('METRIC_NON_ELG_PAG_ADDED_IN_ODM');
                
                getPagRec.PMP_Mismatch_Cnt__c = countOfNonEligibleMemInOdm;
            	getPagRec.PMP_Total_Cnt__c = totalGrpMemsInOdm.size();
				dashboardRecToUpdate.add(getPagRec);

		}
        
        if(pagRecNameToObjMap.containsKey('METRIC_NON_ELG_PAG_ADDED_IN_NON_ODM')){
				
				PMP_Marketplace_Metric__c getRec = pagRecNameToObjMap.get('METRIC_NON_ELG_PAG_ADDED_IN_NON_ODM');
				getRec.PMP_Mismatch_Cnt__c = countOfNonEligibleMemInNonOdm;
            	getRec.PMP_Total_Cnt__c = totalGrpMemsInNonOdm.size();
				dashboardRecToUpdate.add(getRec);

			}
        
         if(pagRecNameToObjMap.containsKey('METRIC_PAG_ADDED_IN_BOTH_ODM_AND_NON_ODM')){
				System.debug('coming in wrong sharing');
				PMP_Marketplace_Metric__c getRec = pagRecNameToObjMap.get('METRIC_PAG_ADDED_IN_BOTH_ODM_AND_NON_ODM');
				
				getRec.PMP_Mismatch_Cnt__c = countOfGrpInBothOdmAndNonOdm;
            	getRec.PMP_Total_Cnt__c = allGroupMembers.size();
				dashboardRecToUpdate.add(getRec);
				//pagDashboardRecToUpdate.add(getRec);
				
			}

    }
    
    
    /******************************* Script to check segment based groups are being created and correct users are getting added in the group or not***********/
    Public static void contactSegmentGroupValidation(Set<Id> partnerAccIds, Map<String,PMP_Marketplace_Metric__c> pagRecNameToObjMap,List<														PMP_Marketplace_Metric__c> dashboardRecToUpdate){
        
        
        Map<Id,Set<Id>> partnerAccIdToIntelAccIds = new Map<Id,Set<Id>>();
        Set<Id> intelAccIds = new Set<Id>();
        
        // Logic to have a map of partner accountids to their intel accounts ids
        for(Core_Account_Group_Member__c partnerAcc : [Select Id,Core_Partner_Account_Id__c,Core_Intel_Account_Id__c FROM Core_Account_Group_Member__c WHERE 
                                                        Core_Partner_Account_Id__c IN :partnerAccIds]){  
                                                            
            if(partnerAccIdToIntelAccIds.get(partnerAcc.Core_Partner_Account_Id__c)!=null){
                 partnerAccIdToIntelAccIds.get(partnerAcc.Core_Partner_Account_Id__c).add(partnerAcc.Core_Intel_Account_Id__c);
              }
            else{
                  // Map Of partner accounts to intel accounts
                  partnerAccIdToIntelAccIds.put(partnerAcc.Core_Partner_Account_Id__c,new Set<Id>{partnerAcc.Core_Intel_Account_Id__c});
                }
                                                                
        }// End of for loop
        
        // Getting all the intel account ids
        for(Set<Id> intelAcc:partnerAccIdToIntelAccIds.Values()){
            if(intelAcc!=null){
                intelAccIds.addAll(intelAcc);
            }
        } //End of for loop
        
        Map<Id,Set<Id>> intelAccIdToLdrContactIds = new Map<Id,Set<Id>>();
        String ldrEntId = System.Label.Core_Lead_Development_Representative ;
        
        Set<Id> intelContactIds = new Set<Id>();
        // Getting all the contact ids belongs to intel accounts
        for(Contact con:[Select Id,Name,AccountId From Contact Where AccountId IN :intelAccIds]){
            intelContactIds.add(con.Id);
        }
        
        // Logic to have a map of intel account id to their ldr contacts
        for(Core_Contact_Entitlement__c cont: [SELECT Id, Core_Contact_Id__c,Core_Entitlement_Id__c,Core_Selected__c,Core_Status__c,
                                               Core_Contact_Id__r.AccountId FROM Core_Contact_Entitlement__c WHERE Core_Contact_Id__c 
                                               IN : intelContactIds AND Core_Entitlement_Id__c =:ldrEntId AND Core_Selected__c=true AND 
                                               Core_Status__c='Complete' ]){
                                                   
            
            if(cont!=null){
                if(intelAccIdToLdrContactIds.containsKey(cont.Core_Contact_Id__r.AccountId)){
                	intelAccIdToLdrContactIds.get(cont.Core_Contact_Id__r.AccountId).add(cont.Core_Contact_Id__c);
            	}
            	else{
                    //Intel Accounts to partner Admin contactids map 
                intelAccIdToLdrContactIds.put(cont.Core_Contact_Id__r.AccountId,new Set<Id>{cont.Core_Contact_Id__c});
            	}
            }
        }// End of for loop
        
	
        Map<Id,Set<Id>> partnerAccToAllLdrConts = new Map<Id,Set<Id>>();
        
        // Logic to have a map of partner account to their all LDR contacts
        for(Id partnerAccId:partnerAccIdToIntelAccIds.keySet()){
                Set<Id> intelAcc =null;
                intelAcc = partnerAccIdToIntelAccIds.get(partnerAccId);
            
            if(intelAcc!=null){
                Set<Id> allContactIds =new Set<Id>();
                for(Id accId:intelAcc){
                    Set<Id> contactIds =null;
                    contactIds = intelAccIdToLdrContactIds.get(accId);
                    
                    if(contactIds!=null){
                        allContactIds.addAll(contactIds);
                    }
                }
                
                if(allContactIds!=null && !allContactIds.isEmpty() ){
                    //Map of partner Account to all  LDR intel contacts under it
                    partnerAccToAllLdrConts.put(partnerAccId,allContactIds);
                    
                }
                
        	} 
        }//End of for
        
        Set<Id> ldrConIds = new Set<Id>();
        Map<Id,Id> partnerConToPartnerUserMap = new Map<Id,Id>();
        for(Set<Id> conId : partnerAccToAllLdrConts.Values()){
            ldrConIds.addAll(conId);
        }
        
        //Map of ldr contact to ldr user
        for(User u:[Select Id,ContactId FROM User WHERE ContactId IN:ldrConIds]){
            partnerConToPartnerUserMap.put(u.ContactId, u.Id);
        }
        
        // Logic to have a map of partner account to their ldr users
        Map<Id,Set<Id>> partnerAccIdToPartnerUserMap = new Map<Id,Set<Id>>();
        for(Id partnerAccId:partnerAccToAllLdrConts.keySet()){
            Set<Id> partnerConIds = null;
            partnerConIds = partnerAccToAllLdrConts.get(partnerAccId);
            
            
            if(partnerConIds!=null){
                Set<Id> userIds = new Set<Id>();
                for(Id conId:partnerConIds){
                    
                    Id userId = partnerConToPartnerUserMap.get(conId);
                    userIds.add(userId);
                    
                }
                // Map of partner account id to ldr user ids
            partnerAccIdToPartnerUserMap.put(partnerAccId,userIds);
        	}
        }
        
                
        

       
        // Map of LDR contacts to their contact segmet
        Map<Id, String> ldrContactIdToContactSegmentMap = new Map<Id, String>();
        for(Contact ldrCon:[Select Id,Name,Core_IPA_Contact_Segment__c FROM Contact WHERE Id IN:ldrConIds]){
            if( ldrCon.Core_IPA_Contact_Segment__c != null){
                	ldrContactIdToContactSegmentMap.put(ldrCon.Id, ldrCon.Core_IPA_Contact_Segment__c);
            	}
       	 	}
        
        
        //Map of ldr user to to contact segment
        Map<Id,Set<String>> ldrUserToSegmentMap = new Map<Id,Set<String>>();
        
        for(User ldrUsr:[Select Id,Name,ContactId From User Where ContactId IN:ldrContactIdToContactSegmentMap.keySet()]){
            System.debug('ldrUsr Id =='+ldrUsr.Id);
            String segments = null;
            segments = ldrContactIdToContactSegmentMap.get(ldrUsr.ContactId);
            
            Set<String> allSegmentsSet = new Set<String>();
            if(segments!=null){
                List<String> segmentList = segments.split(';');
                System.debug('segmentList All='+segmentList);
                if(segmentList!=null && segmentList.size()>0){
                	allSegmentsSet.addAll(segmentList);
            	}
            }
            
            //ldr user to segment map
            ldrUserToSegmentMap.put(ldrUsr.Id, allSegmentsSet);
        }//End of for loop
        
        
        
        // Map of partner account to their segments groups to be created
        Map<Id, Set<String>> partnerAccIdToContactSegmentsMap = new Map<Id, Set<String>>();
                                                         
		 for(Id partnerAccId : partnerAccToAllLdrConts.KeySet()){
			 Set<Id> contactsWithLDR = partnerAccToAllLdrConts.get(partnerAccId);
			 Set<String> allSegmentsSet = new Set<String>();
			 if(contactsWithLDR != null){
				 for(Id contactRecordId : contactsWithLDR){
					 if(contactRecordId !=null && ldrContactIdToContactSegmentMap.get(contactRecordId) != null){
						 String tempSegment = ldrContactIdToContactSegmentMap.get(contactRecordId);
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
		 }//End of for
        
        
        
   
   // Logic tohave a expected partner account to their segment group
     Map<Id,Set<String>> expectedPartnerAccIdToSegmentGroup = new Map<Id,Set<String>>();
	 for(Id partnerAccId : partnerAccIdToContactSegmentsMap.KeySet()){
		 Set<String> contactsSegmentSet = partnerAccIdToContactSegmentsMap.get(partnerAccId);
		 if(contactsSegmentSet != null){
             Set<String> allSegmentGrp = new Set<String>();
			 for(String contactSegment : contactsSegmentSet){
                 //Set<String> allSegmentGrp = new Set<String>();
				 String groupName = System.Label.PMP_Group_Name_Prefix+partnerAccId+'_'+contactSegment;
				 if(groupName != null && groupName.length() > 40){
					 groupName = groupName.substring(0,40);
				 }
				 
				groupName = groupName.replaceAll( '\\s+', '_');
                allSegmentGrp.add(groupName);
                
			 }
             expectedPartnerAccIdToSegmentGroup.put(partnerAccId,allSegmentGrp);
		 }
	 }
        
        
       
        String[] segmentGroupNames = new String[]{'PMP_00_________________Internet_of_Thing','PMP_00_________________Client_Computing','PMP_00_________________Data_Center',
    			'PMP_00_________________Storage_and_Memor','PMP_00_________________Programmable_Logi'};
          
        // Logic to get all the existing Segment Group            
		Set<String> existingSegmenetGroups = new Set<String>();
        for(Group grp:[Select Id, Name From Group Where name like :segmentGroupNames]){
            	existingSegmenetGroups.add(grp.Name);
        	}
        
        // Displaying Missing segment group
        Integer totalNumberOfSegmentProcessed = 0;
        Integer totalNumberOfMismatch = 0;
        for(Id partnerAccId:expectedPartnerAccIdToSegmentGroup.keySet()){
            Set<String> segmentGrps = new Set<String>();
            segmentGrps = expectedPartnerAccIdToSegmentGroup.get(partnerAccId);
            
            for(String segmentName:segmentGrps){
                totalNumberOfSegmentProcessed++;
                if(!existingSegmenetGroups.contains(segmentName)){
                    totalNumberOfMismatch++;
                	System.debug('Segment group name = ' +segmentName +'is missing');
            	}
            }
            
        }
        
        if(pagRecNameToObjMap.containsKey('METRIC_SEGMENT_GRP_NOT_CREATED') ){
           
  
				PMP_Marketplace_Metric__c getPagRec = pagRecNameToObjMap.get('METRIC_SEGMENT_GRP_NOT_CREATED');
                
                getPagRec.PMP_Mismatch_Cnt__c = totalNumberOfMismatch;
            	getPagRec.PMP_Total_Cnt__c = totalNumberOfSegmentProcessed;
            
				
				dashboardRecToUpdate.add(getPagRec);
            
            
		}
		
        
    /********************Check if correct user are added correctly in the group or not**********************/
        
    Set<String> ldrSegmentValues = new Set<String>();
    Map<String,Set<Id>> expectedgrpDevNameToUserIdMap = new Map<String,Set<Id>>();
    Map<String,Set<Id>> existinggrpDevNameToUserIdMap = new Map<String,Set<Id>>();
    Set<String> grpDevNames = new Set<String>();
    Set<String> segmentGrpDevNames = new Set<String>();
        
    // logic to form a map of expected group name with their users
    for(Id partnerAccId : partnerAccIdToContactSegmentsMap.KeySet()){
        
     for(Id ldrUser:ldrUserToSegmentMap.keySet()){
       
         ldrSegmentValues = ldrUserToSegmentMap.get(ldrUser);
         
         for(String segment:ldrSegmentValues){
             String groupName = System.Label.PMP_Group_Name_Prefix+partnerAccId+'_'+segment;
             if(groupName != null && groupName.length() > 40){
                 groupName = groupName.substring(0,40);
             }
             
             groupName = groupName.replaceAll( '\\s+', '_');
             /*String onlyPMP_id = groupName.left(22);
             
             if(!grpDevNames.contains(onlyPMP_id)){
                 grpDevNames.add(onlyPMP_id);
                 segmentGrpDevNames.add(groupName);
             }*/
             
             grpDevNames.add(groupName);
             if(partnerAccIdToPartnerUserMap.get(partnerAccId).Contains(ldrUser)){
                 if(expectedgrpDevNameToUserIdMap.get(groupName) !=null){
                     expectedgrpDevNameToUserIdMap.get(groupName).add(ldrUser);
                 }else{
                        expectedgrpDevNameToUserIdMap.put(groupName,new Set<Id>{ldrUser});
                     }
            	}
             
         	}
     	}
    }
        //logic to get a map of existing grp with their users
        Map<String,Set<Id>> existingGrpToUserIdMap = new Map<String,Set<Id>>();
        for(GroupMember grp:[SELECT Id, GroupId,Group.Name, UserOrGroupId FROM GroupMember Where Group.Name IN :expectedgrpDevNameToUserIdMap.keySet()] ){
            
            if(existingGrpToUserIdMap.containsKey(grp.Group.Name)){
                existingGrpToUserIdMap.get(grp.Group.Name).add(grp.UserOrGroupId);
            }else{
                existingGrpToUserIdMap.put(grp.Group.Name,new Set<Id>{grp.UserOrGroupId});
            }
        }
        
        //logic to find out whether account or group has extra users
        for(String grpName :existingGrpToUserIdMap.keySet()){
            
            if(expectedgrpDevNameToUserIdMap.containsKey(grpName)){
                Set<Id> acctHasExtraUsersAll = new Set<Id>();
                Set<Id> segmentGrpHasExtraUsersAll = new Set<Id>();            
                Set<Id> groupHasExtraUsers = existingGrpToUserIdMap.get(grpName);
                Set<Id> accountHasUsers = expectedgrpDevNameToUserIdMap.get(grpName);
                
                acctHasExtraUsersAll.addAll(accountHasUsers);
                segmentGrpHasExtraUsersAll.addAll(groupHasExtraUsers);
                
                acctHasExtraUsersAll.removeAll(existingGrpToUserIdMap.get(grpName));
                    
                segmentGrpHasExtraUsersAll.removeAll(expectedgrpDevNameToUserIdMap.get(grpName));
                
                // If account has extra users which are not there in Group
                if(acctHasExtraUsersAll.size()!=0){
                    for(Id userId:acctHasExtraUsersAll){
                        System.debug('Partner Account 1 =' + grpName+' has extra users ='+userId +' Which are not there in group');
                    }
                    
                }
                
                // If Group has extra users which are not supposed to be there
                if(segmentGrpHasExtraUsersAll.size()!=0){
                    for(Id userId:segmentGrpHasExtraUsersAll){
                        System.debug('Group 1 =' + grpName +' has extra users ='+userId +' Which are not there in Account');
                    }
                    
                }
                
             }
			
            
        }//End of for loop
        Set<Id> userIdsInExistingSegmentGroup = new Set<Id>();
        for(Set<Id> userId :existingGrpToUserIdMap.Values()){
            userIdsInExistingSegmentGroup.addAll(userId);
        }
        
       
        Map<Id,Set<String>> userIdToGrpNamesMap = new Map<Id,Set<String>>();  
        for(GroupMember grpMem:[SELECT Id, GroupId, UserOrGroupId FROM GroupMember Where UserOrGroupId IN: userIdsInExistingSegmentGroup AND Group.Name IN:segmentGroupNames]){
                if(grpMem!=null){
                    if(userIdToGrpNamesMap.containskey(grpMem.UserOrGroupId)){
                       userIdToGrpNamesMap.get(grpMem.UserOrGroupId).add(grpMem.Group.Name);
                    }
                    else{
                        userIdToGrpNamesMap.put(grpMem.UserOrGroupId,new Set<String>{grpMem.Group.Name});
                    }
                    
                }
            }   
        
        for(Id userId :userIdToGrpNamesMap.keySet()){
               Set<String> grpNames = new Set<String>();
               grpNames = userIdToGrpNamesMap.get(userId);
            
               if(grpNames.size()>1){
                   System.debug('User ='+userId + 'Which are in following group ='+grpNames);
               }
        	}
	
       
    }
}