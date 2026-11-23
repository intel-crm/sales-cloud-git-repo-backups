public without sharing class UCD_AccountDeactivation {
    //Method for Fetching the record available for deactivation
    @AuraEnabled
    public static list<Account> GetDeactivateAccts(Datetime startDate, Datetime endDate){
        List<Account> accs = new List<Account>();
        try
        {
            if(startDate > endDate)
            {
                return accs;
            }
            endDate = endDate.addDays(1);
            List<Account> acctsToDeactivate = new List<Account>();
            if (Schema.sObjectType.Account.fields.Name.isAccessible() && Schema.sObjectType.Opportunity.fields.Name.isAccessible() && Schema.sObjectType.Contact.fields.Name.isAccessible() 
                && Schema.sObjectType.AccountTeamMember.fields.AccountId.isAccessible() && Schema.sObjectType.Case.fields.AccountId.isAccessible() 
                && Schema.sObjectType.Core_Account_ERPM_Engagement__c.fields.Name.isAccessible() && Schema.sObjectType.Core_CCV__c.fields.Name.isAccessible() 
                && Schema.sObjectType.Core_MDF_Partner_Group_Mapping__c.fields.Name.isAccessible()&& Schema.sObjectType.Event.fields.AccountId.isAccessible() 
                && Schema.sObjectType.ContentDocumentLink.fields.LinkedEntityId.isAccessible())
            {    
                String iAccount = Label.PRM_Intel_Account_Record_Type;
                String uncoveredUserId = Label.Core_Uncovered_Account_ID;
                String stageLost = Label.UCD_Opportunity_Stage_Lost;
                String stageCancelled = Label.UCD_Opportunity_Stage_Cancelled;
               
                Set<Id> acctIds = new Map<Id,Account>([SELECT Id FROM Account WHERE recordtype.name =: iAccount 
                AND Core_PSG_Account__c = false AND Core_Intel_Partner_Alliance_PartnerGroup__c = false 
                AND Core_MDF_CoMarketingActive__c = false AND Core_MDF_CoMarketingAgency__c = false
                AND OwnerId =: uncoveredUserId  AND CreatedDate >: startDate AND CreatedDate <: endDate 
                AND Id NOT IN (SELECT AccountId FROM Contact) AND Id NOT IN (SELECT AccountId FROM Case)]).keySet();                

                Set<Id> noOppAccountIds = new Map<Id,Account>([SELECT Id FROM Account WHERE Id IN: acctIds AND
                Id NOT IN (SELECT AccountId FROM Opportunity)]).keySet();
                
                /* Including Accounts with Opportunity which has StageName as 'lost' and stage updated before Last Year */
                List<Opportunity> lostOpps = [SELECT Id FROM Opportunity WHERE AccountId IN:acctIds AND StageName IN (:stageLost,:stageCancelled)];
                string opptHisQuery='SELECT Id,OpportunityId, stageName FROM OpportunityHistory where OpportunityId in :lostOpps AND CreatedDate < ' + system.Label.UCD_Opportunity_Date;
                List<OpportunityHistory> opHistory= Database.query(opptHisQuery);
                Set<ID> lostOppIds = new set<ID>();
                for(OpportunityHistory oh:opHistory){
                    if(oh.stageName == stageLost || oh.stageName == stageCancelled){
                        lostOppIds.add(oh.OpportunityId);
                    }
                }
                Set<Id> lostOppAcctIds = new Map<Id,Account>([SELECT Id FROM Account WHERE Id IN (SELECT AccountId FROM Opportunity WHERE Id IN:lostOppIds)]).keySet();

                Set<Id> notInUseAccountIds = new Set<Id>();
                notInUseAccountIds.addAll(noOppAccountIds);
                notInUseAccountIds.addAll(lostOppAcctIds);

                notInUseAccountIds = new Map<Id,Account>([SELECT Id FROM Account WHERE Id IN: notInUseAccountIds AND Id NOT IN (SELECT AccountId FROM AccountTeamMember) AND Id NOT IN (SELECT Account__c FROM Account_Meeting_Brief__c)]).keySet();
                
                notInUseAccountIds = new Map<Id,Account>([SELECT Id FROM Account WHERE Id IN: notInUseAccountIds AND 
                /*Id NOT IN (SELECT Core_Partner__c FROM core_opportunity_partner__c) AND*/
                Id NOT IN (SELECT Core_Account_Id__c FROM Core_Account_ERPM_Engagement__c) AND
                Id NOT IN (SELECT Core_Account__c FROM Core_CCV__c)]).keySet(); 
                
                notInUseAccountIds = new Map<Id,Account>([SELECT Id FROM Account WHERE Id IN: notInUseAccountIds AND 
                //Id NOT IN (SELECT Account__c FROM Account_Meeting_Brief__c) AND
                /*CCF/DCF*/
                Id NOT IN (SELECT Core_MDF_Account__c FROM Core_MDF_Partner_Group_Mapping__c)]).keySet();

                List<ContentDocumentLink> noNoteAcct = [select id,LinkedEntityId from ContentDocumentLink where LinkedEntityId IN: notInUseAccountIds ];    
                 if(noNoteAcct.Size()!=0){
                     for(ContentDocumentLink n:noNoteAcct){
                        notInUseAccountIds.remove(n.LinkedEntityId);
                    }
                }
                
                List<Event> noEventAcct= [select id,AccountId from Event where AccountId IN: notInUseAccountIds ];    
                if(noEventAcct.Size()!=0){
                    for(Event e:noEventAcct){
                        notInUseAccountIds.remove(e.AccountId);
                    }
                }

                acctsToDeactivate = [SELECT Id, Name, BillingAddress, recordtype.id, Core_CIM_ID__c ,BillingStreet, 
                BillingCity, BillingState, BillingPostalCode,BillingCountry,Core_Sales_Groups__c,
                Core_Prime_Account_Name__c,Core_Geo__c,Core_Deactivation_Reason__c FROM Account WHERE Id IN: notInUseAccountIds Order by Name];
            }

            system.debug('AccountList :'+acctsToDeactivate);
            return acctsToDeactivate;
        } 
        catch(Exception e){
            
        }
        return accs;
    }

    //Method for deactivating multiple records
    @AuraEnabled
    public static string DeactivateSelectedAccts(List<account> Accts){
        string isUpdated;
        try{
            if (Schema.sObjectType.Account.fields.Name.isUpdateable()) {
                List<Account> deAccts = new List<Account>();
                for(Account de:Accts){
                    Account acc = new Account();
                    acc.id = de.Id;                
                    acc.Core_Deactivated__c = true;
                    acc.Core_Deactivation_Reason__c = Label.UCD_Account_Deactivation_Reason;//'Salesforce Cleanup ACM';
                    deAccts.add(acc);                   
                }
                update deAccts;
                isUpdated = 'yes';
            }
            else {
                isUpdated = 'No';
            }
        }
        catch(Exception e){            
            PRM_ErrorUtilityClass.logError(e);
            if(e != null){
                throw new AuraHandledException(e.getMessage());
            }
            System.debug('Exception : '+e);
        }
        return isUpdated;
    }

    //Method for deactivating single record
    @AuraEnabled
    public static string DeactivateSingleAcct(ID AcctId){
        string isUpdated;
        try{
            if (Schema.sObjectType.Account.fields.Name.isUpdateable()) {
                Account deacc = new Account();
                deacc.id = AcctId;
                deacc.Core_Deactivated__c = true;
                deacc.Core_Deactivation_Reason__c = Label.UCD_Account_Deactivation_Reason;   
                update deacc;
                isUpdated = 'yes';
            }
            else{
                isUpdated = 'No';
            }
        }
        catch(Exception e){            
            PRM_ErrorUtilityClass.logError(e);
            if(e != null){
                throw new AuraHandledException(e.getMessage());
            }
            System.debug('Exception : '+e);
        }
        return isUpdated;
    }
    
}