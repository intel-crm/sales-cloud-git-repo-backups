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
public with sharing class PRM_searchSfdcAccounts {
    public static final Integer CRITERIA_ONE=1;
    public static final Integer CRITERIA_TWO=2;
    public static final Integer CRITERIA_THREE=3;
    public static final Integer CRITERIA_FOUR=4;
    public static final Integer CRITERIA_FIVE=5;
    public static final Integer CRITERIA_SIX=6; 
    public static String strCountryCode;
    
    //public static boolean IPARefresh = Boolean.valueOf(label.PRM_IPARefresh);
    
    public static boolean emailValidationCheck(String email){
        //System.debug('>>>> email : '+email);
        String emailRegex = System.Label.PRM_Email_Regex;
        //System.debug('Email Regex : '+emailRegex);
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
        //Added by Naresh as part of US637998
        //system.debug('strCountryCode PROCCountries ==>'+Label.PRM_PROC_Countries);
        List<String> PROCCountries = Label.PRM_PROC_Countries.toUpperCase().split(',');
        //system.debug('strCountryCode PROCCountries ==>'+PROCCountries);
        //system.debug('strCountryCode ==>'+strCountryCode);
        //List<Core_Intel_System_Accounts__mdt> systemAccounts = new List<Core_Intel_System_Accounts__mdt>();
        Set<Id> accountIds = new Set<Id>();
        map<id,contact> contactsMap = new map<id,contact>();
        Map<String,Core_Intel_System_Accounts__mdt> mapSysAcc = new Map<String,Core_Intel_System_Accounts__mdt>();
        Set<String>SysAccIdSet = new Set<String>();
        
        /*TWC727-19 - START - UTKARSH - As part of the story we need to restrict system account to appear in SBC at both AEM form and salesforce*/
        for(Core_Intel_System_Accounts__mdt systemAccounts :[Select id,AccountId__c,Account_Name__c From Core_Intel_System_Accounts__mdt]){
            mapSysAcc.put(systemAccounts.id,systemAccounts);
        }
        for(String keySetString :mapSysAcc.keySet()){
            SysAccIdSet.add(mapSysAcc.get(keySetString).Account_Name__c); // 'SysAccIdSet' is added as a condition check at line no 63.
        }
        /*TWC727-19 - END*/
        if(isBlacklistedEmailDomian(contactDomain) && (String.isEmpty(strCountryCode) || (!String.isEmpty(strCountryCode) && !PROCCountries.contains(strCountryCode.toUpperCase())))){
        //if(isBlacklistedEmailDomian(contactDomain)){
            contactDomain = String.escapeSingleQuotes(contactDomain.substringAfter('@'));
            //System.debug('ContactDomain : '+contactDomain);
            //contactDomain = String.escapeSingleQuotes(contactDomain);
            Id intelaccountRT = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
            accountIds.add(intelaccountRT);
            accountIds.add(Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('Inactive_Account').getRecordTypeId());
            List<List<SObject>> searchList = [FIND :contactDomain IN EMAIL FIELDS RETURNING Contact(id,name,Accountid WHERE account.recordtype.id=:accountIds AND Account.Name NOT IN:SysAccIdSet)];
            Contact[] contList = (Contact[])searchList[0];
            for(contact ct : contList){
                contactsMap.put(ct.Accountid,ct);
                //system.debug('Contacts--> '+contactsMap);
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
            searchResultsInst.PRM_SearchScore_Nbr__c=0;
        return searchResultsInst;
    }
    
     public static PRM_CIMSearchResults__c instCimSearchResultsForEmailDomainMatch(PRM_Registration_Request__c regRequest,Id acctId){
        PRM_CIMSearchResults__c searchResultsInst = new PRM_CIMSearchResults__c();
        Account acc = new Account(id = acctId);
        if(regRequest!=null){
            searchResultsInst.PRM_RegReq_Id__c = regRequest.id;
        }
        searchResultsInst.PRM_Account_Id__c = acc.id;
        //searchResultsInst.PRM_SearchScore_Nbr__c=Integer.valueOf(System.Label.PRM_Default_Search_Score_Email_Domain_Match);
        searchResultsInst.PRM_SearchScore_Nbr__c=0;
        return searchResultsInst;
    }
    // Common method for sorting the accounts based on IPA/Non-IPA and Search score
    public static List<PRM_SearchAccounts> searchForRelatedAccount(List<PRM_CIMSearchResults__c> listOfCimResult, Set<Id> domainBaseAccIdset){
        List<PRM_SearchAccounts> lstSearchAccountObj = new List<PRM_SearchAccounts>();     
        Map<String,Double> cimIdMap = new Map<String,Double>();
        Map<Id,Integer> accIdMap= new Map<Id,Integer>(); 
        Map<Id,String> accCimMap = new Map<Id,String>();
        Map<String,Core_Intel_System_Accounts__mdt> mapSysAcc = new Map<String,Core_Intel_System_Accounts__mdt>();
        Set<String>SysAccIdSet = new Set<String>();
        /*TWC727-19 - START - UTKARSH - As part of the story we need to restrict system account to appear in SBC at both AEM form and salesforce*/
        for(Core_Intel_System_Accounts__mdt systemAccounts :[Select id,AccountId__c,Account_Name__c From Core_Intel_System_Accounts__mdt]){
            mapSysAcc.put(systemAccounts.id,systemAccounts);
        }
        for(String keySetString :mapSysAcc.keySet()){
            SysAccIdSet.add(mapSysAcc.get(keySetString).Account_Name__c); // 'SysAccIdSet' is added as a condition check at line no 63.
        }
        /*TWC727-19 - END*/
        if(listOfCimResult != null){
            for(PRM_CIMSearchResults__c cimResult : listOfCimResult){
                
                if(cimResult.PRM_Account_Id__c != null){                    
                    if(!accIdMap.containsKey(cimResult.PRM_Account_Id__c)){
                        accIdMap.put(cimResult.PRM_Account_Id__c, (cimResult.PRM_SearchScore_Nbr__c != null ? cimResult.PRM_SearchScore_Nbr__c.intValue():0));
                    } 
                    accCimMap.put(cimResult.PRM_Account_Id__c,cimResult.PRM_CIM_Id__c);
                }else if(cimResult.PRM_CIM_Id__c!=null && !cimIdMap.containsKey(cimResult.PRM_CIM_Id__c)){
                    cimIdMap.put(cimResult.PRM_CIM_Id__c, cimResult.PRM_SearchScore_Nbr__c); 
                }                
            }
        }
        
        Set<Id> accSetId = accIdMap.isEmpty() ? domainBaseAccIdset : accIdMap.keySet();
        //Added below code as a prt of TWC729-3018 3rd issue
        List<Id> accountRecordTypeIds = new List<Id>();           
        accountRecordTypeIds.add(Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId());
        accountRecordTypeIds.add(Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('Inactive_Account').getRecordTypeId());
        
        // Added in SOQL query RecordTypeId, in where condition RecordTypeId IN:accountRecordTypeIds as a prt of TWC729-3018 3rd issue
        List<Account> acctobj = new List<Account>();
        // IPA Refresh 2.0 - TWC729-7874
        acctobj = [select id, name, BillingStreet, BillingCity,BillingCountry,BillingCountryCode, BillingStateCode, BillingPostalCode,Core_Intel_Partner_Alliance_PartnerGroup__c,Core_IPA_Partner_Role__c,RecordType.DeveloperName,Core_Covered_Account__c,RecordTypeId,
                    (SELECT Name,PRM_Agreement_Sign_Dt__c,PRM_InActive_Ind__c,PRM_Signed_By_Name__c,PRM_Signed_By_Email__c,PRM_Partner_Agreement_Id__r.Name,PRM_Partner_Agreement_Id__r.PRM_InActive_Ind__c,PRM_Partner_Agreement_Id__r.PRM_Agreement_Category_Nm__c,PRM_Partner_Agreement_Id__r.PRM_Agreement_Cd__c,PRM_Partner_Agreement_Id__r.PRM_Channel_Program_Id__r.Name FROM AccountLegalAgreementAssociations__r)
                    from Account where (id in :accSetId) AND RecordTypeId IN:accountRecordTypeIds AND Name NOT IN:SysAccIdSet];
        for(Account acc : acctobj){
                PRM_SearchAccounts accSearchObj = new PRM_SearchAccounts(acc.id,accCimMap.get(acc.id), acc, (domainBaseAccIdset.contains(acc.id) && !accIdMap.containsKey(acc.id))? Integer.valueOf(System.Label.PRM_Default_Search_Score): (accIdMap.get(acc.id) != null ? accIdMap.get(acc.id) : 0));
            lstSearchAccountObj.add(accSearchObj);
        }

        return lstSearchAccountObj;
    }
    
    
    
    //public static List<PRM_SearchAccounts> sortBasedOnIPAandPartnerRole(List<PRM_SearchAccounts> lstSrcAccount, Set<Id> domainBasedIds, Map<Id, RelatedACMRecords> acmMapObj,Map<id,account> ipaPartnerRoleAccsWithCover, Map<id,account> ipaPartnerRoleAccs,map<id,account> ipaAccounts, Map<id,account> ipaPartnerRoleAccsWithOutCover,map<id,account> nonipaPartnerRoleAccsWithCover,map<id,account> nonIpaAccounts){
    //     List<PRM_SearchAccounts> sortedListOfAccount = new List<PRM_SearchAccounts>();        
    //     List<PRM_SearchAccounts> tempLst=new List<PRM_SearchAccounts>();
    //     Map<Integer, List<PRM_SearchAccounts>> sortedDomainIDMap = new Map<Integer, List<PRM_SearchAccounts>>();
    //     Map<Integer, List<PRM_SearchAccounts>> sortedCIMIDMap = new Map<Integer, List<PRM_SearchAccounts>>();
    //     Map<Integer, List<PRM_SearchAccounts>> sortedCIMIDMinScrMap = new Map<Integer, List<PRM_SearchAccounts>>();
    //     Integer targetLimit = targetLimit();
    //     //First sorting based on search score
    //     lstSrcAccount.sort();
    //     Map<Integer, List<PRM_SearchAccounts>> mapOfsrcScoreSrcAccount = new Map<Integer, List<PRM_SearchAccounts>>();
    //     for(PRM_SearchAccounts prmAccObj : lstSrcAccount){
    //         if(mapOfsrcScoreSrcAccount.containsKey(prmAccObj.searchScore)){
    //            mapOfsrcScoreSrcAccount.get(prmAccObj.searchScore).add(prmAccObj);                
    //         }else{
    //             List<PRM_SearchAccounts> searchAccList = new List<PRM_SearchAccounts>();
    //             searchAccList.add(prmAccObj);
    //             mapOfsrcScoreSrcAccount.put(prmAccObj.searchScore, searchAccList);
    //         }
    //     }        
    //     Integer searchScoreProcessed;
    //                          Integer targetcount=0;
    //     for(PRM_SearchAccounts searchAcc: lstSrcAccount){  
    //         if(searchAcc.searchScore != searchScoreProcessed){
    //             searchScoreProcessed = searchAcc.searchScore;
    //             for(PRM_SearchAccounts prmAccObj : mapOfsrcScoreSrcAccount.get(searchScoreProcessed)){
                    
    //                 // if(searchScoreProcessed>0)
    //                 // {    //system.debug('searchScoreProcessed inside score match:'+searchScoreProcessed);
    //                 //     if(searchScoreProcessed >= 30)
    //                 //     {
    //                 //         if(targetcount < targetLimit) 
    //                 //         {
    //                 //             sortedCIMIDMap = sortIdBasedOnSortingCriteria(prmAccObj,acmMapObj,ipaPartnerRoleAccsWithCover,ipaPartnerRoleAccs,ipaAccounts,ipaPartnerRoleAccsWithOutCover,sortedCIMIDMap,nonipaPartnerRoleAccsWithCover,nonIpaAccounts);
    //                 //             targetcount++;
    //                 //         }
    //                 //     }
    //                 //     else
    //                 //     { // if(targetLimit(targetcount)) {                                                                   
    //                 //         sortedCIMIDMinScrMap = sortIdBasedOnSortingCriteria(prmAccObj,acmMapObj,ipaPartnerRoleAccsWithCover,ipaPartnerRoleAccs,ipaAccounts,ipaPartnerRoleAccsWithOutCover,sortedCIMIDMinScrMap,nonipaPartnerRoleAccsWithCover,nonIpaAccounts);
    //                 //                                            //  targetcount++;                                                                          
    //                 //            // }
    //                 //     }
    //                 // } 
    //                 // else if (searchScoreProcessed==0) 
    //                 // {
    //                 //     sortedDomainIDMap = sortIdBasedOnSortingCriteria(prmAccObj,acmMapObj,ipaPartnerRoleAccsWithCover,ipaPartnerRoleAccs,ipaAccounts,ipaPartnerRoleAccsWithOutCover,sortedDomainIDMap,nonipaPartnerRoleAccsWithCover,nonIpaAccounts);
    //                 // }

    //                 if(searchScoreProcessed==30){
    //                     sortedDomainIDMap = sortIdBasedOnSortingCriteria(prmAccObj,acmMapObj,ipaPartnerRoleAccsWithCover,ipaPartnerRoleAccs,ipaAccounts,ipaPartnerRoleAccsWithOutCover,sortedDomainIDMap,nonipaPartnerRoleAccsWithCover,nonIpaAccounts);
    //                 }
    //                 else if(searchScoreProcessed>0 && searchScoreProcessed>=30 && targetcount<targetLimit){
    //                         sortedCIMIDMap = sortIdBasedOnSortingCriteria(prmAccObj,acmMapObj,ipaPartnerRoleAccsWithCover,ipaPartnerRoleAccs,ipaAccounts,ipaPartnerRoleAccsWithOutCover,sortedCIMIDMap,nonipaPartnerRoleAccsWithCover,nonIpaAccounts);
    //                         targetcount++;
    //                 }
    //                 else if(searchScoreProcessed>0 && searchScoreProcessed<30){
    //                 sortedCIMIDMinScrMap = sortIdBasedOnSortingCriteria(prmAccObj,acmMapObj,ipaPartnerRoleAccsWithCover,ipaPartnerRoleAccs,ipaAccounts,ipaPartnerRoleAccsWithOutCover,sortedCIMIDMinScrMap,nonipaPartnerRoleAccsWithCover,nonIpaAccounts);
    //                 }
    //             }  
    //         }
        
    //     }                                
    //         if(!sortedCIMIDMap.isEmpty()){
    //             //System.debug('sortedCIMIDMap .>>>> ');
                                                          
    //             sortedListOfAccount.addAll(getResponseList(sortedCIMIDMap,CRITERIA_ONE));
    //             //system.debug('sortedListOfAccount1:'+sortedListOfAccount);
    //             sortedListOfAccount.addAll(getResponseList(sortedCIMIDMap,CRITERIA_TWO));
    //             //system.debug('sortedListOfAccount2:'+sortedListOfAccount);
    //             sortedListOfAccount.addAll(getResponseList(sortedCIMIDMap,CRITERIA_THREE));
    //             //system.debug('sortedListOfAccount3:'+sortedListOfAccount);
    //             sortedListOfAccount.addAll(getResponseList(sortedCIMIDMap,CRITERIA_FOUR));
    //             //system.debug('sortedListOfAccount4:'+sortedListOfAccount);
    //             sortedListOfAccount.addAll(getResponseList(sortedCIMIDMap,CRITERIA_FIVE));
    //             //system.debug('sortedListOfAccount5:'+sortedListOfAccount);
    //             sortedListOfAccount.addAll(getResponseList(sortedCIMIDMap,CRITERIA_SIX));
    //             //system.debug('sortedListOfAccount6:'+sortedListOfAccount);
                
                               
    //           /*  sortedListOfAccount.addAll(sortedCIMIDMap.containsKey(CRITERIA_ONE)?sortedCIMIDMap.get(CRITERIA_ONE):null);
    //             sortedListOfAccount.addAll(sortedCIMIDMap.containsKey(CRITERIA_TWO)?sortedCIMIDMap.get(CRITERIA_TWO):null);
    //             sortedListOfAccount.addAll(sortedCIMIDMap.containsKey(CRITERIA_THREE)?sortedCIMIDMap.get(CRITERIA_THREE):null);
    //             sortedListOfAccount.addAll(sortedCIMIDMap.containsKey(CRITERIA_FOUR)?sortedCIMIDMap.get(CRITERIA_FOUR):null);
    //             sortedListOfAccount.addAll(sortedCIMIDMap.containsKey(CRITERIA_FIVE)?sortedCIMIDMap.get(CRITERIA_FIVE):null);*/
    //         } 
        
    //     if(!sortedDomainIDMap.isEmpty()){            
    //         //System.debug('sortedDomainIDMap .>>>> ');
    //       //  for(sortedDomainIDMap)
    //         tempLst.addAll(getResponseList(sortedDomainIDMap,CRITERIA_ONE));
    //         tempLst.addAll(getResponseList(sortedDomainIDMap,CRITERIA_TWO));
    //         tempLst.addAll(getResponseList(sortedDomainIDMap,CRITERIA_THREE));
    //         tempLst.addAll(getResponseList(sortedDomainIDMap,CRITERIA_FOUR));
    //         tempLst.addAll(getResponseList(sortedDomainIDMap,CRITERIA_FIVE));
    //         tempLst.addAll(getResponseList(sortedDomainIDMap,CRITERIA_SIX));
    //         for(PRM_SearchAccounts accs:tempLst){
    //             if(sortedListOfAccount.size() < targetLimit){
    //                 sortedListOfAccount.add(accs);
    //             }
    //         }
    //     }
    //     //system.debug('sortedListOfAccount:'+sortedListOfAccount.size());
        
    //     if(!sortedCIMIDMinScrMap.isEmpty()){            
    //     //system.debug('sortedListOfAccount11:'+sortedListOfAccount.size());
    //     //System.debug('sortedCIMIDMinScrMap .>>>> ');
    //         tempLst.clear();
    //         tempLst.addAll(getResponseList(sortedCIMIDMinScrMap,CRITERIA_ONE));
    //         tempLst.addAll(getResponseList(sortedCIMIDMinScrMap,CRITERIA_TWO));
    //         tempLst.addAll(getResponseList(sortedCIMIDMinScrMap,CRITERIA_THREE));
    //         tempLst.addAll(getResponseList(sortedCIMIDMinScrMap,CRITERIA_FOUR));
    //         tempLst.addAll(getResponseList(sortedCIMIDMinScrMap,CRITERIA_FIVE));   
    //         tempLst.addAll(getResponseList(sortedCIMIDMinScrMap,CRITERIA_SIX)); 
    //          for(PRM_SearchAccounts accs:tempLst){
    //             if(sortedListOfAccount.size() < targetLimit){
    //                 sortedListOfAccount.add(accs);
    //             }
    //         }
    //     }
        
    //     return sortedListOfAccount;
    // 
    public class sortBasedOnIPAandPartnerRoleWrapper{
        public List<PRM_SearchAccounts> lstSrcAccount{get;set;}
        public Set<Id> domainBasedIds{get;set;}
        public Map<Id, RelatedACMRecords> acmMapObj{get;set;}
        public Map<id,account> ipaPartnerRoleAccsWithCover{get;set;}
        public Map<id,account> ipaPartnerRoleAccs{get;set;}
        public map<id,account> ipaAccounts{get;set;}
        public Map<id,account> ipaPartnerRoleAccsWithOutCover{get;set;}
        public map<id,account> nonipaPartnerRoleAccsWithCover{get;set;}
        public map<id,account> nonIpaAccounts{get;set;}
    }//ATHR fixes

    public static List<PRM_SearchAccounts> sortBasedOnIPAandPartnerRole(sortBasedOnIPAandPartnerRoleWrapper att)
    {
        List<PRM_SearchAccounts> sortedListOfAccount = new List<PRM_SearchAccounts>();        
        List<PRM_SearchAccounts> tempLst=new List<PRM_SearchAccounts>();
        Map<Integer, List<PRM_SearchAccounts>> sortedDomainIDMap = new Map<Integer, List<PRM_SearchAccounts>>();
        Map<Integer, List<PRM_SearchAccounts>> sortedCIMIDMap = new Map<Integer, List<PRM_SearchAccounts>>();
        Map<Integer, List<PRM_SearchAccounts>> sortedCIMIDMinScrMap = new Map<Integer, List<PRM_SearchAccounts>>();
        Integer targetLimit = targetLimit();
        //First sorting based on search score
        att.lstSrcAccount.sort();
        Map<Integer, List<PRM_SearchAccounts>> mapOfsrcScoreSrcAccount = new Map<Integer, List<PRM_SearchAccounts>>();
        for(PRM_SearchAccounts prmAccObj : att.lstSrcAccount){
            if(mapOfsrcScoreSrcAccount.containsKey(prmAccObj.searchScore)){
               mapOfsrcScoreSrcAccount.get(prmAccObj.searchScore).add(prmAccObj);                
            }else{
                List<PRM_SearchAccounts> searchAccList = new List<PRM_SearchAccounts>();
                searchAccList.add(prmAccObj);
                mapOfsrcScoreSrcAccount.put(prmAccObj.searchScore, searchAccList);
            }
        }        
        Integer searchScoreProcessed;
                             Integer targetcount=0;
        for(PRM_SearchAccounts searchAcc: att.lstSrcAccount){  
            if(searchAcc.searchScore != searchScoreProcessed){
                searchScoreProcessed = searchAcc.searchScore;
                for(PRM_SearchAccounts prmAccObj : mapOfsrcScoreSrcAccount.get(searchScoreProcessed)){
                    
                    // if(searchScoreProcessed>0)
                    // {    //system.debug('searchScoreProcessed inside score match:'+searchScoreProcessed);
                    //     if(searchScoreProcessed >= 30)
                    //     {
                    //         if(targetcount < targetLimit) 
                    //         {
                    //             sortedCIMIDMap = sortIdBasedOnSortingCriteria(prmAccObj,att.acmMapObj,att.ipaPartnerRoleAccsWithCover,att.ipaPartnerRoleAccs,att.ipaAccounts,att.ipaPartnerRoleAccsWithOutCover,sortedCIMIDMap,att.nonipaPartnerRoleAccsWithCover,att.nonIpaAccounts);
                    //             targetcount++;
                    //         }
                    //     }
                    //     else
                    //     { // if(targetLimit(targetcount)) {                                                                   
                    //         sortedCIMIDMinScrMap = sortIdBasedOnSortingCriteria(prmAccObj,att.acmMapObj,att.ipaPartnerRoleAccsWithCover,att.ipaPartnerRoleAccs,att.ipaAccounts,att.ipaPartnerRoleAccsWithOutCover,sortedCIMIDMinScrMap,att.nonipaPartnerRoleAccsWithCover,att.nonIpaAccounts);
                    //                                            //  targetcount++;                                                                          
                    //            // }
                    //     }
                    // } 
                    // else if (searchScoreProcessed==0) 
                    // {
                    //     sortedDomainIDMap = sortIdBasedOnSortingCriteria(prmAccObj,att.acmMapObj,att.ipaPartnerRoleAccsWithCover,att.ipaPartnerRoleAccs,att.ipaAccounts,att.ipaPartnerRoleAccsWithOutCover,sortedDomainIDMap,att.nonipaPartnerRoleAccsWithCover,att.nonIpaAccounts);
                    // }
    
                    if(searchScoreProcessed==30){
                        sortIdBasedOnSortingCriteriaWrapper obj1=new sortIdBasedOnSortingCriteriaWrapper();
                        obj1.prmSrchAccnt=prmAccObj;
                        obj1.acmMapObj=att.acmMapObj;
                        obj1.ipaPartnerRoleAccsWithCover=att.ipaPartnerRoleAccsWithCover;
                        obj1.ipaPartnerRoleAccs=att.ipaPartnerRoleAccs;
                        obj1.ipaAccounts=att.ipaAccounts;
                        obj1.ipaPartnerRoleAccsWithOutCover=att.ipaPartnerRoleAccsWithOutCover;
                        obj1.inputMapObj=sortedDomainIDMap;
                        obj1.nonipaPartnerRoleAccsWithCover=att.nonipaPartnerRoleAccsWithCover;
                        obj1.nonIpaAccounts=att.nonIpaAccounts;
                        sortedDomainIDMap=sortIdBasedOnSortingCriteria(obj1);
                        //sortedDomainIDMap = sortIdBasedOnSortingCriteria(prmAccObj,att.acmMapObj,att.ipaPartnerRoleAccsWithCover,att.ipaPartnerRoleAccs,att.ipaAccounts,att.ipaPartnerRoleAccsWithOutCover,sortedDomainIDMap,att.nonipaPartnerRoleAccsWithCover,att.nonIpaAccounts);
                    }
                    else if(searchScoreProcessed>0 && searchScoreProcessed>=30 && targetcount<targetLimit){
                         sortIdBasedOnSortingCriteriaWrapper obj2=new sortIdBasedOnSortingCriteriaWrapper();
                        obj2.prmSrchAccnt=prmAccObj;
                        obj2.acmMapObj=att.acmMapObj;
                        obj2.ipaPartnerRoleAccsWithCover=att.ipaPartnerRoleAccsWithCover;
                        obj2.ipaPartnerRoleAccs=att.ipaPartnerRoleAccs;
                        obj2.ipaAccounts=att.ipaAccounts;
                        obj2.ipaPartnerRoleAccsWithOutCover=att.ipaPartnerRoleAccsWithOutCover;
                        obj2.inputMapObj=sortedCIMIDMap;
                        obj2.nonipaPartnerRoleAccsWithCover=att.nonipaPartnerRoleAccsWithCover;
                        obj2.nonIpaAccounts=att.nonIpaAccounts;
                        sortedCIMIDMap=sortIdBasedOnSortingCriteria(obj2);    
                        //sortedCIMIDMap = sortIdBasedOnSortingCriteria(prmAccObj,att.acmMapObj,att.ipaPartnerRoleAccsWithCover,att.ipaPartnerRoleAccs,att.ipaAccounts,att.ipaPartnerRoleAccsWithOutCover,sortedCIMIDMap,att.nonipaPartnerRoleAccsWithCover,att.nonIpaAccounts);
                            targetcount++;
                    }
                    else if(searchScoreProcessed>0 && searchScoreProcessed<30){
                        sortIdBasedOnSortingCriteriaWrapper obj3=new sortIdBasedOnSortingCriteriaWrapper();
                        obj3.prmSrchAccnt=prmAccObj;
                        obj3.acmMapObj=att.acmMapObj;
                        obj3.ipaPartnerRoleAccsWithCover=att.ipaPartnerRoleAccsWithCover;
                        obj3.ipaPartnerRoleAccs=att.ipaPartnerRoleAccs;
                        obj3.ipaAccounts=att.ipaAccounts;
                        obj3.ipaPartnerRoleAccsWithOutCover=att.ipaPartnerRoleAccsWithOutCover;
                        obj3.inputMapObj=sortedCIMIDMinScrMap;
                        obj3.nonipaPartnerRoleAccsWithCover=att.nonipaPartnerRoleAccsWithCover;
                        obj3.nonIpaAccounts=att.nonIpaAccounts;
                        sortedCIMIDMinScrMap=sortIdBasedOnSortingCriteria(obj3);
                      //sortedCIMIDMinScrMap = sortIdBasedOnSortingCriteria(prmAccObj,att.acmMapObj,att.ipaPartnerRoleAccsWithCover,att.ipaPartnerRoleAccs,att.ipaAccounts,att.ipaPartnerRoleAccsWithOutCover,sortedCIMIDMinScrMap,att.nonipaPartnerRoleAccsWithCover,att.nonIpaAccounts);
                    }
                }  
            }
        
        }                                
            if(!sortedCIMIDMap.isEmpty()){
                sortedListOfAccount.addAll(getResponseList(sortedCIMIDMap,CRITERIA_ONE));
                sortedListOfAccount.addAll(getResponseList(sortedCIMIDMap,CRITERIA_TWO));
                sortedListOfAccount.addAll(getResponseList(sortedCIMIDMap,CRITERIA_THREE));
                sortedListOfAccount.addAll(getResponseList(sortedCIMIDMap,CRITERIA_FOUR));
                sortedListOfAccount.addAll(getResponseList(sortedCIMIDMap,CRITERIA_FIVE));
                sortedListOfAccount.addAll(getResponseList(sortedCIMIDMap,CRITERIA_SIX));

            } 
        
        if(!sortedDomainIDMap.isEmpty()){            
            tempLst.addAll(getResponseList(sortedDomainIDMap,CRITERIA_ONE));
            tempLst.addAll(getResponseList(sortedDomainIDMap,CRITERIA_TWO));
            tempLst.addAll(getResponseList(sortedDomainIDMap,CRITERIA_THREE));
            tempLst.addAll(getResponseList(sortedDomainIDMap,CRITERIA_FOUR));
            tempLst.addAll(getResponseList(sortedDomainIDMap,CRITERIA_FIVE));
            tempLst.addAll(getResponseList(sortedDomainIDMap,CRITERIA_SIX));
            for(PRM_SearchAccounts accs:tempLst){
                if(sortedListOfAccount.size() < targetLimit){
                    sortedListOfAccount.add(accs);
                }
            }
        }
        //system.debug('sortedListOfAccount:'+sortedListOfAccount.size());
        
        if(!sortedCIMIDMinScrMap.isEmpty()){            
        //System.debug('sortedCIMIDMinScrMap .>>>> ');
            tempLst.clear();
            tempLst.addAll(getResponseList(sortedCIMIDMinScrMap,CRITERIA_ONE));
            tempLst.addAll(getResponseList(sortedCIMIDMinScrMap,CRITERIA_TWO));
            tempLst.addAll(getResponseList(sortedCIMIDMinScrMap,CRITERIA_THREE));
            tempLst.addAll(getResponseList(sortedCIMIDMinScrMap,CRITERIA_FOUR));
            tempLst.addAll(getResponseList(sortedCIMIDMinScrMap,CRITERIA_FIVE));   
            tempLst.addAll(getResponseList(sortedCIMIDMinScrMap,CRITERIA_SIX)); 
             for(PRM_SearchAccounts accs:tempLst){
                if(sortedListOfAccount.size() < targetLimit){
                    sortedListOfAccount.add(accs);
                }
            }
        }
        
        return sortedListOfAccount;
    }
    
    public static PRM_CIM_Request__mdt cimMdt;
    public static Integer targetLimit(){
    cimMdt = [Select Id, MasterLabel,API_Key__c, PRM_Async_Id__c, PRM_Calling_System__c, Score_Bar__c,PRM_Restriction_Level__c, PRM_Max_Records__c, PRM_Max_Score__c, PRM_Min_Score__c from PRM_CIM_Request__mdt where MasterLabel =: Label.PRM_Dupe_Scores];
      return  integer.valueof(cimMdt.PRM_Max_Records__c);
    }
              
    private static List<PRM_SearchAccounts> getResponseList(Map<Integer,List<PRM_SearchAccounts>> mapObject, Integer criteria){
        List<PRM_SearchAccounts> listOfAcct = new List<PRM_SearchAccounts>();
        if(mapObject.containsKey(criteria)){
            listOfAcct.addAll(mapObject.get(criteria));
        } 
        return listOfAcct;
    }
     
    public static List<PRM_SearchAccounts> getSortedAccountsCim(List<PRM_CIMSearchResults__c> listOfCimResult, Set<Id> domainBaseAccIdset,String partnerRole){//cognitive complexity of 54
        List<PRM_SearchAccounts> lstSearchAccountObj = new List<PRM_SearchAccounts>();
        map<id,account> ipaPartnerRoleAccsWithCover = new map<id,account>();
     map<id,account> ipaPartnerRoleAccs = new map<id,account>();
        map<id,account> ipaPartnerRoleAccsWithOutCover = new map<id,account>();
        map<id,account> nonipaPartnerRoleAccsWithCover = new map<id,account>();
        //map<id,account> nonipaPartnerRoleAccsWithOutCover = new map<id,account>();
        map<id,account> ipaAccounts = new map<id,account>();
        map<id,account> nonIpaAccounts = new map<id,account>();
        lstSearchAccountObj = searchForRelatedAccount(listOfCimResult,domainBaseAccIdset);
        Set<Id> setOfAccId = new Set<Id>();
        //Map<String,Core_Intel_System_Accounts__mdt> mapSysAcc = new Map<String,Core_Intel_System_Accounts__mdt>();
        //Set<String>SysAccIdSet = new Set<String>();
        for(PRM_SearchAccounts srchAccObj : lstSearchAccountObj){
            setOfAccId.add(srchAccObj.AccountId);
            //system.debug('ACCOUNT IDS--> '+srchAccObj.AccountId);
        }
        
        Map<String,Integer> ipaBadgeMap = getIPABadgeMap();
        //system.debug('ipaBadgeMap : '+ipaBadgeMap);
        //ACM Mapping with IPABadge details
        Map<Id, RelatedACMRecords> relatedACMMapObj = new Map<Id, RelatedACMRecords>();
        for(PRM_AccountChannelMembership__c acm :  [select PRM_Account_Id__c, Name ,PRM_Channel_Program_Id__r.name,toLabel(PRM_Partner_Role__c),PRM_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c, PRM_Account_Id__r.Core_Covered_Account__c ,PRM_Channel_Program_Level_Id__r.name,  PRM_Status_Nm__c, PRM_Status_Change_Dt__c from PRM_AccountChannelMembership__c where PRM_Account_Id__c  in :setOfAccId and PRM_Status_Nm__c !='Inactive']){
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
                //system.debug('acmBadge : '+acmBadge);
                if( acmBadge != null && ipaBadgeMap.get(acmBadge) < ipaBadgeMap.get(acmRecord.ipaBadge)){
                    acmRecord.ipaBadge = acmBadge;
                }                    
            }
            
            
            
            // Check for the type of account
      //1. partner role,ipa,covered
            if (acm.PRM_Partner_Role__c == partnerRole  && acm.PRM_Channel_Program_Id__r.name==System.Label.PRM_Intel_Partner_Alliance  && acm.PRM_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c==true  && acm.PRM_Account_Id__r.Core_Covered_Account__c == true){
                    
                    if(ipaPartnerRoleAccsWithOutCover.containsKey(acm.PRM_Account_Id__c)){  ipaPartnerRoleAccsWithOutCover.remove(acm.PRM_Account_Id__c);
                      }    
                    ipaPartnerRoleAccsWithCover.put(acm.PRM_Account_Id__c,null);
                    //system.debug('ipaPR --> '+ipaPartnerRoleAccsWithCover);                 
                    //2. ipa partner role ipa 
                }else if(acm.PRM_Partner_Role__c == partnerRole 
                         && acm.PRM_Channel_Program_Id__r.name==System.Label.PRM_Intel_Partner_Alliance 
                         && acm.PRM_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c==true){
                             if(ipaPartnerRoleAccsWithOutCover.containsKey(acm.PRM_Account_Id__c)){
                                 ipaPartnerRoleAccsWithOutCover.remove(acm.PRM_Account_Id__c);
                             }
                             ipaPartnerRoleAccs.put(acm.PRM_Account_Id__c,null);      

                //3. ipa accounts covered
                         }else if(acm.PRM_Channel_Program_Id__r.name==System.Label.PRM_Intel_Partner_Alliance 
                                  && acm.PRM_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c==true 
                  && acm.PRM_Account_Id__r.Core_Covered_Account__c == true){
                     if(ipaPartnerRoleAccsWithOutCover.containsKey(acm.PRM_Account_Id__c)){
                       ipaPartnerRoleAccsWithOutCover.remove(acm.PRM_Account_Id__c);
                     }
                                      
                                             ipaAccounts.put(acm.PRM_Account_Id__c,null);
                                         
                                  }
                  //4. ipa accounts uncovered
                  else if(acm.PRM_Channel_Program_Id__r.name==System.Label.PRM_Intel_Partner_Alliance 
                                  && acm.PRM_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c==true 
                  && acm.PRM_Account_Id__r.Core_Covered_Account__c == false){                                      
                                      if(!ipaPartnerRoleAccsWithCover.containsKey(acm.PRM_Account_Id__c) 
                                        && !ipaAccounts.containsKey(acm.PRM_Account_Id__c)
                    && !ipaPartnerRoleAccs.containsKey(acm.PRM_Account_Id__c) ){
                                             ipaPartnerRoleAccsWithOutCover.put(acm.PRM_Account_Id__c,null);
                                             //system.debug('ipa --> '+ipaPartnerRoleAccsWithOutCover);
                                         }
                                  }
                                  
                  //5. nonipa covered
              else if(acm.PRM_Channel_Program_Id__r.name==System.Label.PRM_Intel_Partner_Alliance 
               && acm.PRM_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c==false 
               && acm.PRM_Account_Id__r.Core_Covered_Account__c == true){
                 if(nonIpaAccounts.containsKey(acm.PRM_Account_Id__c)){
                   nonIpaAccounts.remove(acm.PRM_Account_Id__c);
                             }
                             nonipaPartnerRoleAccsWithCover.put(acm.PRM_Account_Id__c,null);
                             //system.debug('nonipaWC --> '+nonipaPartnerRoleAccsWithCover);                       
                         }
             
            /* //nonipa uncovered partner role
                         else if(acm.PRM_Partner_Role__c == partnerRole 
                         && acm.PRM_Channel_Program_Id__r.name==System.Label.PRM_Intel_Partner_Alliance 
                         && acm.PRM_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c==false 
                         && acm.PRM_Account_Id__r.Core_Covered_Account__c == false){
                             if(nonIpaAccounts.containsKey(acm.PRM_Account_Id__c)){
                                 nonIpaAccounts.remove(acm.PRM_Account_Id__c);
                             }
                             nonipaPartnerRoleAccsWithoutCover.put(acm.PRM_Account_Id__c,null);                      
                         }*/
             
             //6. non ipa accounts uncovered
                         else if(acm.PRM_Channel_Program_Id__r.name==System.Label.PRM_Intel_Partner_Alliance 
                                  && acm.PRM_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c==false
                                 && acm.PRM_Account_Id__r.Core_Covered_Account__c == false){                                      
                                      if(!nonipaPartnerRoleAccsWithCover.containsKey(acm.PRM_Account_Id__c) ){
                                             nonIpaAccounts.put(acm.PRM_Account_Id__c,null);
                                         }
                                  }
                                  
        }
        
        
        //For Empty ACMrecord scenario to put as nonIPA record
     map<id, Account> accMap=new Map<id, account>([select Core_Intel_Partner_Alliance_PartnerGroup__c,Core_Covered_Account__c, id from account where id in: setOfAccId]);
            Account acc=new Account();
        for(id accId : setOfAccId){
                if(accMap.containsKey(accId)){
         acc = accMap.get(accId);
                }
            if(!relatedACMMapObj.containsKey(accId)){
                    if(acc!=null){
                    if(acc.Core_Covered_Account__c==true){
                nonipaPartnerRoleAccsWithCover.put(accId, null);
                    }else{
                nonIpaAccounts.put(accId,null);
                    }
                relatedACMMapObj.put(accId, null);
            }
          }       
         }       
        sortBasedOnIPAandPartnerRoleWrapper obj=new sortBasedOnIPAandPartnerRoleWrapper();
        obj.lstSrcAccount=lstSearchAccountObj;
        obj.domainBasedIds=domainBaseAccIdset;
        obj.acmMapObj=relatedACMMapObj;
        obj.ipaPartnerRoleAccsWithCover=ipaPartnerRoleAccsWithCover;
        obj.ipaPartnerRoleAccs=ipaPartnerRoleAccs;
        obj.ipaAccounts=ipaAccounts;
        obj.ipaPartnerRoleAccsWithOutCover=ipaPartnerRoleAccsWithOutCover;
        obj.nonipaPartnerRoleAccsWithCover=nonipaPartnerRoleAccsWithCover;
        obj.nonIpaAccounts=nonIpaAccounts;
        return sortBasedOnIPAandPartnerRole(obj);//ATHR fixes
        //return sortBasedOnIPAandPartnerRole(lstSearchAccountObj, domainBaseAccIdset, relatedACMMapObj,ipaPartnerRoleAccsWithCover,ipaPartnerRoleAccs,ipaAccounts,ipaPartnerRoleAccsWithOutCover,nonipaPartnerRoleAccsWithCover,nonIpaAccounts);
   } 
    
    //Return map of badge with rank from custom metdata
    public static Map<String,Integer> getIPABadgeMap(){
        Map<String, Integer> mapOfIPABadge = new Map<String, Integer>();
        for(String bageMapping :LabelConfiguration__mdt.getInstance('ChannelProgramLevelRanking').Value__c.split(';')){ 
            List<String> progTier = bageMapping.split(':');
            if(!mapOfIPABadge.containsKey(progTier[0])){   
                mapOfIPABadge.put(progTier[0],Integer.valueOf(progTier[1])); 
            }
        }
        return mapOfIPABadge;
    }
    
    /** This method is written to support for Custom sorting logic based on following criteria
* 
* CRITERA 1 :- IPA Account, Partner Role, Covered Account=TRUE
* CRITERA 2 :- IPA Account, Partner Role
* CRITERA 3 :- IPA Account, Covered Account=TRUE
* CRITERA 4 :- IPA Account, Covered Account=FALSE
* CRITERA 5 :- Non-IPA Account, Covered Account=TRUE 
* CRITERA 6 :- Non-IPA Account 
*/
//sortIdBasedOnSortingCriteria(prmAccObj,acmMapObj,ipaPartnerRoleAccsWithCover,ipaPartnerRoleAccs,ipaAccounts,ipaPartnerRoleAccsWithOutCover,sortedDomainIDMap,nonipaPartnerRoleAccsWithCover,nonIpaAccounts);
    /*public static Map<Integer, List<PRM_SearchAccounts>> sortIdBasedOnSortingCriteria(PRM_SearchAccounts prmSrchAccnt, Map<Id, RelatedACMRecords> acmMapObj, Map<id,account> ipaPartnerRoleAccsWithCover,Map<id,account> ipaPartnerRoleAccs, Map<id,account> ipaAccounts, Map<id,account> ipaPartnerRoleAccsWithOutCover,Map<Integer, List<PRM_SearchAccounts>> inputMapObj,Map<Id,account> nonipaPartnerRoleAccsWithCover,Map<Id,account> nonIpaAccounts){
        //ACM association
        Account acc = prmSrchAccnt.acc;         
        prmSrchAccnt.relatedACM = acmMapObj.get(acc.id);
        
        // CRITERA 1 :- IPA Account, Partner Role, Covered Account=TRUE
        if (ipaPartnerRoleAccsWithCover.containskey(string.valueof(acc.Id))){
            mapSearchAccount(inputMapObj,prmSrchAccnt,CRITERIA_ONE);
        }        
        
        //CRITERA 2 :- IPA Account, Partner Role
        if (ipaPartnerRoleAccs.containskey(string.valueof(acc.Id))){
            mapSearchAccount(inputMapObj,prmSrchAccnt,CRITERIA_TWO);
        }
        
        //CRITERA 3 :- IPA Account Covered
        if (ipaAccounts.containskey(string.valueof(acc.Id))){
            mapSearchAccount(inputMapObj,prmSrchAccnt,CRITERIA_THREE);
        }
        
        //CRITERA 4 :- IPA Account UnCovered
        if (ipaPartnerRoleAccsWithOutCover.containskey(string.valueof(acc.Id))){
            mapSearchAccount(inputMapObj,prmSrchAccnt,CRITERIA_FOUR);
        }
        //CRITERA 5 :- Non-IPA Account covered
        if (nonipaPartnerRoleAccsWithCover.containskey(string.valueof(acc.Id))){
            mapSearchAccount(inputMapObj,prmSrchAccnt,CRITERIA_FIVE);
        }
    
    //CRITERA 6 :- Non-IPA Account
     if (nonIpaAccounts.containskey(string.valueof(acc.Id))){
            mapSearchAccount(inputMapObj,prmSrchAccnt,CRITERIA_SIX);
        }
        return inputMapObj;
        
    }*/
    
    public class sortIdBasedOnSortingCriteriaWrapper{
        public PRM_SearchAccounts prmSrchAccnt{get;set;}
        public Map<Id, RelatedACMRecords> acmMapObj{get;set;}
        public Map<id,account> ipaPartnerRoleAccsWithCover{get;set;}
        public Map<id,account> ipaPartnerRoleAccs{get;set;}
        public Map<id,account> ipaAccounts{get;set;}
        public Map<id,account> ipaPartnerRoleAccsWithOutCover{get;set;}
        public Map<Integer, List<PRM_SearchAccounts>> inputMapObj{get;set;}
        public Map<Id,account> nonipaPartnerRoleAccsWithCover{get;set;}
        public Map<Id,account> nonIpaAccounts{get;set;}
    }//ATHR fixes
    
    public static Map<Integer, List<PRM_SearchAccounts>> sortIdBasedOnSortingCriteria(sortIdBasedOnSortingCriteriaWrapper att){
        //ACM association
        Account acc = att.prmSrchAccnt.acc;         
        att.prmSrchAccnt.relatedACM = att.acmMapObj.get(acc.id);
        
        // CRITERA 1 :- IPA Account, Partner Role, Covered Account=TRUE
        if (att.ipaPartnerRoleAccsWithCover.containskey(string.valueof(acc.Id))){
            mapSearchAccount(att.inputMapObj,att.prmSrchAccnt,CRITERIA_ONE);
        }        
        
        //CRITERA 2 :- IPA Account, Partner Role
        if (att.ipaPartnerRoleAccs.containskey(string.valueof(acc.Id))){
            mapSearchAccount(att.inputMapObj,att.prmSrchAccnt,CRITERIA_TWO);
        }
        
        //CRITERA 3 :- IPA Account Covered
        if (att.ipaAccounts.containskey(string.valueof(acc.Id))){
            mapSearchAccount(att.inputMapObj,att.prmSrchAccnt,CRITERIA_THREE);
        }
        
        //CRITERA 4 :- IPA Account UnCovered
        if (att.ipaPartnerRoleAccsWithOutCover.containskey(string.valueof(acc.Id))){
            mapSearchAccount(att.inputMapObj,att.prmSrchAccnt,CRITERIA_FOUR);
        }
        //CRITERA 5 :- Non-IPA Account covered
        if (att.nonipaPartnerRoleAccsWithCover.containskey(string.valueof(acc.Id))){
            mapSearchAccount(att.inputMapObj,att.prmSrchAccnt,CRITERIA_FIVE);
        }
    
        //CRITERA 6 :- Non-IPA Account
        if (att.nonIpaAccounts.containskey(string.valueof(acc.Id))){
                mapSearchAccount(att.inputMapObj,att.prmSrchAccnt,CRITERIA_SIX);
            }
            return att.inputMapObj;
        
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