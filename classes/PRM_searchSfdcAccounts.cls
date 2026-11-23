/*********************************************************************************************************************
Class Name    : PRM_MatchingAccounts
Version       : 1.0
Created Date  : Jan 2020
Function      : Common logic implementation used in Rest and End-to-End registration process

Modification Log :
* Developer                           Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Nishant                         07 Jan,2020            Common logic flow merging and implemention CIM and domainbased 
* Prasant Sahu                    14 Feb,2020             Logical updation based on scenrio and custom label update
*********************************************************************************************************************/
public class PRM_searchSfdcAccounts {
    public static final Integer CRITERIA_ONE=1;
    public static final Integer CRITERIA_TWO=2;
    public static final Integer CRITERIA_THREE=3;
    public static final Integer CRITERIA_FOUR=4;
    
    public static boolean emailValidationCheck(String email){
        System.debug('>>>> email : '+email);
        String emailRegex = System.Label.PRM_Email_Regex;
        System.debug('Email Regex : '+emailRegex);
        Pattern myPattern = Pattern.compile(emailRegex);
        Matcher myMatcher = MyPattern.matcher(email);
        return MyMatcher.matches();
    }
    
    public static boolean isBlacklistedEmailDomian(String email){
        if(emailValidationCheck(email)){
        	String blacklistedDomain = System.Label.PRM_Intel_BlackListed_Email_Domain.toUpperCase();
        	return !blacklistedDomain.contains(email.substringAfter('@').toUpperCase());
        }
        return false;
    }
    
    public static map<id,contact> getAccounts(String contactDomain){
        //List<contact> contList = new list<contact>();
        map<id,contact> contactsMap = new map<id,contact>();
        if(isBlacklistedEmailDomian(contactDomain)){
            contactDomain = String.escapeSingleQuotes(contactDomain.substringAfter('@'));
            System.debug('ContactDomain : '+contactDomain);
            //contactDomain = String.escapeSingleQuotes(contactDomain);
            Id intelaccountRT = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
            List<List<SObject>> searchList = [FIND :contactDomain IN EMAIL FIELDS RETURNING Contact(id,name,Accountid WHERE account.recordtype.id=:intelaccountRT)];
            System.debug('>>>> test :'+ searchList);
            Contact[] contList = (Contact[])searchList[0];
            for(contact ct : contList){
                contactsMap.put(ct.Accountid,ct);
                system.debug('Contacts--> '+contactsMap);
            }
        }
        return contactsMap;
    }
    
    public static PRM_CIMSearchResults__c instCimSearchResults(PRM_Registration_Request__c regRequest,Id acctId){
        PRM_CIMSearchResults__c searchResultsInst = new PRM_CIMSearchResults__c();
        Account acc = new Account(id = acctId);
        if(regRequest!=null){
            searchResultsInst.PRM_RegReq_Id__c = regRequest.id;
        }
        searchResultsInst.PRM_Account_Id__c = acc.id;
        searchResultsInst.PRM_SearchScore_Nbr__c=Integer.valueOf(System.Label.PRM_Default_Search_Score);
        return searchResultsInst;
    }
    
    // Common method for sorting the accounts based on IPA/Non-IPA and Search score
    public static List<PRM_SearchAccounts> searchForRelatedAccount(List<PRM_CIMSearchResults__c> listOfCimResult, Set<Id> domainBaseAccIdset){
        List<PRM_SearchAccounts> lstSearchAccountObj = new List<PRM_SearchAccounts>();     
        Map<String,Double> cimIdMap = new Map<String,Double>();
        Map<Id,Integer> accIdMap= new Map<Id,Integer>(); 
        Map<Id,String> accCimMap = new Map<Id,String>();
        
        if(listOfCimResult != null){
            for(PRM_CIMSearchResults__c cimResult : listOfCimResult){
                
                if(cimResult.PRM_Account_Id__c != null){                    
                    accIdMap.put(cimResult.PRM_Account_Id__c, (cimResult.PRM_SearchScore_Nbr__c != null ? cimResult.PRM_SearchScore_Nbr__c.intValue():0));
                    accCimMap.put(cimResult.PRM_Account_Id__c,cimResult.PRM_CIM_Id__c);
                }else if(cimResult.PRM_CIM_Id__c!=null && !cimIdMap.containsKey(cimResult.PRM_CIM_Id__c)){
                    cimIdMap.put(cimResult.PRM_CIM_Id__c, cimResult.PRM_SearchScore_Nbr__c); 
                    system.debug('cimResult.PRM_CIM_Id__c -->'+cimResult.PRM_CIM_Id__c);
                }                
                system.debug('accIdset -->'+accIdMap);
            }
        }
        
        Set<Id> accSetId = accIdMap.isEmpty() ? domainBaseAccIdset : accIdMap.keySet();
        
        system.debug('domain >>> '+domainBaseAccIdset);
        system.debug('accSetId >>> '+accSetId);
        
        for(Account acc : [select id, name, BillingStreet, BillingCity,BillingCountry,BillingCountryCode, BillingStateCode, BillingPostalCode,Core_Intel_Partner_Alliance_PartnerGroup__c,Core_IPA_Partner_Role__c,Core_CIM_ID__c from Account where Core_CIM_ID__c in :cimIdMap.keySet() or id in :accSetId]){
            PRM_SearchAccounts accSearchObj = new PRM_SearchAccounts(acc.id,accCimMap.get(acc.id), acc, domainBaseAccIdset.contains(acc.id) ? Integer.valueOf(System.Label.PRM_Default_Search_Score): (accIdMap.get(acc.id) != null ? accIdMap.get(acc.id) : (acc.Core_CIM_ID__c != null ? cimIdMap.get(acc.Core_CIM_ID__c).intValue() : 0))); 
            lstSearchAccountObj.add(accSearchObj);
        }
        
        System.debug('lstSearchAccountObj >>>>> '+lstSearchAccountObj.size());
        return lstSearchAccountObj;
    }
    
    
    
    public static List<PRM_SearchAccounts> sortBasedOnIPAandPartnerRole(List<PRM_SearchAccounts> lstSrcAccount, Set<Id> domainBasedIds, Map<Id, RelatedACMRecords> acmMapObj,Map<id,account> ipaPartnerRoleAccsWithCover,Map<id,account> ipaPartnerRoleAccsWithOutCover,map<id,account> ipaAccounts,map<id,account> nonIpaAccounts){
        List<PRM_SearchAccounts> sortedListOfAccount = new List<PRM_SearchAccounts>();        
        Map<Integer, List<PRM_SearchAccounts>> sortedDomainIDMap = new Map<Integer, List<PRM_SearchAccounts>>();
        Map<Integer, List<PRM_SearchAccounts>> sortedCIMIDMap = new Map<Integer, List<PRM_SearchAccounts>>();
        for(PRM_SearchAccounts prmAccObj : lstSrcAccount){
            if(domainBasedIds.contains(prmAccObj.AccountId)){
                sortedDomainIDMap = sortIdBasedOnSortingCriteria(prmAccObj,acmMapObj,ipaPartnerRoleAccsWithCover,ipaPartnerRoleAccsWithOutCover,ipaAccounts,nonIpaAccounts,sortedDomainIDMap);
            }else{
                sortedCIMIDMap = sortIdBasedOnSortingCriteria(prmAccObj,acmMapObj,ipaPartnerRoleAccsWithCover,ipaPartnerRoleAccsWithOutCover,ipaAccounts,nonIpaAccounts,sortedCIMIDMap);
            }
        }
        
        
        if(!sortedDomainIDMap.isEmpty()){            
            System.debug('sortedDomainIDMap .>>>> ');
            sortedListOfAccount.addAll(getResponseList(sortedDomainIDMap,CRITERIA_ONE));
            sortedListOfAccount.addAll(getResponseList(sortedDomainIDMap,CRITERIA_TWO));
            sortedListOfAccount.addAll(getResponseList(sortedDomainIDMap,CRITERIA_THREE));
            sortedListOfAccount.addAll(getResponseList(sortedDomainIDMap,CRITERIA_FOUR));
        }
        
        if(!sortedCIMIDMap.isEmpty()){
            System.debug('sortedCIMIDMap .>>>> ');
            sortedListOfAccount.addAll(getResponseList(sortedCIMIDMap,CRITERIA_ONE));
            sortedListOfAccount.addAll(getResponseList(sortedCIMIDMap,CRITERIA_TWO));
            sortedListOfAccount.addAll(getResponseList(sortedCIMIDMap,CRITERIA_THREE));
            sortedListOfAccount.addAll(getResponseList(sortedCIMIDMap,CRITERIA_FOUR));
        }
        return sortedListOfAccount;
    }
    
    
    private static List<PRM_SearchAccounts> getResponseList(Map<Integer,List<PRM_SearchAccounts>> mapObject, Integer criteria){
        List<PRM_SearchAccounts> listOfAcct = new List<PRM_SearchAccounts>();
        if(mapObject.containsKey(criteria)){
            listOfAcct = getSortedList(mapObject,criteria);
        } 
        return listOfAcct;
    }
    
    
    private static List<PRM_SearchAccounts> getSortedList(Map<Integer,List<PRM_SearchAccounts>> mapObject, Integer criteria){
        System.debug('mapObject >>>> '+mapObject);
        List<PRM_SearchAccounts> listOfObject = mapObject.get(criteria);
        System.debug('Before Sort of listOfObject >>>> '+listOfObject);
        if(listOfObject != null){ listOfObject.sort();}
        System.debug('After Sort of listOfObject >>>> '+listOfObject);
        return listOfObject;
    }
    
    
    public static List<PRM_SearchAccounts> getSortedAccountsCim(List<PRM_CIMSearchResults__c> listOfCimResult, Set<Id> domainBaseAccIdset,String partnerRole){
        List<PRM_SearchAccounts> lstSearchAccountObj = new List<PRM_SearchAccounts>();
        map<id,account> ipaPartnerRoleAccsWithCover = new map<id,account>();
        map<id,account> ipaPartnerRoleAccsWithOutCover = new map<id,account>();
        map<id,account> ipaAccounts = new map<id,account>();
        map<id,account> nonIpaAccounts = new map<id,account>();
        lstSearchAccountObj = searchForRelatedAccount(listOfCimResult,domainBaseAccIdset);
        Set<Id> setOfAccId = new Set<Id>();
        for(PRM_SearchAccounts srchAccObj : lstSearchAccountObj){
            setOfAccId.add(srchAccObj.AccountId);
            system.debug('ACCOUNT IDS--> '+srchAccObj.AccountId);
        }
        
        Map<String,Integer> ipaBadgeMap = getIPABadgeMap();
        system.debug('ipaBadgeMap : '+ipaBadgeMap);
        //ACM Mapping with IPABadge details
        Map<Id, RelatedACMRecords> relatedACMMapObj = new Map<Id, RelatedACMRecords>();
        for(PRM_AccountChannelMembership__c acm :  [select PRM_Account_Id__c, Name ,PRM_Channel_Program_Id__r.name, PRM_Partner_Role__c,PRM_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c, PRM_Account_Id__r.Core_Covered_Account__c ,PRM_Channel_Program_Level_Id__r.name,  PRM_Status_Nm__c, PRM_Status_Change_Dt__c from PRM_AccountChannelMembership__c where PRM_Account_Id__c  in :setOfAccId]){
            if(!relatedACMMapObj.containsKey(acm.PRM_Account_Id__c)){
                List<PRM_AccountChannelMembership__c> listOfAcm  = new List<PRM_AccountChannelMembership__c>();
                listOfAcm.add(acm);   
                //relatedACMMapObj.put(acm.PRM_Account_Id__c,new RelatedACMRecords(listOfAcm,acm.PRM_Channel_Program_Level_Id__r.name.toUpperCase()));
                relatedACMMapObj.put(acm.PRM_Account_Id__c,new RelatedACMRecords(listOfAcm,acm.PRM_Channel_Program_Level_Id__r.name));
            }else{
                RelatedACMRecords acmRecord = relatedACMMapObj.get(acm.PRM_Account_Id__c);
                acmRecord.listOfAcm.add(acm);
                //String acmBadge = acm.PRM_Channel_Program_Level_Id__r.name.toUpperCase();
                String acmBadge = acm.PRM_Channel_Program_Level_Id__r.name;
                system.debug('acmBadge : '+acmBadge);
                if( acmBadge != null && ipaBadgeMap.get(acmBadge) < ipaBadgeMap.get(acmRecord.ipaBadge)){
                    acmRecord.ipaBadge = acmBadge;
                }                    
            }
            
            
            
            // Check for the type of account
            if (acm.PRM_Partner_Role__c == partnerRole 
                && acm.PRM_Channel_Program_Id__r.name==System.Label.PRM_Intel_Partner_Alliance 
                && acm.PRM_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c==true 
                && acm.PRM_Account_Id__r.Core_Covered_Account__c == true){
                    
                    if(ipaAccounts.containsKey(acm.PRM_Account_Id__c)){
                        ipaAccounts.remove(acm.PRM_Account_Id__c);
                    }    
                    ipaPartnerRoleAccsWithCover.put(acm.PRM_Account_Id__c,null);
                    system.debug('ipaPR --> '+ipaPartnerRoleAccsWithCover);                 
                    
                }else if(acm.PRM_Partner_Role__c == partnerRole 
                         && acm.PRM_Channel_Program_Id__r.name==System.Label.PRM_Intel_Partner_Alliance 
                         && acm.PRM_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c==true 
                         && acm.PRM_Account_Id__r.Core_Covered_Account__c == false){
                             if(ipaAccounts.containsKey(acm.PRM_Account_Id__c)){
                                 ipaAccounts.remove(acm.PRM_Account_Id__c);
                             }
                             ipaPartnerRoleAccsWithOutCover.put(acm.PRM_Account_Id__c,null);
                             system.debug('ipaWOC --> '+ipaPartnerRoleAccsWithOutCover);                       
                         }else if(acm.PRM_Channel_Program_Id__r.name==System.Label.PRM_Intel_Partner_Alliance 
                                  && acm.PRM_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c==true){                                      
                                      if(!ipaPartnerRoleAccsWithCover.containsKey(acm.PRM_Account_Id__c) 
                                         && !ipaPartnerRoleAccsWithOutCover.containsKey(acm.PRM_Account_Id__c)){
                                             ipaAccounts.put(acm.PRM_Account_Id__c,null);
                                             system.debug('ipa --> '+ipaAccounts);
                                         }
                                  }else{
                                      if(!ipaAccounts.containsKey(acm.PRM_Account_Id__c) 
                                         && !ipaPartnerRoleAccsWithCover.containsKey(acm.PRM_Account_Id__c) 
                                         && !ipaPartnerRoleAccsWithOutCover.containsKey(acm.PRM_Account_Id__c)){                                             
                                             nonIpaAccounts.put(acm.PRM_Account_Id__c,null);
                                             system.debug('nonIpaAccounts --> '+nonIpaAccounts);
                                         }				
                                  }
        }
        
        
        //For Empty ACMrecord scenario to put as nonIPA record
        for(id accId : setOfAccId){
            if(!relatedACMMapObj.containsKey(accId)){
                System.debug('Issue Acct : '+accId);
                nonIpaAccounts.put(accId,null);
                relatedACMMapObj.put(accId, null);
            }
        }       
        
        return sortBasedOnIPAandPartnerRole(lstSearchAccountObj, domainBaseAccIdset, relatedACMMapObj,ipaPartnerRoleAccsWithCover,ipaPartnerRoleAccsWithOutCover,ipaAccounts,nonIpaAccounts);
    } 
    
    //Return map of badge with rank from custom metdata
    public static Map<String,Integer> getIPABadgeMap(){
        Map<String, Integer> mapOfIPABadge = new Map<String, Integer>();
        for(PRM_IPABadgeMapping__mdt badgeObj : [Select Id,IPA_Badge_Name__c,Rank__c from PRM_IPABadgeMapping__mdt]){
            if(!mapOfIPABadge.containsKey(badgeObj.IPA_Badge_Name__c)){                
                mapOfIPABadge.put(badgeObj.IPA_Badge_Name__c, badgeObj.Rank__c.intValue());
            }
        }
        return mapOfIPABadge;
    }
    
    /** This method is written to support for Custom sorting logic based on following criteria
* 
* CRITERA 1 :- IPA Account, Partner Role, Covered Account=TRUE
* CRITERA 2 :- IPA Account, Partner Role, Covered Account = FALSE
* CRITERA 3 :- IPA Account
* CRITERA 4 :- Non-IPA Account 
*/
    public static Map<Integer, List<PRM_SearchAccounts>> sortIdBasedOnSortingCriteria(PRM_SearchAccounts prmSrchAccnt, Map<Id, RelatedACMRecords> acmMapObj, Map<id,account> ipaPartnerRoleAccs,Map<id,account> ipaPartnerRoleAccsNotCover, Map<id,account> ipaAccounts, Map<id,account> nonIpaAccounts,Map<Integer, List<PRM_SearchAccounts>> inputMapObj){
        //ACM association
        Account acc = prmSrchAccnt.acc;         
        prmSrchAccnt.relatedACM = acmMapObj.get(acc.id);
        
        // CRITERA 1 :- IPA Account, Partner Role, Covered Account=TRUE
        if (ipaPartnerRoleAccs.containskey(string.valueof(acc.Id))){
            mapSearchAccount(inputMapObj,prmSrchAccnt,CRITERIA_ONE);
        }        
        
        //CRITERA 2 :- IPA Account, Partner Role, Covered Account = FALSE 
        if (ipaPartnerRoleAccsNotCover.containskey(string.valueof(acc.Id))){
            mapSearchAccount(inputMapObj,prmSrchAccnt,CRITERIA_TWO);
        }
        
        //CRITERA 3 :- IPA Account
        if (ipaAccounts.containskey(string.valueof(acc.Id))){
            mapSearchAccount(inputMapObj,prmSrchAccnt,CRITERIA_THREE);
        }
        
        //CRITERA 4 :- Non-IPA Account
        if (nonIpaAccounts.containskey(string.valueof(acc.Id))){
            mapSearchAccount(inputMapObj,prmSrchAccnt,CRITERIA_FOUR);
        }
        return inputMapObj;
        
    }
    
    private static void mapSearchAccount(Map<Integer, List<PRM_SearchAccounts>> inputMapObj,PRM_SearchAccounts prmSrchAccnt,Integer criteria){        
        if(!inputMapObj.containsKey(criteria)){
            List<PRM_SearchAccounts> obj1 = new List<PRM_SearchAccounts>();
            obj1.add(prmSrchAccnt);
            inputMapObj.put(criteria,obj1);
        }else{
            inputMapObj.get(criteria).add(prmSrchAccnt);
        }
    }
    
    
}