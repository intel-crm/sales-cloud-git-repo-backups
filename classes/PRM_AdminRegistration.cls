public without sharing class PRM_AdminRegistration {
    
    @AuraEnabled(cacheable=true)
    public static List<stateCountryInfo> fetchStateCountryValues()
    {
        Map<String,List<String>> countryStateMap = new Map<String,List<String>>();
        //JB Map<String, Schema.SObjectField> objFieldMap = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap();
        Map<String, Schema.SObjectField> objFieldMap = Account.SObjectType.getDescribe().fields.getMap();        
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
            //system.debug('!!'+info.validFor);
            //system.debug('##'+EncodingUtil.base64Decode(info.validFor));
            //system.debug('@@'+hexString);
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
        
        List<stateCountryInfo> stateCountryInfoList = new List<stateCountryInfo>();
        for(String s : countryStateMap.keySet())
        {
            stateCountryInfo info = new stateCountryInfo();
            info.country= s+';'+countryLabelValueMap.get(s);
            info.stateList= countryStateMap.get(s);
            stateCountryInfoList.add(info);
        }
      //  System.debug(LoggingLevel.ERROR,' before return ' + Limits.getCpuTime() + '/' + Limits.getLimitCpuTime());
        return stateCountryInfoList;
    }
    
    @AuraEnabled(cacheable=true)
    public static picklistValues getPicklistValues()
    {
        picklistValues pi = new picklistValues();
        pi.stateCountryInfoList =  fetchStateCountryValues();
        Map<String,String> bizOrgTypeMap= new Map<String,String>();      
        Schema.DescribeFieldResult fieldResult1 = PRM_Registration_Request__c.PRM_Partner_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple1 = fieldResult1.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple1){
            bizOrgTypeMap.put(pickListVal.getValue(),pickListVal.getLabel());              
        }                        
        pi.bizOrgTypeMap = bizOrgTypeMap ;
/*        
Map<String,String> partnerRoleMap= new Map<String,String>();      
Schema.DescribeFieldResult fieldResult2 = Account.Core_IPA_Partner_Role__c.getDescribe();
List<Schema.PicklistEntry> ple2 = fieldResult2.getPicklistValues();
for( Schema.PicklistEntry pickListVal : ple2){
partnerRoleMap.put(pickListVal.getValue(),pickListVal.getLabel());
}
pi.partnerRoleMap = partnerRoleMap ;
        */
        //returning map of biz org type and partner role
        
        Map<String,String> roleTypeMap = new Map<String,String>();
        for(PRM_PartnerRoleTypeMappings__mdt roleTypeReq : [Select Id,PRM_Biz_Org_Type__c,PRM_Partner_Role__c,PRM_Partner_Role_Label__c
                                                            from PRM_PartnerRoleTypeMappings__mdt]){
                                                                roleTypeMap.put(roleTypeReq.PRM_Biz_Org_Type__c, roleTypeReq.PRM_Partner_Role_Label__c);
                                                            }
        pi.roleTypeMapping = roleTypeMap;
        
        Map<String,String> prefLanguageMap= new Map<String,String>();   
        String excludePrelang = System.Label.PRM_Exclude_Preferred_Languag ;
        List<String> lstName = excludePrelang.split(',');
        Schema.DescribeFieldResult fieldResult3 = Contact.Core_Preferred_Language__c.getDescribe();
        List<Schema.PicklistEntry> ple3 = fieldResult3.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple3){
            
            if(!lstName.contains(pickListVal.getValue())){
            prefLanguageMap.put(pickListVal.getValue(),pickListVal.getLabel());
                }
        }     
        pi.prefLanguageMap = prefLanguageMap;
        return pi;
    }
    
    @AuraEnabled
    public static Map<String,Contact> fetchAccountDetails(String emailId){

        Map<String,Contact> accConMap;
        for(Contact c : [Select Id,AccountId,Account.Name,Account.BillingStreet,Account.BillingCountryCode,Account.BillingStateCode,
                         Account.BillingCity,Account.BillingPostalCode,Account.Core_Account_Type__c,Account.Core_User_Defined_Website__c,
                         toLabel(Core_IPA_PartnerRole__c) from Contact where Email =: emailId]){
                             System.debug('c'+c);
                             accConMap = new Map<String,Contact>();
                             accConMap.put(c.Id,c);
                         }
        return accConMap;
    }
    
     @AuraEnabled
    public static boolean systemAccountDetails(String emailId){
        
        //Map<String,Contact> accConMap;
        Set<id> accountIdSet = new Set<id>();
        Set<id>SysAccIdSet=new Set<id>();
        boolean flag = false;
        
        for(Contact c : [Select Id,AccountId,Account.Name from Contact where Email =: emailId]){
                             accountIdSet.add(c.AccountId);
                         }
        System.debug('accountIdSet-->'+accountIdSet);
        
        Map<String,Core_Intel_System_Accounts__mdt> mapSysAcc = Core_Intel_System_Accounts__mdt.getAll();
        for(String keySetString : mapSysAcc.keySet()){
            SysAccIdSet.add(mapSysAcc.get(keySetString).AccountId__c);
           
        }
        
        for(id accid :accountIdSet)
        {
            if(accid!=null && SysAccIdSet != null && SysAccIdSet.contains(accid))
            {
               flag = true;
            }
        }
         system.debug('flag--->'+flag);
        return flag;
       

    }
   
/****************************************************************************************************************
    * Method Name:accountTypeToPartnerRoleMapping
    * Date: 05/11/2022    
  * Owner: Sushmita Sen Sharma (Agate)
    * Description: Map account type(BizOrg Type) to the partner role on Contact/ACM
  * Story: TWC729-3476
***************************************************************************************************************************/
  private static String accountTypeToPartnerRoleMapping(Map<String,String> roleTypeMap,List<String> accountTypelist,Map<String,List<String>> roleTypeAccountMap, String PartnerRoleType){
    String isMatchedPartnerRole = '';
    List<String> roleMapAccountTypeList = roleTypeAccountMap.get(PartnerRoleType);
      for(String roleMapAccountTypeString : roleMapAccountTypeList){
        if(accountTypelist.contains(roleMapAccountTypeString)){
          isMatchedPartnerRole = roleMapAccountTypeString;
          break;
        }
      }
      return isMatchedPartnerRole;
  }
/****************************************************************************************************************************/  
    //Method to fetch Pending ACM from Account
    @AuraEnabled
    public static String fetchPendingACM(String emailId){
        Set<Id>accountIdset = new Set<Id>();
        Set<Id>pendingACMSet = new Set<Id>();
        Map<String,String> roleTypeMap = new Map<String,String>();
        Map<String,List<String>> roleTypeAccountMap = new Map<String,List<String>>();
        //boolean pendingAcm = false;
        boolean approvedAcm = false;
        String partnerRole='inactive';
        //String roleMapAccountTypeString = '';
        List<PRM_PartnerRoleTypeMappings__mdt> mdtRoleType= PRM_PartnerRoleTypeMappings__mdt.getall().values();
        
        //System.debug('metadata map1'+mdtRoleType);        
        for(PRM_PartnerRoleTypeMappings__mdt roleTypeReq : mdtRoleType){
            if(roleTypeReq.isDefault__c ==true){
                roleTypeMap.put(roleTypeReq.PRM_Partner_Role__c  , roleTypeReq.PRM_Biz_Org_Type__c);
            }
            if(roleTypeAccountMap.containskey(roleTypeReq.PRM_Partner_Role__c  )){
                List<String> roletypeList = roleTypeAccountMap.get(roleTypeReq.PRM_Partner_Role__c  );
                roletypeList.add(roleTypeReq.PRM_Biz_Org_Type__c);
                roleTypeAccountMap.put(roleTypeReq.PRM_Partner_Role__c  ,roletypeList);
                
            }else{
                roleTypeAccountMap.put(roleTypeReq.PRM_Partner_Role__c,new List<String>{''+roleTypeReq.PRM_Biz_Org_Type__c});
            }
        }
        
        List<String> accountTypelist = new List<String>();
        Boolean contactPartnerRoleEmpty;
        for(Contact con : [Select Id,AccountId,Account.Core_Account_Type__c,Core_IPA_PartnerRole__c from Contact where Email =:emailId]){
            if(con.Account.Core_Account_Type__c == null){
                if(con.Core_IPA_PartnerRole__c != null){
                    partnerRole = roleTypeMap.get(con.Core_IPA_PartnerRole__c);
                    //  break;
                }
                else{
                    contactPartnerRoleEmpty = true;                    
                }
            }
            if(con.Account.Core_Account_Type__c != null){
                accountTypelist = con.Account.Core_Account_Type__c.split( ';' );
            }
            else{
                accountTypelist.add('empty');
            }
            
            
            if(con.Core_IPA_PartnerRole__c != null){        
                if(roleTypeMap.containskey(con.Core_IPA_PartnerRole__c)){
                    if(con.Account.Core_Account_Type__c != null){
                        String isMatchedPartnerRole = accountTypeToPartnerRoleMapping(roleTypeMap,accountTypelist,roleTypeAccountMap, con.Core_IPA_PartnerRole__c);            
                        if(isMatchedPartnerRole == ''){
                            partnerRole = roleTypeMap.get(con.Core_IPA_PartnerRole__c);
                        }else{
                            partnerRole = isMatchedPartnerRole;
                        }            
                    }
                }
            }else{
                accountIdset.add(con.AccountId);    
            }
        }     
        
        if(!accountIdset.isEmpty()  && accountIdset != null){
            for(PRM_AccountChannelMembership__c acm : [Select Id,PRM_Account_Id__c,PRM_Status_Nm__c,PRM_Partner_Role__c from PRM_AccountChannelMembership__c 
                                                       where PRM_Account_Id__c in:accountIdset  Order by CreatedDate ASC]){
                                                           
                                                           if(acm.PRM_Status_Nm__c == system.label.PRM_Status){
                                                               String isMatchedPartnerRole = accountTypeToPartnerRoleMapping(roleTypeMap,accountTypelist,roleTypeAccountMap, acm.PRM_Partner_Role__c);
                                                               if (contactPartnerRoleEmpty == true){
                                                                   partnerRole = roleTypeMap.get(acm.PRM_Partner_Role__c);
                                                                   System.debug('partnerRole263----> '+partnerRole);
                                                                   approvedAcm = true;
                                                                   break;
                                                               }
                                                               if(isMatchedPartnerRole == ''){
                                                                   partnerRole = roleTypeMap.get(acm.PRM_Partner_Role__c);
                                                               }else{
                                                                   partnerRole = isMatchedPartnerRole;
                                                               }  
                                                               approvedAcm = true;
                                                               break;
                                                           }
                                                           else If(acm.PRM_Status_Nm__c ==system.label.PRM_Status_Pending){
                                                               pendingACMSet.add(acm.PRM_Account_Id__c);
                                                           }
                                                       }
        }
        if(!pendingACMSet.isEmpty() && pendingACMSet !=null && approvedAcm ==false){
            for(PRM_AccountChannelMembership__c acm : [Select Id,PRM_Account_Id__c,PRM_Status_Nm__c,PRM_Partner_Role__c from PRM_AccountChannelMembership__c where PRM_Account_Id__c in:pendingACMSet and PRM_Status_Nm__c='Pending'  Order by CreatedDate ASC Limit 1]){
                if(roleTypeMap.containskey(acm.PRM_Partner_Role__c)){
                    
                    String isMatchedPartnerRole = accountTypeToPartnerRoleMapping(roleTypeMap,accountTypelist,roleTypeAccountMap,acm.PRM_Partner_Role__c);
                    if (contactPartnerRoleEmpty == true){
                        partnerRole = roleTypeMap.get(acm.PRM_Partner_Role__c);
                        break;
                    }
                    if(isMatchedPartnerRole == ''){
                        partnerRole = roleTypeMap.get(acm.PRM_Partner_Role__c);
                    }else{
                        partnerRole = isMatchedPartnerRole;
                    }  
                }
            }
        }
        //System.debug('partnerRole'+partnerRole);
        return partnerRole;
    }
    
    @AuraEnabled
    public static Map<Id,String> fetchPendingSelfRegRequests(String emailId){
        Map<Id,String> penRegReqMap;
        for(PRM_Registration_Request__c regReq : [Select Id,PRM_Status__c,PRM_Email_ID__c,PRM_Record_Type_Name_rpt_txt__c from PRM_Registration_Request__c where PRM_Email_ID__c =:emailId and PRM_Status__c ='New' and PRM_Record_Type_Name_rpt_txt__c ='Account Create Request'and PRM_Channel_Program_Level_txt__c ='Intel Partner Alliance']){
             penRegReqMap = new Map<Id,String>();   
            penRegReqMap.put(regReq.id,regReq.PRM_Email_ID__c);
            }
        System.debug('penRegReqMap'+penRegReqMap);
        return penRegReqMap;
    }
    
    
    @AuraEnabled
    public static Map<String,String> submitAdminRequestForm(Map<String,String> registrationDetailsMap)
    {
        return PRM_CreateAccountAndRelatedRecordsAdmin.createAccountAndRelatedRecordsAdmin(registrationDetailsMap);
    }
    
    @AuraEnabled
    public static Boolean getBlockedAccountContact(string emailId,string accId){
    
        //JB Id blocedAccContRT = Schema.getGlobalDescribe().get('PRM_SBC_Account_Search_Configuration__c').getDescribe().getRecordTypeInfosByDeveloperName().get('PRM_BlockedAccountContacts').getRecordTypeId();
               	Id blocedAccContRT = PRM_SBC_Account_Search_Configuration__c.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('PRM_BlockedAccountContacts').getRecordTypeId();
                list<PRM_SBC_Account_Search_Configuration__c> ipaAdminConfig=[select PRM_isActive__c,Account__c,Account__r.id,PRM_Contact__c,PRM_Contact__r.email from PRM_SBC_Account_Search_Configuration__c  
                where RecordTypeId=:blocedAccContRT and ((PRM_Contact__r.email=:emailId and PRM_Type__c='Contact_Blocked') 
                or (Account__r.id=:accId and PRM_Type__c='Account_Blocked')) and PRM_isActive__c=true ];
                system.debug('ipaAdminConfig'+ipaAdminConfig);
                boolean blocked=false;
                iF(ipaAdminConfig.size()>0){
                    for(PRM_SBC_Account_Search_Configuration__c sbc:ipaAdminConfig){
                        if((emailId!=null && sbc.PRM_Contact__r.email==emailId) || (accId!=null && sbc.Account__r.id==accId) && sbc.PRM_isActive__c){
                            blocked=true;
                        }
                    else{
                        if(!blocked)
                        blocked=false;
                    }
                    }
                    
                }
            
                return blocked;
        
}
        
    /*@AuraEnabled
    public static List<Account> getAccountFromId(String accId){
        System.debug('accId:'+accId);
        List<Account> accList;

        if(String.IsNotBlank(accId)){
            accList = [Select Id,Name,BillingStreet,BillingCountryCode,BillingStateCode,BillingCity,
                                     BillingPostalCode,Core_Account_Type__c,Core_User_Defined_Website__c,
                                    toLabel(Core_IPA_Partner_Role__c) from Account where Id =: accId];  
        }
        
        return accList;
    }*/
    
    public class PicklistValues{
        @AuraEnabled
        public List<stateCountryInfo> stateCountryInfoList;
        @AuraEnabled
        public Map<String,String> bizOrgTypeMap;
        @AuraEnabled
        public Map<String,String> roleTypeMapping;
        @AuraEnabled
        public Map<String,String> prefLanguageMap;
        
    }  
    
    public class StateCountryInfo{
        @AuraEnabled
        public String country;
        @AuraEnabled
        public List<String> stateList;
    }  
    
    public class PickListInfo{
        @AuraEnabled 
        public String validFor;
    }
}