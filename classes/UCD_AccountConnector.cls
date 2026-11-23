/*********************************************************************************************************************
Apex Class Name  : UCD_AccountConnector
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
public with sharing class UCD_AccountConnector {
    public static final string LOG_ENTRY_ORIGIN = 'UCD_AccountConnector';
    public static final String LOG_ENTRY_PROJECT = 'ACM';
    public static final String LOG_ENTRY_SCOPE = 'GetCIMResult';
    public static final String LOG_ENTRY_INFO = 'info';
    public static final String LOG_ENTRY_OBJECT = 'Account';
    public static final String LOG_ENTRY_ERROR = 'error';
    public static string LOG_ENTRY_SEVERITY;
    public static string LOG_ENTRY_Message;
    public static Map<String,Core_ACM_Control_Execution__c> mapFunctionalityAcmAppSwitch = Core_ACM_Control_Execution__c.getAll();
    public UCD_AccountConnector(){
        
    }
    /* ------------------------------------------------------------------------------------------------------------------   
* Below method uses UCD_AccountInfoWrapper as inputs 
* It stores the CIM Results calling the UCD_CIMConnector class and method getCimResults
* Based on the CIM id available  from CIM Results it calls to checks for records in SalesCloud
* Based on comparable interface it sorts the salesforce records if record has SF id and is full dup it is given higer pref
* for the CIM ids whos records do not exist in CIM it populates fields with results from CIM
* -------------------------------------------------------------------------------------------------------------------*/
    /*Code commented by Bhavesh on Nov 9 2020, as it is not been used for SB4C in UCD track
* @AuraEnabled(cacheable=true)
public static List<UCD_AccountModel> getDuplicateAccountDetails(UCD_AccountInfoWrapper accountDetails){
String CountryMatch = accountDetails.accCountry;
String StateMatch = accountDetails.accStateProvince;
List<UCD_CIMModel> cimResult = UCD_CIMConnector.getCimResults(accountDetails);
List<UCD_AccountModel> mergedResults = new List<UCD_AccountModel>();
List<UCD_AccountModel> finalresults = new List<UCD_AccountModel>();
if(cimResult!=null){
if(cimResult.size() == 0 || cimResult.isEmpty()){
UCD_AccountModel checkforNull = new UCD_AccountModel();
checkforNull.noRecordsFromCim = true;
}
}
Map<String,String> cimIdandScore = new Map<String,String>();
List<String> cimIDs = new List<String>();
set<decimal> score = new set<decimal>();
if(cimResult!=null){
for(UCD_CIMModel c:cimResult ){
// if(c.physicalCountry == CountryMatch)
//{
cimIDs.add(c.cimID);
//}  
cimIdandScore.put(c.cimID,c.searchScore);

}
}

List<UCD_AccountModel> accResults = getAccountfromOrg(cimIdandScore);
accResults.sort();
for(UCD_AccountModel ua : accResults){
if(ua.country == countryMatch && ua.state == StateMatch || ua.country == countryMatch && String.isBlank(StateMatch)){
//mergedResults = accResults;
mergedResults.add(ua);
}
}
List<String> cimIDinSalesforce = new List<String>();
List<String> cimIDnotinSalesforce = new List<String>();
for(UCD_AccountModel m: accResults){
m.sourceSystemCIM = false;   
if(m.Country == CountryMatch){
cimIDinSalesforce.add(m.cimID); 
}
}
for(String s:cimIDs ){
if(!cimIDinSalesforce.contains(s)){
cimIDnotinSalesforce.add(s);
}else{
}
}
if(cimResult!=null){
for(UCD_CIMModel c: cimResult){
if(c.physicalCountry == CountryMatch && c.CountrySubdivisionNm == StateMatch || c.physicalCountry == CountryMatch && String.isBlank(StateMatch))
{
if(cimIDnotinSalesforce.contains(c.cimID)){
UCD_AccountModel temp = new UCD_AccountModel();
temp.accName = c.accName;
temp.address = (string)c.physicalStreetAddr;
temp.city = (String)c.physicalCity;
temp.state = (String)c.CountrySubdivisionNm;
temp.Country = (String)c.physicalCountry;
temp.fullAddress = (string)c.physicalStreetAddr + ',' +(String)c.physicalCity + ',' +(String)c.CountrySubdivisionNm + ',' +(String)c.physicalCountry;
temp.bizOrgType = c.bizOrgVal;
temp.cimID = c.cimID;
temp.sourceSystemCIM = true;
temp.searchScore = c.searchScore;
temp.postalCode=c.physicalPostalCode;
if((temp.Country !=null || String.isnotEmpty(temp.Country)) && (temp.State != null || String.isnotEmpty(temp.State))  && (temp.City != null || String.isnotEmpty(temp.city))){
mergedResults.add(temp);
}
}
}
}
}
return mergedResults;
} */
    
    /* ------------------------------------------------------------------------------------------------------------------   
* Below method accepts the map of CIM id and search score and returns accounts found in salesforce
* -------------------------------------------------------------------------------------------------------------------*/
    /*Code commented by Bhavesh on Nov 9 2020, as it is not been used for SB4C in UCD track
public static List<UCD_AccountModel> getAccountfromOrg(Map<String,String> cimandScore){
List<UCD_AccountModel> accResults = new List<UCD_AccountModel>();
List<UCD_AccountModel> noAccountsinSalesforce = new List<UCD_AccountModel>();

string stateName;
String countryName;
for(Account a : [SELECT Id,Name, Owner.Name,Core_Account_Type__c, Core_Account_Tier__c,RecordtypeID, 
Industry,Core_Intel_Partner_Alliance_PartnerGroup__c,core_deactivated__c,
Core_IPA_Partner_Role__c,Core_CIM_ID__c,BillingStreet,BillingCity,BillingCountry,BillingState,
BillingAddress
FROM Account 
WHERE Core_CIM_ID__c in :cimandScore.keyset()]){
UCD_AccountModel ac = new UCD_AccountModel();
ac.accId = a.id;   
ac.accName = a.name;
ac.bizOrgType = (String)a.Core_Account_Type__c;
ac.accNTier = a.Core_Account_Tier__c;
ac.Industry = a.Industry;
ac.IPAFlag = a.Core_Intel_Partner_Alliance_PartnerGroup__c;
ac.accountDeactivated = a.core_deactivated__c;
ac.partnerRole = a.Core_IPA_Partner_Role__c;
ac.RecordTypeId = a.RecordTypeId;
//ac.primaryAddress =(Address) a.BillingAddress;
ac.primaryAddress =a.BillingAddress;
ac.Country = UCD_AccountConnector.getCountryName((String)ac.primaryAddress.getCountry());
ac.State = UCD_AccountConnector.getStateName((String)ac.primaryAddress.getState());
//ac.accRecordtypeId = a.recordtypeID;

if(ac.primaryAddress != null){
stateName = UCD_AccountConnector.getStateName((String)ac.primaryAddress.getState());
countryName = UCD_AccountConnector.getCountryName((String)ac.primaryAddress.getCountry());
ac.fullAddress =    ((String)ac.primaryAddress.getStreet()!= null ? (String)ac.primaryAddress.getStreet() : ' ') + ' ' + 
((String)ac.primaryAddress.getCity()!= null ? (String)ac.primaryAddress.getCity() : ' ') + ' ' + 
((String)ac.primaryAddress.getPostalCode()!= null ? (String)ac.primaryAddress.getPostalCode() : ' ') +' ' + 
(stateName!= null ? stateName : (String)ac.primaryAddress.getState()) +' ' + 
(countryName!= null ? countryName : (String)ac.primaryAddress.getCountry()) + ''; 
}
ac.accOwner = a.Owner.Name;
ac.cimID = a.Core_CIM_ID__c;
ac.searchScore = cimandScore.get(ac.cimID);

if(ac.fullAddress !=null || String.isnotEmpty(ac.fullAddress)){
accResults.add(ac);

}

}
return accResults;
}
*/
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
    
   
    
    /*public class PickListInfo{
        @AuraEnabled 
        public String validFor;
    }
    
    @AuraEnabled
    public static Map<String,List<String>> fetchStateCountryValues(){
        string stateName;
        Map<String,List<String>> countryStateMap = new Map<String,List<String>>();
        Map<String, Schema.SObjectField> objFieldMap = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap();
        Schema.SObjectField  controllingField = objFieldMap.get('billingcountrycode');
        Schema.SObjectField  dependentField = objFieldMap.get('billingstatecode');
        List<String> controllingValues = new List<String>();
        List<Schema.PicklistEntry> contrEntries = new List<Schema.PicklistEntry>();
        List<Schema.PicklistEntry> depEntries =  new List<Schema.PicklistEntry>();
        Map<String,String> countryLabelValueMap = new Map<String,String>();
        
        for(Schema.PicklistEntry f :  controllingField.getDescribe().getPicklistValues()){
            String label = f.getLabel();
            contrEntries.add(f);
            countryLabelValueMap.put(label,f.getValue());
            countryStateMap.put(label, new List<String>());
            controllingValues.add(label);
        } 
        for(Schema.PicklistEntry currDependentValue : dependentField.getDescribe().getPicklistValues()){
            depEntries.add(currDependentValue);
            String jsonString = JSON.serialize(currDependentValue);
            PickListInfo info = (PickListInfo) JSON.deserialize(jsonString, PickListInfo.class);
            String hexString = EncodingUtil.convertToHex(EncodingUtil.base64Decode(info.validFor)).toUpperCase();
            Integer baseCount = 0;
            for(Integer curr : hexString.getChars()){
                Integer val = 0;
                if(curr >= 65){
                    val = curr - 65 + 10;
                }
                else{
                    val = curr - 48;
                }
                if((val & 8) == 8){
                    countryStateMap.get(contrEntries[baseCount + 0].getLabel()).add(currDependentValue.getLabel()+';'+currDependentValue.getValue());
                }
                if((val & 4) == 4){
                    countryStateMap.get(contrEntries[baseCount + 1].getLabel()).add(currDependentValue.getLabel()+';'+currDependentValue.getValue());                 
                }
                if((val & 2) == 2){
                    countryStateMap.get(contrEntries[baseCount + 2].getLabel()).add(currDependentValue.getLabel()+';'+currDependentValue.getValue());                 
                }
                if((val & 1) == 1){
                    countryStateMap.get(contrEntries[baseCount + 3].getLabel()).add(currDependentValue.getLabel()+';'+currDependentValue.getValue());                 
                }
                baseCount += 4;
            }         
        }         
        return countryStateMap;
    }
*/
    
    public static string getOwnerName(id ownerId){
        User usr=[select id,Name from User where id=:ownerId WITH SECURITY_ENFORCED];
        String ownerName=usr.Name;
        return ownerName;
    }
    
    //Create new salescloud account and return id and account name if account does not exist in salescloud
    /*Code commented by Bhavesh on Nov 9 2020, as it is not been used for SB4C in UCD track
@AuraEnabled
public static UCD_AccountModel createNewSlsCldAccount(UCD_CIMModel cimRecord){  

UCD_AccountModel accCreated = new UCD_AccountModel();   
try{
Account newAccount = new Account();
Id accountRecordType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
newAccount.RecordTypeId = accountRecordType;      
newAccount.Name = (cimRecord.accName != null ? cimRecord.accName : ' ');
newAccount.Core_CIM_ID__c = (cimRecord.cimID != null ? cimRecord.cimID : ' ');
newAccount.BillingStreet = ( cimRecord.physicalStreetAddr!= null ?  cimRecord.physicalStreetAddr : ' ');
newAccount.BillingCity = (cimRecord.physicalCity != null ? cimRecord.physicalCity : ' ');
newAccount.BillingPostalCode = (cimRecord.physicalPostalCode!= null ?  cimRecord.physicalPostalCode : ' ');
newAccount.Core_Account_Type__c = ( cimRecord.bizOrgVal != null ?  cimRecord.bizOrgVal : ' ');
//(cimRecord.physicalCountry!= null ?  +cimRecord.physicalCountry : ' ');
//(cimRecord.physicalState != null ?  cimRecord.physicalState : ' ');   
newAccount.BillingCountryCode = UCD_AccountConnector.getCountryCode(cimRecord.physicalCountry);
//newAccount.BillingCountry = [SELECT Name FROM Core_Country_Code_Mapping__c where ISO_Code__c = :newAccount.BillingCountryCode OR Country_Code__c = :newAccount.BillingCountryCode Limit 1].Name;
newAccount.BillingCountry =  newAccount.BillingCountryCode; 
//newAccount.ownerId ='005o0000001zEZiAAM'; 
//newAccount.BillingStateCode = cimRecord.CountrySubdivisionCd;
// newAccount.BillingCountryCode = 'IND';
newAccount.BillingStateCode =  UCD_AccountConnector.getStateAndCountryName(cimRecord.physicalState);
// newAccount.BillingState = cimRecord.CountrySubdivisionNm;
newAccount.BillingState= newAccount.BillingStateCode;
/*
newAccount.AccountSource='';
newAccount.AnnualRevenue='';
newAccount.ChannelProgramLevelName='';
newAccount.ChannelProgramName='';
newAccount.Channel_Partner_Referance__c='';
newAccount.Company_Domain__c='';
newAccount.Core_Account_BU_Focus__c='';
newAccount.Core_Account_CCG_Tier__c='';
newAccount.Core_Account_Cnt__c='';
newAccount.Core_Account_Code__c='';
newAccount.Core_Account_Country__c='';
newAccount.Core_Account_Coverage__c='';
newAccount.Core_Account_DCG_Tier__c='';
newAccount.Core_Account_GA_Tier__c='';
newAccount.Core_Account_ID__c='';
newAccount.Core_Account_IOTG_Tier__c='';
newAccount.Core_Account_ISG_Tier__c='';
newAccount.Core_Account_Legal_Name__c='';
newAccount.Core_Account_Not_In_CIM__c='';
newAccount.Core_Account_NTG_Tier__c='';
newAccount.Core_Account_Owner_Active__c='';
newAccount.Core_Account_Owner__c='';
newAccount.Core_Account_PSG_Tier__c='';
newAccount.Core_Account_Record_Type__c='';
newAccount.Core_Account_RSG_Tier__c='';
newAccount.Core_Account_State_Province__c='';
newAccount.Core_Account_Team_Anchor_URL__c='';
newAccount.Core_Account_Team_Audit_Complete__c='';
newAccount.Core_Account_Team_Audit_Due_Date__c='';
newAccount.Core_Account_Tier__c='';
//newAccount.Core_Account_Type__c='';
newAccount.Core_Address_Details__c='';
newAccount.Core_Alternate_Language_Name__c='';
newAccount.Core_Alt_Address_1__c='';
newAccount.Core_Alt_Address_2__c='';
newAccount.Core_Alt_Language_City__c='';
newAccount.Core_Alt_Language_country__c='';
newAccount.Core_Alt_Language_Postal_Code__c='';
newAccount.Core_Alt_Language_State_Province__c='';
newAccount.Core_Annual_Revenue__c='';
newAccount.Core_Approved_Account__c='';
newAccount.Core_B2B_AcctGrpCMF_Link__c='';
newAccount.Core_B2B_Entitlement__c='';
newAccount.Core_B2B_ERPM_Account_Number__c='';
newAccount.Core_Batch_Run_Date__c='';
newAccount.Core_Business_ID__c='';
newAccount.Core_Business_Partner_Id__c='';
newAccount.Core_Calculated_Sales_Group__c='';
newAccount.Core_CIM_Gold_Status__c='';
newAccount.Core_CIM_ID_Old__c='';
newAccount.Core_CIM_ID__c=cimID;
newAccount.Core_CIM_Intel_Ultimate_ID__c='';
newAccount.Core_CIM_Intel_Ultimate_Name__c='';
newAccount.Core_CNDA_Number__c='';
newAccount.Core_Country_Label__c='';
newAccount.Core_Covered_Account__c='';
newAccount.Core_CPM_ID_255__c='';
newAccount.Core_CPM_ID_message__c='';
newAccount.Core_CPM_ID__c='';
newAccount.Core_Customer_Relationship__c='';
newAccount.Core_Deactivated__c='';
newAccount.Core_Deactivation_Reason__c='';
newAccount.Core_Direct_Sale__c='';
newAccount.Core_Domestic_Ultimate_DUNS__c='';
newAccount.Core_DUNS_Number__c='';
newAccount.Core_D_B_Hierarchy__c='';
newAccount.Core_D_B_Industry_1__c='';
newAccount.Core_D_B_Industry_2__c='';
newAccount.Core_D_B_Industry_3__c='';
newAccount.Core_D_B_Industry_4__c='';
newAccount.Core_D_B_Industry_5__c='';
newAccount.Core_D_B_Industry_6__c='';
newAccount.Core_English_Only_Name__c='';
newAccount.Core_Export_Compliance_Block_Reason__c='';
newAccount.Core_Export_Compliance_Block__c='';
newAccount.Core_First_Revenue_Date__c='';
newAccount.Core_Fully_Executed_NDA__c='';
newAccount.Core_Geo__c='';
newAccount.Core_global_500__c='';
newAccount.Core_global_1000__c='';
newAccount.Core_Global_Account__c='';
newAccount.Core_Global_MNC_ODM_Account__c='';
newAccount.Core_Global_Ultimate_DUNS__c='';
newAccount.Core_Global_Ultimate_Indicator__c='';
newAccount.Core_Headquarter_Parent_DUNS__c='';
newAccount.Core_High_Priority_Account__c='';
newAccount.Core_IBL_Flag__c='';
newAccount.Core_Import_ID__c='';
newAccount.Core_Intel_Partner_Alliance_PartnerGroup__c='';
newAccount.Core_IPA_Badge_Tier__c='';
newAccount.Core_IPA_Partner_Prog_Application__c='';
newAccount.Core_IPA_Partner_Role__c='';
newAccount.Core_IPA_Partner_Segment__c='';
newAccount.Core_IPA_Partner_Speciality__c='';
newAccount.Core_IPS_Active__c='';
newAccount.Core_IPS_PSG_WOM_Check__c='';
newAccount.Core_IPS_SFT_Partner_Path__c='';
newAccount.Core_IsODM__c='';
newAccount.Core_Is_Active__c='';
newAccount.Core_Is_Duplicate__c='';
newAccount.Core_Is_PAG_Member_Ind__c='';
newAccount.Core_Is_Parent__c='';
newAccount.Core_ITP_ID__c='';
newAccount.Core_ITP_Membership_Status__c='';
newAccount.Core_ITP__c='';
newAccount.Core_Last_MsgId__c='';
newAccount.Core_Lead_Conversion_Flag__c='';
newAccount.Core_Lead_Sales_Segment__c='';
newAccount.Core_Lead_to_Account_Conversion__c='';
newAccount.Core_MAG_Value__c='';
newAccount.Core_MDF_Active_Ind__c='';
newAccount.Core_MDF_Auto_Transfer_Account__c='';
newAccount.Core_MDF_Channel_Program__c='';
newAccount.Core_MDF_CoMarketingActive__c='';
newAccount.Core_MDF_CoMarketingAgency__c='';
newAccount.Core_MDF_CoMarketing_Ultimate_Account__c='';
newAccount.Core_MDF_Enabled_Auto_Transfer__c='';
newAccount.Core_MDF_Parent_Fund_Account__c='';
newAccount.Core_Military_Aerospace_and_Government__c='';
newAccount.Core_Not_an_Embargoed_Country__c='';
newAccount.Core_Not_on_Denied_Persons_List__c='';
newAccount.Core_OPID_Name__c='';
newAccount.Core_OPID__c='';
newAccount.Core_Opportunity_Revenue_for_Account__c='';
newAccount.Core_PAG_Grouping_Method__c='';
newAccount.Core_Partner_Account__c='';
newAccount.Core_Partner_Alliance_Program_Member__c='';
newAccount.Core_Partner_Alliance_Program__c='';
newAccount.Core_Physical_Location__c='';
newAccount.Core_PMP_Membership_Change_Ind__c='';
newAccount.Core_PMP_Partner_Type_Nm__c='';
newAccount.Core_Primary_City__c='';
newAccount.Core_Primary_State__c='';
newAccount.Core_Primary_Street__c='';
newAccount.Core_Primary_Zip_Code__c='';
newAccount.Core_Prime_Account_Name__c='';
/*newAccount.Core_Private__c='';
newAccount.Core_PSG_Account__c='';
newAccount.Core_RDC_Content_Restriction__c='';
newAccount.Core_Recommendations_Available_New__c='';
newAccount.Core_Recommendations_Available__c='';
newAccount.Core_Recommendations_Indicator__c='';
newAccount.Core_Sales_Groups__c='';
newAccount.Core_Sales_Group__c='';
newAccount.Core_Sales_Segment__c='';
newAccount.Core_Secondary_City__c='';
newAccount.Core_Secondary_Country__c='';
newAccount.Core_Secondary_State__c='';
newAccount.Core_Secondary_Street__c='';
newAccount.Core_Secondary_Zip_Code__c='';
newAccount.Core_Standard_Industry_Classification_1__c='';
newAccount.Core_Standard_Industry_Classification_2__c='';
newAccount.Core_Standard_Industry_Classification_3__c='';
newAccount.Core_Standard_Industry_Classification_4__c='';
newAccount.Core_Standard_Industry_Classification_5__c='';
newAccount.Core_Standard_Industry_Classification_6__c='';
newAccount.Core_Sub_Geo__c='';
newAccount.Core_System_Siebel_Account_Matched__c='';
newAccount.Core_System_Siebel_Account_Row_ID__c='';
newAccount.Core_Sys_Next_Account__c='';
newAccount.Core_Technical_Owner__c='';
newAccount.Core_Territory_Description__c='';
newAccount.Core_Territory_ID__c='';
newAccount.Core_Total_Approved_Revenue_Amount__c='';
newAccount.Core_Trade_Style_Name__c='';
newAccount.Core_Uncover_Marked_for_Clean_Up__c='';
newAccount.Core_User_Defined_Number_of_Employees__c='';
newAccount.Core_User_Defined_Phone_Number__c='';
newAccount.Core_User_Defined_Website__c='';
newAccount.Core_Year_Started__c='';
newAccount.CreatedById='';
newAccount.CreatedDate='';
newAccount.Description='';
newAccount.Fax='';
newAccount.Id='';
newAccount.Inactive__c='';
newAccount.Industry='';
newAccount.IPA_Partner_Program__c='';
newAccount.IPA_Partner_Role__c='';
newAccount.IsCustomerPortal='';
newAccount.IsDeleted='';
newAccount.IsExcludedFromRealign='';
newAccount.IsPartner='';
newAccount.Jigsaw='';
newAccount.JigsawCompanyId='';
newAccount.LastActivityDate='';
newAccount.LastModifiedById='';
newAccount.LastModifiedDate='';
newAccount.LastReferencedDate='';
newAccount.LastViewedDate='';
newAccount.Lead_to_Account_on_Contact_NoOpportunity__c='';
newAccount.LID__LinkedIn_Company_Id__c='';
newAccount.MaritzCX__Active__c='';
newAccount.MaritzCX__CustomerPriority__c='';
newAccount.MaritzCX__NumberofLocations__c='';
newAccount.MaritzCX__SLAExpirationDate__c='';
newAccount.MaritzCX__SLASerialNumber__c='';
newAccount.MaritzCX__SLA__c='';
newAccount.MaritzCX__UpsellOpportunity__c='';
newAccount.MasterRecordId='';
newAccount.Name='';
newAccount.NppEngagement__c='';
newAccount.NPP_Region__c='';
newAccount.NPP_State__c='';
newAccount.NumberOfEmployees='';
newAccount.OwnerId='';
newAccount.Ownership='';
newAccount.ParentId='';
newAccount.Phone='';
newAccount.PhotoUrl='';
newAccount.PRM_AccountNumberFormula__c='';
newAccount.PRM_Account_Create_Date__c='';
newAccount.PRM_Account_Grouping_Method_Value__c='';
newAccount.PRM_IPA_Integration_Queue_Text__c='';
newAccount.PRM_IPA_Integration_Status__c='';
newAccount.PRM_IsUpdated__c='';
newAccount.Rating='';
newAccount.RecordTypeId='';
newAccount.Sic='';
newAccount.SicDesc='';
newAccount.Site='';
newAccount.Sync_Account_Team__c='';
newAccount.SystemModstamp='';
newAccount.TickerSymbol='';
newAccount.tst_Sales_Out__c='';
newAccount.tst_Training_Points__c='';
newAccount.Type='';
//newAccount.Website='www.varep.com';
//newAccount.Website = cimRecord.companyWebsite;

//newAccount.Core_IPA_Partner_Role__c = = cimRecord.partnerRole;
//newAccount.Core_Sales_Groups__c = System.Label.PRM_Undefined;
//newAccount.Industry = System.Label.PRM_Needs_Defined;
//newAccount.Website = cimRecord.companyWebsite; 


//if(cimRecord.ownerId != null) {
//newAccount.OwnerId = cimRecord.ownerId;
//} else {
//newAccount.OwnerId = UserInfo.getUserId();
//}

if(newAccount != null) {
insert newAccount;          
}
accCreated.accId=newAccount.id;
accCreated.accName=newAccount.Name;
//updateAccountOwners(newAccount.id,cimRecord.cimID);
return accCreated; 
} catch(Exception e){
PRM_ErrorUtilityClass.logError(e);
}
return null;
}
*/
    

    /* This method will get inputs from ucdAcctCreateForrm (LWC) and returns if any existing account with same 
billing address (US740756) */
    @AuraEnabled(cacheable=true)
    public static List<Account> findAccounts(String bStreet1, String bStreet2) {
        if (mapFunctionalityAcmAppSwitch.containsKey('SwitchAcmApp') && mapFunctionalityAcmAppSwitch.get('SwitchAcmApp').IsActive__c) {
            String street = bStreet1+' '+bStreet2;
            return [
                SELECT Id, Name
                FROM Account
                WHERE BillingStreet =: street
                WITH SECURITY_ENFORCED LIMIT 1
            ];
        }
        else{
            return null;
        }
    }
    static string a;
    
    @AuraEnabled(cacheable = true)
    public static void findAccountOwners(String cimId, string rId) {
        if (mapFunctionalityAcmAppSwitch.containsKey('SwitchAcmApp') && mapFunctionalityAcmAppSwitch.get('SwitchAcmApp').IsActive__c) {
            String cim = cimId;
            String recId = rId;
            a = recId;
            updateAccountOwners(recId,cim);
        }
    }
    //Fixed too many query rows exception by adding count in soql and update Account owner accordingly. 
    @future
    public static void updateAccountOwners(String acc,string cimf) {
        Account objAcc;
        Id logged = UserInfo.getUserId();
        String uncovered = Label.ucdUncoveredOwner;
        Integer scc = [select count() from Account where Core_CIM_ID__c =: cimf WITH SECURITY_ENFORCED ];
        Integer countOfAcc = [select count() from Account where Core_CIM_ID__c =: cimf AND Owner.Name =: uncovered WITH SECURITY_ENFORCED];

        if(scc == 0 || scc == countOfAcc){
                objAcc = new Account(Id = acc,OwnerId = userInfo.getUserId());
                if(Schema.sObjectType.Account.isUpdateable()){                    
                    update objAcc;
                } 
        }
        
    } 
}