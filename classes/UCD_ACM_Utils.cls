public without sharing class UCD_ACM_Utils {

    private static Map<String, Account_Create_Process_Mapping__mdt> accountProcessMappingBySourceName = new  Map<String, Account_Create_Process_Mapping__mdt>();
    private static Map<String, Core_Country_Reference__c> mCountryCodeGeoRef = new map<String, Core_Country_Reference__c>();      
    private static Map<String, Map<String,String>> controllingInfo=null;
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
        public static Map<String,String> getCountryCodeByName(){
            Map<String,String> countryCodeByCountryName = new Map<String,String>();
            Schema.DescribeFieldResult fieldResult =  Account.BillingCountryCode.getDescribe();
            List<Schema.PicklistEntry> pickListValues = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry pickListVal : pickListValues){
                countryCodeByCountryName.put(pickListVal.getLabel(),pickListVal.getValue());
            }
            return countryCodeByCountryName;
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
        /* Unused code Ankit 25/11/23
        public static string recordTypeNameById(string objAPIName, string recordTypeId){
            String recordTypeName;
            if(String.isNotBlank(objAPIName) && String.isNotBlank(recordTypeId)){
                recordTypeName= Schema.getGlobalDescribe().get(objAPIName).getDescribe().getRecordTypeInfosById().get(recordTypeId).getName();
            }  
            return recordTypeName;  
        } */



        public class MyPickListInfo {

            public String validFor;
            
        }

        public static Map<String, Map<String,String>> getGlobalPickList( )  {            
            if(controllingInfo==null){
                controllingInfo= new Map<String, Map<String,String>>( ) ;

            //Define table name that has picklist value set fields
        
            String objectName = 'Account';
        
            //Define controlling picklist value field
        
            String controllingField = 'BillingCountryCode' ;
        
            //Define dependent picklist value field
        
            String dependentField =  'BillingStateCode';
                   
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
    
    /**
        * description : Method to get State global picklist values for a country code
        * params : String
        * return : Map<String, String>    
        * author and date : chethan.s.kunder@intel.com 19-Apr-2024
     */

    public static Map<String,String> getStateValuesForCountryCode(String countryCode) {
        
        Map<String, String> mStatePicklistValues = new Map<String, String>();
        Map<String, Map<String,String>> stateNameAndCodeByCountry = getGlobalPickList();

        if(stateNameAndCodeByCountry.get(countryCode) != null){
            for(String statecode : stateNameAndCodeByCountry.get(countryCode).keySet()){                
                mStatePicklistValues.put(stateNameAndCodeByCountry.get(countryCode).get(statecode),statecode);                
            }
        }
        return mStatePicklistValues;
    }

    /**
        * description : Method to get State code for a state name
        * params : String, String
        * return : String 
        * author and date : chethan.s.kunder@intel.com 19-Apr-2024
     */
    public static String getStateCodeForStateName(String stateName, String countryCode) {
        Map<String,String> mStateValues = getStateValuesForCountryCode(countryCode);
        String stateCode = (!mStateValues.isEmpty() && mStateValues.containsKey(stateName)) ? mStateValues.get(stateName) : '';       
        return stateCode;
    }
        
}