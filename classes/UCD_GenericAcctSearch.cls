/*********************************************************************************************************************
Apex Class Name  : UCD_GenericAcctSearch
Version       : 1.0
Created Date  : May 2021
Function      : Accepts the input from LWC and send data back to LWC

Modification Log :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------
* Saranya Ramaiah              9/8/2020            Calling account data
*********************************************************************************************************************/
public without sharing class UCD_GenericAcctSearch {

 /*@AuraEnabled(cacheable = true)
   public static List<fieldsetwrapper> getFieldSet(String objectApiName, String fieldSetName){
        List<Schema.FieldSetMember> fieldset = ((SObject)Type.forName(objectApiName).newInstance()).getSObjectType().getDescribe().FieldSets.getMap().get(fieldSetName).getFields();
        //List<Schema.FieldSetMember> fieldset =  SObjectType.Account.FieldSets.UCD_SearchField.getFields();
        List<fieldsetwrapper> acctFields = new List<fieldsetwrapper>();
        String result1 = '';
        for(Schema.FieldSetMember f : fieldset) {
            fieldsetwrapper result = new fieldsetwrapper();
            result.fieldLabel = f.getLabel();
            result.fieldAPIName = f.getFieldPath();
            result.fieldValue ='';
                acctFields.add(result);
                
        }
        system.debug('****'+acctFields);
        
        
        return acctFields;
        //return '['+result+']';
        
    }*/

public class Fieldsetwrapper{
    @AuraEnabled
    public String fieldLabel {get;set;}
    @AuraEnabled
    public String fieldAPIName {get;set;}
    @AuraEnabled
    public String fieldValue {get;set;}
}

@AuraEnabled
public static List<UCD_Account_Identifiers__c> fetchIdentifiers(){
    Map<String,UCD_Account_Identifiers__c> allCodes = UCD_Account_Identifiers__c.getAll();
     List<UCD_Account_Identifiers__c> code = allCodes.values();
     return code;
}


/*****************************************************************************/

@AuraEnabled
public static List<sObject> searchRecords(List<fieldsetwrapper> fDetails,String objectApiName,List<string> cimID){
      String cols = '';
      String condition = '';
      String cleanedSearch ='';
      Id InactiveRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.UCD_Inactive_Account_Record_Type).getRecordTypeId();
     
      for(fieldsetwrapper fs:fDetails){
             if(cols == ''){
                  cols = fs.fieldAPIName;
              }
              else{
                  cols = cols + ',' + fs.fieldAPIName;
              } 
              if(fs.fieldAPIName == 'BillingCountry' && fs.fieldValue != ''){
                  fs.fieldValue = UCD_AccountConnector.getCountryCode(fs.fieldValue);
                  //fs.fieldAPIName = 'toLabel(BillingCountryCode)';
                  //system.debug('%%%%%^^^'+fs.fieldAPIName);
              }
              else if(fs.fieldAPIName == 'BillingState' && fs.fieldValue != ''){
                  fs.fieldValue = UCD_AccountConnector.getStateAndCountryName(fs.fieldValue);
              }
          if(fs.fieldValue != '' && fs.fieldValue !=null ){    
              cleanedSearch = '%' + fs.fieldValue.trim().replaceAll('\\s+', '%') + '%';
              //String searchText = fs.fieldValue;
              if(condition == ''){
                  condition = fs.fieldAPIName+' LIKE '+ '\''+String.escapeSingleQuotes(cleanedSearch) + '\''; 
              }
              else{
                  condition = condition + ' AND ' + fs.fieldAPIName+' LIKE ' +'\''+ String.escapeSingleQuotes(cleanedSearch) + '\'';
              }
          }
      }
        condition = condition + ' AND Core_CIM_ID__c IN : cimID AND recordtypeId !=:InactiveRecordTypeId';
        string query = 'select tolabel(billingcountrycode), tolabel(billingstatecode),  '+cols+' from '+objectApiName+' where '+condition;
        if(Account.SObjectType.getDescribe().isAccessible()){  
            List<sObject> records = Database.query(query); 
            return records;  
        }    
        else{
            return null;
        }      
}

/*****************************************************************************/

@AuraEnabled
public static List<UCD_AccountModel> getAcctResults(List<fieldsetwrapper> fDetails){
   List<UCD_CIMModel> cimResult = UCD_GenericAcctSearch.getCimResults(fDetails);
    system.debug('CIM RESULTS'+cimResult);
    system.debug('CIM RESULTS SIZE'+cimResult.size());
   List<UCD_AccountModel> mergedResults = new List<UCD_AccountModel>();
   List<String> cimIDinSalesforce = new List<String>();
   List<String> cimIDnotinSalesforce = new List<String>();
   List<String> cimIDs = new List<String>();
   
   String CountryMatch;
   String StateMatch;
   
    for(fieldsetwrapper fs:fDetails){
            if(fs.fieldAPIName == 'BillingState' && fs.fieldValue != ''){
                StateMatch = fs.fieldValue;
            }
            if(fs.fieldAPIName == 'BillingCountry' && fs.fieldValue != ''){
                CountryMatch  =  fs.fieldValue;
            }
    }
   
    for(UCD_CIMModel c:cimResult ){
            cimIDs.add(c.cimID);       
    }
   List<sObject> accResults = searchRecords(fDetails,'Account',cimIDs);   
   List<UCD_AccountModel> acctWrapResults = acctWrapContructor(accResults);
   
    
     for(UCD_AccountModel ua : acctWrapResults ){
            //if(ua.country == countryMatch && ua.state == StateMatch || ua.country == countryMatch && String.isBlank(StateMatch)){
        //mergedResults = accResults;
                mergedResults.add(ua);
            //}
        }
        for(sObject obj: accResults){
            cimIDinSalesforce.add((String)obj.get('Core_CIM_ID__c')); 
        }
        for(String s:cimIDs ){
            if(!cimIDinSalesforce.contains(s)){
                cimIDnotinSalesforce.add(s);
            }
        }
        
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
                temp.CountryCode = (string)c.CountryCd;
                temp.StateCode = (String)c.CountrySubdivisionCd;
                temp.fullAddress = (string)c.physicalStreetAddr + ',' +(String)c.physicalCity + ',' +(String)c.CountrySubdivisionNm + ',' +(String)c.physicalCountry;
                temp.bizOrgType = c.bizOrgVal;
                temp.cimID = c.cimID;
                temp.sourceSystemCIM = true;
                temp.searchScore = c.searchScore;
                temp.postalCode=c.physicalPostalCode;
                temp.addColList = new List<UCD_AccountModel.additionalColumns>();
                for(UCD_Account_Identifiers__c ai:UCD_GenericAcctSearch.fetchIdentifiers()){
                    UCD_AccountModel.additionalColumns am= new UCD_AccountModel.additionalColumns();
                    am.ApiName = null;
                    am.isCheckbox = ai.IsCheckbox__c;
                    am.UILabel = ai.UI_Label__c;
                    am.showColumn= false;
                    am.textFieldValue= null;
                    am.checkboxFieldValue= null;
                                   
                    //addColListnew.add(am); 
                    temp.addColList.add(am);
               }
                if((temp.Country !=null || String.isnotEmpty(temp.Country)) && (temp.State != null || String.isnotEmpty(temp.State))  && (temp.City != null || String.isnotEmpty(temp.city))){
                    mergedResults.add(temp);
                }
            }
          }
        } 
        system.debug('MERGE RESULTS'+mergedResults);
   return mergedResults;
}

  /*  public class StateCountryInfo{
        @AuraEnabled
        public String country;
        @AuraEnabled
        public List<String> stateList;
    }*/
  
  public static Map<id,List<Contact>> fetchContact(List<Id> accIdList){
      List<Contact> contactsList= [select id,name,AccountId from contact where AccountId IN: accIdList];
      Map<id,List<Contact>> ConAccMap = new Map<id,List<Contact>>();
       for(Contact contacts:contactsList)
        {
             if(ConAccMap.containsKey(contacts.AccountId))
              {   
                ConAccMap.get(contacts.AccountId).add(contacts);                  
              }
              else 
              {   
                ConAccMap.put(contacts.AccountId,new list<contact>{contacts}); 
              }
        }
        
        return ConAccMap;
  }
  

 public static List<UCD_AccountModel> acctWrapContructor(List<sObject> acctList){
     string stateName;
     String countryName;
     //Map<String,List<String>> countryStateMap = UCD_AccountConnector.fetchStateCountryValues();
     //stateCountryInfo info = new stateCountryInfo();
     
     List<Id> sObjectIDList= new List<Id>();
     for(sObject obj:acctList){
         sObjectIDList.add((Id)obj.get('Id'));
     }
     Map<id,List<Contact>> conMap = new Map<id,List<Contact>>();
     conMap=fetchContact(sObjectIDList);
     system.debug('&&&&&&&&&&&&&&&&&&&&&&&&&&&' +conMap);
     
     List<UCD_AccountModel> accResults = new List<UCD_AccountModel>();
     
     
     //List<UCD_Account_Identifiers__c> accIdentifiers = UCD_AccountModel.fetchIdentifiers();  
     List<UCD_AccountModel.additionalColumns> addColListnew = new List<UCD_AccountModel.additionalColumns>();
     for(sObject obj:acctList){
       
          UCD_AccountModel ac= new UCD_AccountModel();
                             ac.accId = (Id)obj.get('Id');   
                             ac.accName = (String)obj.get('Name');
                             ac.SFaccName = (String)obj.get('Name');
                            // ac.accNTier = (String)obj.get('Core_Account_Tier__c');
                            // ac.Industry = (String)obj.get('Industry');                             
                             //ac.accountDeactivated = (boolean)obj.get('core_deactivated__c');
                             ac.partnerRole = (String)obj.get('Core_IPA_Partner_Role__c');
                             ac.RecordTypeId = (Id)obj.get('RecordTypeId');
                             //ac.Country = UCD_AccountConnector.getCountryName((String)obj.get('BillingCountry'));
                             ac.Country = (string)obj.get('BillingCountryCode');
                             //ac.State = UCD_AccountConnector.getStateName((String)obj.get('BillingState'));
                             ac.State = (string)obj.get('BillingStateCode');
                             ac.sourceSystemCIM = false;
                            string statecode = (String)obj.get('BillingState');
                            string countrycode = (String)obj.get('BillingCountry');
                            
                           /* ac.IPAFlag = (boolean)obj.get('Core_Intel_Partner_Alliance_PartnerGroup__c');
                            ac.IPSFlag = (boolean)obj.get('Core_IPS_Active__c');
                            ac.ABMFlag = (String)obj.get('Core_Account_BU_Focus__c');
                            ac.B2BFlag = (boolean)obj.get('core_b2b_entitlement__c'); */
                            ac.addColList = new List<UCD_AccountModel.additionalColumns>();
                            for(UCD_Account_Identifiers__c ai:UCD_GenericAcctSearch.fetchIdentifiers()){
                                    UCD_AccountModel.additionalColumns am= new UCD_AccountModel.additionalColumns();
                                    am.ApiName = ai.API_Name__c;
                                    am.isCheckbox = ai.IsCheckbox__c;
                                    am.UILabel = ai.UI_Label__c;
                                    am.showColumn= false;
                                    if(ai.IsCheckbox__c == false){
                                        am.textFieldValue= (String)obj.get(ai.API_Name__c);
                                        am.checkboxFieldValue= null;
                                    }
                                    else{
                                        am.checkboxFieldValue = (boolean)obj.get(ai.API_Name__c);
                                        am.textFieldValue= null;
                                    }
                                   addColListnew.add(am); 
                                   ac.addColList.add(am);
                            }
                            
                            if(conMap.get((Id)obj.get('Id'))!=null){
                                ac.relatedContacts = (Integer)conMap.get((Id)obj.get('Id')).size();
                            }
                            else{
                                ac.relatedContacts = 0;
                            }
                            
                                //stateName = UCD_AccountConnector.getStateName((String)obj.get('BillingState'));
                                //countryName = UCD_AccountConnector.getCountryName((String)obj.get('BillingCountry'));
        /* if(ac.Country != null){
             info.stateList= countryStateMap.get(ac.Country);
         }
                       
        Map<String, string> stateMap = new Map<String, String>();
        string delimiter = ';';
         if(info.stateList != null){
             for(String str: info.stateList){
            stateMap.put(str.substringAfter(delimiter), str.substringBefore(delimiter));
        }
         }
        
         if(statecode != null){
            // stateName = stateMap.get(statecode);
         }*/

        
                       stateName =  (string)obj.get('BillingStateCode');
         countryName = (string)obj.get('BillingCountryCode');
                                 ac.fullAddress =    ((String)obj.get('BillingStreet')!= null ? (String)obj.get('BillingStreet') : ' ') + ' ' + 
                                     ((String)obj.get('BillingCity')!= null ? (String)obj.get('BillingCity') : ' ') + ' ' + 
                                     ((String)obj.get('BillingPostalCode')!= null ? (String)obj.get('BillingPostalCode') : ' ') +' ' + 
                                     (stateName!= null ? stateName : (String)obj.get('BillingState')) +' ' + 
                                     (countryName!= null ? countryName : (String)obj.get('BillingCountry')) + ''; 
                             ac.accOwner =UCD_AccountConnector.getOwnerName((String)obj.get('OwnerId'));
                             ac.cimID = (String)obj.get('Core_CIM_ID__c');
                            
                     if(ac.fullAddress !=null || String.isnotEmpty(ac.fullAddress)){
                                 accResults.add(ac);
                                
                             }
     }
     return accResults;
 }
 
 @AuraEnabled
public static List<UCD_AccountModel> showFields(List<UCD_AccountModel> accDetails, List<String> colList){
List<UCD_AccountModel> accDetailsNew = new List<UCD_AccountModel>();
    for(UCD_AccountModel am: accDetails){
        for(UCD_AccountModel.additionalColumns fg:am.addColList){
            if(colList.contains(fg.UILabel)){
                fg.showColumn= true;
            }
            else{
                fg.showColumn = false;
            }
        }
    }
    return accDetails;
}

 /*****************************************************************************/

  public static list<UCD_CIMModel> getCimResults(List<fieldsetwrapper> fDetails){
        List<UCD_CIMModel> cimResults = new list<UCD_CIMModel>();
        Http http = new Http();
        HttpRequest req = createHttpRequest(http);
              system.debug('QQQQQQQQQQQQ'+req);

        UCD_GenericAcctSearch.PhysicalAddress physicalAdd = mapPhysicalAddressDetails(fDetails);
        UCD_GenericAcctSearch.BusinessOrganization busOrg = mapBusinessOrganizationDetails(fDetails,physicalAdd);
        UCD_GenericAcctSearch.PopulateRequestDetails requestDetail = mapRequestDetails(fDetails,busOrg);
        system.debug('requestDetail--> '+requestDetail);
        String reqBody = JSON.serialize(requestDetail);
        req.setBody(reqBody);
              system.debug('REQ -->'+req);

        
         try{
            HttpResponse response = http.send(req);
            string str= response.getBody();
                         System.debug('@@@Response'+response);

             if(response.getStatusCode() == 200 && String.isNotBlank(response.getBody())){
                PRM_CIMWrapper respWrap = (PRM_CIMWrapper)JSON.deserialize(response.getBody(),PRM_CIMWrapper.class);
                if(respWrap != null){
                    cimResults=UCD_CIMConnector.handleResponse(respWrap);
                     System.debug('@@@cim'+cimResults);
                }
            }else{
                cimResults = null;
            }
        }catch(Exception e){
            if(e != null){
            throw new AuraHandledException(e.getMessage());
                }
            PRM_ErrorUtilityClass.logError(e);
            cimResults = null;
        }
        return cimResults;
  }


    public static HttpRequest createHttpRequest(Http http){
        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type','application/json');
        req.setHeader('API_KEY', cimMdt.API_Key__c);
        req.setEndpoint('callout:PRM_CIM_Callout_Credentials');
        req.setMethod('POST');
        req.setTimeout(Integer.valueOf(System.Label.PRM_Timeout));
                System.debug('@@@HTTP Request'+req);

        return req;
    }


 /*****************************************************************************/
 public class PhysicalAddress{
        public String PostalCd;
        public String CityNm;
        public String PhysicalStreetAddressTxt;
        public String Country3Cd;
        public string CountrySubdivisionCd;
        public string CountrySubdivisionNm;
    }

 public static PhysicalAddress mapPhysicalAddressDetails(List<fieldsetwrapper> fDetails){
    UCD_GenericAcctSearch.PhysicalAddress physicalAdd = new UCD_GenericAcctSearch.PhysicalAddress();
    if(fDetails.size()!=0){
        for(fieldsetwrapper fs:fDetails){
            if(fs.fieldAPIName == 'BillingStreet' && fs.fieldValue != ''){
                physicalAdd.PhysicalStreetAddressTxt= fs.fieldValue;
            }
            if(fs.fieldAPIName == 'BillingCity' && fs.fieldValue != ''){
                physicalAdd.CityNm = fs.fieldValue;
            }
            if(fs.fieldAPIName == 'BillingState' && fs.fieldValue != ''){
                physicalAdd.CountrySubdivisionNm= fs.fieldValue;
            }
            if(fs.fieldAPIName == 'BillingCountry' && fs.fieldValue != ''){
                //physicalAdd.Country3Cd= fs.fieldValue;
                physicalAdd.Country3Cd= UCD_AccountConnector.getCountryCode(fs.fieldValue);

            }
            if(fs.fieldAPIName == 'BillingPostalCode' && fs.fieldValue != ''){
                physicalAdd.PostalCd = fs.fieldValue;
            }
        }
    }     
    return physicalAdd;
  
 }


/*****************************************************************************/
    public class BusinessOrganization{
        public String BusinessOrganizationNm;
        public PhysicalAddress PhysicalAddress;
    }

    public static BusinessOrganization mapBusinessOrganizationDetails(List<fieldsetwrapper> fDetails,PhysicalAddress phyAddr ){
        UCD_GenericAcctSearch.BusinessOrganization busOrg = new UCD_GenericAcctSearch.BusinessOrganization();
        if(fDetails.size()!=0){
            for(fieldsetwrapper fs:fDetails){
                if(fs.fieldAPIName == 'Name' && fs.fieldValue != ''){
                    busOrg.BusinessOrganizationNm = fs.fieldValue;
                }
            }
        }
       
        busOrg.PhysicalAddress = phyAddr;
        return busOrg;
    }

/*****************************************************************************/

    public class PopulateRequestDetails{
        public BusinessOrganization BusinessOrganization;
        public String MaximumNumberOfRecordsToReturn;
        public String CallingSourceSystem;
        public Integer MandatoryFieldRestrictionLevel;
        public Integer MinimumSearchScore;
        public Boolean IncludeDefaultAttributesForSourceTypes;
        public String AsynchronousRequestId;
    }
    
    public static PRM_CIM_Request__mdt cimMdt = [Select Id, MasterLabel,API_Key__c, PRM_Async_Id__c, PRM_Calling_System__c, PRM_Restriction_Level__c, PRM_Max_Records__c, PRM_Max_Score__c, PRM_Min_Score__c from PRM_CIM_Request__mdt where MasterLabel =: System.Label.PRM_Dupe_Scores];
    
    
    public static PopulateRequestDetails mapRequestDetails(List<fieldsetwrapper> fDetails,BusinessOrganization busOrganization ){
        UCD_GenericAcctSearch.PopulateRequestDetails requestDetail = new UCD_GenericAcctSearch.PopulateRequestDetails();
        requestDetail.MinimumSearchScore= 25;
        requestDetail.BusinessOrganization = busOrganization;
        requestDetail.MaximumNumberOfRecordsToReturn = cimMdt.PRM_Max_Records__c;
        requestDetail.CallingSourceSystem = cimMdt.PRM_Calling_System__c;
        requestDetail.MandatoryFieldRestrictionLevel = Integer.valueOf(cimMdt.PRM_Restriction_Level__c);
        requestDetail.IncludeDefaultAttributesForSourceTypes = False;
        //requestDetail.IncludeDefaultAttributesForSourceTypes = true;
        requestDetail.AsynchronousRequestId = cimMdt.PRM_Async_Id__c;
        return requestDetail;
    }
    
  /*****************************************************************************/  


}