/****************************************************************************************************************************
Apex Class Name     : PRM_AddPartnerController 
Version             : 1.0
Created Date        : 28-Nov-2019

Modification Log    :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------------
* Monishaditya Sampathkumar       28-Nov-2019                Search and Filter capability for Partner Account to assign Specialty

 
****************************************************************************************************************************/
public without sharing class PRM_AddPartnerController { 
    public static Integer dmlLimits;
    public static Schema.DescribeSObjectResult objDescribe;
    public static map < String, Schema.SObjectField > fieldMap;
    public static list < Schema.PicklistEntry > values;
    public static list < FatchValueWrapper > objWrapper = new list < FatchValueWrapper > ();    
    public static List<AccAndAcmWrapper> lstofAccAndAcmWrapper = new List<AccAndAcmWrapper>();
    public static Map<Id,List<Id>> mapSpCritAndAccId = new Map<Id,List<Id>>();    
    public static Map<String,set<String>> mapOfAccIdAndPartnerRole;
    public static Map<String,List<String>> mapPartnerRoleAndSpCritId;
    public Static String errorMsg = '';
    public Static List<FinalRecWrapperlist> lstOfFinalAcmRecWrap = new List<FinalRecWrapperlist>();
    public Static List<string> lstofSpCrit = new List<string>();   
    public Static set<String> setOfAccIds = new set<String>();
    public Static Map<String,PRM_Specialty_Data__c> mapOfAccIdRoleAndspcialtyData = new Map<String,PRM_Specialty_Data__c>();
    public Static Map<String,PRM_AccountChannelMembership__c> mapOfAccIdRoleAndAcmData = new Map<String,PRM_AccountChannelMembership__c>();
    
    //Method to return list of accounts with search criteria and if specialty is not associated with accounts.
    @AuraEnabled
    public static List<FinalRecWrapperlist> fetchAccsData(String accountName, Id currentspecialtyId) {        
        dmlLimits = Limits.getLimitQueryRows();
        String specialtyname = '';        
        accountName = '%' + accountName + '%';    
        List<String> lstOfspecialtyRole = new List<String>();  
        //US587204  START
        list<PRM_AccountChannelMembership__c> lstACMtemp=new List<PRM_AccountChannelMembership__c>();        
        Boolean flag=true;
        
        Try{
            //US587183        
            PRM_Specialty__c specialtyRecord =[Select Id,Name,PRM_Role_Nm__c from PRM_Specialty__c where Id =: currentspecialtyId][0];      //US587183
            specialtyname = specialtyRecord.Name; 
            lstOfspecialtyRole =specialtyRecord.PRM_Role_Nm__c.split(';');
            
            if(accountName != NULL && accountName != '')
            {
                list<PRM_AccountChannelMembership__c> lstACM = [SELECT Id,PRM_Account_Id__r.RecordType.DeveloperName,PRM_Account_Id__c,PRM_Account_Id__r.Name,PRM_Account_Id__r.AccountNumber,PRM_Partner_Role__c, PRM_Account_Id__r.Core_User_Defined_Phone_Number__c, tolabel(PRM_Account_Id__r.BillingCountryCode), PRM_Account_Id__r.Core_Account_BU_Focus__c,PRM_Channel_Program_Level_Id__r.Name,PRM_Account_Id__r.Core_IPA_Partner_Speciality__c FROM PRM_AccountChannelMembership__c where PRM_Account_Id__r.Name LIKE :accountName AND PRM_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c = TRUE AND PRM_Account_Id__r.RecordType.DeveloperName =:System.Label.PRM_Intel_Account AND PRM_Partner_Role__c IN:lstOfspecialtyRole LIMIT: dmlLimits];                
                list<PRM_Account_Specialty_Association__c> lstASA = [SELECT Id,PRM_Account_Id__c,PRM_Specialty_Id__c,PRM_Partner_Role__c,PRM_InActive_Ind__c from PRM_Account_Specialty_Association__c where PRM_Account_Id__r.Name LIKE :accountName AND PRM_Specialty_Id__c =:specialtyRecord.Id];
                
                if(lstACM != null && !lstACM.isEmpty()){
                    for(PRM_AccountChannelMembership__c acmRecord : lstACM){
                        flag=true;
                        if(acmRecord != null){
                            if(lstASA != null && !lstASA.isEmpty()){
                                for(PRM_Account_Specialty_Association__c asaRec: lstASA){                            
                                    if(acmRecord.PRM_Partner_Role__c == asaRec.PRM_Partner_Role__c && acmRecord.PRM_Account_Id__c == asaRec.PRM_Account_Id__c && asaRec.PRM_InActive_Ind__c == false){
                                        flag=false;
                                        break;
                                    }                            
                                }
                            }
                            if(flag==true){
                                lstACMtemp.add(acmRecord);                            
                            }                        
                        }                     
                    }
                }         
                if(lstACMtemp != null && !lstACMtemp.isEmpty()){
                    for(PRM_AccountChannelMembership__c acmRec : lstACMtemp){
                        setOfAccIds.add(acmRec.PRM_Account_Id__c);
                    }                    
                }
                List<PRM_Specialty_Data__c> lstOfSpecialtyData = [SELECT Id,PRM_Account_Id__c,PRM_Account_Id__r.Name,PRM_Tier_Id__r.Name,PRM_Partner_Role_Nm__c, PRM_Specialty_Nbr_Employees_Trained_Nbr__c, PRM_Specialty_Training_Credits_Nbr__c from PRM_Specialty_Data__c
                                                                  where PRM_Account_Id__c IN :setOfAccIds AND PRM_Specialty_Id__c = :currentspecialtyId];
                
                if(lstOfSpecialtyData != null && !lstOfSpecialtyData.isEmpty()){
                    for(PRM_Specialty_Data__c spRec : lstOfSpecialtyData){                        
                        string keyValue = spRec.PRM_Account_Id__c +';'+spRec.PRM_Partner_Role_Nm__c;                                                
                        mapOfAccIdRoleAndspcialtyData.put(keyValue, spRec);                                              
                    }
                }
                
                if(lstACMtemp != null && !lstACMtemp.isEmpty()){
                    for(PRM_AccountChannelMembership__c acmRec : lstACMtemp){                        
                        string keyValue = acmRec.PRM_Account_Id__c +';'+acmRec.PRM_Partner_Role__c;                                                
                        mapOfAccIdRoleAndAcmData.put(keyValue, acmRec);                                              
                    }
                }
                
                if(mapOfAccIdRoleAndAcmData != null && !mapOfAccIdRoleAndAcmData.isEmpty()){                    
                    for(String acmkey : mapOfAccIdRoleAndAcmData.keyset()){
                        string noOfTrainedEmp ='';
                        string noOftrainingCredits = '';
                        if(mapOfAccIdRoleAndspcialtyData != null && !mapOfAccIdRoleAndspcialtyData.isEmpty()){
                            if(mapOfAccIdRoleAndspcialtyData.containskey(acmkey)){
                                PRM_AccountChannelMembership__c acmRec = new PRM_AccountChannelMembership__c();
                                PRM_Specialty_Data__c sprec = new PRM_Specialty_Data__c();
                                acmRec = mapOfAccIdRoleAndAcmData.get(acmkey);
                                sprec = mapOfAccIdRoleAndspcialtyData.get(acmkey);
                                Double noOfEmp = sprec.PRM_Specialty_Nbr_Employees_Trained_Nbr__c;
                                Double trainingCreditsnum = sprec.PRM_Specialty_Training_Credits_Nbr__c;
                                noOfTrainedEmp = string.valueOf(Integer.valueOf(noOfEmp));
                                noOftrainingCredits = string.valueOf(Integer.valueOf(trainingCreditsnum));                                    
                                lstofAccAndAcmWrapper.add(new AccAndAcmWrapper(acmRec.Id,acmRec.PRM_Account_Id__c,acmRec.PRM_Account_Id__r.AccountNumber,acmRec.PRM_Account_Id__r.Name,acmRec.PRM_Partner_Role__c,acmRec.PRM_Account_Id__r.Core_User_Defined_Phone_Number__c,acmRec.PRM_Account_Id__r.BillingCountryCode,acmRec.PRM_Account_Id__r.Core_Account_BU_Focus__c,acmRec.PRM_Channel_Program_Level_Id__r.Name,noOftrainingCredits,noOfTrainedEmp));
                            }else{                                
                                PRM_AccountChannelMembership__c acmRec = new PRM_AccountChannelMembership__c();
                                PRM_Specialty_Data__c sprec = new PRM_Specialty_Data__c();
                                acmRec = mapOfAccIdRoleAndAcmData.get(acmkey);                                    
                                lstofAccAndAcmWrapper.add(new AccAndAcmWrapper(acmRec.Id,acmRec.PRM_Account_Id__c,acmRec.PRM_Account_Id__r.AccountNumber,acmRec.PRM_Account_Id__r.Name,acmRec.PRM_Partner_Role__c,acmRec.PRM_Account_Id__r.Core_User_Defined_Phone_Number__c,acmRec.PRM_Account_Id__r.BillingCountryCode,acmRec.PRM_Account_Id__r.Core_Account_BU_Focus__c,acmRec.PRM_Channel_Program_Level_Id__r.Name,noOftrainingCredits,noOfTrainedEmp));
                            }                           
                        }else{                            
                            PRM_AccountChannelMembership__c acmRec = new PRM_AccountChannelMembership__c();
                            PRM_Specialty_Data__c sprec = new PRM_Specialty_Data__c();
                            acmRec = mapOfAccIdRoleAndAcmData.get(acmkey);                                    
                            lstofAccAndAcmWrapper.add(new AccAndAcmWrapper(acmRec.Id,acmRec.PRM_Account_Id__c,acmRec.PRM_Account_Id__r.AccountNumber,acmRec.PRM_Account_Id__r.Name,acmRec.PRM_Partner_Role__c,acmRec.PRM_Account_Id__r.Core_User_Defined_Phone_Number__c,acmRec.PRM_Account_Id__r.BillingCountryCode,acmRec.PRM_Account_Id__r.Core_Account_BU_Focus__c,acmRec.PRM_Channel_Program_Level_Id__r.Name,noOftrainingCredits,noOfTrainedEmp));
                        } 
                    }
                }                              
            }         
            //US587204  END
            
            if(lstofAccAndAcmWrapper.isEmpty()) {
                errorMsg = System.Label.PRM_Error_Msg_OnAddPartner;
            } 
            else{
                errorMsg = '';
            }           
            FinalRecWrapperlist finalRecWrapperObj = new FinalRecWrapperlist();
            finalRecWrapperObj.errMsg = errorMsg;
            finalRecWrapperObj.lstofAccAndAcmWrapper = lstofAccAndAcmWrapper;
            lstOfFinalAcmRecWrap.add(finalRecWrapperObj);           
        }
        catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }         
        return lstOfFinalAcmRecWrap;
    }    
    
    //US587186:- Method to return Partner Role picklist field values
    @AuraEnabled(cacheable=true)
    public static List < FatchValueWrapper > fetchPickListValue(String currentSpecialtyId) {    
        List<String> lstofpartnerRole = new List<String>();        
        String partnerroleNames = [Select Id, PRM_Role_Nm__c from PRM_Specialty__c where Id =:currentSpecialtyId].PRM_Role_Nm__c;
        lstofpartnerRole = partnerroleNames.split(';');              
        if(lstofpartnerRole != null && !lstofpartnerRole.isEmpty()){
            for (String roleName: lstofpartnerRole) {
                FatchValueWrapper oFatchValueWrapper = new FatchValueWrapper();
                oFatchValueWrapper.slabel = roleName;
                oFatchValueWrapper.svalue = roleName;
                objWrapper.add(oFatchValueWrapper);
            }
        }        
        return objWrapper; 
    }
    //Method to return picklist field values.
    @AuraEnabled(cacheable=true)
    public static List < FatchValueWrapper > fetchAccTypePickListValue(sObject objInfo, string picklistFieldApi) {
        objDescribe = objInfo.getSObjectType().getDescribe();
        fieldMap = objDescribe.fields.getMap();
        values = fieldMap.get(picklistFieldApi).getDescribe().getPickListValues();
        //list < FatchValueWrapper > objWrapper = new list < FatchValueWrapper >();
        for (Schema.PicklistEntry a: values) {
            FatchValueWrapper oFatchValueWrapper = new FatchValueWrapper();
            oFatchValueWrapper.slabel = a.getLabel();
            oFatchValueWrapper.svalue = a.getValue();
            objWrapper.add(oFatchValueWrapper);
        }
        return objWrapper;
    }
    //Method to return picklist field values.
    @AuraEnabled(cacheable=true)
    public static List < FatchValueWrapper > fetchAccCouPickListValue(sObject objInfo, string picklistFieldApi) {
        objDescribe = objInfo.getSObjectType().getDescribe();
        fieldMap = objDescribe.fields.getMap();
        values = fieldMap.get(picklistFieldApi).getDescribe().getPickListValues();
        //list < FatchValueWrapper > objWrapper = new list < FatchValueWrapper > ();
        for (Schema.PicklistEntry a: values) {
            FatchValueWrapper oFatchValueWrapper = new FatchValueWrapper();
            oFatchValueWrapper.slabel = a.getLabel();
            oFatchValueWrapper.svalue = a.getValue();
            objWrapper.add(oFatchValueWrapper);
        }
        return objWrapper;
    }
    
    //Method to return picklist field values
    @AuraEnabled(cacheable=true)
    public static List < FatchValueWrapper > fetchTierPickListValue() {
        //list < FatchValueWrapper > objWrapper = new list < FatchValueWrapper > (); 
        List<ChannelProgramLevel> lstTier=[select Name from ChannelProgramLevel where Program.Name = :System.Label.PRM_Intel_Partner_Alliance];
        
        for (ChannelProgramLevel a: lstTier) {
            FatchValueWrapper oFatchValueWrapper = new FatchValueWrapper();
            oFatchValueWrapper.slabel = a.Name;
            oFatchValueWrapper.svalue = a.Name;
            objWrapper.add(oFatchValueWrapper);
        }
        return objWrapper;    
    }
    
    //Method to fetch Specialty criteria Ids related to current specialty(useful for removing unselected crit from Persisted partners)
    @AuraEnabled(cacheable=true)
    public static list<string> fetchSpCritRelatedToCurrentSp(Id currentspecialtyId) {
        System.debug(' currentspecialtyId '+currentspecialtyId);
        List<string> lstOfspCritIdsrelatedToSp = new List<string>();
        List<PRM_Specialty_Qualitative_Criteria__c> lstofSpCritData = new List<PRM_Specialty_Qualitative_Criteria__c>();
        
        lstofSpCritData  = [Select Id,PRM_Specialty_Id__r.name,PRM_Criteria_Id__c,PRM_Criteria_Id__r.Name from PRM_Specialty_Qualitative_Criteria__c where PRM_Specialty_Id__c =: currentspecialtyId];
        if(lstofSpCritData != null && !lstofSpCritData.isEmpty()){
            for(PRM_Specialty_Qualitative_Criteria__c critData : lstofSpCritData){
                lstOfspCritIdsrelatedToSp.add(critData.PRM_Criteria_Id__c);
            }            
        }   
        
        return lstOfspCritIdsrelatedToSp;
    }    
    
    //Method to return list of filtered list of accounts based on criteria
    @AuraEnabled
    public static List<FinalRecWrapperlist> filterAccsData(String accountName,String partnerRoleValues, String accType, String countryValues, String tierValue,Id currentspecialtyId) {
        String cols;
        String specialtyname = ''; 
        Boolean flag = true;
        String accountNameFilter = '%' + accountName + '%';        
        dmlLimits = Limits.getLimitQueryRows();       
        Set<String> accountRecordType = new Set<String>{System.Label.PRM_Intel_Account};
        list<PRM_AccountChannelMembership__c> lstACM = new list<PRM_AccountChannelMembership__c>();
        list<PRM_AccountChannelMembership__c> lstACMtemp=new List<PRM_AccountChannelMembership__c>();  
        List<String> lstOfspecialtyRole = new List<String>();  //US587183  
        
        Try{
            PRM_Specialty__c specialtyRecord =[Select Id,Name,PRM_Role_Nm__c from PRM_Specialty__c where Id =: currentspecialtyId][0];      //US587183
            specialtyname = specialtyRecord.Name; 
            lstOfspecialtyRole =specialtyRecord.PRM_Role_Nm__c.split(';');
            String conditionString = 'PRM_Account_Id__r.Name LIKE: accountNameFilter AND PRM_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c = TRUE AND PRM_Account_Id__r.RecordType.DeveloperName IN:accountRecordType AND PRM_Partner_Role__c IN:lstOfspecialtyRole';
            cols = 'Id, Name,PRM_Account_Id__r.RecordType.DeveloperName,PRM_Account_Id__c,PRM_Account_Id__r.Id,PRM_Account_Id__r.AccountNumber ,PRM_Account_Id__r.Name,PRM_Partner_Role__c, PRM_Account_Id__r.Core_User_Defined_Phone_Number__c, tolabel(PRM_Account_Id__r.BillingCountryCode),PRM_Account_Id__r.Core_Account_BU_Focus__c,PRM_Channel_Program_Level_Id__c,PRM_Channel_Program_Level_Id__r.Name,PRM_Account_Id__r.Core_IPA_Partner_Speciality__c';
            String query = 'SELECT '+cols+ ' from PRM_AccountChannelMembership__c WHERE ';        
            
            if(String.isempty(partnerRoleValues) != TRUE){
                conditionString += ' AND PRM_Partner_Role__c =: partnerRoleValues';
            }
            if(String.isempty(accType) != TRUE){
                conditionString += ' AND PRM_Account_Id__r.Core_Account_BU_Focus__c INCLUDES (:accType)';
            }
            if(String.isempty(countryValues) != TRUE){
                conditionString += ' AND PRM_Account_Id__r.BillingCountryCode =: countryValues';
                
            }
            if(String.isempty(tierValue) != TRUE){
                conditionString += ' AND PRM_Channel_Program_Level_Id__r.Name =: tierValue';
            }
            conditionString += ' LIMIT: dmlLimits';
            query += conditionString;
            lstACM = database.query(query); 
            list<PRM_Account_Specialty_Association__c> lstASA = [SELECT Id,PRM_Account_Id__c,PRM_Specialty_Id__c,PRM_Partner_Role__c,PRM_InActive_Ind__c from PRM_Account_Specialty_Association__c where PRM_Account_Id__r.Name LIKE :accountNameFilter AND PRM_Specialty_Id__c =:specialtyRecord.Id];
            
            if(lstACM != null && !lstACM.isEmpty()){
                for(PRM_AccountChannelMembership__c acmRecord : lstACM){
                    flag=true;
                    if(acmRecord != null){
                        if(lstASA != null && !lstASA.isEmpty()){
                            for(PRM_Account_Specialty_Association__c asaRec: lstASA){                            
                                if(acmRecord.PRM_Partner_Role__c == asaRec.PRM_Partner_Role__c && acmRecord.PRM_Account_Id__c == asaRec.PRM_Account_Id__c && asaRec.PRM_InActive_Ind__c == false){
                                    flag=false;
                                    break;
                                }                            
                            }
                        }
                        if(flag==true){
                            lstACMtemp.add(acmRecord);                            
                        }                        
                    }                     
                }
            }
            
            if(lstACMtemp != null && !lstACMtemp.isEmpty()){
                for(PRM_AccountChannelMembership__c acmRec : lstACMtemp){
                    setOfAccIds.add(acmRec.PRM_Account_Id__c);
                }                    
            }
            List<PRM_Specialty_Data__c> lstOfSpecialtyData = [SELECT Id,PRM_Account_Id__c,PRM_Account_Id__r.Name,PRM_Tier_Id__r.Name,PRM_Partner_Role_Nm__c, PRM_Specialty_Nbr_Employees_Trained_Nbr__c, PRM_Specialty_Training_Credits_Nbr__c from PRM_Specialty_Data__c
                                                              where PRM_Account_Id__c IN :setOfAccIds AND PRM_Specialty_Id__c = :currentspecialtyId];
            
            if(lstOfSpecialtyData != null && !lstOfSpecialtyData.isEmpty()){
                for(PRM_Specialty_Data__c spRec : lstOfSpecialtyData){                        
                    string keyValue = spRec.PRM_Account_Id__c +';'+spRec.PRM_Partner_Role_Nm__c;                                                
                    mapOfAccIdRoleAndspcialtyData.put(keyValue, spRec);                                              
                }
            }
            
            if(lstACMtemp != null && !lstACMtemp.isEmpty()){
                for(PRM_AccountChannelMembership__c acmRec : lstACMtemp){                        
                    string keyValue = acmRec.PRM_Account_Id__c +';'+acmRec.PRM_Partner_Role__c;                                                
                    mapOfAccIdRoleAndAcmData.put(keyValue, acmRec);                                              
                }
            }
            
            if(mapOfAccIdRoleAndAcmData != null && !mapOfAccIdRoleAndAcmData.isEmpty()){                    
                for(String acmkey : mapOfAccIdRoleAndAcmData.keyset()){
                    string noOfTrainedEmp ='';
                    string noOftrainingCredits = '';
                    if(mapOfAccIdRoleAndspcialtyData != null && !mapOfAccIdRoleAndspcialtyData.isEmpty()){
                        if(mapOfAccIdRoleAndspcialtyData.containskey(acmkey)){
                            PRM_AccountChannelMembership__c acmRec = new PRM_AccountChannelMembership__c();
                            PRM_Specialty_Data__c sprec = new PRM_Specialty_Data__c();
                            acmRec = mapOfAccIdRoleAndAcmData.get(acmkey);
                            sprec = mapOfAccIdRoleAndspcialtyData.get(acmkey);
                            Double noOfEmp = sprec.PRM_Specialty_Nbr_Employees_Trained_Nbr__c;
                            Double trainingCreditsnum = sprec.PRM_Specialty_Training_Credits_Nbr__c;
                            noOfTrainedEmp = string.valueOf(Integer.valueOf(noOfEmp));
                            noOftrainingCredits = string.valueOf(Integer.valueOf(trainingCreditsnum));                                    
                            lstofAccAndAcmWrapper.add(new AccAndAcmWrapper(acmRec.Id,acmRec.PRM_Account_Id__c,acmRec.PRM_Account_Id__r.AccountNumber,acmRec.PRM_Account_Id__r.Name,acmRec.PRM_Partner_Role__c,acmRec.PRM_Account_Id__r.Core_User_Defined_Phone_Number__c,acmRec.PRM_Account_Id__r.BillingCountryCode,acmRec.PRM_Account_Id__r.Core_Account_BU_Focus__c,acmRec.PRM_Channel_Program_Level_Id__r.Name,noOftrainingCredits,noOfTrainedEmp));
                        }else{                            
                            PRM_AccountChannelMembership__c acmRec = new PRM_AccountChannelMembership__c();
                            PRM_Specialty_Data__c sprec = new PRM_Specialty_Data__c();
                            acmRec = mapOfAccIdRoleAndAcmData.get(acmkey);                                    
                            lstofAccAndAcmWrapper.add(new AccAndAcmWrapper(acmRec.Id,acmRec.PRM_Account_Id__c,acmRec.PRM_Account_Id__r.AccountNumber,acmRec.PRM_Account_Id__r.Name,acmRec.PRM_Partner_Role__c,acmRec.PRM_Account_Id__r.Core_User_Defined_Phone_Number__c,acmRec.PRM_Account_Id__r.BillingCountryCode,acmRec.PRM_Account_Id__r.Core_Account_BU_Focus__c,acmRec.PRM_Channel_Program_Level_Id__r.Name,noOftrainingCredits,noOfTrainedEmp));
                        }                           
                    }else{                        
                        PRM_AccountChannelMembership__c acmRec = new PRM_AccountChannelMembership__c();
                        PRM_Specialty_Data__c sprec = new PRM_Specialty_Data__c();
                        acmRec = mapOfAccIdRoleAndAcmData.get(acmkey);                                    
                        lstofAccAndAcmWrapper.add(new AccAndAcmWrapper(acmRec.Id,acmRec.PRM_Account_Id__c,acmRec.PRM_Account_Id__r.AccountNumber,acmRec.PRM_Account_Id__r.Name,acmRec.PRM_Partner_Role__c,acmRec.PRM_Account_Id__r.Core_User_Defined_Phone_Number__c,acmRec.PRM_Account_Id__r.BillingCountryCode,acmRec.PRM_Account_Id__r.Core_Account_BU_Focus__c,acmRec.PRM_Channel_Program_Level_Id__r.Name,noOftrainingCredits,noOfTrainedEmp));
                    } 
                }
            }            
            
            if(lstofAccAndAcmWrapper.isEmpty()) {
                errorMsg = System.Label.PRM_Error_Msg_OnAddPartner;
            } 
            else{
                errorMsg = '';
            }           
            FinalRecWrapperlist finalRecWrapperObj = new FinalRecWrapperlist();
            finalRecWrapperObj.errMsg = errorMsg;
            finalRecWrapperObj.lstofAccAndAcmWrapper = lstofAccAndAcmWrapper;
            lstOfFinalAcmRecWrap.add(finalRecWrapperObj);   
        }
        catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }     
        
        return lstOfFinalAcmRecWrap; 
    }  
    
    //Method to return specialty criteria details
    @AuraEnabled(cacheable=true)
    public static List<PRM_Specialty__c> getCriteriaDetails(String specialtyId) {
        return [Select id,name, PRM_Quantitative_Criteria_Txt__c, (Select Id, Name, PRM_Account_Id__c, PRM_Specialty_Id__c from Account_Specialty_Associations__r), (Select id , name, PRM_Criteria_Id__c, PRM_Criteria_Id__r.Name from Specialty_Criteria_Associations__r) from PRM_Specialty__c where Id =:specialtyId];
    }
    
    //Method to insert record after confirmation
    @AuraEnabled
    public static String insertRelatedRecords(List<Object> lstaccIdAndAcm, String specialtyId, String accCommentsMap,List<String> lstOfTotalSpCritRelSp) {       
        List<List<String>> accstring = (List<List<String>>) System.JSON.deserialize(accCommentsMap, List<List<String>>.class);
        List<AccAndAcmWrapper> lstaccAndAcmWrapper = (List<AccAndAcmWrapper>)JSON.deserialize(JSON.serialize(lstaccIdAndAcm), List<AccAndAcmWrapper>.class);              
        Map<String,String> commentMap = new  Map<String,String>();
        String result = 'Warning';
        Database.UpsertResult[] succlstOfASA;
        Integer successCount = 0;
        Integer failureCount = 0;
        Set<Id> successfulAccountIds = new Set<Id>();
        set<String> lstAccId = new set<String>();
        set<PRM_Account_Specialty_Association__c> asaset = new set<PRM_Account_Specialty_Association__c>();
        List<PRM_Account_Specialty_Association__c> asalist = new List<PRM_Account_Specialty_Association__c>();
        set<PRM_Account_Specialty_Association__c> existingASA = new set<PRM_Account_Specialty_Association__c>();        
        Map<String,String> uniqueMap = new Map<String,String>();
        Map<String,List<String>> finalMap = new Map<String,List<String>>();
        List<String> lstcritids = new List<String>();
        set<PRM_Account_Specialty_Qual_Criteria__c> asqcset = new set<PRM_Account_Specialty_Qual_Criteria__c>();
        set<PRM_Account_Specialty_Qual_Criteria__c> insertset = new set<PRM_Account_Specialty_Qual_Criteria__c>();
        set<PRM_Account_Specialty_Qual_Criteria__c> existingset = new set<PRM_Account_Specialty_Qual_Criteria__c>();
        Map<String,Set<String>> asaCriteriaIdMap = new Map<String,Set<String>>();
        set<string> setOfAsaId = new set<String>();
        set<string> setOfInsertedspCritId = new set<String>();                     
        List<PRM_Account_Specialty_Qual_Criteria__c> finalPossAsqcLst = new List<PRM_Account_Specialty_Qual_Criteria__c>();
        List<PRM_Account_Specialty_Qual_Criteria__c> finalAsqcToUpsert = new List<PRM_Account_Specialty_Qual_Criteria__c>();
        List<PRM_Account_Specialty_Qual_Criteria__c> lstOfAsqcToBeInserted = new List<PRM_Account_Specialty_Qual_Criteria__c>();
        List<PRM_Account_Specialty_Qual_Criteria__c> lstOfAllPossibleAsqcRec = new List<PRM_Account_Specialty_Qual_Criteria__c>();
        map<String,boolean> mapOfAsaCritAndInactiveInd = new map<String,boolean>();
        map<String, String> mapOfAsaCritIdAndAsqcId = new map<String, String>();
        
        Try{
            if(lstaccAndAcmWrapper!= null && !lstaccAndAcmWrapper.isEmpty()){
                for(AccAndAcmWrapper rec : lstaccAndAcmWrapper){                
                    lstAccId.add(rec.accountId);                
                }      
            }
            
            for(List<String> str:accstring){
                commentMap.put(str[0],str[1]);
            }
            
            PRM_Specialty__c Specialty =[select id,PRM_Start_Date_Dt__c,PRM_End_Date_Dt__c from PRM_Specialty__c where id=:specialtyId];
            Set<Id> succASARecIds = new Set<Id>();
            for(PRM_Account_Specialty_Association__c dupcheckasa: [select id,PRM_Account_Id__c,PRM_Partner_Role__c,PRM_Specialty_Id__c,PRM_Notes_Txt__c,PRM_InActive_Ind__c from PRM_Account_Specialty_Association__c where PRM_Account_Id__c IN:lstAccId AND PRM_Specialty_Id__c=:specialtyId and PRM_InActive_Ind__c=TRUE ]){
                //dupcheckasa.PRM_InActive_Ind__c=False;
                if(lstaccAndAcmWrapper != null && !lstaccAndAcmWrapper.isEmpty()){
                    for(AccAndAcmWrapper wraplstRec : lstaccAndAcmWrapper){ 
                        if(wraplstRec.accountId == dupcheckasa.PRM_Account_Id__c && wraplstRec.acmpartnerRole == dupcheckasa.PRM_Partner_Role__c){
                            dupcheckasa.PRM_InActive_Ind__c=False;//Bug
                            if(commentMap!=null && commentMap.ContainsKey(wraplstRec.Id)){                    
                                dupcheckasa.PRM_Notes_Txt__c=commentMap.get(wraplstRec.Id); 
                                
                            }else {
                                dupcheckasa.PRM_Notes_Txt__c = '';
                            }
                        }
                    }                    
                }
                existingASA.add(dupcheckasa); 
                setOfAsaId.add(dupcheckasa.Id);
            }
            
            if(lstaccAndAcmWrapper!=Null || !lstaccAndAcmWrapper.isEmpty()){
                for(AccAndAcmWrapper acc : lstaccAndAcmWrapper){
                    PRM_Account_Specialty_Association__c asa = new PRM_Account_Specialty_Association__c();
                    asa.PRM_Account_Id__c = acc.accountId;
                    asa.PRM_Specialty_Id__c = specialtyId;
                    asa.PRM_Partner_Role__c = acc.acmpartnerRole;
                    if(commentMap!=null && commentMap.ContainsKey(acc.Id)){
                        asa.PRM_Notes_Txt__c=commentMap.get(acc.Id);
                    }else {
                        asa.PRM_Notes_Txt__c = '';
                    }
                    if(!existingASA.contains(asa)){                        
                        asaset.add(asa);   
                    }            
                }
            }
            
            if(existingASA!=Null || !existingASA.isEmpty()){
                asaList.addAll(existingASA); 
            }
            
            if(asaset!=Null || !asaset.isEmpty()){
                asaList.addAll(asaset); 
            }
            
            if(asaList<>null && !asaList.isEmpty()){         
                succlstOfASA =  Database.upsert(asaList,false);
            }
            if(succlstOfASA<>null && !succlstOfASA.isEmpty()){
                for(Database.upsertResult successrec:succlstOfASA)
                {
                    if(successrec.isSuccess())
                    { 
                        succASARecIds.add(successrec.getId());                        
                        successCount++;}else{                       
                            for(Database.Error err : successrec.getErrors()) {
                                failureCount++;  
                            }
                        }
                }
            }
            if(successCount > 0){result = 'Success';
                                 
                                }        
            else{
                result = 'Failed';
            } 
            system.debug('Sucess ASA Ids' +succASARecIds);           
            
            List<PRM_Account_Specialty_Association__c> succASA = [SELECT ID,Name,PRM_Account_Id__c,PRM_Partner_Role__c,PRM_Account_Id__r.name,PRM_Specialty_Id__r.name,PRM_Specialty_Id__c FROM PRM_Account_Specialty_Association__c WHERE ID IN :succASARecIds];
            if(!succASA.isEmpty()){               
                PRM_EmailUtility.sendEmailToPublicGroup(succASA);                
            }            
            List<PRM_Persisted_Partners__c> persistdata = [Select Id,PRM_Account_Id__c,PRM_Partner_Role__c,PRM_Specialty_Id__c,PRM_Specialty_Criteria_Id__c from PRM_Persisted_Partners__c where PRM_Specialty_Id__c =: specialtyId AND PRM_Specialty_Criteria_Id__c != null];
            if(persistdata!=Null || !persistdata.isEmpty()){
                for(PRM_Persisted_Partners__c perRec : persistdata){ 
                    if(lstaccAndAcmWrapper != null && !lstaccAndAcmWrapper.isEmpty()){
                        for(AccAndAcmWrapper wraplstRec : lstaccAndAcmWrapper){ 
                            if(wraplstRec.accountId == perRec.PRM_Account_Id__c && wraplstRec.acmpartnerRole == perRec.PRM_Partner_Role__c){
                                //  check the below code
                                if(finalMap.containskey(wraplstRec.Id)){
                                    lstcritids = finalMap.get(wraplstRec.Id);
                                    lstcritids.add(perRec.PRM_Specialty_Criteria_Id__c);
                                    finalMap.put(wraplstRec.Id,lstcritids);
                                }else{
                                    finalMap.put(wraplstRec.Id, new  List<String> {perRec.PRM_Specialty_Criteria_Id__c});   
                                } 
                            }                            
                        }
                    }                               
                }  
            } 
            List<PRM_Account_Specialty_Association__c> lstOfInsertedAsa = [select id,PRM_Account_Id__c,PRM_Partner_Role__c,PRM_Specialty_Id__c,PRM_Start_Date_Dt__c,
                                                                            PRM_End_Date_Dt__c from PRM_Account_Specialty_Association__c where 
                                                                            PRM_Account_Id__c IN:lstAccId AND PRM_Specialty_Id__c =:specialtyId];
            for(PRM_Account_Specialty_Association__c asa:lstOfInsertedAsa)
            {   
                //US616939  Insert All criteria related specialty Inactive Asqc record 
                if(lstOfTotalSpCritRelSp != null && !lstOfTotalSpCritRelSp.isEmpty()){
                    for(String crit : lstOfTotalSpCritRelSp){
                        PRM_Account_Specialty_Qual_Criteria__c asqa = new PRM_Account_Specialty_Qual_Criteria__c();
                        asqa.PRM_Account_Specialty_Association_Id__c = asa.id;
                        asqa.PRM_Specialty_Criteria_Id__c= crit;
                        asqa.PRM_InActive_Ind__c = true;//changed
                        lstOfAllPossibleAsqcRec.add(asqa);
                    }
                }
                //FinalMap - containing selected sp crit related to ACM Id
            	if(finalMap<>null && !finalMap.isEmpty()){               
                                
                    for(String acmId : finalMap.keySet()){
                        if(lstaccAndAcmWrapper != null && !lstaccAndAcmWrapper.isEmpty()){
                            for(AccAndAcmWrapper wrapRec : lstaccAndAcmWrapper){ 
                                if(acmId == wrapRec.Id && wrapRec.accountId == asa.PRM_Account_Id__c && wrapRec.acmpartnerRole == asa.PRM_Partner_Role__c){
                                    if(finalMap.get(acmId)!= null){
                                        for(id criteriaID:finalMap.get(acmId)){                            
                                            PRM_Account_Specialty_Qual_Criteria__c asqa = new PRM_Account_Specialty_Qual_Criteria__c();
                                            asqa.PRM_Account_Specialty_Association_Id__c = asa.id;
                                            asqa.PRM_Specialty_Criteria_Id__c= criteriaID;
                                            asqa.PRM_InActive_Ind__c = false;                                           
                                            lstOfAsqcToBeInserted.add(asqa);                                        
                                            mapOfAsaCritAndInactiveInd.put(asqa.PRM_Account_Specialty_Association_Id__c+';'+asqa.PRM_Specialty_Criteria_Id__c,false); 
                                            
                                        }           
                                    }                                    
                                }
                            }
                        } 
                    } 
                }               
            }

            for(PRM_Account_Specialty_Qual_Criteria__c allRec :lstOfAllPossibleAsqcRec){
                if(mapOfAsaCritAndInactiveInd.containsKey(allRec.PRM_Account_Specialty_Association_Id__c+';'+allRec.PRM_Specialty_Criteria_Id__c)){
                    allRec.PRM_InActive_Ind__c = false;
                }
                finalPossAsqcLst.add(allRec);
            }           
            
            List<PRM_Account_Specialty_Qual_Criteria__c> lstOfAllAsqcRec = [Select Id, PRM_Account_Specialty_Association_Id__c,PRM_Specialty_Criteria_Id__c,PRM_InActive_Ind__c from PRM_Account_Specialty_Qual_Criteria__c 
                                                                           where PRM_Account_Specialty_Association_Id__c IN: succASARecIds];
            
            if(lstOfAllAsqcRec<>null && !lstOfAllAsqcRec.isEmpty()){
                for(PRM_Account_Specialty_Qual_Criteria__c asqcRec : lstOfAllAsqcRec){
                	mapOfAsaCritIdAndAsqcId.put(asqcRec.PRM_Account_Specialty_Association_Id__c+';'+asqcRec.PRM_Specialty_Criteria_Id__c, asqcRec.Id);
            	}   
            }
            
            if(finalPossAsqcLst<>null && !finalPossAsqcLst.isEmpty()){
                for(PRM_Account_Specialty_Qual_Criteria__c asqcObj : finalPossAsqcLst){
                    PRM_Account_Specialty_Qual_Criteria__c upAsqcObj;
                    if(mapOfAsaCritIdAndAsqcId.containsKey(asqcObj.PRM_Account_Specialty_Association_Id__c+';'+asqcObj.PRM_Specialty_Criteria_Id__c)){
                         upAsqcObj = new PRM_Account_Specialty_Qual_Criteria__c();
                        upAsqcObj.Id = mapOfAsaCritIdAndAsqcId.get(asqcObj.PRM_Account_Specialty_Association_Id__c+';'+asqcObj.PRM_Specialty_Criteria_Id__c);
                        upAsqcObj.PRM_InActive_Ind__c = asqcObj.PRM_InActive_Ind__c;
					}else{
                         upAsqcObj = new PRM_Account_Specialty_Qual_Criteria__c();
                        upAsqcObj.PRM_Account_Specialty_Association_Id__c = asqcObj.PRM_Account_Specialty_Association_Id__c;
                        upAsqcObj.PRM_Specialty_Criteria_Id__c = asqcObj.PRM_Specialty_Criteria_Id__c;
                        upAsqcObj.PRM_InActive_Ind__c = asqcObj.PRM_InActive_Ind__c;
                    }
                    finalAsqcToUpsert.add(upAsqcObj);
                }
            }
            
            if(finalAsqcToUpsert<>null && !finalAsqcToUpsert.isEmpty()){                    
                upsert finalAsqcToUpsert;
                
            }            
            //Delete approved records from Persist Partner Object----START
            List<PRM_Persisted_Partners__c > lstOfApprovedPersistData = [select Id,PRM_Account_Id__c,PRM_Account_Id__r.Id,PRM_Partner_Role__c,PRM_Specialty_Id__c,PRM_Specialty_Criteria_Id__c from PRM_Persisted_Partners__c where PRM_Account_Id__c =: lstAccId AND PRM_Specialty_Id__c =: specialtyId];
            delete lstOfApprovedPersistData;
            //Delete approved records from Persist Partner Object----END
        }
        catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }         
        return result;
        }
        //Method to Insert Approval Pending Records in Custom Object
        @AuraEnabled
        public static void insertApprovalPendingRecords(List<Object> lstaccId, String specialtyId) {        
            List<AccAndAcmWrapper> lstaccAndAcmWrapper = (List<AccAndAcmWrapper>)JSON.deserialize(JSON.serialize(lstaccId), List<AccAndAcmWrapper>.class);
            List<AccAndAcmWrapper> finallstOfAccAndAcmWrapper = new List<AccAndAcmWrapper>();              
            set<PRM_Persisted_Partners__c> persPartnerset = new set<PRM_Persisted_Partners__c>();
            List<PRM_Persisted_Partners__c> persPartnerslist = new List<PRM_Persisted_Partners__c>();        
            Database.SaveResult[] succlstOfpersPartners;
            Map<String,List<String>> finalMap = new Map<String,List<String>>();
            Boolean flag=true;
            Try{
                List<PRM_Persisted_Partners__c> existPersistRec =[Select PRM_Account_Id__c,PRM_Partner_Role__c,PRM_Specialty_Id__c from PRM_Persisted_Partners__c where PRM_Specialty_Id__c = :specialtyId];
                
                if(lstaccAndAcmWrapper != null && !lstaccAndAcmWrapper.isEmpty()){
                    for(AccAndAcmWrapper acmRecord : lstaccAndAcmWrapper){
                        flag=true;
                        if(acmRecord != null){
                            if(existPersistRec != null && !existPersistRec.isEmpty()){
                                for(PRM_Persisted_Partners__c existRec: existPersistRec){                            
                                    if(acmRecord.acmpartnerRole == existRec.PRM_Partner_Role__c && acmRecord.accountId == existRec.PRM_Account_Id__c){
                                        flag=false;
                                        break;
                                    }                            
                                }
                            }
                            if(flag==true){
                                finallstOfAccAndAcmWrapper.add(acmRecord);                            
                            }                        
                        }                     
                    }
                } 
                
                if(finallstOfAccAndAcmWrapper != null && !finallstOfAccAndAcmWrapper.isEmpty()){            
                    for(AccAndAcmWrapper acc : finallstOfAccAndAcmWrapper){                                      
                        PRM_Persisted_Partners__c persPartners = new PRM_Persisted_Partners__c();
                        persPartners.PRM_Account_Id__c = acc.accountId;
                        persPartners.PRM_Specialty_Id__c = specialtyId; 
                        persPartners.PRM_Partner_Role__c = acc.acmpartnerRole;                             
                        persPartnerset.add(persPartners); 
                        
                    }
                }
                
                if(persPartnerset!=Null || !persPartnerset.isEmpty()){
                    persPartnerslist.addAll(persPartnerset); 
                }  
                
                if(persPartnerslist<>null && !persPartnerslist.isEmpty()){
                    
                    succlstOfpersPartners =  Database.insert(persPartnerslist,false);
                } 
            }catch(DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
            } 
        }
        
        @AuraEnabled
        public static Void insertApprovalPendingCriteria(List<Object> lstaccAndAcmRec,String specialtyId,String accWithSpecCriteria) {            
            List<AccAndAcmWrapper> lstaccAndAcmRecWrapper = (List<AccAndAcmWrapper>)JSON.deserialize(JSON.serialize(lstaccAndAcmRec), List<AccAndAcmWrapper>.class);
            set<PRM_Persisted_Partners__c> persPartnerset = new set<PRM_Persisted_Partners__c>();
            List<PRM_Persisted_Partners__c> persPartnerslist = new List<PRM_Persisted_Partners__c>();
            Map<String,List<Object>> requredmap = new Map<String,List<Object>>();
            Map<String,List<String>> finalMap = new Map<String,List<String>>();
            List<Object> accountspecialtyCriteria;        
            Database.SaveResult[] succlstOfpersPartners;   
            set<PRM_Persisted_Partners__c> existingPerPartners = new set<PRM_Persisted_Partners__c>();
            List<PRM_Persisted_Partners__c > lstOfExistPersistSpCritRec;
            set<String> lstpartnerRole = new set<String>();        
            List<String> lstcritids = new List<String>();            
            Boolean flag = true;        
            List<AccAndAcmWrapper> finallstOfAccAndAcmWrapper = new List<AccAndAcmWrapper>();
            set<String> existcriteriaList = new set<String>();
            Map<String,string> mapOfCmpStrAndAcmID = new Map<String,string>();
            Map<String,List<String>> mapOfExistPersAccRoleAndlstOfspCrit = new Map<String,List<String>>();
            String acmIdKey ='';
            List<PRM_Persisted_Partners__c> existPersistRec = new List<PRM_Persisted_Partners__c>();
            //List<PRM_Persisted_Partners__c> existPersistRec = (List<PRM_Persisted_Partners__c>)JSON.deserialize(JSON.serialize(existPersData), List<PRM_Persisted_Partners__c>.class);
            //system.debug('existPersistRec After:-'+existPersistRec);
            
            Try{
                existPersistRec = [Select PRM_Account_Id__c,PRM_Partner_Role__c,PRM_Specialty_Id__c,PRM_Specialty_Criteria_Id__c from PRM_Persisted_Partners__c where PRM_Specialty_Id__c = :specialtyId AND PRM_Specialty_Criteria_Id__c != null];            
                                
                accountspecialtyCriteria  = (List<Object>) JSON.deserializeUntyped(accWithSpecCriteria);                
                for(Object a : accountspecialtyCriteria)
                {  
                    Map<String,object> c = (Map<String,object>) a;                    
                    for(String key : c.keySet()){                        
                        List<Object> vv = (List<Object>) c.get('value');                                            
                        requredmap.put(String.valueOf(c.get('label')),vv);
                    }
                }      
                
                for(String s : requredmap.keySet()){
                    List<String> criteriaList = new List<String>();
                    for(Object o : requredmap.get(s)){
                        criteriaList.add(String.valueOf(o));
                        existcriteriaList.add(String.valueOf(o));
                    }
                    finalMap.put(s,criteriaList);
                }           
                                
                if(finalMap<>null && !finalMap.isEmpty()){
                    for(String acmId : finalMap.keySet()){
                        if(finalMap.get(acmId)!= null){
                            for(Id criteriaID:finalMap.get(acmId)){
                                if(lstaccAndAcmRecWrapper != null && !lstaccAndAcmRecWrapper.isEmpty()){
                                    for(AccAndAcmWrapper acmrecord :lstaccAndAcmRecWrapper){                               
                                        if(acmrecord.Id == acmId){
                                            flag = true;
                                            if(existPersistRec != null && !existPersistRec.isEmpty()){
                                                for(PRM_Persisted_Partners__c existRec: existPersistRec){                                                
                                                    if(acmrecord.acmpartnerRole == existRec.PRM_Partner_Role__c && acmrecord.accountId == existRec.PRM_Account_Id__c && criteriaID == existRec.PRM_Specialty_Criteria_Id__c){                                                
                                                        System.debug('criteriaID????'+criteriaID+'ExistCrit>>>>'+existRec.PRM_Specialty_Criteria_Id__c);
                                                        flag=false;    
                                                        System.debug('flag??'+flag);
                                                        break;
                                                    } 
                                                }
                                            }                                    
                                            if(flag == true){
                                                PRM_Persisted_Partners__c persPartners = new PRM_Persisted_Partners__c();
                                                persPartners.PRM_Specialty_Criteria_Id__c = criteriaID;
                                                persPartners.PRM_Account_Id__c = acmrecord.accountId;
                                                persPartners.PRM_Specialty_Id__c = specialtyId;
                                                persPartners.PRM_Partner_Role__c = acmrecord.acmpartnerRole; 
                                                System.debug('persPartners Rec>>>>>'+persPartners);
                                                persPartnerset.add(persPartners);   
                                            }                                                                    
                                            //break;
                                        }
                                    }                            
                                }                                                                         
                            }
                        }
                    }
                }           
               
                if(persPartnerset!=Null || !persPartnerset.isEmpty()){
                    persPartnerslist.addAll(persPartnerset); 
                }
                
                if(persPartnerslist<>null && !persPartnerslist.isEmpty()){ 
                    insert persPartnerslist;
                    //succlstOfpersPartners =  Database.insert(persPartnerslist,false);
                }  
            }catch(DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
            }        
            
        }     
        
        //Delete unselected specialty criteria from Persist Partner Object
        @AuraEnabled
        public static void deleteUnselectedSpCrit(String specialtyId, String currentaccId, String partnerRole,List<String> spCritId) {
            System.debug('speciality id'+specialtyId+' Current acc id'+ currentaccId+ ' partner role '+ partnerRole+' List sp cri'+spCritId);
            Try{
                List<PRM_Persisted_Partners__c > lstToDeleteSpCritRec = [select Id,PRM_Account_Id__c,PRM_Account_Id__r.Id,PRM_Specialty_Id__c,PRM_Specialty_Criteria_Id__c from PRM_Persisted_Partners__c where PRM_Specialty_Id__c =: specialtyId AND PRM_Account_Id__c =: currentaccId AND PRM_Partner_Role__c = :partnerRole AND PRM_Specialty_Criteria_Id__c IN: spCritId];
                System.debug('Todays '+lstToDeleteSpCritRec);
                if(lstToDeleteSpCritRec != null && !lstToDeleteSpCritRec.isEmpty()){
                    delete lstToDeleteSpCritRec; 
                }
            }catch(DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
            } 
        }
        
        //Method to fetch Approval Pending Records from Persist Partner Object.
        @AuraEnabled(cacheable=true)
        public static List<AccAndAcmWrapper> fetchPendingData(Id currentspecialtyId) { 
            set<Id> lstaccIds = new set<Id>();
            set<String> lstspeId = new set<String>();       
            List<string> lstofpartnerRole = new List<string>();
            string partnerRole = '';
            List<AccAndAcmWrapper> finalLstofAccAndAcmWrapper = new List<AccAndAcmWrapper>();
            
            Try{
                List<PRM_Persisted_Partners__c> persistdata = [Select Id,PRM_Account_Id__c,PRM_Partner_Role__c,PRM_Specialty_Id__c,PRM_Specialty_Criteria_Id__c from PRM_Persisted_Partners__c where PRM_Specialty_Id__c =: currentspecialtyId];
                if(persistdata != null && !persistdata.isEmpty()){
                    for(PRM_Persisted_Partners__c perRec : persistdata){
                        lstaccIds.add(perRec.PRM_Account_Id__c);
                        lstspeId.add(perRec.PRM_Specialty_Id__c);                
                        lstofpartnerRole.add(perRec.PRM_Partner_Role__c);
                    } 
                }
                List<PRM_AccountChannelMembership__c> lstACM = [SELECT Id,PRM_Account_Id__c,PRM_Account_Id__r.Name,PRM_Account_Id__r.AccountNumber,PRM_Partner_Role__c, PRM_Account_Id__r.Core_User_Defined_Phone_Number__c, tolabel(PRM_Account_Id__r.BillingCountryCode), PRM_Account_Id__r.Core_Account_BU_Focus__c,PRM_Channel_Program_Level_Id__r.Name,PRM_Account_Id__r.Core_IPA_Partner_Speciality__c FROM PRM_AccountChannelMembership__c  where PRM_Account_Id__c = :lstaccIds];
                if(lstACM != null && !lstACM.isEmpty()){
                    for(PRM_AccountChannelMembership__c acmRec : lstACM){
                        setOfAccIds.add(acmRec.PRM_Account_Id__c);
                    }                    
                }
                List<PRM_Specialty_Data__c> lstOfSpecialtyData = [SELECT Id,PRM_Account_Id__c,PRM_Account_Id__r.Name,PRM_Tier_Id__r.Name,PRM_Partner_Role_Nm__c, PRM_Specialty_Nbr_Employees_Trained_Nbr__c, PRM_Specialty_Training_Credits_Nbr__c from PRM_Specialty_Data__c
                                                                  where PRM_Account_Id__c IN :setOfAccIds AND PRM_Specialty_Id__c = :currentspecialtyId];
                
                if(lstOfSpecialtyData != null && !lstOfSpecialtyData.isEmpty()){
                    for(PRM_Specialty_Data__c spRec : lstOfSpecialtyData){                        
                        string keyValue = spRec.PRM_Account_Id__c +';'+spRec.PRM_Partner_Role_Nm__c;                                                
                        mapOfAccIdRoleAndspcialtyData.put(keyValue, spRec);                                              
                    }
                }
                
                if(lstACM != null && !lstACM.isEmpty()){
                    for(PRM_AccountChannelMembership__c acmRec : lstACM){                        
                        string keyValue = acmRec.PRM_Account_Id__c +';'+acmRec.PRM_Partner_Role__c;                                                
                        mapOfAccIdRoleAndAcmData.put(keyValue, acmRec);                                              
                    }
                }
                
                if(mapOfAccIdRoleAndAcmData != null && !mapOfAccIdRoleAndAcmData.isEmpty()){                    
                    for(String acmkey : mapOfAccIdRoleAndAcmData.keyset()){
                        string noOfTrainedEmp ='';
                        string noOftrainingCredits = '';
                        if(mapOfAccIdRoleAndspcialtyData != null && !mapOfAccIdRoleAndspcialtyData.isEmpty()){                            
                                                       
                            if(mapOfAccIdRoleAndspcialtyData.containskey(acmkey)){
                                PRM_AccountChannelMembership__c acmRec = new PRM_AccountChannelMembership__c();
                                PRM_Specialty_Data__c sprec = new PRM_Specialty_Data__c();
                                acmRec = mapOfAccIdRoleAndAcmData.get(acmkey);
                                sprec = mapOfAccIdRoleAndspcialtyData.get(acmkey);
                                Double noOfEmp = sprec.PRM_Specialty_Nbr_Employees_Trained_Nbr__c;
                                Double trainingCreditsnum = sprec.PRM_Specialty_Training_Credits_Nbr__c;
                                noOfTrainedEmp = string.valueOf(Integer.valueOf(noOfEmp));
                                noOftrainingCredits = string.valueOf(Integer.valueOf(trainingCreditsnum));                                    
                                lstofAccAndAcmWrapper.add(new AccAndAcmWrapper(acmRec.Id,acmRec.PRM_Account_Id__c,acmRec.PRM_Account_Id__r.AccountNumber,acmRec.PRM_Account_Id__r.Name,acmRec.PRM_Partner_Role__c,acmRec.PRM_Account_Id__r.Core_User_Defined_Phone_Number__c,acmRec.PRM_Account_Id__r.BillingCountryCode,acmRec.PRM_Account_Id__r.Core_Account_BU_Focus__c,acmRec.PRM_Channel_Program_Level_Id__r.Name,noOftrainingCredits,noOfTrainedEmp));
                            }else{                                
                                PRM_AccountChannelMembership__c acmRec = new PRM_AccountChannelMembership__c();
                                PRM_Specialty_Data__c sprec = new PRM_Specialty_Data__c();
                                acmRec = mapOfAccIdRoleAndAcmData.get(acmkey);                                    
                                lstofAccAndAcmWrapper.add(new AccAndAcmWrapper(acmRec.Id,acmRec.PRM_Account_Id__c,acmRec.PRM_Account_Id__r.AccountNumber,acmRec.PRM_Account_Id__r.Name,acmRec.PRM_Partner_Role__c,acmRec.PRM_Account_Id__r.Core_User_Defined_Phone_Number__c,acmRec.PRM_Account_Id__r.BillingCountryCode,acmRec.PRM_Account_Id__r.Core_Account_BU_Focus__c,acmRec.PRM_Channel_Program_Level_Id__r.Name,noOftrainingCredits,noOfTrainedEmp));
                            }                           
                        }else{                            
                            PRM_AccountChannelMembership__c acmRec = new PRM_AccountChannelMembership__c();
                            PRM_Specialty_Data__c sprec = new PRM_Specialty_Data__c();
                            acmRec = mapOfAccIdRoleAndAcmData.get(acmkey);                                    
                            lstofAccAndAcmWrapper.add(new AccAndAcmWrapper(acmRec.Id,acmRec.PRM_Account_Id__c,acmRec.PRM_Account_Id__r.AccountNumber,acmRec.PRM_Account_Id__r.Name,acmRec.PRM_Partner_Role__c,acmRec.PRM_Account_Id__r.Core_User_Defined_Phone_Number__c,acmRec.PRM_Account_Id__r.BillingCountryCode,acmRec.PRM_Account_Id__r.Core_Account_BU_Focus__c,acmRec.PRM_Channel_Program_Level_Id__r.Name,noOftrainingCredits,noOfTrainedEmp));
                        } 
                    }
                }                
                
                if(persistdata != null && !persistdata.isEmpty()){
                    for(PRM_Persisted_Partners__c rec : persistdata){
                        if(lstofAccAndAcmWrapper!= null && !lstofAccAndAcmWrapper.isEmpty()){
                            for(AccAndAcmWrapper acmRec : lstofAccAndAcmWrapper){                         
                                if(rec.PRM_Account_Id__c == acmRec.accountId && rec.PRM_Partner_Role__c == acmRec.acmpartnerRole){                            
                                    if(!finalLstofAccAndAcmWrapper.contains(acmRec)){                                                            
                                        finalLstofAccAndAcmWrapper.add(acmRec);
                                    }                            
                                }
                            }
                        }
                    }
                }
            }catch(DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
            }        
            
            return finalLstofAccAndAcmWrapper;
        }
        
        //Method to fetch specialty criteria related to account from Persist Partner
        @AuraEnabled(cacheable=true)
        public static List<PRM_Persisted_Partners__c> fetchSpCriteriaData(Id currentspecialtyId) {
            List<PRM_Persisted_Partners__c> persistdata = new List<PRM_Persisted_Partners__c>();
            persistdata = [Select Id,PRM_Account_Id__c,PRM_Partner_Role__c,PRM_Specialty_Id__c,PRM_Specialty_Criteria_Id__c,PRM_Specialty_Criteria_Id__r.Name from PRM_Persisted_Partners__c where PRM_Specialty_Id__c =: currentspecialtyId AND PRM_Specialty_Criteria_Id__c != null];
            
            return persistdata;
            
        }  
        
        //US554904 :- Method to create specialty criteria Id list related to ACM ID for Export Selected List
        @AuraEnabled
        public static List<WrapperOfAcmIdAndRelSpCriLst> fetchSpeCritRelToACM(Id currentspecialtyId) { 
            
            List<PRM_Persisted_Partners__c> persistdata = new List<PRM_Persisted_Partners__c>();
            List<WrapperOfAcmIdAndRelSpCriLst> lstOfACMIdAndSpCritlst = new List<WrapperOfAcmIdAndRelSpCriLst>();
            List<PRM_AccountChannelMembership__c> lstofAccAndAcmWrapper = new List<PRM_AccountChannelMembership__c>();
            List<String> lstofSpCrit = new List<string>(); 
            Map<String,List<String>> mapOfAcmIdAndlstOfSpScrit = new Map<String,List<String>>();
            List<String> lstOfAcc = new List<String>();   
            Map<String, List<String>> mapOfCmpStringAndPersistData = new Map<String, List<String>>();
            List<PRM_Persisted_Partners__c> lstofPersData = new List<PRM_Persisted_Partners__c>(); 
            Map<String, string> mapOfCmpStrAndAcmData = new Map<String, String>();
            List<PRM_AccountChannelMembership__c> lstOfAcmRec = new List<PRM_AccountChannelMembership__c>();
            String acmIdKey = '';
            set<String> setOfSpCritName = new set<String>();
            
            persistdata = fetchSpCriteriaData(currentspecialtyId);
            
            if(persistdata != null && !persistdata.isEmpty()){
                for(PRM_Persisted_Partners__c persistRec : persistdata){
                    lstOfAcc.add(persistRec.PRM_Account_Id__c);
                }
            }
            if(lstOfAcc != null && !lstOfAcc.isEmpty()){
                lstofAccAndAcmWrapper = [SELECT Id,PRM_Account_Id__c,PRM_Account_Id__r.Name,PRM_Account_Id__r.AccountNumber,PRM_Partner_Role__c, PRM_Account_Id__r.Core_User_Defined_Phone_Number__c, tolabel(PRM_Account_Id__r.BillingCountryCode), PRM_Account_Id__r.Core_Account_BU_Focus__c,PRM_Channel_Program_Level_Id__r.Name,PRM_Account_Id__r.Core_IPA_Partner_Speciality__c FROM PRM_AccountChannelMembership__c where PRM_Account_Id__c =: lstOfAcc];        
            }
            
            if(persistdata != null && !persistdata.isEmpty()){
                for(PRM_Persisted_Partners__c persistRec : persistdata){
                    string keyValue = persistRec.PRM_Account_Id__c +''+persistRec.PRM_Partner_Role__c;
                    if(mapOfCmpStringAndPersistData.containskey(keyValue)){ 
                        lstofSpCrit = mapOfCmpStringAndPersistData.get(keyValue);                         
                        lstofSpCrit.add(persistRec.PRM_Specialty_Criteria_Id__r.Name);                    
                        mapOfCmpStringAndPersistData.put(keyValue,lstofSpCrit);
                        
                    }
                    else{                        
                        mapOfCmpStringAndPersistData.put(keyValue, new List<String> {persistRec.PRM_Specialty_Criteria_Id__r.Name});
                    }
                }
            } 
            
            if(lstofAccAndAcmWrapper != null && !lstofAccAndAcmWrapper.isEmpty()){
                for(PRM_AccountChannelMembership__c acmWrap : lstofAccAndAcmWrapper){
                    string keyVal = acmWrap.PRM_Account_Id__c+''+acmWrap.PRM_Partner_Role__c;
                    if(mapOfCmpStrAndAcmData.containskey(keyVal)){
                        acmIdKey = mapOfCmpStrAndAcmData.get(keyVal);                        
                        mapOfCmpStrAndAcmData.put(keyVal,acmIdKey);
                        
                    }
                    else{                        
                        mapOfCmpStrAndAcmData.put(keyVal,acmWrap.Id);                    
                    }
                }               
            }     
                        
            if(mapOfCmpStringAndPersistData != null && !mapOfCmpStringAndPersistData.isEmpty()){
                for(String key : mapOfCmpStringAndPersistData.keyset()){
                    if(mapOfCmpStrAndAcmData.containskey(key)){
                        if(mapOfAcmIdAndlstOfSpScrit.containskey(mapOfCmpStrAndAcmData.get(key))){
                            lstofSpCrit = mapOfAcmIdAndlstOfSpScrit.get(key);
                            lstofSpCrit = mapOfCmpStringAndPersistData.get(key);
                            mapOfAcmIdAndlstOfSpScrit.put(key,lstofSpCrit);
                        }
                        else{
                            mapOfAcmIdAndlstOfSpScrit.put(mapOfCmpStrAndAcmData.get(key), mapOfCmpStringAndPersistData.get(key));
                        }
                    }
                }
            }        
                        
            if(mapOfAcmIdAndlstOfSpScrit != null && !mapOfAcmIdAndlstOfSpScrit.isEmpty()){
                for(String acmId : mapOfAcmIdAndlstOfSpScrit.keySet()){
                    WrapperOfAcmIdAndRelSpCriLst acmIdAndSpCrit = new WrapperOfAcmIdAndRelSpCriLst();
                    acmIdAndSpCrit.acmId = acmId;
                    acmIdAndSpCrit.spCrit = mapOfAcmIdAndlstOfSpScrit.get(acmId);
                    lstOfACMIdAndSpCritlst.add(acmIdAndSpCrit);
                }
            }                
            return lstOfACMIdAndSpCritlst;
        }
        
        //US554904 Method to fetch custom setting data
        @AuraEnabled(cacheable=true)
        public static List<PRM_AddPartnerAttribute__c> fetchCustomSettingValues(){
            List<PRM_AddPartnerAttribute__c> lstOfattibuteVal = PRM_AddPartnerAttribute__c.getall().values();        
            return lstOfattibuteVal;
        }
        
        //Method to delete Approval Pending Records from Custom Object which is removed from UI.
        @AuraEnabled
        public static void deleteApprovalPendingRec(List<Object> lstOfRemovalAcmRec, String specialtyId) {
            List<AccAndAcmWrapper> lstaccAndAcmRecWrapper = (List<AccAndAcmWrapper>)JSON.deserialize(JSON.serialize(lstOfRemovalAcmRec), List<AccAndAcmWrapper>.class);
            List<String> lstOfRemovalAccIds = new List<string>();
            list<string> lstofpartnerRole = new List<String>();
            string strPartnerRole = '';
            List<PRM_Persisted_Partners__c> lstToDeleteRecords = new List<PRM_Persisted_Partners__c>();
            Try{
                if(lstaccAndAcmRecWrapper!= null && !lstaccAndAcmRecWrapper.isEmpty()){
                    for(AccAndAcmWrapper acmRemovedRec : lstaccAndAcmRecWrapper){                 
                        lstOfRemovalAccIds.add(acmRemovedRec.accountId);  
                        lstofpartnerRole.add(acmRemovedRec.acmpartnerRole);                
                    }            
                }
                List<PRM_Persisted_Partners__c > lstOfNonApprovedAccIdPersistData = [select Id,PRM_Account_Id__c,PRM_Account_Id__r.Id,PRM_Partner_Role__c,PRM_Specialty_Id__c,PRM_Specialty_Criteria_Id__c from PRM_Persisted_Partners__c where PRM_Specialty_Id__c =: specialtyId];
                
                if(lstOfNonApprovedAccIdPersistData != null && !lstOfNonApprovedAccIdPersistData.isEmpty()){
                    for(PRM_Persisted_Partners__c rec : lstOfNonApprovedAccIdPersistData){
                        if(lstaccAndAcmRecWrapper!= null && !lstaccAndAcmRecWrapper.isEmpty()){
                            for(AccAndAcmWrapper acmRemovedRec : lstaccAndAcmRecWrapper){                         
                                if(rec.PRM_Account_Id__c == acmRemovedRec.accountId && rec.PRM_Partner_Role__c == acmRemovedRec.acmpartnerRole){                            
                                    lstToDeleteRecords.add(rec);
                                }
                            }
                        }
                    }
                }
                
                if(lstToDeleteRecords != null && !lstToDeleteRecords.isEmpty()){
                    delete lstToDeleteRecords;
                }    
            }catch(DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
            } 
        }
        
        // wrapper class to fetch value from ACM object related to Account
        public with sharing class AccAndAcmWrapper {
            @auraEnabled public Id id {get;set;}
            @auraEnabled public Id accountId {get;set;}
            @auraEnabled public string accountNum {get;set;}
            @auraEnabled public string accountName {get;set;}
            @auraEnabled public string acmpartnerRole {get;set;}
            @auraEnabled public string accountPhoneNo {get;set;}
            @auraEnabled public string accCountry {get;set;}
            @auraEnabled public string accountBuFocus {get;set;}
            @auraEnabled public string channelProgLevelName {get;set;}
            @auraEnabled public string spTrainingCredits {get;set;}
            @auraEnabled public string noOfTrainedEmployee {get;set;}
            
            public AccAndAcmWrapper(Id acmId,Id accId,String accountNo,String accName,String partnerRole, String phone,String country, String buFocus, String chProgLevelName, string spTrCredits,string noOfTrainedEmp){
                Id = acmId; 
                accountId = accId;
                accountNum = accountNo;
                accountName = accName;
                acmpartnerRole = partnerRole;
                accountPhoneNo = phone;
                accCountry = country;
                accountBuFocus = buFocus;
                channelProgLevelName = chProgLevelName;
                spTrainingCredits = spTrCredits;
                noOfTrainedEmployee = noOfTrainedEmp;
                
            }
        }    
        //Final List of data with errorMessage
        public with sharing class FinalRecWrapperlist {
            @auraEnabled public List<AccAndAcmWrapper> lstofAccAndAcmWrapper {get;set;}
            @auraEnabled public String errMsg {get;set;} 
            
        }
        //wrapper of ACM Id and related Specialty Criteria 
        public with sharing class WrapperOfAcmIdAndRelSpCriLst {
            @auraEnabled public List<String> spCrit {get;set;}
            @auraEnabled public String acmId {get;set;} 
            
        }       
        
        // wrapper class 
        public with sharing class FatchValueWrapper {
            @auraEnabled public string slabel {get;set;}
            @auraEnabled public string svalue {get;set;}
        }    
    	
    }