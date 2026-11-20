/***********************************************************************************************************************************************
Apex Class Name: PRM_IPA_Affiliations
Created Date: 28 july 2022
Function    :  Ability to tagged partner as a strategic partners

Modification Log :
* Developer                     Date                Description                                             TestClass
* -----------------------------------------------------------------------------------------------------------------------------------------------
* Sathya                         2022-07-28         Added search and tagged method                       PRM_IPA_Affiliations_Test
* Shraddha More                 23/08/2022         Modified search and tagged method                    PRM_IPA_Affiliations_Test
*************************************************************************************************************************************************/

Public without sharing class PRM_IPA_Affiliations{
    
    //to search Intel account
    @AuraEnabled
    public static List<opidAccAndAcmWrapper > fetchAccsData(String accountName, Id currentbuilderId) {
        list<opidAccAndAcmWrapper > wrapperList =new list<opidAccAndAcmWrapper >(); 
        
        // Map<Id, PRM_IPA_Affiliation__c> builderlocMap = new Map<Id, PRM_IPA_Affiliation__c>();
        Map<Id, PRM_IPA_Affiliation__c> builderMap = new Map<Id, PRM_IPA_Affiliation__c>();
        //Set<Id> accLocIds = new Set<Id>();
        
        string acmStatus='Approved', program='Intel Partner Alliance',accountId, masterAccount = 'Mastered_Account', opidAccount = 'Core_Partner_Account_Group', deactivate= 'false';
        list<PRM_AccountChannelMembership__c > acmList=new list<PRM_AccountChannelMembership__c >();
        Map<Id, PRM_AccountChannelMembership__c > acmMap=new Map<Id, PRM_AccountChannelMembership__c >();
        
        
        try {
            if(accountName.startsWith('001') && (accountName.length() ==15 || accountName.length() == 18)){
                accountId = accountName;
            }else{
                accountName = '%' + accountName + '%';   
            }
            
            string query='SELECT Id,PRM_Account_Id__r.RecordType.DeveloperName,PRM_Account_Id__c,PRM_Account_Id__r.Name,PRM_Account_Id__r.UCD_Primary_Account__r.name,PRM_Partner_Role__c, PRM_Account_Id__r.Core_PAG_Grouping_Method__c, PRM_Account_Id__r.Core_IPA_Badge_Tier__c FROM PRM_AccountChannelMembership__c'+
                ' where PRM_Channel_Program_Id__r.Name=:program AND PRM_Status_Nm__c =:acmStatus AND PRM_Account_Id__r.RecordType.DeveloperName =: opidAccount AND PRM_Account_Id__r.Core_Deactivated__c = false';
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

    public static list<opidAccAndAcmWrapper> fetchAccsDataHelper(list<PRM_AccountChannelMembership__c > acmList, Map<Id, PRM_AccountChannelMembership__c > acmMap, Id currentbuilderId ){

        Set<Id> accLocIds = new Set<Id>();
        Map<Id, PRM_IPA_Affiliation__c> builderlocMap = new Map<Id, PRM_IPA_Affiliation__c>();
        list<opidAccAndAcmWrapper> wrapperList =new list<opidAccAndAcmWrapper >(); 

        if(!acmList.isEmpty() && acmList.size()>0){
            For(PRM_AccountChannelMembership__c ac : acmList){
                accLocIds.add(ac.PRM_Account_Id__c);
            }
        }
        
        if(!accLocIds.isEmpty() && accLocIds.size()>0){
            for(PRM_IPA_Affiliation__c tgb : [select id, Name, PRM_Account__c, PRM_Account__r.id, PRM_Active__c, PRM_Builder_Strategy__c, PRM_Builder_Strategy__r.Name from PRM_IPA_Affiliation__c where PRM_Account__c IN : acmMap.keySet() AND PRM_Builder_Strategy__c =: currentbuilderId AND PRM_Active__c = true]//True check added forTWC729-9469
               ){
                   builderlocMap.put(tgb.PRM_Account__c, tgb);
               }
        }
        
        if(!acmList.isEmpty() && acmList.size()>0){
            for(PRM_AccountChannelMembership__c acm: acmList){
                if(!builderlocMap.containsKey(acm.PRM_Account_Id__c)){
                    opidAccAndAcmWrapper accwrap=new opidAccAndAcmWrapper(acm.PRM_Account_Id__c,acm.PRM_Account_Id__r.Name,acm.PRM_Account_Id__r.UCD_Primary_Account__r.name,acm.PRM_Account_Id__r.Core_IPA_Badge_Tier__c ,acm.PRM_Account_Id__r.Core_PAG_Grouping_Method__c, 'Affiliation associated through Tag Builders'); 
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
        Id recordTypeIdOPIDAccount = Schema.SObjectType.PRM_IPA_Affiliation__c.getRecordTypeInfosByName().get('Partner Account Group Affiliation').getRecordTypeId();
        
        list<PRM_IPA_Affiliation__c> tagList=new list<PRM_IPA_Affiliation__c>();  
        //List<PRM_IPA_Affiliation__c> buList = new List<PRM_IPA_Affiliation__c>();
        //Map<Id, PRM_IPA_Affiliation__c> buMap = new Map<Id, PRM_IPA_Affiliation__c>();
        
        list<opidAccAndAcmWrapper > wrapper = (List<opidAccAndAcmWrapper>)JSON.deserialize(JSON.serialize(AccountIds), List<opidAccAndAcmWrapper>.class);   
        String throwableExceptions = '';
        CustomResponse res = new CustomResponse();
        //defect fix- start -TWC729-9469
        Set<Id> accountIdSet = new Set<Id>();
        
        for(opidAccAndAcmWrapper wrap : wrapper){
            accountIdSet.add(wrap.accountId);
        }
        
        Map<Id,List<PRM_IPA_Affiliation__c>> inactiveAffMap = new Map<Id, List<PRM_IPA_Affiliation__c>>();
        
        for(PRM_IPA_Affiliation__c aff : [
            SELECT Id,
            PRM_Account__c,
            PRM_Active__c
            FROM PRM_IPA_Affiliation__c
            WHERE PRM_Account__c IN :accountIdSet
            AND PRM_Builder_Strategy__c = :currentbuilderId
            AND PRM_Active__c = false
        ]){
            if(!inactiveAffMap.containsKey(aff.PRM_Account__c)){
                inactiveAffMap.put(aff.PRM_Account__c,new List<PRM_IPA_Affiliation__c>());
            }
            inactiveAffMap.get(aff.PRM_Account__c).add(aff);
        }
        //defect fix -TWC729-9469

        try{
            if(wrapper.size()>0){
                List<PRM_IPA_Affiliation__c> updateList = new List<PRM_IPA_Affiliation__c>();//defect fix- change -TWC729-9469
                for(opidAccAndAcmWrapper  wrap : wrapper ){
                    if(inactiveAffMap.containsKey(wrap.accountId)){ //defect fix- start -TWC729-9469            
                        for(PRM_IPA_Affiliation__c aff : inactiveAffMap.get(wrap.accountId)){
                            aff.PRM_Active__c = true;
                            aff.PRM_Notes__c = wrap.accNotes;
                            updateList.add(aff);
                        }//defect fix- END -TWC729-9469                     
                    }else{
                        PRM_IPA_Affiliation__c tag=new PRM_IPA_Affiliation__c();
                        tag.PRM_Account__c = wrap.accountId;
                        tag.PRM_Builder_Strategy__c = currentbuilderId;
                        tag.RecordTypeId = recordTypeIdOPIDAccount;
                        tag.PRM_Notes__c = wrap.accNotes;
                        tagList.add(tag);
                    }
                }
                if(!updateList.isEmpty()){
                    update updateList;
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
   /* public with sharing class AccAndAcmWrapper {
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
    } */

    //OPID and ACMWrapper
    public with sharing class opidAccAndAcmWrapper {
        @auraEnabled public Id id {get;set;}
        @auraEnabled public Id accountId {get;set;}
        @auraEnabled public string accountName {get;set;}
        @auraEnabled public string ucdPrimary {get;set;}
        @auraEnabled public string badgeTier {get;set;}
        @auraEnabled public string groupingMethod {get;set;}
        @auraEnabled public string accNotes {get;set;}
        
        public opidAccAndAcmWrapper(Id accId,String accName,String ucdPrimaryAcc, String badgeTierValue,String groupMethod, String notes){
            id=accId;
            accountId = accId;
            accountName = accName;
            ucdPrimary = ucdPrimaryAcc;
            groupingMethod = groupMethod;
            badgeTier = badgeTierValue;
            accNotes = notes;        
        }
    } 
}