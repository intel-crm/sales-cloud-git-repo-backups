/*********************************************************************************************************************
Apex Class Name  : UCD_AccountConnector_SBR
Version       : 1.0
Created Date  : May 2021
Function      : Accepts the Account related inputs from Admin
Gets the result from UCD_CIMConnector class and getCimResults
Based on the CIM id received it searches for Salesforce accounts in the org and returns it

References: 
UCD_CIMConnector
UCD_AccountModel
UCD_AccountInfoWrapper

Modification Log :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------
* Bhavesh Jain               06/05/2020             Calling CIM system, reading the response from CIM system
*********************************************************************************************************************/
public with sharing class UCD_AccountConnector_SBR {
    public UCD_AccountConnector_SBR(){
        
    }

    /* ------------------------------------------------------------------------------------------------------------------   
* Below method returns the country name based on the country code passed
* -------------------------------------------------------------------------------------------------------------------*/
    @AuraEnabled (cacheable=true)
    public static String getCountryName(String countrycode){
        String countryName;
        Map<String,String> maplabelValCountries=new Map<String,String>();
        Schema.sObjectType objType = Account.getSObjectType();
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();  
        list<Schema.PicklistEntry> countries = fieldMap.get('BillingCountryCode').getDescribe().getPickListValues();
        for (Schema.PicklistEntry a : countries){
            maplabelValCountries.put(a.getValue(), a.getLabel());
        }
        countryName = maplabelValCountries.get(countrycode);
        return countryName;
    }
    
    /* ------------------------------------------------------------------------------------------------------------------   
* Below method returns the country name based on the country name passed
* -------------------------------------------------------------------------------------------------------------------*/
    public static String getCountryCode(String countryName){
        String countrycd;
        Map<String,String> maplabelValCountries=new Map<String,String>();
        Schema.sObjectType objType = Account.getSObjectType();
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();  
        list<Schema.PicklistEntry> countries = fieldMap.get('BillingCountryCode').getDescribe().getPickListValues();
        for (Schema.PicklistEntry a : countries){
            maplabelValCountries.put( a.getLabel(),a.getValue());
        }
        countrycd = maplabelValCountries.get(countryName);
        return countrycd;
    }
    /* ------------------------------------------------------------------------------------------------------------------   
* Below code will return the state code based on the state name entered
* -------------------------------------------------------------------------------------------------------------------*/
    public static String getStateAndCountryName(String stateCode){
        String stCode;
        Map<String,String> maplabelVal=new Map<String,String>();
        Map<String,String> countryMap=new Map<String,String>();
        Map<String,String> maplabelStateCode = new Map<String,String>();
        Schema.sObjectType objType = Account.getSObjectType();
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();        
        list<Schema.PicklistEntry> states = fieldMap.get('BillingStateCode').getDescribe().getPickListValues();
        list<Schema.PicklistEntry> country = fieldMap.get('Billingcountrycode').getDescribe().getPickListValues();
        for(Schema.PicklistEntry c:country){
            if( c.label == 'Venezuela'){
                for(Schema.PicklistEntry s:states){
                    if(s.label == statecode && c.label == 'Venezuela'){
                    }
                }
            }
        }    
        //}
        for (Schema.PicklistEntry a : states){
            maplabelStateCode.put(a.getLabel(),a.getValue());
        }
        stCode= maplabelStateCode.get(stateCode);
        return stCode;
    }
    
    public static String getStateName(String stateCode){
        String stateName;
        Map<String,String> maplabelValStates=new Map<String,String>();
        Schema.sObjectType objType = Account.getSObjectType();
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();  
        list<Schema.PicklistEntry> states = fieldMap.get('BillingStateCode').getDescribe().getPickListValues();
        for (Schema.PicklistEntry a : states){
            maplabelValStates.put(a.getValue(), a.getLabel());
        }
        stateName = maplabelValStates.get(stateCode);
        if(stateName != 'null'){
            return stateName;
        }
        return stateCode;
        
    }
    
   
    

    
    public static string getOwnerName(id ownerId){
        User usr=[select id,Name from User where id=:ownerId];
        String ownerName=usr.Name;
        return ownerName;
    }
    

    

    /* This method will get inputs from ucdAcctCreateForrm (LWC) and returns if any existing account with same 
billing address (US740756) */
    @AuraEnabled(cacheable=true)
    public static List<Account> findAccounts(String bStreet1, String bStreet2) {
        String street = bStreet1+' '+bStreet2;
        return [
            SELECT Id, Name
            FROM Account
            WHERE BillingStreet =: street
            WITH SECURITY_ENFORCED LIMIT 1
        ];
    }
    static string a;
    
    @AuraEnabled(cacheable = true)
    public static void findAccountOwners(String cimId, string rId) {
        String cim = cimId;
        String recId = rId;
        a = recId;
        updateAccountOwners(recId,cim);
    }
    
    @future
    public static void updateAccountOwners(String acc,string cimf) {
        Account objAcc;
        Id logged = UserInfo.getUserId();
        String uncovered = Label.ucdUncoveredOwner;
        List<string> uncovAcc = new List<string>();
        List<Account> scc = [select id,OwnerId,Owner.Name,Core_CIM_ID__c from Account where Core_CIM_ID__c =: cimf WITH SECURITY_ENFORCED ];
        integer isUncovered = 0;
        if(scc.size() > 1 && scc != null){
            for(Account ac : scc){
                if(ac.Owner.Name == uncovered){
                    isUncovered++;
                }
            }
        }
        else{
            if(scc[0].Owner.Name == uncovered){
                objAcc = new Account(Id = acc,OwnerId = userInfo.getUserId());
                if(Account.SObjectType.getDescribe().isAccessible()){                    
                    update objAcc;
                }                
                return ;
            }
        }
        if(isUncovered == scc.size()){
            objAcc = new Account(Id = acc,OwnerId = userInfo.getUserId());
            if(Account.SObjectType.getDescribe().isAccessible()){
                update objAcc;   
            }
        }
        
    }  
}