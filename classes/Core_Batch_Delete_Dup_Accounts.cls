global class Core_Batch_Delete_Dup_Accounts implements Database.Batchable<sObject> {
        Map<String,Core_ACM_Control_Execution__c> mapAcmClassCheckToEol = Core_ACM_Control_Execution__c.getAll();
        global Database.QueryLocator start(Database.BatchableContext bc) {
            if(mapAcmClassCheckToEol.containsKey('Delete_Dup_Accounts') && mapAcmClassCheckToEol.get('Delete_Dup_Accounts').IsActive__c) {
                // Pull campaign members for the campaign(s) flagged for batch generation
                Database.QueryLocator duplicateAccounts = Database.getQueryLocator(
                    [SELECT ID, Name FROM Account WHERE Core_Is_Duplicate__c != null AND CreatedById = :System.Label.Core_CRM_Integration_User_ID AND  Core_Covered_Account__c = false]);
                return duplicateAccounts;
            }
            else
            { 
                return Database.getQuerylocator('');    
            }
        }
        
        global void execute(Database.BatchableContext bc, List<Account> duplicateAccounts) {
            Set<Id> duplicateAccountsId = (new Map<Id,SObject>(duplicateAccounts)).keySet();
            System.Debug('Pre delete' + duplicateAccountsId.size() ) ;
            for(Id acId : duplicateAccountsId)
            {
                System.Debug(acId) ;
            }
            
            List<Lead> leadAccounts = [ select Id, Core_Existing_Covered_Account__c from Lead where Core_Existing_Covered_Account__c IN:duplicateAccounts];
            for(Lead acLead : leadAccounts)
            {
                duplicateAccountsId.remove(acLead.Core_Existing_Covered_Account__c) ;
                //System.Debug(acLead.Core_Existing_Covered_Account__c) ;
            }
            System.Debug('Post Lead delete' + duplicateAccountsId.size() ) ;
            
            List<Opportunity> oppAccounts = [select Id, AccountId from Opportunity where AccountId IN:duplicateAccounts];
            for(Opportunity acOpp : oppAccounts)
            {
                duplicateAccountsId.remove(acOpp.AccountId) ;
                //System.Debug(acOpp.AccountId) ;
            }
            
            System.Debug('Post Opp delete' + duplicateAccountsId.size() ) ;
            List<Core_Opportunity_Partner__c> oppPartnerAccounts = [select Id, Core_Partner__c FROM Core_Opportunity_Partner__c where Core_Partner__c IN :duplicateAccounts];
            for(Core_Opportunity_Partner__c acOppPartner : oppPartnerAccounts)
            {
                duplicateAccountsId.remove(acOppPartner.Core_Partner__c) ;
                //System.Debug(acOppPartner.Core_Partner__c) ;
            }
            
            System.Debug('Post oppPartner delete' + duplicateAccountsId.size() ) ;
            List<Contact> conAccounts = [select Id, AccountId from Contact where AccountId IN:duplicateAccounts];
            for(Contact acContact : conAccounts)
            {
                duplicateAccountsId.remove(acContact.AccountId) ;
                //System.Debug(acContact.AccountId) ;
            }
            
            System.Debug('Post Account Delete' + duplicateAccountsId.size() ) ;
            List<Core_Channel_Salesout__c> channelAccounts = [ select Id, Core_Account_Name__c from Core_Channel_Salesout__c where Core_Account_Name__c IN:duplicateAccounts];
            for(Core_Channel_Salesout__c acChannel : channelAccounts)
            {
                duplicateAccountsId.remove(acChannel.Core_Account_Name__c) ;
                //System.Debug(acChannel.Core_Account_Name__c) ;
            }
            System.Debug('Post Channel delete' + duplicateAccountsId.size() ) ;
            List<Core_Training__c> trainingAccounts = [select Id, Core_Account__c from Core_Training__c WHERE Core_Account__c IN:duplicateAccounts];
            for(Core_Training__c acTraining : trainingAccounts)
            {
                duplicateAccountsId.remove(acTraining.Core_Account__c) ;
                //System.Debug(acTraining.Core_Account__c) ;
            }
            System.Debug('Post training delete' + duplicateAccountsId.size() ) ;
            List<Core_Redemption_Points__c> rpAccounts = [select Id, Core_Account__c from Core_Redemption_Points__c WHERE Core_Account__c IN:duplicateAccounts];
            for(Core_Redemption_Points__c acRp : rpAccounts)
            {
                duplicateAccountsId.remove(acRp.Core_Account__c) ;
                //System.Debug(acRp.Core_Account__c) ;
            }
            System.Debug('Post RP delete' + duplicateAccountsId.size() ) ;
            List<ObjectTerritory2Association> otaAccounts = [ select Id, ObjectId from ObjectTerritory2Association WHERE ObjectId IN:duplicateAccounts];
            for(ObjectTerritory2Association acOta : otaAccounts)
            {
                duplicateAccountsId.remove(acOta.ObjectId) ;
                //System.Debug(acOta.ObjectId) ;
            }
            System.Debug('Post all delete' + duplicateAccountsId.size()) ;
            for(Id acId : duplicateAccountsId)
            {
                System.Debug(acId) ;
            }
            List<Id> duplicateListId = new List<Id>(duplicateAccountsId) ;        
            Database.delete(duplicateListId ,false);        
        }
        
        global void finish(Database.BatchableContext bc) {
        }
    }