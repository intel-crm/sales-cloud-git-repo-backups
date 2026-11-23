/***********************************************************************************************************************************************
Apex Class Name: PRM_IPA_Affiliations
Created Date: 28 july 2022
Function    :  Ability to tagged partner as a strategic partners

Modification Log :
* Developer                     Date                Description                                             TestClass
* -----------------------------------------------------------------------------------------------------------------------------------------------
* Sathya                       	2022-07-28         Added search and tagged method                       PRM_IPA_Affiliations_Test
* Shraddha More                 23/08/2022         Modified search and tagged method                    PRM_IPA_Affiliations_Test
*************************************************************************************************************************************************/

Public without sharing class PRM_IPA_Affiliations{
    
    //to search Intel account
    @AuraEnabled
    public static List<AccAndAcmWrapper > fetchAccsData(String accountName, Id currentbuilderId) {
        list<AccAndAcmWrapper > wrapperList =new list<AccAndAcmWrapper >(); 
        
        Map<Id, PRM_IPA_Affiliation__c> builderlocMap = new Map<Id, PRM_IPA_Affiliation__c>();
        Map<Id, PRM_IPA_Affiliation__c> builderMap = new Map<Id, PRM_IPA_Affiliation__c>();
        Set<Id> accLocIds = new Set<Id>();
        
        string acmStatus='Approved', program='Intel Partner Alliance',accountId, masterAccount = 'Mastered_Account', deactivate= 'false';
        list<PRM_AccountChannelMembership__c > acmList=new list<PRM_AccountChannelMembership__c >();
        Map<Id, PRM_AccountChannelMembership__c > acmMap=new Map<Id, PRM_AccountChannelMembership__c >();
        
        
        try {
            if(accountName.startsWith('001') && (accountName.length() ==15 || accountName.length() == 18)){
                accountId = accountName;
            }else{
                accountName = '%' + accountName + '%';   
            }
            
            string query='SELECT Id,PRM_Account_Id__r.RecordType.DeveloperName,PRM_Account_Id__c,PRM_Account_Id__r.Name,PRM_Account_Id__r.AccountNumber,PRM_Partner_Role__c, PRM_Account_Id__r.Core_User_Defined_Phone_Number__c, tolabel(PRM_Account_Id__r.BillingCountryCode), PRM_Account_Id__r.Core_Account_BU_Focus__c,PRM_Channel_Program_Level_Id__r.Name,PRM_Account_Id__r.Core_IPA_Partner_Speciality__c FROM PRM_AccountChannelMembership__c'+
                ' where PRM_Channel_Program_Id__r.Name=:program AND PRM_Status_Nm__c =:acmStatus AND PRM_Account_Id__r.RecordType.DeveloperName =: masterAccount AND PRM_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c = true AND PRM_Account_Id__r.Core_Deactivated__c = false';
            if(accountId!=null){
                query+=' and PRM_Account_Id__c =:accountId ';
            }
            else {
                query+=' and PRM_Account_Id__r.Name like :accountName';
            }
            
            List<PRM_AccountChannelMembership__c> ListOfACM = database.query(query);
            
            if(ListOfACM.size()>0 && !ListOfACM.isEmpty()){
                for(PRM_AccountChannelMembership__c pac : ListOfACM){
                    acmMap.put(pac.PRM_Account_Id__c, pac);
                }  
            }
            
            acmList = acmMap.values();

            wrapperList.addAll(fetchAccsDataHelper( acmList,  acmMap, currentbuilderId ));
            
            // if(!acmList.isEmpty() && acmList.size()>0){
            //     For(PRM_AccountChannelMembership__c ac : acmList){
            //         accLocIds.add(ac.PRM_Account_Id__c);
            //     }
            // }
            
            // if(!accLocIds.isEmpty() && accLocIds.size()>0){
            //     for(PRM_IPA_Affiliation__c tgb : [select id, Name, PRM_Account__c, PRM_Account__r.id, PRM_Active__c, PRM_Builder_Strategy__c, PRM_Builder_Strategy__r.Name from PRM_IPA_Affiliation__c where PRM_Account__c IN : acmMap.keySet() AND PRM_Builder_Strategy__c =: currentbuilderId]
            //        ){
            //            builderlocMap.put(tgb.PRM_Account__c, tgb);
            //        }
            // }
            
            // if(!acmList.isEmpty() && acmList.size()>0){
            //     for(PRM_AccountChannelMembership__c acm: acmList){
            //         if(!builderlocMap.containsKey(acm.PRM_Account_Id__c)){
            //             AccAndAcmWrapper accwrap=new AccAndAcmWrapper(acm.PRM_Account_Id__c,acm.PRM_Account_Id__r.AccountNumber,acm.PRM_Account_Id__r.Name,acm.PRM_Partner_Role__c,acm.PRM_Account_Id__r.Core_User_Defined_Phone_Number__c,acm.PRM_Account_Id__r.BillingCountryCode, ''); 
            //             wrapperList.add(accwrap);
            //         }
                    
            //     }
            // }
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return wrapperList;
    }

    public static list<AccAndAcmWrapper> fetchAccsDataHelper(list<PRM_AccountChannelMembership__c > acmList, Map<Id, PRM_AccountChannelMembership__c > acmMap, Id currentbuilderId ){

        Set<Id> accLocIds = new Set<Id>();
        Map<Id, PRM_IPA_Affiliation__c> builderlocMap = new Map<Id, PRM_IPA_Affiliation__c>();
        list<AccAndAcmWrapper> wrapperList =new list<AccAndAcmWrapper >(); 

        if(!acmList.isEmpty() && acmList.size()>0){
            For(PRM_AccountChannelMembership__c ac : acmList){
                accLocIds.add(ac.PRM_Account_Id__c);
            }
        }
        
        if(!accLocIds.isEmpty() && accLocIds.size()>0){
            for(PRM_IPA_Affiliation__c tgb : [select id, Name, PRM_Account__c, PRM_Account__r.id, PRM_Active__c, PRM_Builder_Strategy__c, PRM_Builder_Strategy__r.Name from PRM_IPA_Affiliation__c where PRM_Account__c IN : acmMap.keySet() AND PRM_Builder_Strategy__c =: currentbuilderId]
               ){
                   builderlocMap.put(tgb.PRM_Account__c, tgb);
               }
        }
        
        if(!acmList.isEmpty() && acmList.size()>0){
            for(PRM_AccountChannelMembership__c acm: acmList){
                if(!builderlocMap.containsKey(acm.PRM_Account_Id__c)){
                    AccAndAcmWrapper accwrap=new AccAndAcmWrapper(acm.PRM_Account_Id__c,acm.PRM_Account_Id__r.AccountNumber,acm.PRM_Account_Id__r.Name,acm.PRM_Partner_Role__c,acm.PRM_Account_Id__r.Core_User_Defined_Phone_Number__c,acm.PRM_Account_Id__r.BillingCountryCode, ''); 
                    wrapperList.add(accwrap);
                }
                
            }
        }

        return wrapperList;
    }
    
    //to create Affiliations records
    @AuraEnabled
    public static CustomResponse tagBuilders(list<Object> AccountIds, Id currentbuilderId) {
        Id recordTypeIdIntelAccount = Schema.SObjectType.PRM_IPA_Affiliation__c.getRecordTypeInfosByName().get('Intel Account Affiliation').getRecordTypeId();
        // Id recordTypeIdOPIDAccount = Schema.SObjectType.PRM_IPA_Affiliation__c.getRecordTypeInfosByName().get('Partner Account Group Affiliation').getRecordTypeId();
        
        list<PRM_IPA_Affiliation__c> tagList=new list<PRM_IPA_Affiliation__c>();  
        //List<PRM_IPA_Affiliation__c> buList = new List<PRM_IPA_Affiliation__c>();
        //Map<Id, PRM_IPA_Affiliation__c> buMap = new Map<Id, PRM_IPA_Affiliation__c>();
        
        list<AccAndAcmWrapper > wrapper = (List<AccAndAcmWrapper>)JSON.deserialize(JSON.serialize(AccountIds), List<AccAndAcmWrapper>.class);   
        String throwableExceptions = '';
        CustomResponse res = new CustomResponse();

        try{
            if(wrapper.size()>0){
                for(AccAndAcmWrapper  wrap : wrapper ){
                    PRM_IPA_Affiliation__c tag=new PRM_IPA_Affiliation__c();
                    tag.PRM_Account__c = wrap.accountId;
                    tag.PRM_Builder_Strategy__c = currentbuilderId;
                    tag.RecordTypeId = recordTypeIdIntelAccount;
                    tag.PRM_Notes__c = wrap.accNotes;
                    tagList.add(tag);
                }
                
                if(tagList.size()>0){
                    for(Database.saveResult sr: Database.insert(tagList, false)){
                        if(!sr.isSuccess()){
                            throwableExceptions +=  sr.getErrors()[0].getMessage() + '<br/>';

                        }
                    }
                }
        
            }
        }catch (Exception e) {
            String beautifiedMessage = 'Some Error occured. Please try again later.';
            throw new AuraHandledException(beautifiedMessage);
        }
        finally{

            res = tagBuildersHelper(throwableExceptions);
            // if(!String.isBlank(throwableExceptions)){
            //     String beautifiedMessage = 'Some Error occured. Please try again later.';
            //     if(throwableExceptions.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){          
            //         for(String beautifiedMessage1 : throwableExceptions.split('FIELD_CUSTOM_VALIDATION_EXCEPTION, ')){
            //             Integer count = 0;
            //             for(String beautifiedMessage2 : beautifiedMessage1.split('<br/>')){
            //                 System.debug('beautifiedMessage-> '+beautifiedMessage2);
            //                 if(Math.mod(count, 2) == 0){
            //                     beautifiedMessage +=  beautifiedMessage2 + '\n';
            //                 }                      
            //                 count ++ ;
            //             }        
            //         } 
    
            //     }
            //     else if(throwableExceptions.endsWith('<br/>')){
            //         beautifiedMessage = throwableExceptions.replaceAll('<br/>', '\n');
            //     }

            //     res.message = beautifiedMessage;
            // }else {
            //     res.message = 'Success';
            // }
        }
        return res;
    }

    public static CustomResponse  tagBuildersHelper(String throwableExceptions){

        CustomResponse res = new CustomResponse();

        if(!String.isBlank(throwableExceptions)){
            String beautifiedMessage = 'Some Error occured. Please try again later.';
            if(throwableExceptions.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){          
                for(String beautifiedMessage1 : throwableExceptions.split('FIELD_CUSTOM_VALIDATION_EXCEPTION, ')){
                    Integer count = 0;
                    for(String beautifiedMessage2 : beautifiedMessage1.split('<br/>')){
                        if(Math.mod(count, 2) == 0){
                            beautifiedMessage +=  beautifiedMessage2 + '\n';
                        }                      
                        count ++ ;
                    }        
                } 

            }
            else if(throwableExceptions.endsWith('<br/>')){
                beautifiedMessage = throwableExceptions.replaceAll('<br/>', '\n');
            }

            res.message = beautifiedMessage;
            return res;
        }else {
            res.message = 'Success';
            return res;
        }
    }
    
    public class CustomResponse{
        @auraEnabled public String message;
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
        @auraEnabled public string accNotes {get;set;}
        
        public AccAndAcmWrapper(Id accId,String accountNo,String accName,String partnerRole, String phone,String country, String notes){
            id=accId;
            accountId = accId;
            accountNum = accountNo;
            accountName = accName;
            acmpartnerRole = partnerRole;
            accountPhoneNo = phone;
            accCountry = country;  
            accNotes = notes;        
        }
    } 
}