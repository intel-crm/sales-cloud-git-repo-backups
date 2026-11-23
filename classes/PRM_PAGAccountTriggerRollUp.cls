/*********************************************************************************************************************
Class Name  : PRM_PAGAccountTriggerRollUp
Version       : 1.0
Created Date  : AUG 2020
Function      : Roll Up Biz Org Type and Partner Segment

Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------------------------
* Rahul Kainth          	8/12/2020               Roll Up Biz Org Type and Partner Segment

*********************************************************************************************************************/
public class PRM_PAGAccountTriggerRollUp {
    
    public static void updatepagaccount(List<Account> newAccounts,Map<Id,Account> mapOfOldRecords){
        
        Map<String,Set<String>> act1 = new Map<String,Set<String>>();
        Map<String,Set<String>> act2 = new Map<String,Set<String>>();
        Map<String,Set<String>> act3 = new Map<String,Set<String>>();
        Map<String,Set<String>> act4 = new Map<String,Set<String>>();
        Set<Id> ipaAcnts = new Set<Id>();
        Id intelaccountRT = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        
        Set<String> setOfPagIds = new Set<String>();
        Map<String,String> mapofPagIDs = new Map<String,String>();
        Map<String,Account> mapOfNewRecords = new Map<String,Account>();
        System.debug('oldRecord'+mapOfOldRecords);
        for(Account a : newAccounts){
            System.debug('a'+a);
            Account oldAcnt = (Account)mapOfOldRecords.get(a.id);
            if((oldAcnt!=null && !oldAcnt.Core_Intel_Partner_Alliance_PartnerGroup__c && a.Core_Intel_Partner_Alliance_PartnerGroup__c))
            {
                ipaAcnts.add(a.id);
            }
			System.debug('a.Core_Intel_Partner_Alliance_PartnerGroup__c'+a.Core_Intel_Partner_Alliance_PartnerGroup__c);
            if(a.Core_IPA_One_Partner_Id__c != null && a.RecordTypeId == intelaccountRT && a.Core_Intel_Partner_Alliance_PartnerGroup__c == true){
                setOfPagIds.add(a.Core_IPA_One_Partner_Id__c);
                mapofPagIDs.put(a.Core_IPA_One_Partner_Id__c,a.Id);
                mapOfNewRecords.put(a.Id,a);
            }
        }
        System.debug('@@ setOfPagIds'+setOfPagIds);
        System.debug('@@ mapofPagIDs'+mapofPagIDs);
        System.debug('@@ mapOfNewRecords'+mapOfNewRecords); 
        
        if(!ipaAcnts.isEmpty()){
        List<Core_Account_Group_Member__c> CAGforIPA = [SELECT Id, Name, Core_Partner_Account_Id__c, Core_Intel_Account_Id__c,Core_Partner_Account_Id__r.Core_OnePartnerID__c,Core_Inactive_Ind__c,Core_Intel_Partner_Alliance_PartnerGroup__c from Core_Account_Group_Member__c WHERE Core_Intel_Account_Id__c in :ipaAcnts AND Core_Inactive_Ind__c != true];
        if(CAGforIPA.size()>0){
            PMP_Acct_Grp_Mbr_TriggerHandler.RollUpLocFlagToOPID(CAGforIPA,null);       
        }
     }

        for(String a : setOfPagIds){
            Set<String> oldBizOrgType = new Set<String>();
            Set<String> newBizOrgType = new Set<String>();
            Set<String> oldPartnerSegments = new Set<String>();
            Set<String> newPartnerSegments = new Set<String>();
            
            System.debug('mapOfOldRecords.get(mapofPagIDs.get(a)).Core_Account_Type__c'+mapOfOldRecords.get(mapofPagIDs.get(a)).Core_Account_Type__c);
            System.debug('mapOfNewRecords.get(mapofPagIDs.get(a)).Core_Account_Type__c'+mapOfNewRecords.get(mapofPagIDs.get(a)).Core_Account_Type__c);
            
            System.debug('mapOfOldRecords.get(mapofPagIDs.get(a)).Core_IPA_Partner_Segment__c'+mapOfOldRecords.get(mapofPagIDs.get(a)).Core_IPA_Partner_Segment__c);
            
            System.debug('mapOfNewRecords.get(mapofPagIDs.get(a)).Core_IPA_Partner_Segment__c'+mapOfNewRecords.get(mapofPagIDs.get(a)).Core_IPA_Partner_Segment__c);
            
            
            if((mapOfOldRecords.get(mapofPagIDs.get(a)).Core_Account_Type__c == null || String.isBlank(mapOfOldRecords.get(mapofPagIDs.get(a)).Core_Account_Type__c)) && mapOfNewRecords.get(mapofPagIDs.get(a)).Core_Account_Type__c != null && String.isNotBlank(mapOfNewRecords.get(mapofPagIDs.get(a)).Core_Account_Type__c)){
                //oldBizOrgType = new Set<String>();
                //Addition of biz org type
                System.debug('Addition of biz org type');
                newBizOrgType.addAll(mapOfNewRecords.get(mapofPagIDs.get(a)).Core_Account_Type__c.split(';'));
                
            }
            
            if((mapOfNewRecords.get(mapofPagIDs.get(a)).Core_Account_Type__c == null || String.isBlank(mapOfNewRecords.get(mapofPagIDs.get(a)).Core_Account_Type__c)) && mapOfOldRecords.get(mapofPagIDs.get(a)).Core_Account_Type__c != null && String.isNotBlank(mapOfOldRecords.get(mapofPagIDs.get(a)).Core_Account_Type__c)){
                
                //removal scenario
                System.debug('Removal of biz org type');
                oldBizOrgType.addAll(mapOfOldRecords.get(mapofPagIDs.get(a)).Core_Account_Type__c.split(';'));
                act1.put(a,oldBizOrgType);
                //newBizOrgType = new Set<String>();
            }
                        
            if(mapOfOldRecords.get(mapofPagIDs.get(a)).Core_Account_Type__c != null && String.isNotBlank(mapOfOldRecords.get(mapofPagIDs.get(a)).Core_Account_Type__c) && mapOfNewRecords.get(mapofPagIDs.get(a)).Core_Account_Type__c != null && String.isNotBlank(mapOfNewRecords.get(mapofPagIDs.get(a)).Core_Account_Type__c) &&(!mapOfOldRecords.get(mapofPagIDs.get(a)).Core_Account_Type__c.equals(mapOfNewRecords.get(mapofPagIDs.get(a)).Core_Account_Type__c))){
                
                //Old biz org type and new biz org type have values and are different
                System.debug('Old biz org type and new biz org type have values and are different');
                oldBizOrgType.addAll(mapOfOldRecords.get(mapofPagIDs.get(a)).Core_Account_Type__c.split(';'));
                newBizOrgType.addAll(mapOfNewRecords.get(mapofPagIDs.get(a)).Core_Account_Type__c.split(';'));
                
                
            }
            
            if((mapOfOldRecords.get(mapofPagIDs.get(a)).Core_IPA_Partner_Segment__c == null || String.isBlank(mapOfOldRecords.get(mapofPagIDs.get(a)).Core_IPA_Partner_Segment__c)) && mapOfNewRecords.get(mapofPagIDs.get(a)).Core_IPA_Partner_Segment__c != null && String.isNotBlank(mapOfNewRecords.get(mapofPagIDs.get(a)).Core_IPA_Partner_Segment__c)){
                //Partner Segment Addition
                System.debug('Partner Segment Addition');
                newPartnerSegments.addAll(mapOfNewRecords.get(mapofPagIDs.get(a)).Core_IPA_Partner_Segment__c.split(';'));
                
            }
            
            if((mapOfNewRecords.get(mapofPagIDs.get(a)).Core_IPA_Partner_Segment__c == null || String.isBlank(mapOfNewRecords.get(mapofPagIDs.get(a)).Core_IPA_Partner_Segment__c)) && mapOfOldRecords.get(mapofPagIDs.get(a)).Core_IPA_Partner_Segment__c!= null && String.isNotBlank(mapOfOldRecords.get(mapofPagIDs.get(a)).Core_IPA_Partner_Segment__c)){
                //Partner Segment Removal
                System.debug('Partner Segment Removal');
                oldPartnerSegments.addAll(mapOfOldRecords.get(mapofPagIDs.get(a)).Core_IPA_Partner_Segment__c.split(';'));
                
            }
            
            if(mapOfOldRecords.get(mapofPagIDs.get(a)).Core_IPA_Partner_Segment__c!= null && String.isNotBlank(mapOfOldRecords.get(mapofPagIDs.get(a)).Core_IPA_Partner_Segment__c) && mapOfNewRecords.get(mapofPagIDs.get(a)).Core_IPA_Partner_Segment__c != null && String.isNotBlank(mapOfNewRecords.get(mapofPagIDs.get(a)).Core_IPA_Partner_Segment__c) && (!mapOfOldRecords.get(mapofPagIDs.get(a)).Core_IPA_Partner_Segment__c.equals(mapOfNewRecords.get(mapofPagIDs.get(a)).Core_IPA_Partner_Segment__c))){
                
                //Old Partner Segment and new partner segment have values and are different
                System.debug('Old Partner Segment and new partner segment have values and are different');
                oldPartnerSegments.addAll(mapOfOldRecords.get(mapofPagIDs.get(a)).Core_IPA_Partner_Segment__c.split(';'));
                
                newPartnerSegments.addAll(mapOfNewRecords.get(mapofPagIDs.get(a)).Core_IPA_Partner_Segment__c.split(';'));
                
            }
            
            act1.put(a,oldBizOrgType);
            act2.put(a,newBizOrgType);
            act4.put(a,newPartnerSegments);
            act3.put(a,oldPartnerSegments);
            System.debug('oldBizOrgType'+oldBizOrgType);
            System.debug('newBizOrgType'+newBizOrgType);
            System.debug('oldPartnerSegments'+oldPartnerSegments);
            System.debug('newPartnerSegments'+newPartnerSegments);
            
        }
        
        System.debug('act1 - oldBizOrgType '+act1);
        System.debug('act2 - newBizOrgType '+act2);
        System.debug('act3 - oldPartnerSegments '+act3);
        System.debug('act4 - newPartnerSegments '+act4);
        
        
        Map<Id,Set<String>> finalBizOrgType = new Map<Id,Set<String>>();
        Map<Id,String> finalMapOfScenario = new Map<Id,String>();
        Set<String> bizOrgSet = new Set<String>();
        Set<String> addedBizORgTypes = new Set<String>();
        Map<Id,Set<String>> mapOfAddedBizOrgTypes = new Map<Id,Set<String>>();
        Set<String> removedBizOrgTypes = new Set<String>();
        Map<Id,Set<String>> mapOfRemovedBizOrgTypes = new Map<Id,Set<String>>();
        
        //Code for Biz Org Type
        //old Record Id + old Biz Org Type Iteration
        for(String a : act1.keySet()){
            
            //Removal
            for(String oldValue : act1.get(a)){
                if(!act2.get(a).contains(oldValue)){
                    removedBizOrgTypes.add(oldValue);
                }
            }
            mapOfRemovedBizOrgTypes.put(a,removedBizOrgTypes);
            
            //Addition
            for(String newValue : act2.get(a)){
                if(!act1.get(a).contains(newValue)){
                    addedBizORgTypes.add(newValue);
                }
            }
            mapOfAddedBizOrgTypes.put(a,addedBizORgTypes);
            
        }
        
        Set<String> addedPartnerSegments = new Set<String>();
        Map<Id,Set<String>> mapOfAddedPartnerSegments = new Map<Id,Set<String>>();
        Set<String> removedPartnerSegments = new Set<String>();
        Map<Id,Set<String>> mapOfRemovedPartnerSegments = new Map<Id,Set<String>>();
        
        for(String a : act3.keySet()){
            
            //Removal
            for(String oldValue : act3.get(a)){
                if(!act4.get(a).contains(oldValue)){
                    removedPartnerSegments.add(oldValue);
                }
            }
            mapOfRemovedPartnerSegments.put(a,removedPartnerSegments);
            
            //Addition
            for(String newValue : act4.get(a)){
                if(!act3.get(a).contains(newValue)){
                    addedPartnerSegments.add(newValue);
                }
            }
            mapOfAddedPartnerSegments.put(a,addedPartnerSegments);
            
        }
        
        System.debug('mapOfAddedBizOrgTypes -Added'+mapOfAddedBizOrgTypes);
        System.debug('mapOfRemovedBizOrgTypes - Removed'+mapOfRemovedBizOrgTypes);
        System.debug('mapOfAddedPartnerSegments -Added'+mapOfAddedPartnerSegments);
        System.debug('mapOfRemovedPartnerSegments - Removed'+mapOfRemovedPartnerSegments);
                
        //get child - parent mapping
        List<Core_Account_Group_Member__c> cagList = new List<Core_Account_Group_Member__c>();
        if(setOfPagIds.size() > 0 && (removedBizOrgTypes.size() > 0 || addedBizORgTypes.size()>0 || removedPartnerSegments.size()>0 || addedPartnerSegments.size()>0)){
        cagList = [Select Id, Core_Intel_Account_Id__c, Core_Intel_Account_Id__r.Name, Core_Intel_Account_Id__r.Core_IPA_Partner_Segment__c, Core_Intel_Account_Id__r.Core_Account_Type__c, Core_Intel_Account_Id__r.Core_IPA_One_Partner_Id__c,Core_Intel_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c,
                                                     Core_Partner_Account_Id__c, Core_Partner_Account_Id__r.Name, Core_Partner_Account_Id__r.Core_IPA_Partner_Segment__c, Core_Partner_Account_Id__r.Core_Account_Type__c, Core_Partner_Account_Id__r.Core_IPA_One_Partner_Id__c
                                                     from Core_Account_Group_Member__c where Core_Partner_Account_Id__c IN :setOfPagIds AND Core_Intel_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c = true];
		}
/*
        List<Account> accList = [Select Id,Name,Core_IPA_Partner_Segment__c, Core_Account_Type__c,Core_IPA_One_Partner_Id__c, recordtypeid from Account where Id IN :setOfPagIds or Core_IPA_One_Partner_Id__c IN :setOfPagIds];
        
		Map<Id,Account> childAccounts = new Map<Id,Account>([Select Id,Name,Core_IPA_Partner_Segment__c,
		Core_Account_Type__c,Core_IPA_One_Partner_Id__c from Account where Core_IPA_One_Partner_Id__c IN :setOfPagIds AND RecordTypeId =: intelaccountRT]);
		
		Map<Id,Account> parentAccounts = new Map<Id,Account>([Select Id,Name,Core_IPA_Partner_Segment__c,
		Core_Account_Type__c from Account where Id IN :setOfPagIds and recordTypeId = :pagAccountRT]); */
		
		Map<Id,Account> childAccounts = new Map<Id, Account>();
		Map<Id,Account> parentAccounts = new Map<Id, Account>();
		
        if(cagList.size() > 0){
		System.debug('@@ List size '+cagList.size());
		for(Core_Account_Group_Member__c cag: cagList){
            
            Account intelAcc = new Account();
            intelAcc.id = cag.Core_Intel_Account_Id__c;
            intelAcc.Name = cag.Core_Intel_Account_Id__r.Name;
            intelAcc.Core_IPA_Partner_Segment__c = cag.Core_Intel_Account_Id__r.Core_IPA_Partner_Segment__c; 
            intelAcc.Core_Account_Type__c = cag.Core_Intel_Account_Id__r.Core_Account_Type__c;
            intelAcc.Core_IPA_One_Partner_Id__c = cag.Core_Intel_Account_Id__r.Core_IPA_One_Partner_Id__c;              			
            childAccounts.put(intelAcc.Id, intelAcc);
			
            Account pagAcc = new Account();
            pagAcc.id = cag.Core_Partner_Account_Id__c;
            pagAcc.Name = cag.Core_Partner_Account_Id__r.Name;
            pagAcc.Core_IPA_Partner_Segment__c = cag.Core_Partner_Account_Id__r.Core_IPA_Partner_Segment__c;
            pagAcc.Core_Account_Type__c = cag.Core_Partner_Account_Id__r.Core_Account_Type__c;
            pagAcc.Core_IPA_One_Partner_Id__c = cag.Core_Partner_Account_Id__r.Core_IPA_One_Partner_Id__c;
			parentAccounts.put(pagAcc.Id, pagAcc);			
			
		}
        }
        
        Map<String,Set<String>> act5 = new Map<String,Set<String>>();
        Map<String,Set<String>> act6 = new Map<String,Set<String>>();
        Map<String,Set<String>> act7 = new Map<String,Set<String>>();
        Map<String,Set<String>> act8 = new Map<String,Set<String>>();
        Map<Id,List<Account>> actListMap = new Map<Id,List<Account>>();
        
        //Iterate over core account group member records
        if(childAccounts != null){
			System.debug('@@ childAccounts'+childAccounts);
			for(Id i : childAccounts.keySet()){
				Set<String> childAccountBizOrgType = new Set<String>();
                Set<String> childAccountPartnerSegment = new Set<String>();
				
				if(setOfPagIds.contains(childAccounts.get(i).Core_IPA_One_Partner_Id__c)){
					
					if(childAccounts.get(i).Core_Account_Type__c != null && String.isNotBlank(childAccounts.get(i).Core_Account_Type__c)){
                        childAccountBizOrgType.addAll(childAccounts.get(i).Core_Account_Type__c.split(';'));
                    }
					
					if(childAccounts.get(i).Core_IPA_Partner_Segment__c != null && String.isNotBlank(childAccounts.get(i).Core_IPA_Partner_Segment__c)){
                        childAccountPartnerSegment.addAll(childAccounts.get(i).Core_IPA_Partner_Segment__c.split(';'));
                    }
				}
				System.debug('@@ childAccountBizOrgType'+childAccountBizOrgType);
                System.debug('@@ childAccountPartnerSegment'+childAccountPartnerSegment);
				act5.put(i,childAccountBizOrgType);
                act6.put(i,childAccountPartnerSegment);
			}
		}
		
		System.debug('@@ act5 childAccountBizOrgType '+act5);
        System.debug('@@ act6 childAccountPartnerSegment '+act6);
		
		if(parentAccounts != null){
			System.debug('@@ parentAccounts'+parentAccounts);
			for(Id i : parentAccounts.keySet()){
				
				Set<String> pagBizOrgType = new Set<String>();
                Set<String> pagPartnerSegment = new Set<String>();
				
				if(setOfPagIds.contains(i)){
					
					if(parentAccounts.get(i).Core_Account_Type__c != null && 
                       String.isNotBlank(parentAccounts.get(i).Core_Account_Type__c)){
                           pagBizOrgType.addAll(parentAccounts.get(i).Core_Account_Type__c.split(';'));
                       }
                    
                    if(parentAccounts.get(i).Core_IPA_Partner_Segment__c != null && 
                       String.isNotBlank(parentAccounts.get(i).Core_IPA_Partner_Segment__c)){
                           pagPartnerSegment.addAll(parentAccounts.get(i).Core_IPA_Partner_Segment__c.split(';'));
                       }
				}
				System.debug('@@ pagBizOrgType'+pagBizOrgType);
                System.debug('@@ pagPartnerSegment'+pagPartnerSegment);
				act7.put(i,pagBizOrgType);
                act8.put(i,pagPartnerSegment);

			}
		}
		System.debug('@@ act7 pagBizOrgType'+act7);
        System.debug('@@ act8 pagPartnerSegment'+act8);		
                
        Map<String,Set<String>> finalPagIdMap = new Map<String,Set<String>>();
        Map<String,String> finalPagBizOrgScenario = new Map<String,String>();
        Map<String,Set<String>> finalPagIdMap2 = new Map<String,Set<String>>();
        Map<String,Set<String>> finalPagIdMap4 = new Map<String,Set<String>>();
        Set<String> pagAdditionBizOrgType = new Set<String>();
        Set<String> pagRemovalBizOrgType = new Set<String>();
        Set<String> pagAdditionPartnerSegments = new Set<String>();
        Set<String> pagRemovalPartnersegments = new Set<String>();
        Map<String,Set<String>> finalPagIdMap3 = new Map<String,Set<String>>();
        Map<Id,Set<String>> mapForNoRemovalBizOrgType = new Map<Id,Set<String>>();
        
        //Iterate over CAG ID + PAG Biz Org Types
        for(String i : childAccounts.keySet()){
            
            if(mapOfAddedBizOrgTypes.get(childAccounts.get(i).Core_IPA_One_Partner_Id__c) != null && 
               mapOfAddedBizOrgTypes.get(childAccounts.get(i).Core_IPA_One_Partner_Id__c).size() > 0){
                   //Addition Scenario
                   System.debug('Biz Org Type - Addition');
                   for(String b : mapOfAddedBizOrgTypes.get(childAccounts.get(i).Core_IPA_One_Partner_Id__c)){
                       if(act7.get(childAccounts.get(i).Core_IPA_One_Partner_Id__c) != null && (!act7.get(childAccounts.get(i).Core_IPA_One_Partner_Id__c).contains(b))){
                           System.debug('Biz Org Type Addition - b'+b);
                           pagAdditionBizOrgType.add(b);
                       }
                   }
               }
            
            Set<String> noRemoval = new Set<String>();
            
            if(mapOfRemovedBizOrgTypes.get(childAccounts.get(i).Core_IPA_One_Partner_Id__c) != null && 
               mapOfRemovedBizOrgTypes.get(childAccounts.get(i).Core_IPA_One_Partner_Id__c).size() > 0){
                   //Removal Scenario
                   if(act5.keySet().contains(i) && mapOfRemovedBizOrgTypes.get(childAccounts.get(i).Core_IPA_One_Partner_Id__c).size() > 0){
                       System.debug('Biz Org Type Removal');
                       for(String b : mapOfRemovedBizOrgTypes.get(childAccounts.get(i).Core_IPA_One_Partner_Id__c)){

                           if(act7.get(childAccounts.get(i).Core_IPA_One_Partner_Id__c) != null && act7.get(childAccounts.get(i).Core_IPA_One_Partner_Id__c).contains(b)){
                               System.debug('Biz ORg Type Removal -b'+b);
                               System.debug('Present in Parent');
                               if(act5.get(i) != null && act5.get(i).contains(b)){
                                   System.debug('Present in child');
                                   if(finalPagIdMap2.get(childAccounts.get(i).Core_IPA_One_Partner_Id__c) != null && finalPagIdMap2.get(childAccounts.get(i).Core_IPA_One_Partner_Id__c).size() > 0 && finalPagIdMap2.get(childAccounts.get(i).Core_IPA_One_Partner_Id__c).contains(b)){
                                       System.debug('Before Removal'+finalPagIdMap2);
                                       finalPagIdMap2.get(childAccounts.get(i).Core_IPA_One_Partner_Id__c).remove(b);
                                       System.debug('After Removal'+finalPagIdMap2);
                                   }
                                   
								   System.debug('Restricted ones addition');
                                       noRemoval.add(b);
                                       System.debug('noRemoval'+noRemoval);
                                       mapForNoRemovalBizOrgType.put(childAccounts.get(i).Core_IPA_One_Partner_Id__c,noRemoval);
                                       System.debug('mapForNoRemovalBizOrgType'+mapForNoRemovalBizOrgType);
                               }
                               
                               else{
                                   System.debug('Not Present in child');
								   System.debug('Line 346 mapForNoRemovalBizOrgType'+mapForNoRemovalBizOrgType);
								   System.debug('Line 347 mapForNoRemovalBizOrgType.get()'+mapForNoRemovalBizOrgType.get(childAccounts.get(i).Core_IPA_One_Partner_Id__c));
                                  
								  if((mapForNoRemovalBizOrgType.get(childAccounts.get(i).Core_IPA_One_Partner_Id__c) != null && (!mapForNoRemovalBizOrgType.get(childAccounts.get(i).Core_IPA_One_Partner_Id__c).contains(b))) || (mapForNoRemovalBizOrgType.get(childAccounts.get(i).Core_IPA_One_Partner_Id__c) == null))
								  {
                                       System.debug('Add it to the Map');
                                       pagRemovalBizOrgType.add(b);
                                   }

                               }
                           }
                           
                       }
                   }
               }
            //mapForNoRemoval Contains PAG Id
            finalPagIdMap.put(childAccounts.get(i).Core_IPA_One_Partner_Id__c,pagAdditionBizOrgType);
            finalPagIdMap2.put(childAccounts.get(i).Core_IPA_One_Partner_Id__c,pagRemovalBizOrgType);
            
        }
        System.debug('@@ finalPagIdMap'+finalPagIdMap);
        System.debug('@@ finalPagIdMap2'+finalPagIdMap2);
        
        Map<Id,Set<String>> mapForNoRemovalValues = new Map<Id,Set<String>>();
        
        //Iterate over CAG ID + PAG partner segments
        for(String i : childAccounts.keySet()){
            
            if(mapOfAddedPartnerSegments.get(childAccounts.get(i).Core_IPA_One_Partner_Id__c) != null && 
               mapOfAddedPartnerSegments.get(childAccounts.get(i).Core_IPA_One_Partner_Id__c).size() > 0){
                   //Addition Scenario
                   System.debug('Partner Segment - Addition');
                   for(String b : mapOfAddedPartnerSegments.get(childAccounts.get(i).Core_IPA_One_Partner_Id__c)){
                       if(act8.get(childAccounts.get(i).Core_IPA_One_Partner_Id__c) != null && (!act8.get(childAccounts.get(i).Core_IPA_One_Partner_Id__c).contains(b))){
                           System.debug('Partner Segment - b'+b);
                           pagAdditionPartnerSegments.add(b);
                       }
                   }
               }
            
            Set<String> noRemoval = new Set<String>();
            
            if(mapOfRemovedPartnerSegments.get(childAccounts.get(i).Core_IPA_One_Partner_Id__c) != null && 
               mapOfRemovedPartnerSegments.get(childAccounts.get(i).Core_IPA_One_Partner_Id__c).size() > 0){
                   //Removal Scenario
                   if(act6.keySet().contains(i) && mapOfRemovedPartnerSegments.get(childAccounts.get(i).Core_IPA_One_Partner_Id__c).size() > 0){
                       System.debug('PArtner Segment Removal');
                       
                       for(String b : mapOfRemovedPartnerSegments.get(childAccounts.get(i).Core_IPA_One_Partner_Id__c)){
                                                   
                           if(act8.get(childAccounts.get(i).Core_IPA_One_Partner_Id__c) != null && act8.get(childAccounts.get(i).Core_IPA_One_Partner_Id__c).contains(b)){
                               System.debug('Partner Segment Removal -b'+b);
                               System.debug('Present in Parent');
                               if(act6.get(i) != null && act6.get(i).contains(b)){
                                   System.debug('Present in child');
                                   if(finalPagIdMap4.get(childAccounts.get(i).Core_IPA_One_Partner_Id__c) != null && finalPagIdMap4.get(childAccounts.get(i).Core_IPA_One_Partner_Id__c).size() > 0 && finalPagIdMap4.get(childAccounts.get(i).Core_IPA_One_Partner_Id__c).contains(b)){
                                       System.debug('Before Removal'+finalPagIdMap4);
                                       finalPagIdMap4.get(childAccounts.get(i).Core_IPA_One_Partner_Id__c).remove(b);
                                       System.debug('After Removal'+finalPagIdMap4);
                                   }
                                   
								   System.debug('Restricted ones addition 2');
                                   noRemoval.add(b);
                                   System.debug('noRemoval'+noRemoval);
								   mapForNoRemovalValues.put(childAccounts.get(i).Core_IPA_One_Partner_Id__c,noRemoval);
                                   System.debug('mapForNoRemovalValues'+mapForNoRemovalValues);
                               }
                               
                               else{
                                   System.debug('Not Present in child');
                                   
								   if((mapForNoRemovalValues.get(childAccounts.get(i).Core_IPA_One_Partner_Id__c) != null && (!mapForNoRemovalValues.get(childAccounts.get(i).Core_IPA_One_Partner_Id__c).contains(b))) || (mapForNoRemovalValues.get(childAccounts.get(i).Core_IPA_One_Partner_Id__c) == null))
								  {
                                       System.debug('Add it to the Map');
                                       pagRemovalPartnersegments.add(b);
                                   }
                                   
                               }
                           }
                           
                       }
                       
                   }
               }
            System.debug('@@ noRemoval'+noRemoval);	
            
            finalPagIdMap3.put(childAccounts.get(i).Core_IPA_One_Partner_Id__c,pagAdditionPartnerSegments);	
            finalPagIdMap4.put(childAccounts.get(i).Core_IPA_One_Partner_Id__c,pagRemovalPartnersegments);
            
        }
        
        System.debug('@@ finalPagIdMap3'+finalPagIdMap3);
        System.debug('@@ finalPagIdMap4'+finalPagIdMap4);
        System.debug('@@ mapForNoRemovalValues'+mapForNoRemovalValues);
        
        //List<Account> actToUpdate = new List<Account>();
        List<Account> finalUpdateAccount = new List<Account>();
        
        if(parentAccounts.size() > 0){
            for(Account p : parentAccounts.values()){	
                Set<String> bizOrgs = new Set<String>();
                Set<String> partnerSegment = new Set<String>();
                Account accountUpdate;
                System.debug('Update Biz Org Type');
                if(finalPagIdMap.get(p.Id) != null && finalPagIdMap.get(p.Id).size() > 0){
                    for(String a : finalPagIdMap.get(p.Id)){
                        System.debug('Biz Org Type Addition -a'+a);
                        if(p.Core_Account_Type__c == null || p.Core_Account_Type__c == ''){
                            p.Core_Account_Type__c = a;
                        }
                        else{
                            p.Core_Account_Type__c = p.Core_Account_Type__c+';'+a;
                        }
                        System.debug('p.Core_Account_Type__c'+p.Core_Account_Type__c);
                    }
					accountUpdate = p;
                }
                
                if(finalPagIdMap2.get(p.Id) != null && finalPagIdMap2.get(p.Id).size() > 0){
                    bizOrgs.addAll(p.Core_Account_Type__c.split(';'));
                    System.debug('bizOrgs - before removal'+bizOrgs);
                    for(String a : finalPagIdMap2.get(p.Id)){
                        System.debug('Biz Org Type Removal -a'+a);
                        bizOrgs.remove(a);
                        System.debug('bizOrgs - After removal'+bizOrgs);
                    }
                    if(bizOrgs.size() == 0){
                        p.Core_Account_Type__c = '';
                    }
                    if(bizOrgs.size() > 0){
                        p.Core_Account_Type__c = '';
                        for(String b : bizOrgs){
                            System.debug('b'+b);
                            if(p.Core_Account_Type__c == null || p.Core_Account_Type__c == ''){
                                p.Core_Account_Type__c = b;
                            }
                            else{
                                p.Core_Account_Type__c = p.Core_Account_Type__c+';'+b;  
                            }
                        }
                    }
                    System.debug('p.Core_Account_Type__c'+p.Core_Account_Type__c);
					accountUpdate = p;
                }
                
                System.debug('Update Partner Segment');
                if(finalPagIdMap3.get(p.Id) != null && finalPagIdMap3.get(p.Id).size() > 0){
                    for(String a : finalPagIdMap3.get(p.Id)){
                        System.debug('PArtner Segment Addition -a'+a);
                        if(p.Core_IPA_Partner_Segment__c == null || p.Core_IPA_Partner_Segment__c == ''){
                            p.Core_IPA_Partner_Segment__c = a;
                        }
                        else{
                            p.Core_IPA_Partner_Segment__c = p.Core_IPA_Partner_Segment__c+';'+a;
                        }
                        System.debug('p.Core_IPA_Partner_Segment__c'+p.Core_IPA_Partner_Segment__c);
                    }
					accountUpdate = p;
                }
                
                if(finalPagIdMap4.get(p.Id) != null && finalPagIdMap4.get(p.Id).size() > 0){
                    partnerSegment.addAll(p.Core_IPA_Partner_Segment__c.split(';'));
                    System.debug('partnerSegment - before removal'+partnerSegment);
                    for(String a : finalPagIdMap4.get(p.Id)){
                        System.debug('PArtner Segment Removal -a'+a);
                        partnerSegment.remove(a);
                        System.debug('partnerSegment - After removal'+partnerSegment);
                    }
                    if(partnerSegment.size() == 0){
                        p.Core_IPA_Partner_Segment__c = '';
                    }
                    if(partnerSegment.size() > 0){
                        p.Core_IPA_Partner_Segment__c = '';
                        for(String b : partnerSegment){
                            System.debug('b'+b);
                            if(p.Core_IPA_Partner_Segment__c == null || p.Core_IPA_Partner_Segment__c == ''){
                                p.Core_IPA_Partner_Segment__c = b;
                            }
                            else{
                                p.Core_IPA_Partner_Segment__c = p.Core_IPA_Partner_Segment__c+';'+b;  
                            }
                        }
                    }
                    System.debug('p.Core_IPA_Partner_Segment__c'+p.Core_IPA_Partner_Segment__c);
					accountUpdate = p;
                }
                
				if(accountUpdate!= null){
                System.debug('@@ Updated Final Record'+accountUpdate);
                finalUpdateAccount.add(accountUpdate);
				}
				
            }
        }
        
        if(finalUpdateAccount.size() > 0){
            update finalUpdateAccount;
        }
        
    }
}