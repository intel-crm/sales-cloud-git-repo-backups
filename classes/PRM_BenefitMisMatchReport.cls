/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 03-07-2023
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class PRM_BenefitMisMatchReport{ // implements PRM_CustomReportController
    
    public static final String ORIGIN  = 'PRM_ProfileReponseMismatchReport';
    public static final String SEVERITY  = 'Critical';
    public static final String PROJECT  = 'IPA';
    public static Map<String, ReportWrapper> reportWrapperMap = new Map<String, ReportWrapper>();
    public static BnftWrapper bw = new BnftWrapper();
    public static BnftMatrixWrapper bmw = new BnftMatrixWrapper();
    
    @AuraEnabled
    public static List<String> getAccountIds(){
        
        List<String> accountIds = new List<String>();
        String query = 'select id,Name,RecordType.DeveloperName,(select Core_Intel_Account_Id__c,Core_Partner_Account_Id__r.Name, Core_Partner_Account_Id__c from Partner_Account_Group_Members1__r where Core_Inactive_Ind__c= false ),(select toLabel(PRM_Partner_Role__c), PRM_Account_Id__c,  PRM_Channel_Program_Level_Id__r.Name from Channel_Memberships1__r where PRM_Status_Nm__c =\'Approved\' and PRM_Channel_Program_Id__r.Name=\'Intel Partner Alliance\') from account where Core_Intel_Partner_Alliance_PartnerGroup__c =true and Core_IPA_One_Partner_Id__c!= null and RecordType.DeveloperName !=\'Inactive_Account\' order by lastmodifieddate desc';
        try{        
            for(account accountRecord : Database.query(query)){  
                accountIds.add(accountRecord.id);
                if(accountRecord.Partner_Account_Group_Members1__r.size()>0)accountIds.add(accountRecord.Partner_Account_Group_Members1__r[0].Core_Partner_Account_Id__c);
            }
        }catch(Exception ex){
            Core_Log_Entry.logEntryWithDetails(ORIGIN, PROJECT,'Message', SEVERITY, ex.getMessage(), '', null, null, null);            
        }
        return accountIds;
    }
    
    /**
* Get Location Accounts with/without One Partner
* return  : Map<String, String> : accountId, RecordType
*/
    
    @AuraEnabled
    public static List<ReportWrapper> getAccountsAndBenefits(List<String> accountIds, String wrapper){
        System.debug('Logs -->'+wrapper);
        BnftMatrixWrapper matrixRecords =(BnftMatrixWrapper)JSON.deserialize(
            wrapper, BnftMatrixWrapper.class);
        
        Set<String> onePartnerIds = new Set<String>();        
        try{
            for(account accountRecord : [select id,Name,RecordType.DeveloperName,(select PRM_Partner_Benefit_Id__r.Name from AccountBenefitAssociations__r where PRM_Status_Nm__c = 'Active' and PRM_Source__c ='tier'), (select Core_Intel_Account_Id__c,Core_Partner_Account_Id__r.Name, Core_Partner_Account_Id__c from Partner_Account_Group_Members1__r where Core_Inactive_Ind__c= false ),(select toLabel(PRM_Partner_Role__c), PRM_Account_Id__c,  PRM_Channel_Program_Level_Id__r.Name from Channel_Memberships1__r where PRM_Status_Nm__c ='Approved' and PRM_Channel_Program_Id__r.Name='Intel Partner Alliance') from account where id in :accountIds order by lastmodifieddate desc]){            
                if(accountRecord.Channel_Memberships1__r.size()>0){
                    ReportWrapper wrap = new ReportWrapper();
                    wrap.accountId = accountRecord.Id;
                    wrap.recordTypeName = accountRecord.RecordType.DeveloperName;//!=null && accountRecord.RecordType.DeveloperName =='Mastered_Account'?'Location Account':'One Partner Id Account';
                    wrap.accountName = accountRecord.Name;
                    
                    wrap = getRoleTier(accountRecord.Channel_Memberships1__r, wrap); // need to be removed                
                    if(accountRecord.Partner_Account_Group_Members1__r.size()>0){
                        wrap.onePartnerName = accountRecord.Partner_Account_Group_Members1__r[0].Core_Partner_Account_Id__r.Name;
                        wrap.onePartnerId = accountRecord.Partner_Account_Group_Members1__r[0].Core_Partner_Account_Id__c;                                       
                    }
                    if(accountRecord.AccountBenefitAssociations__r.size()>0){
                        wrap.benefitsOnAccount = accountRecord.AccountBenefitAssociations__r;                    
                    }
                    reportWrapperMap.put(accountRecord.Id, wrap);
                }
                
            }
            
            checkApplicableBenefits(reportWrapperMap,matrixRecords);
            System.debug('reportWrapperMap -->'+JSON.serialize(reportWrapperMap));
        }catch(Exception ex){
            Core_Log_Entry.logEntryWithDetails(ORIGIN, PROJECT,'Message', SEVERITY, ex.getMessage(), '', null, null, null);
            throw new AuraHandledException('Eception Occurred :'+ex.getMessage());
        }
        return reportWrapperMap.values();
    }
    
    public static ReportWrapper getRoleTier(List<PRM_AccountChannelMembership__c> channelProgramList, ReportWrapper wrap){
        List<String> roles = new List<String>();
        List<String> tiers = new List<String>();
        Set<String> roleTier = new Set<String>();
        for(PRM_AccountChannelMembership__c channelProgram : channelProgramList){
            roles.add(channelProgram.PRM_Partner_Role__c);
            tiers.add(channelProgram.PRM_Channel_Program_Level_Id__r.Name);
            roleTier.add(channelProgram.PRM_Partner_Role__c+'_'+channelProgram.PRM_Channel_Program_Level_Id__r.Name); 
        }
        wrap.role = roles;
        wrap.tier = tiers;
        wrap.roleTier = roleTier;
        return wrap;
    }
    
    public static void checkApplicableBenefits(Map<String, ReportWrapper> reportWrapperMap,BnftMatrixWrapper requiredBenefits){
       
        for(String id : reportWrapperMap.keySet()){
            //Set<String> missedBenefits = new Set<String>();
            //Set<String> bnftsToBeremoved = new Set<String>();
            ReportWrapper accountDetails = reportWrapperMap.get(id);
            Set<String> roleSpecificBenefits = new Set<String>();
            List<PRM_AccountBenefitAssociation__c> bnftsOnAccount = reportWrapperMap.get(id).benefitsOnAccount;
            
            for(String actRoleTier : accountDetails.roleTier){
                List<String> rl = actRoleTier.split('_');
                String actRoleTier1;String actRoleTier2;
                System.debug('Role -->'+rl);
                System.debug('Record Type -->'+accountDetails.recordTypeName);
                Set<String> responseBnft = getRoleTierSpecificBenefits(requiredBenefits,actRoleTier,accountDetails.recordTypeName);
                if(responseBnft!=null && responseBnft.size()>0){roleSpecificBenefits.addAll(responseBnft);}
                
                if(rl[1] =='Gold'){             
                    Set<String> bnfts = getRoleTierSpecificBenefits(requiredBenefits,rl[0]+'_Member',accountDetails.recordTypeName);
                    if(bnfts!=null && bnfts.size()>0){roleSpecificBenefits.addAll(bnfts);}
                }else if(rl[1] =='Titanium'){                        
                    Set<String> bnfts = getRoleTierSpecificBenefits(requiredBenefits,rl[0]+'_Member',accountDetails.recordTypeName);
                    Set<String> bnfts1 = getRoleTierSpecificBenefits(requiredBenefits,rl[0]+'_Gold',accountDetails.recordTypeName);
                    if(bnfts!=null && bnfts.size()>0){roleSpecificBenefits.addAll(bnfts);}
                    if(bnfts1!=null && bnfts1.size()>0){roleSpecificBenefits.addAll(bnfts1);}                        
                }                
            }
            accountDetails.missedBenefits =  checkRequiredBenefits(roleSpecificBenefits, bnftsOnAccount);
            accountDetails.bnftsToBeremoved = checkExtraBenefits( roleSpecificBenefits,bnftsOnAccount);
            
            reportWrapperMap.put(id,accountDetails);
            
        }        
    }
    
    public static Set<String> getRoleTierSpecificBenefits(BnftMatrixWrapper requiredBenefits,String roleTier, String recordType){        
        Set<String> roleSpecificBenefits = new Set<String>();
        Map<String, Map<String,Set<String>>> recordTypeSpecificBenefits = recordType=='Mastered_Account'?requiredBenefits.intelAccountBenefits:requiredBenefits.opidAccountBenefits;
        if(recordTypeSpecificBenefits.containsKey(roleTier)) {
            Map<String, Set<String>> recordSpecificBnft = recordTypeSpecificBenefits.get(roleTier);//.containsKey('Mastered_Account');
            if(recordSpecificBnft.containsKey(recordType)){
                roleSpecificBenefits = recordSpecificBnft.get(recordType);
            }
        }
        System.debug('roleSpecificBenefits -->'+JSON.serialize(roleSpecificBenefits));
        return roleSpecificBenefits;
    }
    
    // check if records are there as per benefit matrix  
    public static Set<String> checkRequiredBenefits( Set<String> roleSpecificBenefits, List<PRM_AccountBenefitAssociation__c> bnftsOnAccount){
        Set<String> missingBenefits = new Set<String>();
        set<String> bnftsOnAcctNames = new Set<String>();
        if(bnftsOnAccount!=null && bnftsOnAccount.size()>0){
            for(PRM_AccountBenefitAssociation__c bnft : bnftsOnAccount){
                
                bnftsOnAcctNames.add(bnft.PRM_Partner_Benefit_Id__r.Name);
                
            }   
        }
        
        if(roleSpecificBenefits!=null && roleSpecificBenefits.size()>0){
            for( String reqBnft : roleSpecificBenefits){
                //reqBnft +='_Automatic';
                if(reqBnft.contains('_Automatic')){
                    reqBnft = reqBnft.split('_')[0];
                    if(bnftsOnAcctNames!=null && !bnftsOnAcctNames.isEmpty() && !bnftsOnAcctNames.contains(reqBnft)){
                        missingBenefits.add(reqBnft);
                    }
                }
                
            }
        }
	return missingBenefits;
      }
    
    // check if there are any extra benefits on the account
    public static Set<String> checkExtraBenefits( Set<String> roleSpecificBenefits, List<PRM_AccountBenefitAssociation__c> bnftsOnAccount){
        Set<String> wrongBenefits = new Set<String>();
        if(bnftsOnAccount!=null && bnftsOnAccount.size()>0){
            for( PRM_AccountBenefitAssociation__c reqBnft : bnftsOnAccount){                
                if(roleSpecificBenefits!=null && roleSpecificBenefits.size()>0 && (!roleSpecificBenefits.contains(reqBnft.PRM_Partner_Benefit_Id__r.Name+'_Automatic') && !roleSpecificBenefits.contains(reqBnft.PRM_Partner_Benefit_Id__r.Name+'_Manual'))){
                    wrongBenefits.add(reqBnft.PRM_Partner_Benefit_Id__r.Name);
                }
            }
        }
	return wrongBenefits;
    }
    
    
    //Query on Bnft Matrix to check for beneiftis
    @AuraEnabled(cacheable=true)
    public static BnftMatrixWrapper getRequiredBenefits(){
        // key will have partner role tier and inside map key will be account type
        Map<String, Map<String,Set<String>>> opidAccountBenefits = new Map<String, Map<String,Set<String>>>();
        Map<String, Map<String,Set<String>>> intelAccountBenefits = new Map<String, Map<String,Set<String>>>();
        
        for(PRM_VXBnftMatrix__c vxBnftRecord : [select PRM_Partner_Benefit_Id__r.Name, PRM_Partner_Benefit_Id__r.PRM_Account_Type_Nm__c,PRM_Approval_Type_Nm__c, PRM_Channel_Program_Id__r.Name, toLabel(PRM_Partner_Role_Nm__c),PRM_Channel_Program_Level_Id__r.Name from PRM_VXBnftMatrix__c where PRM_Channel_Program_Id__r.Name	='Intel Partner Alliance' and PRM_IsActive_Ind__c=true]){
            String accountType = vxBnftRecord.PRM_Partner_Benefit_Id__r.PRM_Account_Type_Nm__c;
            String roleTier = vxBnftRecord.PRM_Partner_Role_Nm__c+'_'+vxBnftRecord.PRM_Channel_Program_Level_Id__r.Name;
            String bnftName = vxBnftRecord.PRM_Partner_Benefit_Id__r.Name+'_'+vxBnftRecord.PRM_Approval_Type_Nm__c;
            if(accountType =='Mastered_Account' || accountType =='Both'){ 
                String newAccountType = 'Mastered_Account';
                if(!intelAccountBenefits.isEmpty() && intelAccountBenefits.containsKey(roleTier)){
                    if(intelAccountBenefits.get(roleTier).containsKey(newAccountType)){
                        intelAccountBenefits.get(roleTier).get(newAccountType).add(bnftName);
                    }else{
                        intelAccountBenefits.get(roleTier).put(newAccountType, new Set<String>{bnftName});
                    }
                }else{                    
                    intelAccountBenefits.put(roleTier,new Map<String, Set<String>>{newAccountType=>new Set<String>{bnftName}});
                }
            }
            if(accountType =='Core_Partner_Account_Group' || accountType =='Both'){
                String newAccountType = 'Core_Partner_Account_Group';
                if(!opidAccountBenefits.isEmpty() && opidAccountBenefits.containsKey(roleTier)){
                    if(opidAccountBenefits.get(roleTier).containsKey(newAccountType)){
                        opidAccountBenefits.get(roleTier).get(newAccountType).add(bnftName);
                    }else{
                        opidAccountBenefits.get(roleTier).put(newAccountType, new Set<String>{bnftName});
                    }
                }else{                    
                    opidAccountBenefits.put(roleTier,new Map<String, Set<String>>{newAccountType=>new Set<String>{bnftName}});
                }
            }
        }
        
        BnftMatrixWrapper bmw = new BnftMatrixWrapper();
        bmw.opidAccountBenefits = opidAccountBenefits;
        bmw.intelAccountBenefits = intelAccountBenefits;
        return bmw;
        
    }
    
    public class BnftMatrixWrapper{
        @AuraEnabled public Map<String, Map<String,Set<String>>> opidAccountBenefits{get;set;}
        @AuraEnabled public Map<String, Map<String,Set<String>>> intelAccountBenefits{get;set;}
    }
    public class BnftWrapper{
        public Map<String, Set<String>> missingBenefits{get;set;}
        public Map<String, Set<String>> wrongBenefits{get;set;}
        
    }
    
    public class BenefitMismatchReportWrapper{
        @AuraEnabled public String accountName{get;set;}
        @AuraEnabled public Set<BnftWrapper> benefitsResult {get;set;}       
        
    }
    
    public class ReportWrapper{
        
        @AuraEnabled public String accountId{get;set;}
        @AuraEnabled public String recordTypeName{get;set;}
        @AuraEnabled public string onePartnerId{get;set;}
        @AuraEnabled public string onePartnerName{get;set;}
        @AuraEnabled public List<String> role{get;set;}
        @AuraEnabled public List<String> tier{get;set;}
        @AuraEnabled public Set<String> roleTier{get;set;}
        @AuraEnabled public String accountName{get;set;}
        @AuraEnabled public Set<String> missedBenefits{get;set;}
        @AuraEnabled public Set<String> bnftsToBeremoved{get;set;}
        @AuraEnabled public List<PRM_AccountBenefitAssociation__c> benefitsOnAccount{get;set;}
    }
    
}