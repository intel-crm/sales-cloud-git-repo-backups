/*********************************************************************************************************************
Class Name  : PRM_PAGAccountTriggerRollUp
Version       : 1.0
Created Date  : AUG 2020
Function      : Roll Up Biz Org Type and Partner Segment

Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------------------------
* Rahul Kainth              8/12/2020               Roll Up Biz Org Type and Partner Segment

*********************************************************************************************************************/
public with sharing class PRM_PAGAccountTriggerRollUp {
    //public static boolean iparefresh = boolean.valueOf(Label.PRM_IPARefresh);
    
    public static void updatepagaccount(List<Account> newAccounts,Map<Id,Account> mapOfOldRecords){
        
        Map<String,Set<String>> act1 = new Map<String,Set<String>>();
        Map<String,Set<String>> act2 = new Map<String,Set<String>>();
        Map<String,Set<String>> act3 = new Map<String,Set<String>>();
        Map<String,Set<String>> act4 = new Map<String,Set<String>>();
        Set<Id> ipaAcnts = new Set<Id>();
        Id intelaccountRT = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        List<Account> newAccountsList = new List<Account>();
        newAccountsList = newAccounts != null? newAccounts:newAccountsList;
        Set<String> setOfPagIds = new Set<String>();
        Map<String,String> mapofPagIDs = new Map<String,String>();
        Map<String,Account> mapOfNewRecords = new Map<String,Account>();
    
        for(Account a : newAccountsList){
            Account oldAcnt = (Account)mapOfOldRecords.get(a.id);
            if((oldAcnt!=null && !oldAcnt.Core_Intel_Partner_Alliance_PartnerGroup__c && a.Core_Intel_Partner_Alliance_PartnerGroup__c) ||
               (oldAcnt!=null && String.IsnotBlank(a.Core_Account_Type__c) && a.Core_Account_Type__c !=oldAcnt.Core_Account_Type__c ) /*||
(oldAcnt!=null && String.IsnotBlank(a.Core_IPA_Partner_Segment__c) && a.Core_IPA_Partner_Segment__c !=oldAcnt.Core_IPA_Partner_Segment__c && !iparefresh)*/){
                ipaAcnts.add(a.id);
            } 
            if(a.Core_IPA_One_Partner_Id__c != null && a.RecordTypeId == intelaccountRT && a.Core_Intel_Partner_Alliance_PartnerGroup__c == true){
                setOfPagIds.add(a.Core_IPA_One_Partner_Id__c);
                mapofPagIDs.put(a.Core_IPA_One_Partner_Id__c,a.Id);
                mapOfNewRecords.put(a.Id,a);
            }
        }
       
        Map<String, String> mapOfOPIDAccIdAccTypeSegment = new Map<String, String>();
        //Map<String, String> mapOfOPIDLocSegment = new Map<String, String>();       
        if(!ipaAcnts.isEmpty()){
        //List<Core_Account_Group_Member__c> CAGforIPA = [SELECT Id, Name, Core_Partner_Account_Id__c, Core_Partner_Account_Id__r.Core_Account_Type__c,  Core_Partner_Account_Id__r.Core_IPA_Partner_Segment__c, Core_Intel_Account_Id__r.Core_IPA_Partner_Segment__c, Core_Intel_Account_Id__c,Core_Partner_Account_Id__r.Core_OnePartnerID__c,Core_Inactive_Ind__c,Core_Intel_Partner_Alliance_PartnerGroup__c from Core_Account_Group_Member__c WHERE Core_Intel_Account_Id__c in :ipaAcnts  AND Core_Inactive_Ind__c != true];
        //TWC729-7584 - ApexGuru
         List<Core_Account_Group_Member__c> CAGforIPA = [SELECT Id, Name, Core_Partner_Account_Id__c, Core_Partner_Account_Id__r.Core_Account_Type__c,  Core_Partner_Account_Id__r.Core_IPA_Partner_Segment__c, Core_Intel_Account_Id__r.Core_IPA_Partner_Segment__c, Core_Intel_Account_Id__c,Core_Partner_Account_Id__r.Core_OnePartnerID__c,Core_Inactive_Ind__c,Core_Intel_Partner_Alliance_PartnerGroup__c from Core_Account_Group_Member__c WHERE Core_Intel_Account_Id__c in :ipaAcnts  AND Core_Inactive_Ind__c = false];
        if(CAGforIPA.size()>0){
            //IPA 2.0 TWC729-7917 : profile response roll up/down START
            /*if(!ipaRefresh|| Test.isRunningTest()){
                PMP_Acct_Grp_Mbr_TriggerHandler.RollUpLocFlagToOPID(CAGforIPA,null);
            }
            if(ipaRefresh || Test.isRunningTest()){*/ //Switch Removal
                PMP_Acct_Grp_Mbr_TriggerHandler.PRM_IPAR_rollUpDownIPAMembership(CAGforIPA,null);
            //}
            //IPA 2.0 TWC729-7917 : profile response roll up/down END  
            for(Core_Account_Group_Member__c cag: CAGforIPA){                             
                mapOfOPIDAccIdAccTypeSegment.put(cag.Core_Partner_Account_Id__c, cag.Core_Partner_Account_Id__r.Core_Account_Type__c + '-' + cag.Core_Partner_Account_Id__r.Core_IPA_Partner_Segment__c);                                         
        	}
        }
            
     }

        for(String a : setOfPagIds){
            Set<String> oldBizOrgType = new Set<String>();
            Set<String> newBizOrgType = new Set<String>();
            Set<String> oldPartnerSegments = new Set<String>();
            Set<String> newPartnerSegments = new Set<String>();

            
            
            if(((mapOfOldRecords.get(mapofPagIDs.get(a)).Core_Account_Type__c == null || String.isBlank(mapOfOldRecords.get(mapofPagIDs.get(a)).Core_Account_Type__c)) && mapOfNewRecords.get(mapofPagIDs.get(a)).Core_Account_Type__c != null && String.isNotBlank(mapOfNewRecords.get(mapofPagIDs.get(a)).Core_Account_Type__c)) ||
              (String.isNotBlank(mapOfNewRecords.get(mapofPagIDs.get(a)).Core_Account_Type__c) && mapOfOPIDAccIdAccTypeSegment.containsKey(a) && mapOfNewRecords.get(mapofPagIDs.get(a)).Core_Account_Type__c != mapOfOPIDAccIdAccTypeSegment.get(a).split('-')[0])){
                //oldBizOrgType = new Set<String>();
                //Addition of biz org type
                newBizOrgType.addAll(mapOfNewRecords.get(mapofPagIDs.get(a)).Core_Account_Type__c.split(';'));
                
            }
            
            if((mapOfNewRecords.get(mapofPagIDs.get(a)).Core_Account_Type__c == null || String.isBlank(mapOfNewRecords.get(mapofPagIDs.get(a)).Core_Account_Type__c)) && mapOfOldRecords.get(mapofPagIDs.get(a)).Core_Account_Type__c != null && String.isNotBlank(mapOfOldRecords.get(mapofPagIDs.get(a)).Core_Account_Type__c)){
                
                //removal scenario
                oldBizOrgType.addAll(mapOfOldRecords.get(mapofPagIDs.get(a)).Core_Account_Type__c.split(';'));
                act1.put(a,oldBizOrgType);
                //newBizOrgType = new Set<String>();
            }
                        
            if(mapOfOldRecords.get(mapofPagIDs.get(a)).Core_Account_Type__c != null && String.isNotBlank(mapOfOldRecords.get(mapofPagIDs.get(a)).Core_Account_Type__c) && mapOfNewRecords.get(mapofPagIDs.get(a)).Core_Account_Type__c != null && String.isNotBlank(mapOfNewRecords.get(mapofPagIDs.get(a)).Core_Account_Type__c) &&(!mapOfOldRecords.get(mapofPagIDs.get(a)).Core_Account_Type__c.equals(mapOfNewRecords.get(mapofPagIDs.get(a)).Core_Account_Type__c)) ||
              (String.isNotBlank(mapOfOldRecords.get(mapofPagIDs.get(a)).Core_Account_Type__c) && String.isNotBlank(mapOfNewRecords.get(mapofPagIDs.get(a)).Core_Account_Type__c) && mapOfOPIDAccIdAccTypeSegment.containsKey(a) && mapOfNewRecords.get(mapofPagIDs.get(a)).Core_Account_Type__c != mapOfOPIDAccIdAccTypeSegment.get(a).split('-')[0])){
                
                //Old biz org type and new biz org type have values and are different
                oldBizOrgType.addAll(mapOfOldRecords.get(mapofPagIDs.get(a)).Core_Account_Type__c.split(';'));
                newBizOrgType.addAll(mapOfNewRecords.get(mapofPagIDs.get(a)).Core_Account_Type__c.split(';'));
                
                
            }
            
            
            /*if( (!iparefresh ||Test.isRunningTest()) && (((mapOfOldRecords.get(mapofPagIDs.get(a)).Core_IPA_Partner_Segment__c == null || String.isBlank(mapOfOldRecords.get(mapofPagIDs.get(a)).Core_IPA_Partner_Segment__c)) && mapOfNewRecords.get(mapofPagIDs.get(a)).Core_IPA_Partner_Segment__c != null && String.isNotBlank(mapOfNewRecords.get(mapofPagIDs.get(a)).Core_IPA_Partner_Segment__c)) || (mapOfNewRecords.get(mapofPagIDs.get(a)).Core_IPA_Partner_Segment__c != null && String.isNotBlank(mapOfNewRecords.get(mapofPagIDs.get(a)).Core_IPA_Partner_Segment__c)))){
                //Partner Segment Addition
                newPartnerSegments.addAll(mapOfNewRecords.get(mapofPagIDs.get(a)).Core_IPA_Partner_Segment__c.split(';'));
                
            }
            
            if( (!iparefresh ||Test.isRunningTest()) && ((mapOfNewRecords.get(mapofPagIDs.get(a)).Core_IPA_Partner_Segment__c == null || String.isBlank(mapOfNewRecords.get(mapofPagIDs.get(a)).Core_IPA_Partner_Segment__c)) && mapOfOldRecords.get(mapofPagIDs.get(a)).Core_IPA_Partner_Segment__c!= null && String.isNotBlank(mapOfOldRecords.get(mapofPagIDs.get(a)).Core_IPA_Partner_Segment__c))){
                //Partner Segment Removal
                oldPartnerSegments.addAll(mapOfOldRecords.get(mapofPagIDs.get(a)).Core_IPA_Partner_Segment__c.split(';'));
                
            }
            
            if((!iparefresh ||Test.isRunningTest()) && (mapOfOldRecords.get(mapofPagIDs.get(a)).Core_IPA_Partner_Segment__c!= null && String.isNotBlank(mapOfOldRecords.get(mapofPagIDs.get(a)).Core_IPA_Partner_Segment__c) && mapOfNewRecords.get(mapofPagIDs.get(a)).Core_IPA_Partner_Segment__c != null && String.isNotBlank(mapOfNewRecords.get(mapofPagIDs.get(a)).Core_IPA_Partner_Segment__c) && (!mapOfOldRecords.get(mapofPagIDs.get(a)).Core_IPA_Partner_Segment__c.equals(mapOfNewRecords.get(mapofPagIDs.get(a)).Core_IPA_Partner_Segment__c)))){
                
                //Old Partner Segment and new partner segment have values and are different
                oldPartnerSegments.addAll(mapOfOldRecords.get(mapofPagIDs.get(a)).Core_IPA_Partner_Segment__c.split(';'));
                
                newPartnerSegments.addAll(mapOfNewRecords.get(mapofPagIDs.get(a)).Core_IPA_Partner_Segment__c.split(';'));
                
            }*/ //Switch Removal
            
            act1.put(a,oldBizOrgType);
            act2.put(a,newBizOrgType);
            act4.put(a,newPartnerSegments);
            act3.put(a,oldPartnerSegments);
            
        }
        

        
        
        /*Map<Id,Set<String>> finalBizOrgType = new Map<Id,Set<String>>();
        Map<Id,String> finalMapOfScenario = new Map<Id,String>();
        Set<String> bizOrgSet = new Set<String>();*/
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
                String opidAccountType = '';
                if(mapOfOPIDAccIdAccTypeSegment.containsKey(a))
                    opidAccountType = mapOfOPIDAccIdAccTypeSegment.get(a).split('-')[0];
                if(!act1.get(a).contains(newValue) || ( String.IsBlank(opidAccountType) || 
                                                      !opidAccountType.contains(newValue))){
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
            addedPartnerSegments = new Set<String>();
            removedPartnerSegments = new Set<String>();
            //addedPartnerSegments.clear();
            //removedPartnerSegments.clear();
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
       
        for(Core_Account_Group_Member__c cag: cagList){
            
            Account intelAcc = new Account();
            intelAcc.id = cag.Core_Intel_Account_Id__c;
            intelAcc.Name = cag.Core_Intel_Account_Id__r.Name;
                //if(!iparefresh ||Test.isRunningTest())intelAcc.Core_IPA_Partner_Segment__c = cag.Core_Intel_Account_Id__r.Core_IPA_Partner_Segment__c;
            intelAcc.Core_Account_Type__c = cag.Core_Intel_Account_Id__r.Core_Account_Type__c;
            intelAcc.Core_IPA_One_Partner_Id__c = cag.Core_Intel_Account_Id__r.Core_IPA_One_Partner_Id__c;                          
            childAccounts.put(intelAcc.Id, intelAcc);
            
            Account pagAcc = new Account();
            pagAcc.id = cag.Core_Partner_Account_Id__c;
            pagAcc.Name = cag.Core_Partner_Account_Id__r.Name;
                //if(/*!iparefresh ||*/Test.isRunningTest())pagAcc.Core_IPA_Partner_Segment__c = cag.Core_Partner_Account_Id__r.Core_IPA_Partner_Segment__c;
            pagAcc.Core_Account_Type__c = cag.Core_Partner_Account_Id__r.Core_Account_Type__c;
            pagAcc.Core_IPA_One_Partner_Id__c = cag.Core_Partner_Account_Id__r.Core_IPA_One_Partner_Id__c;
            parentAccounts.put(pagAcc.Id, pagAcc);          
            
        }
        }
        
        Map<String,Set<String>> act5 = new Map<String,Set<String>>();
        Map<String,Set<String>> act6 = new Map<String,Set<String>>();
        Map<String,Set<String>> act7 = new Map<String,Set<String>>();
        Map<String,Set<String>> act8 = new Map<String,Set<String>>();
        //Map<Id,List<Account>> actListMap = new Map<Id,List<Account>>();
        
        //Iterate over core account group member records
        if(childAccounts != null){
            for(Id i : childAccounts.keySet()){
                Set<String> childAccountBizOrgType = new Set<String>();
                Set<String> childAccountPartnerSegment = new Set<String>();
                
                if(setOfPagIds.contains(childAccounts.get(i).Core_IPA_One_Partner_Id__c)){
                    
                    if(childAccounts.get(i).Core_Account_Type__c != null && String.isNotBlank(childAccounts.get(i).Core_Account_Type__c)){
                        childAccountBizOrgType.addAll(childAccounts.get(i).Core_Account_Type__c.split(';'));
                    }
                    
                    /*if((!iparefresh ||Test.isRunningTest()) && childAccounts.get(i).Core_IPA_Partner_Segment__c != null && String.isNotBlank(childAccounts.get(i).Core_IPA_Partner_Segment__c)){
                        childAccountPartnerSegment.addAll(childAccounts.get(i).Core_IPA_Partner_Segment__c.split(';'));
                    }*/ //Switch Removal
                }
               
                act5.put(i,childAccountBizOrgType);
                act6.put(i,childAccountPartnerSegment);
            }
        }
        
       
        if(parentAccounts != null){
            for(Id i : parentAccounts.keySet()){
                
                Set<String> pagBizOrgType = new Set<String>();
                Set<String> pagPartnerSegment = new Set<String>();
                
                if(setOfPagIds.contains(i)){
                    
                    if(parentAccounts.get(i).Core_Account_Type__c != null && 
                       String.isNotBlank(parentAccounts.get(i).Core_Account_Type__c)){
                           pagBizOrgType.addAll(parentAccounts.get(i).Core_Account_Type__c.split(';'));
                       }
                    
                    /*if((!iparefresh || test.isRunningTest()) && parentAccounts.get(i).Core_IPA_Partner_Segment__c != null &&
                       String.isNotBlank(parentAccounts.get(i).Core_IPA_Partner_Segment__c)){
                           pagPartnerSegment.addAll(parentAccounts.get(i).Core_IPA_Partner_Segment__c.split(';'));
                       }*/ //Switch Removal
                }
              
                act7.put(i,pagBizOrgType);
                act8.put(i,pagPartnerSegment);

            }
        }
            
        Map<String,Set<String>> finalPagIdMap = new Map<String,Set<String>>();
        //Map<String,String> finalPagBizOrgScenario = new Map<String,String>();
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
                   for(String b : mapOfAddedBizOrgTypes.get(childAccounts.get(i).Core_IPA_One_Partner_Id__c)){
                       if(act7.get(childAccounts.get(i).Core_IPA_One_Partner_Id__c) != null && (!act7.get(childAccounts.get(i).Core_IPA_One_Partner_Id__c).contains(b))){
                           pagAdditionBizOrgType.add(b);
                       }
                   }
               }
            
            Set<String> noRemoval = new Set<String>();
            
            if(mapOfRemovedBizOrgTypes.get(childAccounts.get(i).Core_IPA_One_Partner_Id__c) != null && 
               mapOfRemovedBizOrgTypes.get(childAccounts.get(i).Core_IPA_One_Partner_Id__c).size() > 0){
                   //Removal Scenario
                   if(act5.keySet().contains(i) && mapOfRemovedBizOrgTypes.get(childAccounts.get(i).Core_IPA_One_Partner_Id__c).size() > 0){
                       for(String b : mapOfRemovedBizOrgTypes.get(childAccounts.get(i).Core_IPA_One_Partner_Id__c)){

                           if(act7.get(childAccounts.get(i).Core_IPA_One_Partner_Id__c) != null && act7.get(childAccounts.get(i).Core_IPA_One_Partner_Id__c).contains(b)){
                               if(act5.get(i) != null && act5.get(i).contains(b)){
                                   if(finalPagIdMap2.get(childAccounts.get(i).Core_IPA_One_Partner_Id__c) != null && finalPagIdMap2.get(childAccounts.get(i).Core_IPA_One_Partner_Id__c).size() > 0 && finalPagIdMap2.get(childAccounts.get(i).Core_IPA_One_Partner_Id__c).contains(b)){
                                       
                                       finalPagIdMap2.get(childAccounts.get(i).Core_IPA_One_Partner_Id__c).remove(b);
                                       
                                   }
                                   
                                       noRemoval.add(b);
                                       
                                       mapForNoRemovalBizOrgType.put(childAccounts.get(i).Core_IPA_One_Partner_Id__c,noRemoval);
                                       
                               }
                               
                               else{
                                  if((mapForNoRemovalBizOrgType.get(childAccounts.get(i).Core_IPA_One_Partner_Id__c) != null && (!mapForNoRemovalBizOrgType.get(childAccounts.get(i).Core_IPA_One_Partner_Id__c).contains(b))) || (mapForNoRemovalBizOrgType.get(childAccounts.get(i).Core_IPA_One_Partner_Id__c) == null))
                                  {
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
      
        Map<Id,Set<String>> mapForNoRemovalValues = new Map<Id,Set<String>>();
        
        //Iterate over CAG ID + PAG partner segments
        for(String i : childAccounts.keySet()){
            
            if(mapOfAddedPartnerSegments.get(childAccounts.get(i).Core_IPA_One_Partner_Id__c) != null && 
               mapOfAddedPartnerSegments.get(childAccounts.get(i).Core_IPA_One_Partner_Id__c).size() > 0){
                   //Addition Scenario
                   for(String b : mapOfAddedPartnerSegments.get(childAccounts.get(i).Core_IPA_One_Partner_Id__c)){
                       if(act8.get(childAccounts.get(i).Core_IPA_One_Partner_Id__c) != null && (!act8.get(childAccounts.get(i).Core_IPA_One_Partner_Id__c).contains(b))){
                           pagAdditionPartnerSegments.add(b);
                       }
                   }
               }
            
            Set<String> noRemoval = new Set<String>();
            
            if(mapOfRemovedPartnerSegments.get(childAccounts.get(i).Core_IPA_One_Partner_Id__c) != null && 
               mapOfRemovedPartnerSegments.get(childAccounts.get(i).Core_IPA_One_Partner_Id__c).size() > 0){
                   //Removal Scenario
                   if(act6.keySet().contains(i) && mapOfRemovedPartnerSegments.get(childAccounts.get(i).Core_IPA_One_Partner_Id__c).size() > 0){
                       
                       for(String b : mapOfRemovedPartnerSegments.get(childAccounts.get(i).Core_IPA_One_Partner_Id__c)){
                                                   
                           if(act8.get(childAccounts.get(i).Core_IPA_One_Partner_Id__c) != null && act8.get(childAccounts.get(i).Core_IPA_One_Partner_Id__c).contains(b)){
                               if(act6.get(i) != null && act6.get(i).contains(b)){
                                   if(finalPagIdMap4.get(childAccounts.get(i).Core_IPA_One_Partner_Id__c) != null && finalPagIdMap4.get(childAccounts.get(i).Core_IPA_One_Partner_Id__c).size() > 0 && finalPagIdMap4.get(childAccounts.get(i).Core_IPA_One_Partner_Id__c).contains(b)){
                                       finalPagIdMap4.get(childAccounts.get(i).Core_IPA_One_Partner_Id__c).remove(b);
                                   }
                                   
                                   noRemoval.add(b);
                                  
                                   mapForNoRemovalValues.put(childAccounts.get(i).Core_IPA_One_Partner_Id__c,noRemoval);
                                   
                               }
                               
                               else{
                                   
                                   if((mapForNoRemovalValues.get(childAccounts.get(i).Core_IPA_One_Partner_Id__c) != null && (!mapForNoRemovalValues.get(childAccounts.get(i).Core_IPA_One_Partner_Id__c).contains(b))) || (mapForNoRemovalValues.get(childAccounts.get(i).Core_IPA_One_Partner_Id__c) == null))
                                  {
                                       pagRemovalPartnersegments.add(b);
                                   }
                                   
                               }
                           }
                           
                       }
                       
                   }
               }
            
            finalPagIdMap3.put(childAccounts.get(i).Core_IPA_One_Partner_Id__c,pagAdditionPartnerSegments); 
            finalPagIdMap4.put(childAccounts.get(i).Core_IPA_One_Partner_Id__c,pagRemovalPartnersegments);
            
        }
        
   
        //List<Account> actToUpdate = new List<Account>();
        List<Account> finalUpdateAccount = new List<Account>();
        
        if(parentAccounts.size() > 0){
            for(Account p : parentAccounts.values()){   
                Set<String> bizOrgs = new Set<String>();
                Set<String> partnerSegment = new Set<String>();
                boolean isAccountUpdated = false;
                Account accountUpdate = new Account();
                accountUpdate.id = p.id;
                if(finalPagIdMap.get(p.Id) != null && finalPagIdMap.get(p.Id).size() > 0){
                    for(String a : finalPagIdMap.get(p.Id)){
                        if(p.Core_Account_Type__c == null || p.Core_Account_Type__c == ''){
                            p.Core_Account_Type__c = a;
                        }
                        else{
                            p.Core_Account_Type__c = p.Core_Account_Type__c+';'+a;
                        }
                    }
                    accountUpdate.Core_Account_Type__c = p.Core_Account_Type__c;
                    isAccountUpdated = true;
                }
                
                if(finalPagIdMap2.get(p.Id) != null && finalPagIdMap2.get(p.Id).size() > 0){
                    bizOrgs.addAll(p.Core_Account_Type__c.split(';'));
                    for(String a : finalPagIdMap2.get(p.Id)){
                        bizOrgs.remove(a);
                    }
                    if(bizOrgs.size() == 0){
                        p.Core_Account_Type__c = '';
                    }
                    if(bizOrgs.size() > 0){
                        p.Core_Account_Type__c = '';
                        for(String b : bizOrgs){
                           
                            if(p.Core_Account_Type__c == null || p.Core_Account_Type__c == ''){
                                p.Core_Account_Type__c = b;
                            }
                            else{
                                p.Core_Account_Type__c = p.Core_Account_Type__c+';'+b;  
                            }
                        }
                    }
                    accountUpdate.Core_Account_Type__c = p.Core_Account_Type__c;
                    isAccountUpdated = true;
                }
                
                /*if((!iparefresh ||Test.isRunningTest()) && finalPagIdMap3.get(p.Id) != null && finalPagIdMap3.get(p.Id).size() > 0 ){
                    for(String a : finalPagIdMap3.get(p.Id)){
                        if(p.Core_IPA_Partner_Segment__c == null || p.Core_IPA_Partner_Segment__c == ''){
                            p.Core_IPA_Partner_Segment__c = a;
                        }
                        else if(!p.Core_IPA_Partner_Segment__c.contains(a)){
                            p.Core_IPA_Partner_Segment__c = p.Core_IPA_Partner_Segment__c+';'+a;
                        }
                    }
                    accountUpdate.Core_IPA_Partner_Segment__c = p.Core_IPA_Partner_Segment__c;
                    isAccountUpdated = true;
                }
                
                if((!iparefresh ||Test.isRunningTest()) && finalPagIdMap4.get(p.Id) != null && finalPagIdMap4.get(p.Id).size() > 0){
                    partnerSegment.addAll(p.Core_IPA_Partner_Segment__c.split(';'));
                    for(String a : finalPagIdMap4.get(p.Id)){
                        partnerSegment.remove(a);
                    }
                    if(partnerSegment.size() == 0){
                        p.Core_IPA_Partner_Segment__c = '';
                    }
                    if(partnerSegment.size() > 0){
                        p.Core_IPA_Partner_Segment__c = '';
                        for(String b : partnerSegment){
                            if(p.Core_IPA_Partner_Segment__c == null || p.Core_IPA_Partner_Segment__c == ''){
                                p.Core_IPA_Partner_Segment__c = b;
                            }
                            else if(!p.Core_IPA_Partner_Segment__c.contains(b)){
                                p.Core_IPA_Partner_Segment__c = p.Core_IPA_Partner_Segment__c+';'+b;  
                            }
                        }
                    }
                    accountUpdate.Core_IPA_Partner_Segment__c = p.Core_IPA_Partner_Segment__c;
                    isAccountUpdated = true;
                }*/ //Switch Removal
                
                if(accountUpdate!= null && isAccountUpdated == true){
                finalUpdateAccount.add(accountUpdate);
                }
                
            }
        }
        
        if(finalUpdateAccount.size() > 0){
            if(!System.isBatch() && !System.isQueueable() && !System.isFuture()){
                Schema.SObjectType acc = Schema.Account.getSObjectType();
                System.enqueueJob(new ContactERPMIntegrationStatusHandler(finalUpdateAccount,acc));
            }
            else {
                update finalUpdateAccount;
            }
        }
        
    }
}