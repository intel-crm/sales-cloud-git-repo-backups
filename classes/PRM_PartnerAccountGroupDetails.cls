public without sharing class PRM_PartnerAccountGroupDetails {
    @AuraEnabled
    public static PAGDetailsWrapper GetPAGDetails(String recordId)
    {
        PAGDetailsWrapper pag_details=new PAGDetailsWrapper();
        
        List<Account> pag_acct=new List<Account>();
        pag_acct= [Select Id,Name,ToLabel(Core_PAG_Grouping_Method__c),Phone,RecordTypeId from account where Id=:recordId]; // RecordTypeId='0126C0000000OXMQA2'
        
        //List<IntelAccountDetails> act_details=new List<IntelAccountDetails>();
        
        Set<String> intelMemberSet=new Set<String>();
        Set<Account> intelAccountsSet=new Set<Account>();
        Map<String,List<PRM_Account_Contact_Relationship__c>> relationMap=new Map<String,List<PRM_Account_Contact_Relationship__c>>();
        
        
        for(Core_Account_Group_Member__c intel_AcctMember : [SELECT Id,Name,Core_Partner_Account_Id__c, Core_Intel_Account_Id__c, Core_MDA_Ind__c, Core_Inactive_Ind__c FROM Core_Account_Group_Member__c where Core_Partner_Account_Id__c=:pag_acct[0].Id and Core_Inactive_Ind__c=false]){
            intelMemberSet.add(intel_AcctMember.Core_Intel_Account_Id__c);
            
        }
        for(Account intelAccount : [Select Id,Name,toLabel(Core_IPA_Partner_Role__c),Phone,Core_Intel_Partner_Alliance_PartnerGroup__c,RecordTypeId,BillingCountry, (SELECT Id,Name,FirstName, LastName, Email,toLabel(Core_IPA_PartnerRole__c) FROM Contacts) from Account where Id in :intelMemberSet]){
            intelAccountsSet.add(intelAccount);
            
        }
        for(PRM_Account_Contact_Relationship__c acr:[Select PRM_Relationship_Id__r.Name,PRM_Account_Id__c,PRM_Contact_Id__c FROM PRM_Account_Contact_Relationship__c where PRM_Account_Id__c in:intelMemberSet])
        {
            
            if(relationMap.containsKey(acr.PRM_Account_Id__c)) {
                List<PRM_Account_Contact_Relationship__c> acctRelationList = relationMap.get(acr.PRM_Account_Id__c);
                acctRelationList.add(acr);
                relationMap.put(acr.PRM_Account_Id__c, acctRelationList);
            } 
            else {
                relationMap.put(acr.PRM_Account_Id__c, new List<PRM_Account_Contact_Relationship__c> { acr });
            }
            
            
        }
       
        for(Account acc:intelAccountsSet)
        {
            IntelAccountDetails act_detail=new IntelAccountDetails();
            act_detail.Id=acc.Id;
            act_detail.Name=acc.Name;
            act_detail.PartnerRole=acc.Core_IPA_Partner_Role__c;
            act_detail.Phone=acc.Phone;
            act_detail.IPAAccount=acc.Core_Intel_Partner_Alliance_PartnerGroup__c;
            act_detail.Address =  acc.BillingCountry;
            List<ContactDetail> contactDetails=new List<ContactDetail>();
            for(Contact c:acc.Contacts)
            {
                ContactDetail cnt_detail=new ContactDetail();
                cnt_detail.Id=c.Id;
                cnt_detail.Name=c.Name;
                cnt_detail.Email=c.Email;
                cnt_detail.PartnerRole=c.Core_IPA_PartnerRole__c;
                List<PRM_Account_Contact_Relationship__c> accountAcrs=relationMap.get(acc.Id);
                cnt_detail.ContactRelationship='';
                if(accountAcrs!=null)
                {
                for (PRM_Account_Contact_Relationship__c acr: accountAcrs)
                {
                    if(acr.PRM_Contact_Id__c==c.Id)
                    {
                        if(cnt_detail.ContactRelationship=='')
                    {
                        cnt_detail.ContactRelationship=acr.PRM_Relationship_Id__r.Name;
                    }else
                    {
                        cnt_detail.ContactRelationship=cnt_detail.ContactRelationship+' , '+acr.PRM_Relationship_Id__r.Name;
                    }
                    }
                }
                }
                contactDetails.add(cnt_detail);
            }
            act_detail.cntDetails=contactDetails;
            pag_details.IntelAccounts.add(act_detail);
        }
        pag_details.PAGAccounts=pag_acct;
        return pag_details;
    }

    public class PAGDetailsWrapper
    {
        @AuraEnabled
        public List<Account> PAGAccounts=new List<Account>();
        @AuraEnabled
        public List<IntelAccountDetails> IntelAccounts=new List<IntelAccountDetails>();
    }
     
    public class IntelAccountDetails
    {   @AuraEnabled
        public String Id;
        @AuraEnabled 
        public String Name;
        @AuraEnabled
        public String PartnerRole;
         @AuraEnabled
        public Boolean IPAAccount;
        @AuraEnabled
        public String Phone;
        @AuraEnabled
        public String Address;
        @AuraEnabled
        public List<ContactDetail> cntDetails=new List<ContactDetail>();  
    }
    
    public class ContactDetail
    {
        @AuraEnabled
        public String Id;
        @AuraEnabled
        public String Name;
        @AuraEnabled
        public String Email;
        @AuraEnabled
        public String PartnerRole;
        @AuraEnabled
        public String ContactRelationship;    
    }
}