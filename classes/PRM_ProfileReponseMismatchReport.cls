/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 03-02-2023
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class PRM_ProfileReponseMismatchReport{    
    
    @AuraEnabled
    public static List<String> getOnePartnerIds(){
        List<String> accountIds = new List<String>();
        for(Account accountRecord : [select id,(select id from Channel_Memberships1__r where PRM_Status_Nm__c ='Approved' and PRM_Channel_Program_Id__r.Name='Intel Partner Alliance') from account where RecordType.DeveloperName ='Core_Partner_Account_Group' and Core_IPA_Badge_Tier__c <> null order by lastmodifieddate desc]){            
            if(accountRecord.channel_Memberships1__r.size()>0){
                accountIds.add(accountRecord.id);
            }
        }
        return accountIds;
    }
    
    @AuraEnabled public static Map<String,ProfileResponseWrapper> getProfileResponse(List<String> accountIds){
        System.debug('Account ids -->'+ accountIds);
        //List<String> accountIds = (List<String>) JSON.deserialize(ids, List<String>.class);
        Map<String, String> onePartnerResponseMap = new Map<String,String>();
        Set<String> clubbedIds = new Set<String>();
        ResponseWrapper accountwrapper = new ResponseWrapper();
        Map<String,ProfileResponseWrapper> profileResponse = new Map<String,ProfileResponseWrapper>();
        Map<String,List<ResponseWrapper>> locationAccountsMap = new Map<String,List<ResponseWrapper>>();
        //ResponseWrapper profileResponseMap = new ResponseWrapper();
        Set<String> flags = new Set<String>{'Points Not eligible','Points Opt-in','Component Point earning excluded','Branded Point earning excluded','ODM whitebox Point earning excluded'};
            String query;
        // get account memebers
        for(Core_Account_Group_Member__c groupMembers : [select Core_Intel_Account_Id__c, Core_Partner_Account_Id__c from Core_Account_Group_Member__c where Core_Inactive_Ind__c = false and Core_Intel_Partner_Alliance_PartnerGroup__c = true and Core_Partner_Account_Id__c in :accountIds]){            
            clubbedIds.add(groupMembers.Core_Intel_Account_Id__c);
            clubbedIds.add(groupMembers.Core_Partner_Account_Id__c);
        }
        
        query= 'select id,Name,RecordType.DeveloperName,(select Core_Partner_Account_Id__r.Name, Core_Partner_Account_Id__c from Partner_Account_Group_Members1__r where Core_Inactive_Ind__c= false and Core_Intel_Partner_Alliance_PartnerGroup__c = true),(select  PRM_Response_Txt__c, PRM_Question_Display_Text__c, PRM_Profile_Answer_Id__r.PRM_Answer_Display_Txt__c  from Profile_Responses__r where PRM_Question_Display_Text__c in :flags) from account where id in :clubbedIds and RecordType.DeveloperName !=\'Inactive_Account\' order by lastmodifieddate desc';
        
        
        for(Account actRecord : Database.Query(query)){
            String unique = '';
            accountwrapper = new ResponseWrapper();
            accountwrapper.accountName = actRecord.Name;
            accountwrapper.recordTypeName = actRecord.RecordType.DeveloperName;
            accountwrapper.accountURL = '/'+actRecord.Id;
            accountwrapper.accountId = actRecord.Id;
            accountwrapper.ptsNotEligible = false;
            accountwrapper.ptsOptIn = false;
            accountwrapper.brandedPtsEarningExl= false;
            accountwrapper.cmpPtsEarningExl= false;
            accountwrapper.odmWhiteboxPtsEarningExl = false;
            
            if(actRecord.RecordType.DeveloperName !='Core_Partner_Account_Group'){
                List<PRM_Profile_Responses__c> profileResponseLst = new List<PRM_Profile_Responses__c>(); 
                for(PRM_Profile_Responses__c prs : actRecord.Profile_Responses__r){profileResponseLst.add(prs);}
                accountwrapper.onePartnerName = actRecord.Partner_Account_Group_Members1__r[0].Core_Partner_Account_Id__r.Name;
                accountwrapper.onePartnerId = actRecord.Partner_Account_Group_Members1__r[0].Core_Partner_Account_Id__c;
                accountwrapper = checkProfileResponse(accountwrapper,profileResponseLst);
                System.debug('onePartnerResponseMap -->'+JSON.serialize(onePartnerResponseMap));
                if(onePartnerResponseMap!=null && onePartnerResponseMap.containsKey(accountwrapper.onePartnerId)){
                    ProfileResponseWrapper pr = profileResponse.get(accountwrapper.onePartnerId);
                    if(accountwrapper.uniqueKey != onePartnerResponseMap.get(accountwrapper.onePartnerId)){                            
                        Set<ResponseWrapper> locationAccountResponse = pr.locationAccountResponse;
                        if(locationAccountResponse!=null){locationAccountResponse.add(accountwrapper);
                                                         }else{                                
                                                             //
                                                             locationAccountResponse = new Set<ResponseWrapper>();
                                                             locationAccountResponse.add(accountwrapper);
                                                         }             
                        pr.locationAccountResponse = locationAccountResponse;
                    }
                    profileResponse.put(accountwrapper.onePartnerId, pr);
                }else if(locationAccountsMap!=null && locationAccountsMap.containsKey(accountwrapper.onePartnerId)){locationAccountsMap.get(accountwrapper.onePartnerId).add(accountwrapper);
                                                                                                                   }else{locationAccountsMap.put(accountwrapper.onePartnerId,new List<ResponseWrapper>{accountwrapper});
                                                                                                                        }
                System.debug('Location Accounts -->'+JSON.serialize(locationAccountsMap));
            }else{
                //accountwrapper = checkProfileResponse(accountwrapper,actRecord.Profile_Responses__r);
                List<PRM_Profile_Responses__c> profileResponseLst = new List<PRM_Profile_Responses__c>(); 
                ProfileResponseWrapper pr = new ProfileResponseWrapper();
                for(PRM_Profile_Responses__c prs : actRecord.Profile_Responses__r){profileResponseLst.add(prs);}
                pr.onePartnerResponse = checkProfileResponse(accountwrapper,profileResponseLst);
                profileResponse.put(accountwrapper.accountId, pr );
                onePartnerResponseMap.put(actRecord.Id, accountwrapper.uniqueKey);
                
            }
            
        }
        
        //check for remaining location accounts
        for(String key : locationAccountsMap.keySet()){
            if(!profileResponse.isEmpty() && profileResponse!=null && profileResponse.containsKey(key)){
                ProfileResponseWrapper opidResp = profileResponse.get(key);//.onePartnerResponse;                    
                for(ResponseWrapper locationAccount : locationAccountsMap.get(key)){                                            
                    System.debug('opidResp.onePartnerResponse.uniqueKey -->'+opidResp.onePartnerResponse.uniqueKey);
                    System.debug('locationAccount.uniqueKey -->'+locationAccount.uniqueKey);
                    Set<ResponseWrapper> locationAccountResponse = opidResp.locationAccountResponse;
                    if(opidResp.onePartnerResponse.uniqueKey != locationAccount.uniqueKey){                            
                        if(locationAccountResponse!=null){
                            locationAccountResponse.add(locationAccount);
                        }else{
                            locationAccountResponse = new Set<ResponseWrapper>();
                            locationAccountResponse.add(locationAccount);
                        }
                        
                    }
                    opidResp.locationAccountResponse = locationAccountResponse;
                }
                // pr.onePartnerResponse = opidResp;
                profileResponse.put(accountwrapper.accountId, opidResp );   
            }
        }
        //}
        System.debug(JSON.serialize(profileResponse));
        return profileResponse;
    }
    
    
    public static ResponseWrapper checkProfileResponse(ResponseWrapper accountwrapper,List<PRM_Profile_Responses__c> response){
        for(PRM_Profile_Responses__c  profileResp: response){
            switch on profileResp.PRM_Question_Display_Text__c {
                when 'Points Not eligible' {
                    System.debug('PNE ->'+profileResp.PRM_Profile_Answer_Id__r.PRM_Answer_Display_Txt__c);
                    if(!String.isEmpty(profileResp.PRM_Response_Txt__c) && (profileResp.PRM_Response_Txt__c.toLowerCase()=='true' || profileResp.PRM_Response_Txt__c.toLowerCase()!='false'))accountwrapper.ptsNotEligible = true;
                }
                when 'Points Opt-in' {if(!String.isEmpty(profileResp.PRM_Response_Txt__c) && (profileResp.PRM_Response_Txt__c.toLowerCase()=='true' || profileResp.PRM_Response_Txt__c.toLowerCase()!='false'))accountwrapper.ptsOptIn = true;
                    System.debug('POI ->'+profileResp.PRM_Profile_Answer_Id__r.PRM_Answer_Display_Txt__c);
                    
                }
                when 'Component Point earning excluded' {if(!String.isEmpty(profileResp.PRM_Response_Txt__c) && (profileResp.PRM_Response_Txt__c.toLowerCase()=='true' || profileResp.PRM_Response_Txt__c.toLowerCase()!='false'))accountwrapper.brandedPtsEarningExl = true;
                    System.debug('CPEE ->'+profileResp.PRM_Profile_Answer_Id__r.PRM_Answer_Display_Txt__c);
                    
                }
                when 'Branded Point earning excluded' {
                    System.debug('BPEE ->'+profileResp.PRM_Profile_Answer_Id__r.PRM_Answer_Display_Txt__c);
                    if(!String.isEmpty(profileResp.PRM_Response_Txt__c) && (profileResp.PRM_Response_Txt__c.toLowerCase()=='true' || profileResp.PRM_Response_Txt__c.toLowerCase()!='false'))accountwrapper.cmpPtsEarningExl= true;
                }
                when 'ODM whitebox Point earning excluded' {
                    System.debug('ODM ->'+profileResp.PRM_Profile_Answer_Id__r.PRM_Answer_Display_Txt__c);
                    if(!String.isEmpty(profileResp.PRM_Response_Txt__c) && (profileResp.PRM_Response_Txt__c.toLowerCase()=='true' || profileResp.PRM_Response_Txt__c.toLowerCase()!='false'))accountwrapper.odmWhiteboxPtsEarningExl = true;
                }
            }
            accountwrapper.uniqueKey = ''+accountwrapper.ptsNotEligible+''+accountwrapper.ptsOptIn+''+accountwrapper.brandedPtsEarningExl+''+accountwrapper.cmpPtsEarningExl+''+accountwrapper.odmWhiteboxPtsEarningExl;
            // accountwrapper.iconName='utility:chevronright';
            // profileResponseMap.put(actRecord.Id,accountwrapper);
        }
        return accountwrapper;
    }
    
    
    public class ResponseWrapper{
        @AuraEnabled public String onePartnerName{get;set;}
        @AuraEnabled public boolean ptsNotEligible{get;set;}
        @AuraEnabled public boolean ptsOptIn{get;set;}
        @AuraEnabled public boolean brandedPtsEarningExl{get;set;}
        @AuraEnabled public boolean cmpPtsEarningExl{get;set;}
        @AuraEnabled public boolean odmWhiteboxPtsEarningExl{get;set;}
        @AuraEnabled public String onePartnerId{get;set;}        
        @AuraEnabled public String recordTypeName{get;set;}
        @AuraEnabled public String accountId{get;set;}
        @AuraEnabled public String accountName{get;set;}        
        @AuraEnabled public String uniqueKey{get;set;}       
        @AuraEnabled public String accountURL{get;set;} 
    }
    
    public class ProfileResponseWrapper{
        @AuraEnabled public  ResponseWrapper onePartnerResponse{get;set;}
        @AuraEnabled public  Set<ResponseWrapper> locationAccountResponse{get;set;}
        
    }
}