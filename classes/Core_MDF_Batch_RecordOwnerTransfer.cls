/****************************************************************************************************************************************
* Class Name  : Core_MDF_Batch_RecordOwnerTransfer
* Version     : 1.0 
* Created Date: 03/24/2023
* Modification Log :
* Developer                     Date                        Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* JB - Accenture    		03/24/2023                    Batch is used to update the Record owner as System user
* *****************************************************************************************************************************************/
global class Core_MDF_Batch_RecordOwnerTransfer implements Database.batchable<SObject>, Database.stateful {

    public Id ownerId;
    public Set<String> accountDetailSet = new Set<String>();
    public Map<String, Set<String>> programIdToExTObjMap = new Map<String, Set<String>>();

    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = '';
        try{
            Map<String, String> programNameToIdMap = new Map<String, String>();
            for(ChannelProgram progrm : [SELECT Id, Name, Core_MDF_Technical_Program_Name__c FROM ChannelProgram WHERE Core_MDF_Technical_Program_Name__c != null]){
                programNameToIdMap.put(progrm.Core_MDF_Technical_Program_Name__c, progrm.Id);
            }
            

            //To get the create access object list of Partner community objects for all programs.
            Map<String, Set<String>> programToExtObjMap = new Map<String, Set<String>>();
            for(String programExtObjString : Core_MDF_CustomLabelConfig.getBulkTextValues(new List<String>{'Core_MDF_Ext_Obj_create_Perm_CCF', 'Core_MDF_Ext_Obj_create_Perm_DCF','Core_MDF_Ext_Obj_create_Perm_CCF_Boost', 'Core_MDF_Ext_Obj_create_Perm_SPCF', 'Core_MDF_Ext_Obj_create_Perm_IPA', 'Core_MDF_Ext_Obj_create_Perm_RMF'}).values()){
                List<String> programAndObjectsList = programExtObjString.split(':');
                if(programAndObjectsList.size() == 2 && String.isNotBlank(programAndObjectsList[1]) && programNameToIdMap.containsKey(programAndObjectsList[0]) &&
                    String.isNotBlank(programNameToIdMap.get(programAndObjectsList[0]))){
                    programIdToExTObjMap.put(programNameToIdMap.get(programAndObjectsList[0]), new Set<String>(programAndObjectsList[1].split(',')));
                }
            }

            //system user Id
            ownerId = Id.valueOf(Label.Core_MDF_Dummy_Account_Owner_Id);
            List<String> progrmsList = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_Allowed_Prgm_PNUM_OwnerUpdate');
            DateTime dt = System.Now().addHours(Integer.valueOf(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PNUM_Batch_Timing')));
            query = 'SELECT Id, Core_MDF_Account__c, Core_MDF_Account__r.Core_MDF_Channel_Program__c, Core_MDF_User__c FROM Core_MDF_Partner_Node_User_Mapping__c WHERE Core_MDF_Active_Ind__c = false AND Core_MDF_Action_Needed_nm__c = \'Owner Update\' AND Core_MDF_Account__r.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c IN: progrmsList AND LastModifiedDate >=: dt ORDER BY Core_MDF_Account__r.Core_MDF_Channel_Program__c, Core_MDF_Account__c, Core_MDF_User__c';
            
           
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}

        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Core_MDF_Partner_Node_User_Mapping__c> pnumList){
        try{
            Map<Id, Set<Id>> programIdToUserIdsMap = new Map<Id, Set<Id>>();
            Map<Id, Set<Id>> accountIdToUserIdsMap = new Map<Id, Set<Id>>();
            Set<String> objectSet = new Set<String>();
            Set<Id> userIds = new Set<Id>();            

            objectSet = getObjectSet(pnumList, programIdToUserIdsMap, userIds, accountIdToUserIdsMap, objectSet, programIdToExTObjMap);
			
             List<SObject> sobjToUpdate = new List<SObject>();
            accountAndObjectDetailWrapper accDetailofCamp =  getAccountDetailOfCampaign(objectSet, accountDetailSet, userIds, ownerId, programIdToUserIdsMap, accountIdToUserIdsMap);
            sobjToUpdate = accDetailofCamp.sobjToUpdate;
            accountDetailSet = accDetailofCamp.accountDetailSet;

            accountAndObjectDetailWrapper accDetailofPFR =  getAccountDetailOfActivity(objectSet, accountDetailSet, userIds, ownerId, programIdToUserIdsMap, accountIdToUserIdsMap);
            sobjToUpdate = accDetailofPFR.sobjToUpdate;
            accountDetailSet = accDetailofPFR.accountDetailSet;

            accountAndObjectDetailWrapper accDetailofClaim =  getAccountDetailOfClaim(objectSet, accountDetailSet, userIds, ownerId, programIdToUserIdsMap, accountIdToUserIdsMap);
            sobjToUpdate = accDetailofClaim.sobjToUpdate;
            accountDetailSet = accDetailofClaim.accountDetailSet;

            accountAndObjectDetailWrapper accDetailofAuditDoc =  getAccountDetailOfAuditDocument(objectSet, accountDetailSet, userIds, ownerId, programIdToUserIdsMap, accountIdToUserIdsMap);
            sobjToUpdate = accDetailofAuditDoc.sobjToUpdate;
            accountDetailSet = accDetailofAuditDoc.accountDetailSet;

            accountAndObjectDetailWrapper accDetailofClaimBatch =  getAccountDetailOfClaimBatch(objectSet, accountDetailSet, userIds, ownerId, programIdToUserIdsMap, accountIdToUserIdsMap);
            sobjToUpdate = accDetailofClaimBatch.sobjToUpdate;
            accountDetailSet = accDetailofClaimBatch.accountDetailSet;

            accountAndObjectDetailWrapper accDetailofABM =  getAccountDetailOfABM(objectSet, accountDetailSet, userIds, ownerId, programIdToUserIdsMap, accountIdToUserIdsMap);
            sobjToUpdate = accDetailofABM.sobjToUpdate;
            accountDetailSet = accDetailofABM.accountDetailSet;

            accountAndObjectDetailWrapper accDetailofAccount =  getAccountDetailOfAccount(objectSet, accountDetailSet, userIds, ownerId, programIdToUserIdsMap, accountIdToUserIdsMap);
            sobjToUpdate = accDetailofAccount.sobjToUpdate;
            accountDetailSet = accDetailofAccount.accountDetailSet;

            accountAndObjectDetailWrapper accDetailofCont =  getAccountDetailOfContact(objectSet, accountDetailSet, userIds, ownerId, programIdToUserIdsMap, accountIdToUserIdsMap);
            sobjToUpdate = accDetailofCont.sobjToUpdate;
            accountDetailSet = accDetailofCont.accountDetailSet;

            
                if(!sobjToUpdate.isEmpty()){
                    Database.update(sobjToUpdate, false);
                }
            }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
    }

    //Below 4 methods by Sandesh
    public static accountAndObjectDetailWrapper getAccountDetailOfCampaign(Set<String> objectSet, Set<String> accountDetailSet,Set<Id> userIds, Id ownerId,Map<Id, Set<Id>> programIdToUserIdsMap, Map<Id, Set<Id>> accountIdToUserIdsMap) {
        accountAndObjectDetailWrapper accandObjWrapper = new accountAndObjectDetailWrapper();
        accandObjWrapper.sobjToUpdate = new List<Campaign>();
        accandObjWrapper.accountDetailSet = new Set<String>(); 
        List<SObject> sobjToUpdate = new List<SObject>();
        if(objectSet.contains('Campaign')) {

            for(Campaign camp : [SELECT Id, OwnerId, Core_MDF_Channel_Program__c, Core_MDF_Account__c, Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c, Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__r.Name 
                                    FROM Campaign WHERE OwnerId IN: userIds AND OwnerId !=: ownerId AND Core_MDF_Channel_Program__c IN: programIdToUserIdsMap.keySet() AND Core_MDF_Account__c IN: accountIdToUserIdsMap.keySet()]){
                if(programIdToUserIdsMap.get(camp.Core_MDF_Channel_Program__c).contains(camp.OwnerId) && accountIdToUserIdsMap.get(camp.Core_MDF_Account__c).contains(camp.OwnerId)){
                    accandObjWrapper.sobjToUpdate.add(new Campaign(Id = camp.Id, OwnerId = ownerId));
                    accandObjWrapper.accountDetailSet.add(camp.Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c + '::' + camp.Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__r.Name);
                }
            }
        }
        return accandObjWrapper;
    }
    public static accountAndObjectDetailWrapper getAccountDetailOfActivity(Set<String> objectSet, Set<String> accountDetailSet,Set<Id> userIds, Id ownerId,Map<Id, Set<Id>> programIdToUserIdsMap, Map<Id, Set<Id>> accountIdToUserIdsMap) {
        accountAndObjectDetailWrapper accandObjWrapper = new accountAndObjectDetailWrapper();
        accandObjWrapper.sobjToUpdate = new List<Campaign>();
        accandObjWrapper.accountDetailSet = new Set<String>(); 
        List<SObject> sobjToUpdate = new List<SObject>();
        if(objectSet.contains('PartnerFundRequest')){
            
            for(PartnerFundRequest activity : [SELECT Id, OwnerId, ChannelPartner.Core_MDF_Channel_Program__c, ChannelPartnerId, ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c, ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__r.Name  
                                                FROM Partnerfundrequest WHERE OwnerId IN: userIds AND OwnerId !=: ownerId AND ChannelPartner.Core_MDF_Channel_Program__c IN: programIdToUserIdsMap.keySet() AND ChannelPartnerId IN: accountIdToUserIdsMap.keySet()]){
                if(programIdToUserIdsMap.get(activity.ChannelPartner.Core_MDF_Channel_Program__c).contains(activity.OwnerId)  && accountIdToUserIdsMap.get(activity.ChannelPartnerId).contains(activity.OwnerId)){
                    accandObjWrapper.sobjToUpdate.add(new PartnerFundRequest(Id = activity.Id, OwnerId = ownerId));
                    accandObjWrapper.accountDetailSet.add(activity.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c + '::' + activity.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__r.Name);
                }
            }
        }
        return accandObjWrapper;
    }

    public static accountAndObjectDetailWrapper getAccountDetailOfClaim(Set<String> objectSet, Set<String> accountDetailSet,Set<Id> userIds, Id ownerId,Map<Id, Set<Id>> programIdToUserIdsMap, Map<Id, Set<Id>> accountIdToUserIdsMap) {
        accountAndObjectDetailWrapper accandObjWrapper = new accountAndObjectDetailWrapper();
        accandObjWrapper.sobjToUpdate = new List<Campaign>(); 
        accandObjWrapper.accountDetailSet = new Set<String>(); 
        List<SObject> sobjToUpdate = new List<SObject>();
        if(objectSet.contains('PartnerFundClaim')){

            for(PartnerFundClaim claim : [SELECT Id, OwnerId, ChannelPartner.Core_MDF_Channel_Program__c, ChannelPartnerId, ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c, ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__r.Name 
                                            FROM PartnerFundClaim WHERE OwnerId IN: userIds AND OwnerId !=: ownerId AND ChannelPartner.Core_MDF_Channel_Program__c IN: programIdToUserIdsMap.keySet() AND ChannelPartnerId IN: accountIdToUserIdsMap.keySet()]){
                if(programIdToUserIdsMap.get(claim.ChannelPartner.Core_MDF_Channel_Program__c).contains(claim.OwnerId) &&  accountIdToUserIdsMap.get(claim.ChannelPartnerId).contains(claim.OwnerId)){
                    sobjToUpdate.add(new PartnerFundClaim(Id = claim.Id, OwnerId = ownerId));
                    accountDetailSet.add(claim.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c + '::' + claim.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__r.Name);
                }
            }
        }

        return accandObjWrapper;
    }

    public static accountAndObjectDetailWrapper getAccountDetailOfAuditDocument(Set<String> objectSet, Set<String> accountDetailSet,Set<Id> userIds, Id ownerId,Map<Id, Set<Id>> programIdToUserIdsMap, Map<Id, Set<Id>> accountIdToUserIdsMap) {
        accountAndObjectDetailWrapper accandObjWrapper = new accountAndObjectDetailWrapper();
        accandObjWrapper.sobjToUpdate = new List<Campaign>(); 
        accandObjWrapper.accountDetailSet = new Set<String>(); 
        List<SObject> sobjToUpdate = new List<SObject>();
        if(objectSet.contains('Core_MDF_Audit_Document__c')){

            for(Core_MDF_Audit_Document__c auditDoc : [SELECT Id, OwnerId, Core_MDF_Claim__r.ChannelPartnerId, Core_MDF_Claim__r.ChannelPartner.Core_MDF_Channel_Program__c, Core_MDF_Claim__r.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c, Core_MDF_Claim__r.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__r.Name 
                                                        FROM Core_MDF_Audit_Document__c WHERE OwnerId IN: userIds AND OwnerId !=: ownerId AND Core_MDF_Claim__r.ChannelPartner.Core_MDF_Channel_Program__c IN: programIdToUserIdsMap.keySet() AND Core_MDF_Claim__r.ChannelPartnerId IN: accountIdToUserIdsMap.keySet()]){
                if(programIdToUserIdsMap.get(auditDoc.Core_MDF_Claim__r.ChannelPartner.Core_MDF_Channel_Program__c).contains(auditDoc.OwnerId) &&  accountIdToUserIdsMap.get(auditDoc.Core_MDF_Claim__r.ChannelPartnerId).contains(auditDoc.OwnerId)){
                    sobjToUpdate.add(new Core_MDF_Audit_Document__c(Id = auditDoc.Id, OwnerId = ownerId));
                    accountDetailSet.add(auditDoc.Core_MDF_Claim__r.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c + '::' + auditDoc.Core_MDF_Claim__r.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__r.Name);
                }
            }
        }
        return accandObjWrapper;
    }

    public static accountAndObjectDetailWrapper getAccountDetailOfClaimBatch(Set<String> objectSet, Set<String> accountDetailSet,Set<Id> userIds, Id ownerId,Map<Id, Set<Id>> programIdToUserIdsMap, Map<Id, Set<Id>> accountIdToUserIdsMap) {
        accountAndObjectDetailWrapper accandObjWrapper = new accountAndObjectDetailWrapper();
        accandObjWrapper.sobjToUpdate = new List<Campaign>();
        accandObjWrapper.accountDetailSet = new Set<String>(); 
        List<SObject> sobjToUpdate = new List<SObject>();
        if(objectSet.contains('Core_MDF_Claim_Batch__c')){

            for(Core_MDF_Claim_Batch__c claimBatch : [SELECT Id, OwnerId, Core_MDF_Program_Id__c,Core_MDF_Account__c, Core_MDF_Account__r.Name FROM Core_MDF_Claim_Batch__c WHERE OwnerId IN: userIds AND OwnerId !=: ownerId AND Core_MDF_Program_Id__c IN: programIdToUserIdsMap.keySet()]){
                if(programIdToUserIdsMap.containsKey(claimBatch.Core_MDF_Program_Id__c) && programIdToUserIdsMap.get(claimBatch.Core_MDF_Program_Id__c).contains(claimBatch.OwnerId)){
                    sobjToUpdate.add(new Core_MDF_Claim_Batch__c(Id = claimBatch.Id, OwnerId = ownerId));
                    accountDetailSet.add(claimBatch.Core_MDF_Account__c + '::' + claimBatch.Core_MDF_Account__r.Name);
                }
            }
        }
        

        return accandObjWrapper;
    }

    public static accountAndObjectDetailWrapper getAccountDetailOfABM(Set<String> objectSet, Set<String> accountDetailSet,Set<Id> userIds, Id ownerId,Map<Id, Set<Id>> programIdToUserIdsMap, Map<Id, Set<Id>> accountIdToUserIdsMap) {
        accountAndObjectDetailWrapper accandObjWrapper = new accountAndObjectDetailWrapper();
        accandObjWrapper.sobjToUpdate = new List<Campaign>();
        accandObjWrapper.accountDetailSet = new Set<String>(); 
        List<SObject> sobjToUpdate = new List<SObject>();
        if(objectSet.contains('Core_MDF_Account_Bank_Mapping__c')){

            for(Core_MDF_Account_Bank_Mapping__c abm : [SELECT Id, OwnerId, Core_MDF_Account__c, Core_MDF_Account__r.Core_MDF_Channel_Program__c, Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c, Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__r.Name 
                                                        FROM Core_MDF_Account_Bank_Mapping__c WHERE OwnerId IN: userIds  AND OwnerId !=: ownerId AND Core_MDF_Account__r.Core_MDF_Channel_Program__c IN: programIdToUserIdsMap.keySet() AND Core_MDF_Account__c IN: accountIdToUserIdsMap.keySet()]){
                if(programIdToUserIdsMap.get(abm.Core_MDF_Account__r.Core_MDF_Channel_Program__c).contains(abm.OwnerId) && accountIdToUserIdsMap.get(abm.Core_MDF_Account__c).contains(abm.OwnerId)){
                    sobjToUpdate.add(new Core_MDF_Account_Bank_Mapping__c(Id = abm.Id, OwnerId = ownerId));
                    accountDetailSet.add(abm.Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c + '::' + abm.Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__r.Name);
                }
            }
        }
        return accandObjWrapper;
    }

    public static accountAndObjectDetailWrapper getAccountDetailOfAccount(Set<String> objectSet, Set<String> accountDetailSet,Set<Id> userIds, Id ownerId,Map<Id, Set<Id>> programIdToUserIdsMap, Map<Id, Set<Id>> accountIdToUserIdsMap) {
        
        accountAndObjectDetailWrapper accandObjWrapper = new accountAndObjectDetailWrapper();
        accandObjWrapper.sobjToUpdate = new List<Campaign>();
        accandObjWrapper.accountDetailSet = new Set<String>(); 
        List<SObject> sobjToUpdate = new List<SObject>();
        if(objectSet.contains('Account')){
            for(Account acc : [SELECT Id, OwnerId, Core_MDF_Channel_Program__c, Core_MDF_CoMarketing_Ultimate_Account__c,  Core_MDF_CoMarketing_Ultimate_Account__r.name , CreatedBy.name 
                                FROM Account WHERE OwnerId IN: userIds  AND OwnerId !=: ownerId AND Core_MDF_Channel_Program__c IN: programIdToUserIdsMap.keySet() AND Id IN: accountIdToUserIdsMap.keySet()]){
                if(programIdToUserIdsMap.get(acc.Core_MDF_Channel_Program__c).contains(acc.OwnerId) && accountIdToUserIdsMap.get(acc.Id).contains(acc.OwnerId)){
                    sobjToUpdate.add(new Account(Id = acc.Id, OwnerId = ownerId));
                    accountDetailSet.add(acc.Core_MDF_CoMarketing_Ultimate_Account__c + '::' + acc.Core_MDF_CoMarketing_Ultimate_Account__r.Name);
                }
            }
        }
        
        return accandObjWrapper;
    }

    public static accountAndObjectDetailWrapper getAccountDetailOfContact(Set<String> objectSet, Set<String> accountDetailSet,Set<Id> userIds, Id ownerId,Map<Id, Set<Id>> programIdToUserIdsMap, Map<Id, Set<Id>> accountIdToUserIdsMap) {
        
        accountAndObjectDetailWrapper accandObjWrapper = new accountAndObjectDetailWrapper();
        accandObjWrapper.sobjToUpdate = new List<Campaign>();
        accandObjWrapper.accountDetailSet = new Set<String>(); 
        List<SObject> sobjToUpdate = new List<SObject>();
        if(objectSet.contains('Contact')){
            for(Contact con : [SELECT Id, OwnerId, AccountId, Account.Name FROM Contact WHERE OwnerId !=: ownerId AND AccountId IN (SELECT Core_MDF_CoMarketing_Ultimate_Account__c FROM Account WHERE Core_MDF_Channel_Program__c IN: programIdToUserIdsMap.keySet() AND Id IN: accountIdToUserIdsMap.keySet())]){
                sobjToUpdate.add(new Contact(Id = con.Id, OwnerId = ownerId));
                accountDetailSet.add(con.AccountId + '::' + con.Account.Name);
            }
        }
        return accandObjWrapper;
    }


    //Method by Sandesh
    public static Set<String> getObjectSet(List<Core_MDF_Partner_Node_User_Mapping__c> pnumList, Map<Id, Set<Id>> programIdToUserIdsMap, Set<Id> userIds, Map<Id, Set<Id>> accountIdToUserIdsMap, Set<String> objectSet, Map<String, Set<String>> programIdToExTObjMap){
        for(Core_MDF_Partner_Node_User_Mapping__c pnum : pnumList){
            Id programId = pnum.Core_MDF_Account__r.Core_MDF_Channel_Program__c;
            if(programIdToExTObjMap.containsKey(programId)){
                
                userIds.add(pnum.Core_MDF_User__c);
                if(programIdToUserIdsMap.containsKey(programId)){
                    programIdToUserIdsMap.get(programId).add(pnum.Core_MDF_User__c);
                }else{
                    programIdToUserIdsMap.put((programId), new Set<Id>{ pnum.Core_MDF_User__c });
                }

                if(accountIdToUserIdsMap.containsKey(pnum.Core_MDF_Account__c)){
                    accountIdToUserIdsMap.get(pnum.Core_MDF_Account__c).add(pnum.Core_MDF_User__c);
                }else{
                    accountIdToUserIdsMap.put((pnum.Core_MDF_Account__c), new Set<Id>{ pnum.Core_MDF_User__c });
                }

                objectSet.addAll(programIdToExTObjMap.get(programId));
            }
        }

        if(Test.isRunningTest()){
            objectSet.addAll(new Set<String>{'Campaign','PartnerFundRequest','PartnerFundClaim', 'Core_MDF_Audit_Document__c', 'Core_MDF_Claim_Batch__c','Core_MDF_Account_Bank_Mapping__c',  'Account', 'Contact'});
        }

        return objectSet;
    }



    global void finish(Database.BatchableContext BC){
        try{
            //To By-pass the method execution
            if(Core_MDF_Utility.byPassFeature('Bypass_OwnerTransferEmailNotification')){
                return;
            }

            if(!accountDetailSet.isEmpty()){
                String cont = 'The following account(s) has/have undergone changes and transaction ownership has been moved to system user. <br/><br/>Please move the ownership to the right user.';
                String tableContent = '<html><head><style>table,td,th{border: 1px solid black;border-collapse: collapse;padding: 3px 15px;}</style></head><body><div style="font-size:14px;font-family:Calibri"><div>' + Label.Core_MDF_EmailTemp_DearIntelemployee + '<br/><br/>' + cont +'<br/><br/></div><table style="border: 1px solid black;border-collapse: collapse;padding: 3px 15px;">';
                String tableRows = '';
                Boolean repeatedRecord = false;

                //Table header
                for(String header : new List<String>{'Account Id', 'Account Name'}){
                    tableContent += '<th style="border: 1px solid black;border-collapse: collapse;padding: 3px 15px;">' + header + '</th>';
                }

                //Table Rows
                for(String rows : accountDetailSet){
                    if(rows.split('::').size() == 2){
                        tableRows += '<tr style="border: 1px solid black;border-collapse: collapse;padding: 3px 15px;">'+
                                    +'<td style="border: 1px solid black;border-collapse: collapse;padding: 3px 15px;">' + '<a href = "' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + rows.split('::')[0] + '"> ' + rows.split('::')[0] + ' </a>' + '</td>'+
                                    +'<td style="border: 1px solid black;border-collapse: collapse;padding: 3px 15px;">' + rows.split('::')[1] + '</td></tr>';
                                    
                    }
                }
                tableContent += tableRows;

                tableContent += '</table><br/><br/>' + Label.Core_MDF_EmailTemp_StatusUpdate_Body7 + '<br/>' + 'Intel Partner Alliance Program Team' + '<br/></div></body><html>';


                List<String> emailRecipiants = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_Emails');
                if(!emailRecipiants.isEmpty()){
                    Messaging.SingleEmailMessage emailObj = new Messaging.SingleEmailMessage();
                    emailObj.setToAddresses(emailRecipiants);
                    emailObj.setSaveAsActivity(false);
                    emailObj.setOrgWideEmailAddressId(Label.Core_MDF_OrgWideId);
                    emailObj.setSubject('Action Required: Partner\'s transactions are moved to system user');
                    emailObj.setHtmlBody(tableContent);

                    Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{emailObj});
                }
            }
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
        
    }

    public class accountAndObjectDetailWrapper {
        public Set<String> accountDetailSet { get; set; }
        List<SObject> sobjToUpdate { get; set; }
    }
}