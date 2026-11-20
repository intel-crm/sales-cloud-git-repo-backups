public without sharing class ER_SearchSalesCloudAccounts 
{
    public static String strCountryCode;
    
    public static map<id,contact> getAccounts(String contactDomain){
        
        map<id,contact> contactsMap = new map<id,contact>();       
        if((String.isEmpty(strCountryCode) || (!String.isEmpty(strCountryCode))))
        {
            contactDomain = String.escapeSingleQuotes(contactDomain.substringAfter('@'));
            
            Id intelaccountRT = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
            List<List<SObject>> searchList = [FIND :contactDomain IN EMAIL FIELDS RETURNING Contact(id,name,Email,Accountid WHERE account.recordtype.id=:intelaccountRT)];
            
            Contact[] contList = (Contact[])searchList[0];
            if(Test.isRunningTest())
            {
                contList = [Select id,name,Email,Accountid FROM Contact WHERE account.recordtype.id=:intelaccountRT LIMIT 1];            
            }
            for(contact ct : contList)
            {
                contactsMap.put(ct.Accountid,ct);
            }
        }
        return contactsMap;
    }
    
    //Preparing Data(Contact Domain Matched Accounts) to look like CIM results to sort further 
    public static PRM_CIMSearchResults__c instCimSearchResults(Id acctId){
        PRM_CIMSearchResults__c searchResultsInst = new PRM_CIMSearchResults__c();
        Account acc = new Account(id = acctId);
        searchResultsInst.PRM_Account_Id__c = acc.id;
        searchResultsInst.PRM_SearchScore_Nbr__c=Integer.valueOf(System.Label.PRM_Default_Search_Score);
        return searchResultsInst;
    }
    
    // Common method for sorting the accounts based on Priority Matrix and Search score
    public static List<ER_SearchAccounts> searchForRelatedAccount(List<PRM_CIMSearchResults__c> listOfCimResult, Set<Id> domainBaseAccIdset,List<ER_SBC_PriorityMatrix__mdt> priorityMatrix){
        List<ER_SearchAccounts> lstSearchAccountObj = new List<ER_SearchAccounts>(); 
        
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
                }         
            }
        }
        
        Set<Id> accSetId = accIdMap.isEmpty() ? domainBaseAccIdset : accIdMap.keySet();
        
        String[] cimIdList;
        String cimIdSet;
        Boolean cimSetPresent = false;
        if(cimIdMap.keySet().size() > 0)
        {
            cimIdList = New List<String>(cimIdMap.keySet()); 
            cimIdSet = '\'' + String.join(cimIdList,'\',\'') + '\'';
            cimIdSet = '('+cimIdSet+')';
            cimSetPresent = true;
        }
        
        String[] acctIdList = New List<String>((List<String>)new List<Id>(accSetId)); 
        String acctIdSet = '\'' + String.join(acctIdList,'\',\'') + '\'';
        acctIdSet = '('+acctIdSet+')';
        
        String acctQuery = 'SELECT Id,Name,BillingStreet, BillingCity,BillingCountry,BillingCountryCode, BillingStateCode, BillingPostalCode,Core_CIM_ID__c,';
        
        for(ER_SBC_PriorityMatrix__mdt pmatrix : priorityMatrix)
        {
            if(!pmatrix.isSearchScore__c)
            {
                acctQuery = acctQuery + pmatrix.PriorityField__c +',';   
            }
        }
        
        if(cimSetPresent)
        {
            acctQuery = acctQuery + 'RecordType.DeveloperName from Account where (Core_CIM_ID__c in '+cimIdSet+' or Id in '+acctIdSet+') AND RecordType.DeveloperName ='+'\''+String.escapeSingleQuotes(System.Label.PRM_Intel_Account)+'\'';
        }
        else
        {
            acctQuery = acctQuery + 'RecordType.DeveloperName from Account where Id in '+acctIdSet+' AND RecordType.DeveloperName ='+'\''+String.escapeSingleQuotes(System.Label.PRM_Intel_Account)+'\'';
        }
        
        for(Account acc : Database.query(acctQuery))
        {
            ER_SearchAccounts accSearchObj = new ER_SearchAccounts(acc.id,accCimMap.get(acc.id), acc, domainBaseAccIdset.contains(acc.id) ? Integer.valueOf(System.Label.PRM_Default_Search_Score): (accIdMap.get(acc.id) != null ? accIdMap.get(acc.id) : (acc.Core_CIM_ID__c != null ? cimIdMap.get(acc.Core_CIM_ID__c).intValue() : 0))); 
            lstSearchAccountObj.add(accSearchObj);
        }
        
        return lstSearchAccountObj;
    }
     
    public static List<ER_SearchAccounts> getSortedAccountsCim(List<PRM_CIMSearchResults__c> listOfCimResult, Set<Id> acctIdsSet,String AccountType,String SearchLimit)
    {
        List<ER_SearchAccounts> lstSearchAccountObj = new List<ER_SearchAccounts>();
        List<ER_SBC_PriorityMatrix__mdt> priorityMatrix = [SELECT AccountType__c,PriorityField__c,PriorityNumber__c,isObjectField__c,PriorityValue__c,isSearchScore__c
                                                           FROM ER_SBC_PriorityMatrix__mdt WHERE AccountType__c =:AccountType ORDER by PriorityNumber__c];
        lstSearchAccountObj = searchForRelatedAccount(listOfCimResult,acctIdsSet,priorityMatrix);
        Set<Id> setOfAccId = new Set<Id>();
        for(ER_SearchAccounts srchAccObj : lstSearchAccountObj){
            setOfAccId.add(srchAccObj.AccountId);
        }
                
        return sortIdBasedOnSortingCriteria(lstSearchAccountObj,setOfAccId,priorityMatrix,SearchLimit);
    }     
 
    
    //Method to get the prority logic based on the Pririty metadata and list of accounts 
    public static List<ER_SearchAccounts> sortIdBasedOnSortingCriteria(List<ER_SearchAccounts> lstSearchAccountObj,Set<Id> acctIdSet,List<ER_SBC_PriorityMatrix__mdt> priorityMatrix,String SearchLimit)
    {
        Map<Integer, List<ER_SearchAccounts>> mapAcctsList= new Map<Integer, List<ER_SearchAccounts>>();
        List<ER_SearchAccounts> finalList= new List<ER_SearchAccounts>();
        Map<String, Schema.SObjectField> mData = Schema.SObjectType.Account.fields.getMap();
 
        //ER_SearchAccounts(Id AccountId,String cimId, Account acc, Integer searchScore)
        for(ER_SearchAccounts seacrhAcct : lstSearchAccountObj)
        {
            String pBit = '';
            for(ER_SBC_PriorityMatrix__mdt pValue : priorityMatrix)
            {
                if(pValue.isObjectField__c)
                {
                    if(mData.get(pValue.PriorityField__c).getDescribe().getType() == DisplayType.BOOLEAN)
                    {
                        if((BOOLEAN)seacrhAcct.acc.get(pValue.PriorityField__c))
                        {
                            pBit=pBit+'1';
                        }
                        else
                        {
                            pBit=pBit+'0';
                        }
                        
                    }
                    else if(mData.get(pValue.PriorityField__c).getDescribe().getType() == DisplayType.STRING)
                    {
                        String fValue=(String)seacrhAcct.acc.get(pValue.PriorityField__c);
                        if(String.isNotBlank((String)seacrhAcct.acc.get(pValue.PriorityField__c)) && !fValue.Contains('Uncovered Account'))
                        {
                            pBit=pBit+'1';
                        }
                        else
                        {
                            pBit=pBit+'0';
                        }
                    }
                }
                else
                {
                    if(pValue.isSearchScore__c)
                    {
                        if(seacrhAcct.searchScore >= Integer.valueOf(pValue.PriorityValue__c))
                        {
                            pBit=pBit+'1';
                        }
                        else
                        {
                            pBit=pBit+'0';
                        }
                    }
                }
            }
            Integer priorityValue = Core_IntegrationOptimization.GetRankedAccounts(pBit);
            if(mapAcctsList.containsKey(priorityValue))
            {
                mapAcctsList.get(priorityValue).add(seacrhAcct);
                
            }
            else
            {
                mapAcctsList.put(priorityValue,new List<ER_SearchAccounts>{seacrhAcct});
            }
        }	
        List<Integer> sortedKeys = new List<Integer>();
        List<Integer> sortedKeysDESC = new List<Integer>();
        sortedKeys.addAll(mapAcctsList.keySet());
        sortedKeys.sort();
        for(Integer i = sortedKeys.size() - 1; i >= 0; i--)
        {
            sortedKeysDESC.add(sortedKeys[i]);
        }        
        
		Integer srchLmt = 0;
        Integer lmt = String.isNotBlank(searchLimit) ? Integer.valueOf(searchLimit) : 25;
        
        for(Integer priorityNumber : sortedKeysDESC)
        {
            if(srchLmt < lmt)
            {
                if(srchLmt + mapAcctsList.get(priorityNumber).size() <= lmt)
                {
                    srchLmt = srchLmt + mapAcctsList.get(priorityNumber).size();
                    finalList.addall(mapAcctsList.get(priorityNumber));
                }
                else
                {
                    for (ER_SearchAccounts acct : mapAcctsList.get(priorityNumber))
                    {
                        if(srchLmt < lmt)//0<=10 //1<=10
                        {
                            finalList.add(acct);
                            srchLmt = srchLmt +1;
                        }
                        else
                            break;
                        
                    }                    
                }                
            }
        }
        
        return finalList;               
    } 

}