public without sharing class UCD_ACM_Utils {

    private static Map<String, Account_Create_Process_Mapping__mdt> accountProcessMappingBySourceName = new  Map<String, Account_Create_Process_Mapping__mdt>();
    private static Map<String, Core_Country_Reference__c> mCountryCodeGeoRef = new map<String, Core_Country_Reference__c>();
    private static UCD_ACM_SelectorContracts.IAccountQuerySelector accountQuerySelectorInstance = UCD_ACM_AccountQuerySelector.getInstance();

   /** 
    * description : validate Country Code
    * params : String
    * return : String
    * author and date : Ankit sharma 04/10/2021
    */
    public static String validateCountryCode(String CountryCode){
        String validCountryname = null;
        Schema.DescribeFieldResult fieldResult =  Account.BillingCountryCode.getDescribe();
        List<Schema.PicklistEntry> pickListValues = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : pickListValues){
            if(pickListVal.getValue() == CountryCode){
                validCountryname = pickListVal.getLabel();
                break;
            }
        }
        return validCountryname;
    }



        /** 
        * description : geeting country Name via country code
        * params : List<String>
        * return : Map<String,String>
        * author and date : Ankit sharma 17/01/2023
        */
        public static Map<String,String> getStateName(){

            Map<String,String> stateNameByStateCode = new Map<String,String>();
            Schema.DescribeFieldResult fieldResult =  Account.BillingStateCode.getDescribe();
            List<Schema.PicklistEntry> pickListValues = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry pickListVal : pickListValues){
                stateNameByStateCode.put(pickListVal.getValue(),pickListVal.getLabel());
            }

            return stateNameByStateCode;
            
        }


        /** 
        * description : getting country Name via country code
        * params : List<String>
        * return : Map<String,String>
        * author and date : Ankit sharma 17/01/2023
        */
        public static Map<String,String> getCountryName(){

            Map<String,String> countryNameByCountryCode = new Map<String,String>();
            Schema.DescribeFieldResult fieldResult =  Account.BillingCountryCode.getDescribe();
            List<Schema.PicklistEntry> pickListValues = fieldResult.getPicklistValues();

            for( Schema.PicklistEntry pickListVal : pickListValues){
                countryNameByCountryCode.put(pickListVal.getValue(),pickListVal.getLabel());
            }

            return countryNameByCountryCode;
            
        }

   /** 
    * description : validate Country Name
    * params : String
    * return : String
    * author and date : Ankit sharma 04/10/2021
    */
    public static String validateCountryName(String CountryName){
        String validCountryCode = null;
        Schema.DescribeFieldResult fieldResult =  Account.BillingCountryCode.getDescribe();
        List<Schema.PicklistEntry> pickListValues = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : pickListValues){
            if(pickListVal.getLabel() == CountryName){
                validCountryCode = pickListVal.getValue();
                break;
            }
        }
        return validCountryCode;
    }


    public static String getPicklistLabel(String objectName,String fieldApiName,String picklistApiName){

        if(picklistApiName != null && picklistApiName != ''){
                String picklistLabel = '';
                Schema.DescribeSObjectResult objResult = Schema.getGlobalDescribe().get(objectName).getDescribe();
                Schema.DescribeFieldResult fieldResult = objResult.fields.getMap().get(fieldAPIName).getDescribe(); 
                List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues(); 
                for( Schema.PicklistEntry picklistVal : picklistValues) { 
                    if(picklistVal.getValue() == picklistAPIName){
                        picklistLabel = picklistVal.getLabel();
                    }
                }
                return picklistLabel;
            }
            return null;
    }


        /** 
        * description : Get RecordType Name
        * params : String ObjectName
        * return : String RecordTypeId
        * author and date : Harshal Gosavi 10/12/2021
        */
        public static string recordTypeNameById(string objAPIName, string recordTypeId){
            String recordTypeName;
            if(String.isNotBlank(objAPIName) && String.isNotBlank(recordTypeId)){
                recordTypeName= Schema.getGlobalDescribe().get(objAPIName).getDescribe().getRecordTypeInfosById().get(recordTypeId).getName();
            }  
            return recordTypeName;  
        }



        public class MyPickListInfo {

            public String validFor;
            
        }

        public static Map<String, Map<String,String>> getGlobalPickList( )  {

            //Define table name that has picklist value set fields
            String objectName = 'Account';
        
            //Define controlling picklist value field
            String controllingField = 'BillingCountryCode' ;
        
            //Define dependent picklist value field        
            String dependentField =  'BillingStateCode';
        
            //Declare map variable to store list of dependent value for controlling field        
            //Map<String, List<String>> controllingInfo = new Map<String, List<String>>( ) ;
            Map<String, Map<String,String>> controllingInfo = new Map<String, Map<String,String>>( ) ;

            //Get the type being dealt with
        
            Schema.SObjectType objType = Schema.getGlobalDescribe( ).get(objectName) ;        
            Schema.DescribeSObjectResult  describeResult = objType.getDescribe ( ) ;
        
            //Get controlling field values
        
            Schema.DescribeFieldResult  controllingFieldInfo = describeResult.fields.getMap ( )        
                .get (controllingField)        
                .getDescribe ( ) ;
        
            //Get dependent field values        
            Schema.DescribeFieldResult  dependentFieldInfo = describeResult.fields.getMap ( )        
                .get (dependentField)        
                .getDescribe ( ) ;        
            List<Schema.PicklistEntry> controllingValues = controllingFieldInfo.getPicklistValues ( ) ;        
            List<Schema.PicklistEntry> dependentValues = dependentFieldInfo.getPicklistValues ( ) ;        
            //Get the label for controlling picklist value set       
            For (Schema.PicklistEntry  currControllingValue  :  controllingValues)  {    
                controllingInfo.put (currControllingValue.getValue() , new Map<String,String>( ) ) ;       
            }
            //Iterate through the dependent values

            for  (Schema.PicklistEntry  currDependentValue  :  dependentValues)  {

            //get the validFor
            
                String  jsonString  =  JSON.serialize(currDependentValue) ;           
                MyPickListInfo  info  =  (MyPickListInfo)  JSON.deserialize( jsonString, MyPickListInfo.class) ;
                String hexString  =  EncodingUtil.convertToHex (          
                EncodingUtil.base64Decode (info.validFor)            
                  )            
                .toUpperCase ( ) ;            
                Integer  baseCount  =  0;            
                for (Integer curr  :  hexString.getChars ( ) )  {                
                    Integer  val  =  0;                
                    if  (curr  >=  65) {                
                        val  =  curr  -  65  +  10;            
                    }  else  {            
                        val  =  curr  -  48;            
                    }            
                    if  ((val & 8)  ==  8)  {            
                        controllingInfo.get (controllingValues[baseCount  +  0].getValue( ) )            
                        .Put (currDependentValue.getValue( ) , currDependentValue.getLabel( )) ;            
                    }            
                    if  ((val & 4)  ==  4)  {                   
                    controllingInfo.get (controllingValues[baseCount  +  1].getValue( ) )                    
                    .Put (currDependentValue.getValue( ) , currDependentValue.getLabel( )) ;
                    }           
                    if  ((val & 2)  ==  2)  {                    
                     controllingInfo.get (controllingValues[baseCount  +  2].getValue( ) )                    
                    .Put (currDependentValue.getValue( ) , currDependentValue.getLabel( )) ;
                    }            
                    if  ((val & 1)  ==  1)  {
                        controllingInfo.get (controllingValues[baseCount  +  3].getValue( ) )
                        .Put (currDependentValue.getValue( ) , currDependentValue.getLabel( )) ;
                    }
                    baseCount  +=  4;           
                }
            }           
            return controllingInfo;           
            }

    /** 
    * description : Method to get Account Process Mapping
    * return : Map
    * author and date : ajayx.gat@intel.com 20-feb-2023
    */
    public static Map<String, Account_Create_Process_Mapping__mdt> getAccountProcessMappingBySourceName() {

        if(accountProcessMappingBySourceName.isEmpty()) {
            Map<String, Account_Create_Process_Mapping__mdt> accountProcessMappingByName = Account_Create_Process_Mapping__mdt.getAll();

            for(Account_Create_Process_Mapping__mdt accountProcess : accountProcessMappingByName.values()) {
                accountProcessMappingBySourceName.put(accountProcess.Core_Account_Reference_Source_Name__c, accountProcess);
            }
        }

        return accountProcessMappingBySourceName;
    }

    /** 
    * description : Method to get Account Process Mapping
    * return : Map
    * author and date : ajayx.gat@intel.com 20-feb-2023
    */
    public static Map<String, Account_Create_Process_Mapping__mdt> getAccountProcessMapping() {
        Map<String, Account_Create_Process_Mapping__mdt> accountProcessMapping = Account_Create_Process_Mapping__mdt.getAll();
        return accountProcessMapping;
    }
    /** 
    * description : Method to get geo field
    * params : String
    * return : String    
    * author and date : yenugantix.tejasri@intel.com 24-Mar-2023
    */
    public static String getGeoforCountry(String CountryCode){
        
        String Validgeo = null;  
        if(mCountryCodeGeoRef.isEmpty()){  
           for(Core_Country_Reference__c sobjStateRef : Core_Country_Reference__c.getall().values()){
              mCountryCodeGeoRef.put(sobjStateRef.Core_ISO_Code__c,sobjStateRef);
           }
        }
        if(mCountryCodeGeoRef.containsKey(CountryCode)){
            Validgeo = mCountryCodeGeoRef.get(CountryCode).Core_Geo__c;
        }
        return Validgeo;
    }
     /** 
    * description : Method to get Sub geo
    * params : String
    * return : String
    * author and date : yenugantix.tejasri@intel.com 24-Mar-2023
    */

    public static String getSubGeoforCountry(String CountryCode){
          
        String ValidSubgeo = null;  
        if(mCountryCodeGeoRef.isEmpty()){  
            for(Core_Country_Reference__c sobjStateRef : Core_Country_Reference__c.getall().values()){
               mCountryCodeGeoRef.put(sobjStateRef.Core_ISO_Code__c,sobjStateRef);
            }
        }
        if(mCountryCodeGeoRef.containsKey(CountryCode)){
            ValidSubgeo = mCountryCodeGeoRef.get(CountryCode).Core_Sub_Geo__c;
        }
        return ValidSubgeo;              
          
    }
        
    /*
    * description : Set UCD hierarchy fields
    * params : Account
    * author and date : chethan.s.kunder@intel.com, 25 Nov 2021
    * Updated : chethan.s.kunder@intel.com, 01 Dec 2022 - New UCD hierachy attributes integration
    * Moved to this utils class by yenugantix.tejasri@intel.com,4-mar-2023.
    */

    public static void setHierarchyFields(Account account, Account parentAcct) {
        UCD_ACM_Logger.information('UCD_ACM_AccountService','setHierarchyFields','Account:ID: '+account.Id +' and AccountCustAggrType :' + account.Core_Customer_Aggregation_Type__c,'AccountIds: '+account.Id);
        if(parentAcct == null) {
            Set<Id> parentAccountIds = new Set<Id>();
            parentAccountIds.add(account.ParentId);              
            UCD_ACM_Models.AccountResponseModel model = new UCD_ACM_Models.AccountResponseModel(); 
            parentAcct = accountQuerySelectorInstance.getAccountsByIds(parentAccountIds, model.getParentAccountQueryForEvent()).get(account.ParentId);
        }        
        string parentCustAggrType = parentAcct.Core_Customer_Aggregation_Type__c;
        Boolean hasSecondaryIntermediateParent = parentCustAggrType == 'UNFD_INTRMD_CUST' ? hasSecondaryIntermediateParent(parentAcct) : false;
        UCD_ACM_Logger.information('UCD_ACM_AccountService','setHierarchyFields','ParentCustAggrType:' + parentCustAggrType,'AccountIds: '+account.Id);
        account.Core_Unified_Global_Customer__c = parentCustAggrType == 'UNFD_GLBL_CUST' ? parentAcct.Id : parentAcct.Core_Unified_Global_Customer__c;
        account.Core_Unified_Global_Customer_BP_Id__c = parentCustAggrType == 'UNFD_GLBL_CUST' ? parentAcct.Core_Business_Party_Id__c : parentAcct.Core_Unified_Global_Customer__r.Core_Business_Party_Id__c;
        account.Core_Unified_Global_Customer_Name__c = parentCustAggrType == 'UNFD_GLBL_CUST' ? parentAcct.Core_Data_Simplified_Account_Nm__c : parentAcct.Core_Unified_Global_Customer__r.Core_Data_Simplified_Account_Nm__c;
       
        switch on account.Core_Customer_Aggregation_Type__c {
            when 'UNFD_LOC_CUST' {
                account.Core_Unified_Country_Customer__c = parentCustAggrType == 'UNFD_CTRY_CUST' ? parentAcct.Id : null;
                account.Core_Unified_Intermediate_Customer__c = parentCustAggrType == 'UNFD_INTRMD_CUST' ? parentAcct.Id : parentAcct.Core_Unified_Intermediate_Customer__c;  
                account.Core_Unified_Intermediate_Customer_2__c = hasSecondaryIntermediateParent ? parentAcct.ParentId : parentAcct.Core_Unified_Intermediate_Customer_2__c;
            }
            when 'UNFD_CTRY_CUST' {
                account.Core_Unified_Intermediate_Customer__c = hasSecondaryIntermediateParent ? parentAcct.ParentId : (parentCustAggrType == 'UNFD_INTRMD_CUST' ? parentAcct.Id : null);             
                account.Core_Unified_Intermediate_Customer_2__c = hasSecondaryIntermediateParent ? parentAcct.Id : null;
                account.Core_Unified_Intermediate_Customer_BP_Id__c = hasSecondaryIntermediateParent ? parentAcct.Core_Unified_Intermediate_Customer__r.Core_Business_Party_Id__c: (parentCustAggrType == 'UNFD_INTRMD_CUST' ? parentAcct.Core_Business_Party_Id__c : null);
                account.Core_Unified_Intermediate_Customer_Name__c = hasSecondaryIntermediateParent ? parentAcct.Core_Unified_Intermediate_Customer__r.Core_Data_Simplified_Account_Nm__c: (parentCustAggrType == 'UNFD_INTRMD_CUST' ? parentAcct.Core_Data_Simplified_Account_Nm__c : null);
             }
            when 'UNFD_INTRMD_CUST' {
                account.Core_Unified_Intermediate_Customer__c = parentCustAggrType == 'UNFD_INTRMD_CUST' ? parentAcct.Id : null;                
                account.Core_Unified_Intermediate_Customer_2__c = null;
                account.Core_Unified_Intermediate_Customer_BP_Id__c = parentCustAggrType == 'UNFD_INTRMD_CUST'? parentAcct.Core_Business_Party_Id__c:account.Core_Business_Party_Id__c;
                account.Core_Unified_Intermediate_Customer_Name__c =parentCustAggrType == 'UNFD_INTRMD_CUST' ? parentAcct.Core_Data_Simplified_Account_Nm__c :account.Core_Data_Simplified_Account_Nm__c;
            }
         }
    }  
        /*
    * description : To check if an intermediate account has secondary intermediate parent
    * params : Account
    * author and date : chethan.s.kunder@intel.com, 15 Mar 2022
    * Moved to this utils class by yenugantix.tejasri@intel.com,4-mar-2023.
    */
    private static Boolean hasSecondaryIntermediateParent(Account parentAccount){
        if(parentAccount.ParentId == null){
            return false;
        }
        Map<Id, Account> parent2AccountById = new Map<Id,Account>();
        Set<Id> parent2AccountIds = new Set<Id>();
        parent2AccountIds.add(parentAccount.ParentId);              
        UCD_ACM_Models.AccountResponseModel model = new UCD_ACM_Models.AccountResponseModel(); 
        parent2AccountById = accountQuerySelectorInstance.getAccountsByIds(parent2AccountIds, model.getParentAccountQueryForEvent());
        return parent2AccountById.get(parentAccount.ParentId).Core_Customer_Aggregation_Type__c == 'UNFD_INTRMD_CUST';
    }
    
}