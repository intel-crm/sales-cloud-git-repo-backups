/****************************************************************************************************************************
    Apex Class Name     : PRM_AddPartnerController 
    Version             : 1.0
    Created Date        : 28-Nov-2019
    
    Modification Log    :
    * Developer                 Date                    Description
    * --------------------------------------------------------------------------------------------------------------------------
    * Monishaditya Sampathkumar       28-Nov-2019                Search and Filter capability for Partner Account to assign Specialty
    
     
****************************************************************************************************************************/
    public with sharing class PRM_AddPartnerController { 
        public static Integer dmlLimits;
        public static Schema.DescribeSObjectResult objDescribe;
        public static map < String, Schema.SObjectField > fieldMap;
        public static list < Schema.PicklistEntry > values;
        public static list < FatchValueWrapper > objWrapper = new list < FatchValueWrapper > ();    
        public static List<AccAndAcmWrapper> lstofAccAndAcmWrapper = new List<AccAndAcmWrapper>();        
        public Static String errorMsg = '';
        public Static List<FinalRecWrapperlist> lstOfFinalAcmRecWrap = new List<FinalRecWrapperlist>();         
        public Static set<String> setOfAccIds = new set<String>();
        public static Map<String,List<String>> finalMap = new Map<String,List<String>>();
        public Static Map<String,PRM_Specialty_Data__c> mapOfAccIdRoleAndspcialtyData = new Map<String,PRM_Specialty_Data__c>();
        public Static Map<String,PRM_AccountChannelMembership__c> mapOfAccIdRoleAndAcmData = new Map<String,PRM_AccountChannelMembership__c>();
        public static Schema.DescribeFieldResult fieldResult = PRM_AccountChannelMembership__c.PRM_Partner_Role__c.getDescribe();  
        public static List<Schema.PicklistEntry> picklistVal = fieldResult.getPicklistValues();
        public static Schema.DescribeFieldResult persistFieldResult = PRM_Persisted_Partners__c.PRM_Partner_Role__c.getDescribe();  
        public static List<Schema.PicklistEntry> persistPicklistVal = persistFieldResult.getPicklistValues();
        public static List<PRM_AccountChannelMembership__c> lstACM = new List<PRM_AccountChannelMembership__c>();
        public static List<PRM_AccountChannelMembership__c> lstACMtemp=new List<PRM_AccountChannelMembership__c>();
        public static List<AccAndAcmWrapper> finallstOfAccAndAcmWrapper = new List<AccAndAcmWrapper>();
        public static Map<String,String> mapOfPicklistValueAndLabel = new Map<String,String>();//To store Role picklist label associated with role value
        public static Map<String,String> mapOfRolePicklstLabelAndVal = new Map<String,String>();//To store Role picklist value associated with role label
             
        
        //Method to return list of accounts with search criteria and if specialty is not associated with accounts.
        @AuraEnabled
        public static List<FinalRecWrapperlist> fetchAccsData(String accountName, Id currentspecialtyId) {        
            dmlLimits = Limits.getLimitQueryRows();
            String accountId = '';
            String specialtyname = '';
            //--------added as part of US--------------
            if(accountName.startsWith('00') && (accountName.length() ==15 || accountName.length() == 18)){
                accountId = accountName;
            }else{
             accountName = '%' + accountName + '%';   
            }
            List<String> lstOfspecialtyRole = new List<String>();  
            //US587204  START
            list<PRM_AccountChannelMembership__c> lstACMtemp=new List<PRM_AccountChannelMembership__c>();        
            Boolean flag=true;
            Try{
                //To show Partner Role picklist label 
                if(picklistVal != null && !picklistVal.isEmpty()){
                    for(Schema.PicklistEntry roleStr : picklistVal){
                        mapOfPicklistValueAndLabel.put(roleStr.getValue(), roleStr.getLabel());
                    }
                }
                //US587183        
                PRM_Specialty__c specialtyRecord =[Select Id,Name,PRM_Role_Nm__c from PRM_Specialty__c where Id =: currentspecialtyId][0];      //US587183
                specialtyname = specialtyRecord.Name; 
                lstOfspecialtyRole =specialtyRecord.PRM_Role_Nm__c.split(';');
                list<PRM_AccountChannelMembership__c> lstACM = new List<PRM_AccountChannelMembership__c>();
                list<PRM_Account_Specialty_Association__c> lstASA = new List<PRM_Account_Specialty_Association__c>();
                if((accountId !=null && accountId !='')){// changes made here
                    lstACM = [SELECT Id,PRM_Account_Id__r.RecordType.DeveloperName,PRM_Account_Id__c,PRM_Account_Id__r.Name,PRM_Account_Id__r.AccountNumber,PRM_Partner_Role__c, PRM_Account_Id__r.Core_User_Defined_Phone_Number__c, tolabel(PRM_Account_Id__r.BillingCountryCode), PRM_Account_Id__r.Core_Account_BU_Focus__c,PRM_Channel_Program_Level_Id__r.Name FROM PRM_AccountChannelMembership__c where PRM_Account_Id__c =:accountId  AND PRM_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c =: TRUE AND PRM_Account_Id__r.RecordType.DeveloperName =: System.Label.PRM_Intel_Account AND PRM_Partner_Role__c IN:lstOfspecialtyRole AND PRM_Status_Nm__c =:System.Label.PRM_Status LIMIT: dmlLimits];                
                    lstASA = [SELECT Id,PRM_Account_Id__c,PRM_Specialty_Id__c,PRM_Partner_Role__c,PRM_InActive_Ind__c from PRM_Account_Specialty_Association__c where  PRM_Account_Id__c =:accountId  AND PRM_Specialty_Id__c =:specialtyRecord.Id];
                }
                else if((accountName != NULL && accountName != '')) 
                {
                    lstACM = [SELECT Id,PRM_Account_Id__r.RecordType.DeveloperName,PRM_Account_Id__c,PRM_Account_Id__r.Name,PRM_Account_Id__r.AccountNumber,PRM_Partner_Role__c, PRM_Account_Id__r.Core_User_Defined_Phone_Number__c, tolabel(PRM_Account_Id__r.BillingCountryCode), PRM_Account_Id__r.Core_Account_BU_Focus__c,PRM_Channel_Program_Level_Id__r.Name FROM PRM_AccountChannelMembership__c where PRM_Account_Id__r.Name LIKE :accountName AND PRM_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c =: TRUE AND PRM_Account_Id__r.RecordType.DeveloperName =: System.Label.PRM_Intel_Account AND PRM_Partner_Role__c IN:lstOfspecialtyRole AND PRM_Status_Nm__c =:System.Label.PRM_Status LIMIT: dmlLimits];                
                    lstASA = [SELECT Id,PRM_Account_Id__c,PRM_Specialty_Id__c,PRM_Partner_Role__c,PRM_InActive_Ind__c from PRM_Account_Specialty_Association__c where  PRM_Account_Id__r.Name LIKE :accountName AND PRM_Specialty_Id__c =:specialtyRecord.Id];
                }
                    
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
                                    /*Partner role change start*/
                                    if(mapOfPicklistValueAndLabel != null && !mapOfPicklistValueAndLabel.isEmpty()){
                                        if(mapOfPicklistValueAndLabel.keySet().contains(acmRec.PRM_Partner_Role__c)){
                                            lstofAccAndAcmWrapper.add(new AccAndAcmWrapper(acmRec.Id,acmRec.PRM_Account_Id__c,acmRec.PRM_Account_Id__r.AccountNumber,acmRec.PRM_Account_Id__r.Name,mapOfPicklistValueAndLabel.get(acmRec.PRM_Partner_Role__c),acmRec.PRM_Account_Id__r.Core_User_Defined_Phone_Number__c,acmRec.PRM_Account_Id__r.BillingCountryCode,acmRec.PRM_Account_Id__r.Core_Account_BU_Focus__c,acmRec.PRM_Channel_Program_Level_Id__r.Name,noOftrainingCredits,noOfTrainedEmp));                                            
                                        }
                                    }                                    
                                    /*Role change END*/                                    
                                }else{                                
                                    PRM_AccountChannelMembership__c acmRec = new PRM_AccountChannelMembership__c();
                                    //PRM_Specialty_Data__c sprec = new PRM_Specialty_Data__c();
                                    acmRec = mapOfAccIdRoleAndAcmData.get(acmkey);
									if(mapOfPicklistValueAndLabel != null && !mapOfPicklistValueAndLabel.isEmpty()){
                                        if(mapOfPicklistValueAndLabel.keySet().contains(acmRec.PRM_Partner_Role__c)){
                                            lstofAccAndAcmWrapper.add(new AccAndAcmWrapper(acmRec.Id,acmRec.PRM_Account_Id__c,acmRec.PRM_Account_Id__r.AccountNumber,acmRec.PRM_Account_Id__r.Name,mapOfPicklistValueAndLabel.get(acmRec.PRM_Partner_Role__c),acmRec.PRM_Account_Id__r.Core_User_Defined_Phone_Number__c,acmRec.PRM_Account_Id__r.BillingCountryCode,acmRec.PRM_Account_Id__r.Core_Account_BU_Focus__c,acmRec.PRM_Channel_Program_Level_Id__r.Name,noOftrainingCredits,noOfTrainedEmp));                                            
                                        }
                                    }                                   
                                }                           
                            }else{                            
                                PRM_AccountChannelMembership__c acmRec = new PRM_AccountChannelMembership__c();
                                //PRM_Specialty_Data__c sprec = new PRM_Specialty_Data__c();
                                acmRec = mapOfAccIdRoleAndAcmData.get(acmkey); 
                                if(mapOfPicklistValueAndLabel != null && !mapOfPicklistValueAndLabel.isEmpty()){
                                	if(mapOfPicklistValueAndLabel.keySet().contains(acmRec.PRM_Partner_Role__c)){
                                    	lstofAccAndAcmWrapper.add(new AccAndAcmWrapper(acmRec.Id,acmRec.PRM_Account_Id__c,acmRec.PRM_Account_Id__r.AccountNumber,acmRec.PRM_Account_Id__r.Name,mapOfPicklistValueAndLabel.get(acmRec.PRM_Partner_Role__c),acmRec.PRM_Account_Id__r.Core_User_Defined_Phone_Number__c,acmRec.PRM_Account_Id__r.BillingCountryCode,acmRec.PRM_Account_Id__r.Core_Account_BU_Focus__c,acmRec.PRM_Channel_Program_Level_Id__r.Name,noOftrainingCredits,noOfTrainedEmp));                                        
                                 	}
                                 }                            
                            } 
                        }
                    }                              
                //}         // commenting
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
            
            Schema.DescribeFieldResult fieldResult = PRM_Specialty__c.PRM_Role_Nm__c.getDescribe();  
            List<Schema.PicklistEntry> picklistVal = fieldResult.getPicklistValues();
            for (String roleName: lstofpartnerRole) {
                 for (Schema.PicklistEntry f : picklistVal) { 
                     if(roleName == f.getValue()){
                        FatchValueWrapper oFatchValueWrapper = new FatchValueWrapper();
                        oFatchValueWrapper.slabel = f.getLabel();
                        oFatchValueWrapper.svalue = roleName;
                        objWrapper.add(oFatchValueWrapper);     
                     }
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
            Set<String> accountRecordType = new Set<String>{System.Label.PRM_Intel_Account};
            String accountNameFilter;
            String accountId;
             if(accountName.startsWith('00') && (accountName.length() ==15 || accountName.length() == 18)){
                accountId = accountName;
            }else{
             accountNameFilter = '%' + accountName + '%'; 
            }
            dmlLimits = Limits.getLimitQueryRows();  
            List<String> lstOfspecialtyRole = new List<String>();  //US587183
            
            Try{
                //To show Partner Role picklist label 
                if(picklistVal != null && !picklistVal.isEmpty()){
                    for(Schema.PicklistEntry roleStr : picklistVal){
                        mapOfPicklistValueAndLabel.put(roleStr.getValue(), roleStr.getLabel());
                    }
                }
                
                PRM_Specialty__c specialtyRecord =[Select Id,Name,PRM_Role_Nm__c from PRM_Specialty__c where Id =: currentspecialtyId][0];      //US587183
                specialtyname = specialtyRecord.Name; 
                lstOfspecialtyRole =specialtyRecord.PRM_Role_Nm__c.split(';');
                
                String conditionString;
                String query;
                if((accountId !=null && accountId !='')){// changes made here
                    conditionString = 'PRM_Account_Id__c =:accountId AND PRM_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c = TRUE AND PRM_Account_Id__r.RecordType.DeveloperName IN: accountRecordType AND PRM_Partner_Role__c IN:lstOfspecialtyRole';
                    cols = 'Id, Name,PRM_Account_Id__r.RecordType.DeveloperName,PRM_Account_Id__c,PRM_Account_Id__r.Id,PRM_Account_Id__r.AccountNumber ,PRM_Account_Id__r.Name,PRM_Partner_Role__c, PRM_Account_Id__r.Core_User_Defined_Phone_Number__c, tolabel(PRM_Account_Id__r.BillingCountryCode),PRM_Account_Id__r.Core_Account_BU_Focus__c,PRM_Channel_Program_Level_Id__c,PRM_Channel_Program_Level_Id__r.Name';
                    query = 'SELECT '+cols+ ' from PRM_AccountChannelMembership__c WHERE ';        
                }
                else if((accountName != NULL && accountName != '')) 
                {
                    conditionString = 'PRM_Account_Id__r.Name LIKE: accountNameFilter AND PRM_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c = TRUE AND PRM_Account_Id__r.RecordType.DeveloperName IN: accountRecordType AND PRM_Partner_Role__c IN:lstOfspecialtyRole';
                    cols = 'Id, Name,PRM_Account_Id__r.RecordType.DeveloperName,PRM_Account_Id__c,PRM_Account_Id__r.Id,PRM_Account_Id__r.AccountNumber ,PRM_Account_Id__r.Name,PRM_Partner_Role__c, PRM_Account_Id__r.Core_User_Defined_Phone_Number__c, tolabel(PRM_Account_Id__r.BillingCountryCode),PRM_Account_Id__r.Core_Account_BU_Focus__c,PRM_Channel_Program_Level_Id__c,PRM_Channel_Program_Level_Id__r.Name';
                    query = 'SELECT '+cols+ ' from PRM_AccountChannelMembership__c WHERE ';        
                } 
                
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
                list<PRM_Account_Specialty_Association__c> lstASA = new List<PRM_Account_Specialty_Association__c>();
                if((accountId !=null && accountId !='')){
                    lstASA = [SELECT Id,PRM_Account_Id__c,PRM_Specialty_Id__c,PRM_Partner_Role__c,PRM_InActive_Ind__c from PRM_Account_Specialty_Association__c where PRM_Account_Id__c =:accountId AND PRM_Specialty_Id__c =:specialtyRecord.Id];
                }else if((accountName != NULL && accountName != '')){
                    lstASA = [SELECT Id,PRM_Account_Id__c,PRM_Specialty_Id__c,PRM_Partner_Role__c,PRM_InActive_Ind__c from PRM_Account_Specialty_Association__c where PRM_Account_Id__r.Name LIKE :accountNameFilter AND PRM_Specialty_Id__c =:specialtyRecord.Id];
                }

                
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
                                if(mapOfPicklistValueAndLabel != null && !mapOfPicklistValueAndLabel.isEmpty()){
                                    if(mapOfPicklistValueAndLabel.keySet().contains(acmRec.PRM_Partner_Role__c)){
                                        lstofAccAndAcmWrapper.add(new AccAndAcmWrapper(acmRec.Id,acmRec.PRM_Account_Id__c,acmRec.PRM_Account_Id__r.AccountNumber,acmRec.PRM_Account_Id__r.Name,mapOfPicklistValueAndLabel.get(acmRec.PRM_Partner_Role__c),acmRec.PRM_Account_Id__r.Core_User_Defined_Phone_Number__c,acmRec.PRM_Account_Id__r.BillingCountryCode,acmRec.PRM_Account_Id__r.Core_Account_BU_Focus__c,acmRec.PRM_Channel_Program_Level_Id__r.Name,noOftrainingCredits,noOfTrainedEmp));                                        
                                    }
                                }                              
                            }else{                            
                                PRM_AccountChannelMembership__c acmRec = new PRM_AccountChannelMembership__c();
                                //PRM_Specialty_Data__c sprec = new PRM_Specialty_Data__c();
                                acmRec = mapOfAccIdRoleAndAcmData.get(acmkey);  
                                if(mapOfPicklistValueAndLabel != null && !mapOfPicklistValueAndLabel.isEmpty()){
                                    if(mapOfPicklistValueAndLabel.keySet().contains(acmRec.PRM_Partner_Role__c)){
                                        lstofAccAndAcmWrapper.add(new AccAndAcmWrapper(acmRec.Id,acmRec.PRM_Account_Id__c,acmRec.PRM_Account_Id__r.AccountNumber,acmRec.PRM_Account_Id__r.Name,mapOfPicklistValueAndLabel.get(acmRec.PRM_Partner_Role__c),acmRec.PRM_Account_Id__r.Core_User_Defined_Phone_Number__c,acmRec.PRM_Account_Id__r.BillingCountryCode,acmRec.PRM_Account_Id__r.Core_Account_BU_Focus__c,acmRec.PRM_Channel_Program_Level_Id__r.Name,noOftrainingCredits,noOfTrainedEmp));                                        
                                    }
                                }                            
                            }                           
                        }else{                        
                            PRM_AccountChannelMembership__c acmRec = new PRM_AccountChannelMembership__c();
                            //PRM_Specialty_Data__c sprec = new PRM_Specialty_Data__c();
                            acmRec = mapOfAccIdRoleAndAcmData.get(acmkey); 
                            if(mapOfPicklistValueAndLabel != null && !mapOfPicklistValueAndLabel.isEmpty()){
                                if(mapOfPicklistValueAndLabel.keySet().contains(acmRec.PRM_Partner_Role__c)){
                                    lstofAccAndAcmWrapper.add(new AccAndAcmWrapper(acmRec.Id,acmRec.PRM_Account_Id__c,acmRec.PRM_Account_Id__r.AccountNumber,acmRec.PRM_Account_Id__r.Name,mapOfPicklistValueAndLabel.get(acmRec.PRM_Partner_Role__c),acmRec.PRM_Account_Id__r.Core_User_Defined_Phone_Number__c,acmRec.PRM_Account_Id__r.BillingCountryCode,acmRec.PRM_Account_Id__r.Core_Account_BU_Focus__c,acmRec.PRM_Channel_Program_Level_Id__r.Name,noOftrainingCredits,noOfTrainedEmp));                                        
                                }
                            }                         
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
        public static String insertRelatedRecords(List<Object> lstaccIdAndAcm, String specialtyId, String accCommentsMap,List<String> lstOfTotalSpCritRelSp, String accSuppressEmailMap) { 
            List<List<String>> accstring = (List<List<String>>) System.JSON.deserialize(accCommentsMap, List<List<String>>.class);
            //System.debug('accstring'+accstring);
            //String accSuppressEmailMap;
            List<List<String>> accsSupEmailString = (List<List<String>>) System.JSON.deserialize(accSuppressEmailMap, List<List<String>>.class);
            //System.debug('accsSupEmailString'+accsSupEmailString);
            List<AccAndAcmWrapper> lstaccAndAcmWrapper = (List<AccAndAcmWrapper>)JSON.deserialize(JSON.serialize(lstaccIdAndAcm), List<AccAndAcmWrapper>.class);              
            Map<String,String> commentMap = new  Map<String,String>();
            Map<String,String> suppressEmailMap = new  Map<String,String>();
            String result = 'Warning';
            Database.UpsertResult[] succlstOfASA;
            Integer successCount = 0;
            Integer failureCount = 0;            
            set<String> lstAccId = new set<String>();
            set<PRM_Account_Specialty_Association__c> asaset = new set<PRM_Account_Specialty_Association__c>();
            List<PRM_Account_Specialty_Association__c> asalist = new List<PRM_Account_Specialty_Association__c>();
            set<PRM_Account_Specialty_Association__c> existingASA = new set<PRM_Account_Specialty_Association__c>();
            Map<String,List<String>> finalMap = new Map<String,List<String>>();
            List<String> lstcritids = new List<String>();                                
            List<PRM_Account_Specialty_Qual_Criteria__c> finalPossAsqcLst = new List<PRM_Account_Specialty_Qual_Criteria__c>();
            List<PRM_Account_Specialty_Qual_Criteria__c> finalAsqcToUpsert = new List<PRM_Account_Specialty_Qual_Criteria__c>();
            List<PRM_Account_Specialty_Qual_Criteria__c> lstOfAsqcToBeInserted = new List<PRM_Account_Specialty_Qual_Criteria__c>();
            List<PRM_Account_Specialty_Qual_Criteria__c> lstOfAllPossibleAsqcRec = new List<PRM_Account_Specialty_Qual_Criteria__c>();
            map<String,boolean> mapOfAsaCritAndInactiveInd = new map<String,boolean>();
            map<String, String> mapOfAsaCritIdAndAsqcId = new map<String, String>();
            
            Try{
                //To show Partner Role picklist label 
                if(picklistVal != null && !picklistVal.isEmpty()){
                    for(Schema.PicklistEntry roleStr : picklistVal){
                        mapOfRolePicklstLabelAndVal.put(roleStr.getLabel(), roleStr.getValue());
                    }
                }
                if(lstaccAndAcmWrapper!= null && !lstaccAndAcmWrapper.isEmpty()){
                    for(AccAndAcmWrapper rec : lstaccAndAcmWrapper){                
                        lstAccId.add(rec.accountId);                
                    }      
                }
                
                for(List<String> str:accstring){
                    commentMap.put(str[0],str[1]);
                }
                for(List<String> str:accsSupEmailString){
                    suppressEmailMap.put(str[0],str[1]);
                }
                //PRM_Specialty__c Specialty =[select id,PRM_Start_Date_Dt__c,PRM_End_Date_Dt__c from PRM_Specialty__c where id=:specialtyId];
                Set<Id> succASARecIds = new Set<Id>();
                for(PRM_Account_Specialty_Association__c dupcheckasa: [select id,PRM_Account_Id__c,PRM_Partner_Role__c,PRM_Specialty_Id__c,PRM_Notes_Txt__c,PRM_Suppress_Email__c,PRM_InActive_Ind__c from PRM_Account_Specialty_Association__c where PRM_Account_Id__c IN:lstAccId AND PRM_Specialty_Id__c=:specialtyId and PRM_InActive_Ind__c=TRUE ]){
                    //dupcheckasa.PRM_InActive_Ind__c=False;
                    if(lstaccAndAcmWrapper != null && !lstaccAndAcmWrapper.isEmpty()){
                        for(AccAndAcmWrapper wraplstRec : lstaccAndAcmWrapper){
                            if(mapOfRolePicklstLabelAndVal != null && !mapOfRolePicklstLabelAndVal.isEmpty()){
                                if(mapOfRolePicklstLabelAndVal.keySet().contains(wraplstRec.acmpartnerRole)){
                                    if(wraplstRec.accountId == dupcheckasa.PRM_Account_Id__c && mapOfRolePicklstLabelAndVal.get(wraplstRec.acmpartnerRole) == dupcheckasa.PRM_Partner_Role__c){
                                        dupcheckasa.PRM_InActive_Ind__c=False;//Bug fix
                                        //dupcheckasa.PRM_Suppress_Email__c=false;
                                        if(commentMap!=null && commentMap.ContainsKey(wraplstRec.Id)){                    
                                            dupcheckasa.PRM_Notes_Txt__c=commentMap.get(wraplstRec.Id); 
                                            
                                        }else {
                                            dupcheckasa.PRM_Notes_Txt__c = '';
                                            
                                        }
                                        if(suppressEmailMap!=null && suppressEmailMap.ContainsKey(wraplstRec.Id)){
                                            if(suppressEmailMap.get(wraplstRec.Id)=='true'){
                                                dupcheckasa.PRM_Suppress_Email__c=true;
                                            } 
                                        }else {
                                            dupcheckasa.PRM_Suppress_Email__c =false;
                                        }
                                    } 
                                }
                            }                        
                        }                    
                    }
                    existingASA.add(dupcheckasa);                    
                }                                
                if(lstaccAndAcmWrapper!=Null || !lstaccAndAcmWrapper.isEmpty()){
                    for(AccAndAcmWrapper acc : lstaccAndAcmWrapper){
                        PRM_Account_Specialty_Association__c asa = new PRM_Account_Specialty_Association__c();
                        asa.PRM_Account_Id__c = acc.accountId;
                        asa.PRM_Specialty_Id__c = specialtyId; 
                        if(mapOfRolePicklstLabelAndVal != null && !mapOfRolePicklstLabelAndVal.isEmpty()){
                            if(mapOfRolePicklstLabelAndVal.keySet().contains(acc.acmpartnerRole)){
                                asa.PRM_Partner_Role__c = mapOfRolePicklstLabelAndVal.get(acc.acmpartnerRole);
                            }
                        }                        
                        if(commentMap!=null && commentMap.ContainsKey(acc.Id)){
                            asa.PRM_Notes_Txt__c=commentMap.get(acc.Id);
                        }else {
                            asa.PRM_Notes_Txt__c = '';
                        }if(suppressEmailMap!=null && suppressEmailMap.ContainsKey(acc.Id)){
                            if(suppressEmailMap.get(acc.Id)=='true'){
                                asa.PRM_Suppress_Email__c=true;
                            } 
                        }else {
                            asa.PRM_Suppress_Email__c =false;
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
                
               /* List<PRM_Account_Specialty_Association__c> succASA = [SELECT ID,Name,PRM_Account_Id__c,PRM_Partner_Role__c,PRM_Account_Id__r.name,PRM_Specialty_Id__r.name,PRM_Specialty_Id__c FROM PRM_Account_Specialty_Association__c WHERE ID IN :succASARecIds];
                if(!succASA.isEmpty()){               
                    PRM_EmailUtility.sendEmailToPublicGroup(succASA);                
                }            */
                List<PRM_Persisted_Partners__c> persistdata = [Select Id,PRM_Account_Id__c,PRM_Partner_Role__c,PRM_Specialty_Id__c,PRM_Specialty_Criteria_Id__c from PRM_Persisted_Partners__c where PRM_Specialty_Id__c =: specialtyId AND PRM_Specialty_Criteria_Id__c != null];
                if(persistdata!=Null || !persistdata.isEmpty()){
                    for(PRM_Persisted_Partners__c perRec : persistdata){ 
                        if(lstaccAndAcmWrapper != null && !lstaccAndAcmWrapper.isEmpty()){
                            for(AccAndAcmWrapper wraplstRec : lstaccAndAcmWrapper){
                                if(mapOfRolePicklstLabelAndVal != null && !mapOfRolePicklstLabelAndVal.isEmpty()){
                                    if(mapOfRolePicklstLabelAndVal.keySet().contains(wraplstRec.acmpartnerRole)){
                                        if(wraplstRec.accountId == perRec.PRM_Account_Id__c && mapOfRolePicklstLabelAndVal.get(wraplstRec.acmpartnerRole) == perRec.PRM_Partner_Role__c){
                                    		//check the below code
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
                                    if(mapOfRolePicklstLabelAndVal != null && !mapOfRolePicklstLabelAndVal.isEmpty()){
                                        if(mapOfRolePicklstLabelAndVal.keySet().contains(wrapRec.acmpartnerRole)){
                                            if(acmId == wrapRec.Id && wrapRec.accountId == asa.PRM_Account_Id__c && mapOfRolePicklstLabelAndVal.get(wrapRec.acmpartnerRole) == asa.PRM_Partner_Role__c){
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
                set<PRM_Persisted_Partners__c> persPartnerset = new set<PRM_Persisted_Partners__c>();
                List<PRM_Persisted_Partners__c> persPartnerslist = new List<PRM_Persisted_Partners__c>();        
                Database.SaveResult[] succlstOfpersPartners;
                Boolean flag=true;                
                
                Try{          
                    //To show Partner Role picklist label 
                    if(persistPicklistVal != null && !persistPicklistVal.isEmpty()){
                        for(Schema.PicklistEntry roleStr : persistPicklistVal){
                            mapOfRolePicklstLabelAndVal.put(roleStr.getLabel(), roleStr.getValue());
                        }
                    }
                    List<PRM_Persisted_Partners__c> existPersistRec =[Select PRM_Account_Id__c,toLabel(PRM_Partner_Role__c),PRM_Specialty_Id__c from PRM_Persisted_Partners__c where PRM_Specialty_Id__c = :specialtyId];
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
                            
                            if(mapOfRolePicklstLabelAndVal != null && !mapOfRolePicklstLabelAndVal.isEmpty()){
                                if(mapOfRolePicklstLabelAndVal.keySet().contains(acc.acmpartnerRole)){
                                    persPartners.PRM_Partner_Role__c = mapOfRolePicklstLabelAndVal.get(acc.acmpartnerRole);
                                }
                            }                                                         
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
                List<Object> accountspecialtyCriteria;        
                //Database.SaveResult[] succlstOfpersPartners;   
                List<PRM_Persisted_Partners__c> existPersistRec = new List<PRM_Persisted_Partners__c>();
                Boolean flag = true;
                
                Try{
                    //To show Partner Role picklist label 
                    if(persistPicklistVal != null && !persistPicklistVal.isEmpty()){
                        for(Schema.PicklistEntry roleStr : persistPicklistVal){
                            mapOfRolePicklstLabelAndVal.put(roleStr.getLabel(), roleStr.getValue());
                        }
                    }
                    existPersistRec = [Select PRM_Account_Id__c,toLabel(PRM_Partner_Role__c),PRM_Specialty_Id__c,PRM_Specialty_Criteria_Id__c from PRM_Persisted_Partners__c where PRM_Specialty_Id__c = :specialtyId AND PRM_Specialty_Criteria_Id__c != null];            
                                    
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
                            //existcriteriaList.add(String.valueOf(o));
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
                                                            flag=false;
                                                            break;
                                                        } 
                                                    }
                                                }                                    
                                                if(flag == true){
                                                    PRM_Persisted_Partners__c persPartners = new PRM_Persisted_Partners__c();
                                                    persPartners.PRM_Specialty_Criteria_Id__c = criteriaID;
                                                    persPartners.PRM_Account_Id__c = acmrecord.accountId;
                                                    persPartners.PRM_Specialty_Id__c = specialtyId;
                                                    if(mapOfRolePicklstLabelAndVal != null && !mapOfRolePicklstLabelAndVal.isEmpty()){
                                                        if(mapOfRolePicklstLabelAndVal.keySet().contains(acmrecord.acmpartnerRole)){
                                                            persPartners.PRM_Partner_Role__c = mapOfRolePicklstLabelAndVal.get(acmrecord.acmpartnerRole);
                                                        }
                                                    }                                                                                                        
                                                    persPartnerset.add(persPartners);   
                                                }
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
            
            //Delete Unselected specialty criteria from Persist Partner Object
            @AuraEnabled
            public static void deleteUnselectedSpCrit(String specialtyId, String currentaccId, String partnerRole,List<String> spCritId) {                
                Try{
                    List<PRM_Persisted_Partners__c > lstToDeleteSpCritRec = [select Id,PRM_Account_Id__c,PRM_Account_Id__r.Id,toLabel(PRM_Partner_Role__c),PRM_Specialty_Id__c,PRM_Specialty_Criteria_Id__c from PRM_Persisted_Partners__c where PRM_Specialty_Id__c =: specialtyId AND PRM_Account_Id__c =: currentaccId AND toLabel(PRM_Partner_Role__c) = :partnerRole AND PRM_Specialty_Criteria_Id__c IN: spCritId];
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
                Try{
                    //To show Partner Role picklist label from AcM object
                    if(picklistVal != null && !picklistVal.isEmpty()){
                        for(Schema.PicklistEntry roleStr : picklistVal){
                            mapOfPicklistValueAndLabel.put(roleStr.getValue(), roleStr.getLabel());
                        }
                    }
                    //To show Partner Role picklist label from persist partner Object
                    if(persistPicklistVal != null && !persistPicklistVal.isEmpty()){
                        for(Schema.PicklistEntry roleStr : persistPicklistVal){
                            mapOfRolePicklstLabelAndVal.put(roleStr.getValue(), roleStr.getLabel());
                        }
                    }
                    
                    List<PRM_Persisted_Partners__c> persistdata = [Select Id,PRM_Account_Id__c,PRM_Partner_Role__c,PRM_Specialty_Id__c,PRM_Specialty_Criteria_Id__c from PRM_Persisted_Partners__c where PRM_Specialty_Id__c =: currentspecialtyId];
                    if(persistdata != null && !persistdata.isEmpty()){
                        for(PRM_Persisted_Partners__c perRec : persistdata){
                            lstaccIds.add(perRec.PRM_Account_Id__c);                            
                        } 
                    }
                    List<PRM_AccountChannelMembership__c> lstACM = [SELECT Id,PRM_Account_Id__c,PRM_Account_Id__r.Name,PRM_Account_Id__r.AccountNumber,PRM_Partner_Role__c, PRM_Account_Id__r.Core_User_Defined_Phone_Number__c, tolabel(PRM_Account_Id__r.BillingCountryCode), PRM_Account_Id__r.Core_Account_BU_Focus__c,PRM_Channel_Program_Level_Id__r.Name FROM PRM_AccountChannelMembership__c  where PRM_Account_Id__c = :lstaccIds];
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
                                    if(mapOfPicklistValueAndLabel != null && !mapOfPicklistValueAndLabel.isEmpty()){
                                        if(mapOfPicklistValueAndLabel.keySet().contains(acmRec.PRM_Partner_Role__c)){
                                            lstofAccAndAcmWrapper.add(new AccAndAcmWrapper(acmRec.Id,acmRec.PRM_Account_Id__c,acmRec.PRM_Account_Id__r.AccountNumber,acmRec.PRM_Account_Id__r.Name,mapOfPicklistValueAndLabel.get(acmRec.PRM_Partner_Role__c),acmRec.PRM_Account_Id__r.Core_User_Defined_Phone_Number__c,acmRec.PRM_Account_Id__r.BillingCountryCode,acmRec.PRM_Account_Id__r.Core_Account_BU_Focus__c,acmRec.PRM_Channel_Program_Level_Id__r.Name,noOftrainingCredits,noOfTrainedEmp));                                        
                                        }
                                    }                                                                        
                                }else{                                
                                    PRM_AccountChannelMembership__c acmRec = new PRM_AccountChannelMembership__c();
                                    //PRM_Specialty_Data__c sprec = new PRM_Specialty_Data__c();
                                    acmRec = mapOfAccIdRoleAndAcmData.get(acmkey); 
                                    if(mapOfPicklistValueAndLabel != null && !mapOfPicklistValueAndLabel.isEmpty()){
                                        if(mapOfPicklistValueAndLabel.keySet().contains(acmRec.PRM_Partner_Role__c)){
                                            lstofAccAndAcmWrapper.add(new AccAndAcmWrapper(acmRec.Id,acmRec.PRM_Account_Id__c,acmRec.PRM_Account_Id__r.AccountNumber,acmRec.PRM_Account_Id__r.Name,mapOfPicklistValueAndLabel.get(acmRec.PRM_Partner_Role__c),acmRec.PRM_Account_Id__r.Core_User_Defined_Phone_Number__c,acmRec.PRM_Account_Id__r.BillingCountryCode,acmRec.PRM_Account_Id__r.Core_Account_BU_Focus__c,acmRec.PRM_Channel_Program_Level_Id__r.Name,noOftrainingCredits,noOfTrainedEmp));                                        
                                        }
                                    }                                                                       
                                }                           
                            }else{                            
                                PRM_AccountChannelMembership__c acmRec = new PRM_AccountChannelMembership__c();
                                //PRM_Specialty_Data__c sprec = new PRM_Specialty_Data__c();
                                acmRec = mapOfAccIdRoleAndAcmData.get(acmkey); 
                                if(mapOfPicklistValueAndLabel != null && !mapOfPicklistValueAndLabel.isEmpty()){
                                    if(mapOfPicklistValueAndLabel.keySet().contains(acmRec.PRM_Partner_Role__c)){
                                        lstofAccAndAcmWrapper.add(new AccAndAcmWrapper(acmRec.Id,acmRec.PRM_Account_Id__c,acmRec.PRM_Account_Id__r.AccountNumber,acmRec.PRM_Account_Id__r.Name,mapOfPicklistValueAndLabel.get(acmRec.PRM_Partner_Role__c),acmRec.PRM_Account_Id__r.Core_User_Defined_Phone_Number__c,acmRec.PRM_Account_Id__r.BillingCountryCode,acmRec.PRM_Account_Id__r.Core_Account_BU_Focus__c,acmRec.PRM_Channel_Program_Level_Id__r.Name,noOftrainingCredits,noOfTrainedEmp));                                        
                                    }
                                }                                                          
                            } 
                        }
                    }                
                    
                    if(persistdata != null && !persistdata.isEmpty()){
                        for(PRM_Persisted_Partners__c rec : persistdata){
                            if(lstofAccAndAcmWrapper!= null && !lstofAccAndAcmWrapper.isEmpty()){
                                for(AccAndAcmWrapper acmRec : lstofAccAndAcmWrapper){ 
                                    if(mapOfRolePicklstLabelAndVal != null && !mapOfRolePicklstLabelAndVal.isEmpty()){
                                        if(mapOfRolePicklstLabelAndVal.keySet().contains(rec.PRM_Partner_Role__c)){                                            
                                            if(rec.PRM_Account_Id__c == acmRec.accountId && mapOfRolePicklstLabelAndVal.get(rec.PRM_Partner_Role__c) == acmRec.acmpartnerRole){                            
                                                if(!finallstOfAccAndAcmWrapper.contains(acmRec)){                                                            
                                                    finallstOfAccAndAcmWrapper.add(acmRec);
                                                }                            
                                            } 
                                        }
                                    }                                                                   
                                }
                            }
                        }
                    }
                }catch(DmlException e) {
                    System.debug('The following exception has occurred: ' + e.getMessage());
                }        
                
                return finallstOfAccAndAcmWrapper;
            }
            
            //Method to fetch specialty criteria related to account from Persist Partner
            @AuraEnabled(cacheable=true)
            public static List<PRM_Persisted_Partners__c> fetchSpCriteriaData(Id currentspecialtyId) {
                List<PRM_Persisted_Partners__c> persistdata = new List<PRM_Persisted_Partners__c>();
                persistdata = [Select Id,PRM_Account_Id__c,toLabel(PRM_Partner_Role__c),PRM_Specialty_Id__c,PRM_Specialty_Criteria_Id__c,PRM_Specialty_Criteria_Id__r.Name from PRM_Persisted_Partners__c where PRM_Specialty_Id__c =: currentspecialtyId AND PRM_Specialty_Criteria_Id__c != null];
                
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
                Map<String, string> mapOfCmpStrAndAcmData = new Map<String, String>();
                String acmIdKey = '';              
                
                //To show Partner Role picklist label 
                if(persistPicklistVal != null && !persistPicklistVal.isEmpty()){
                    for(Schema.PicklistEntry roleStr : persistPicklistVal){
                        mapOfRolePicklstLabelAndVal.put(roleStr.getLabel(), roleStr.getValue());
                    }
                }
                
                persistdata = fetchSpCriteriaData(currentspecialtyId);
                
                if(persistdata != null && !persistdata.isEmpty()){
                    for(PRM_Persisted_Partners__c persistRec : persistdata){
                        lstOfAcc.add(persistRec.PRM_Account_Id__c);
                    }
                }
                if(lstOfAcc != null && !lstOfAcc.isEmpty()){
                    lstofAccAndAcmWrapper = [SELECT Id,PRM_Account_Id__c,PRM_Account_Id__r.Name,PRM_Account_Id__r.AccountNumber,PRM_Partner_Role__c, PRM_Account_Id__r.Core_User_Defined_Phone_Number__c, tolabel(PRM_Account_Id__r.BillingCountryCode), PRM_Account_Id__r.Core_Account_BU_Focus__c,PRM_Channel_Program_Level_Id__r.Name FROM PRM_AccountChannelMembership__c where PRM_Account_Id__c =: lstOfAcc];        
                }
                
                if(persistdata != null && !persistdata.isEmpty()){
                    for(PRM_Persisted_Partners__c persistRec : persistdata){
                        string keyValue ='';
                        if(mapOfRolePicklstLabelAndVal != null && !mapOfRolePicklstLabelAndVal.isEmpty()){
                            if(mapOfRolePicklstLabelAndVal.keySet().contains(persistRec.PRM_Partner_Role__c)){
                                keyValue = persistRec.PRM_Account_Id__c +''+mapOfRolePicklstLabelAndVal.get(persistRec.PRM_Partner_Role__c);
                            }
                        }                         
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
                //list<string> lstofpartnerRole = new List<String>();
                //string strPartnerRole = '';
                //List<String> lstOfRemovalAccIds = new List<string>();
                List<PRM_Persisted_Partners__c> lstToDeleteRecords = new List<PRM_Persisted_Partners__c>();
                Try{                   
                    List<PRM_Persisted_Partners__c > lstOfNonApprovedAccIdPersistData = [select Id,PRM_Account_Id__c,PRM_Account_Id__r.Id,toLabel(PRM_Partner_Role__c),PRM_Specialty_Id__c,PRM_Specialty_Criteria_Id__c from PRM_Persisted_Partners__c where PRM_Specialty_Id__c =: specialtyId];
                    
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