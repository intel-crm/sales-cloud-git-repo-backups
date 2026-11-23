public with sharing class hierarchySample {
    
    @AuraEnabled
    public static String getTreeData(){
        
//userInfoWrapper userInfoWrap = new userInfoWrapper();
        
        // Map of intel acc Id to Tv accs
        Map<Id,List<Account>> mapSample1 = new Map<Id,List<Account>>();
        
        Id usrId = UserInfo.getUserId();
            
		user userRecord = [select id, Name, Contact.Account.Name from user where id =:usrId];           
            
        //Intel Account Id
        account accRecord = [select id, name from account where id = '001g000002AT2MVAA1'];	
        //account accRecord = [select id from account where id =: userRecord.Contact.Account.Id];
        
        //List of Top Virtual Accounts
        List<account> accList = [select id, Name from account where Core_MDF_Parent_Fund_Account__c  =: accRecord.Id];
        
        //map of TV acc Id to N1 accs
        Map<Id,List<Account>> mapSample2 = new Map<Id,List<Account>>();
        
        //map of N1 acc Id to N2 accs
        Map<Id,List<Account>> mapSample3 = new Map<Id,List<Account>>();
        
        mapSample1.put(accRecord.Id,accList);
        
        for(Account a:accList){
            List<Account> accList1 = [select id, Name from account where Core_MDF_Parent_Fund_Account__c  =: a.Id];
            mapSample2.put(a.Id,accList1);
        	
            for(Account acc:accList1){
				List<Account> accList2 = [select id, Name from account where Core_MDF_Parent_Fund_Account__c  =: acc.Id];
            	mapSample3.put(acc.Id,accList2);           
        	}
        }
        
        //userInfoWrap.mapOfIntelAccountIdToTVAccountList = mapSample1;
        //userInfoWrap.mapOfTVAccountIdToN1AccountList = mapSample2;
        //userInfoWrap.mapOfN1AccountIdToN2AccountList = mapSample3;
//
        //List<Account> accs = [Select Id , Name,(Select Id , Name from Contacts) from Account];
        //Map<Id , Contact> opps =new Map<Id , Contact>( [Select Id , Name,(Select Id ,Name From Opportunities) from Contact]);
        
        List<AccountWrapper> aooo = new List<AccountWrapper>();
        for(Account a : accList){
            AccountWrapper aWraper = new AccountWrapper() ; 
            aWraper.name =a.Name ;
            aWraper.label =a.Name ;
            aWraper.expanded =true ;
            List<Items> co = new List<Items>();
            for(Account c : mapSample2.get(a.Id)){
                Items conWrapp = new Items();
                conWrapp.name =c.Name ;
                conWrapp.label =c.Name ;
                conWrapp.expanded =true ;
                
                List<Items> wrapperOooo = new List<Items>();
                for(Account o : mapSample3.get(c.Id)){
                    Items ooo = new Items(); 
                    ooo.name = o.Name ;
                    ooo.label = o.Name ;
                    ooo.expanded = true ;
                    wrapperOooo.add(ooo);
                }
                
                conWrapp.items =wrapperOooo ;
                co.add(conWrapp);
            }
            aWraper.items = co;
            aooo.add(aWraper);
            
        }
        system.debug('aooo::'+aooo);
        system.debug('JSON.serializePretty(aooo)::'+JSON.serializePretty(aooo));
        system.debug('JSON.serialize(aooo)::'+JSON.serialize(aooo));

        return JSON.serializePretty(aooo) ;
    } 
    
    public Class AccountWrapper{
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled
        public Boolean expanded {get;set;}
        @AuraEnabled
        public List<Items> items {get;set;}
        
    }
    public Class Items{
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled
        public Boolean expanded {get;set;}
        @AuraEnabled
        public List<Items> items {get;set;}
    }
    
    /*
  
    @AuraEnabled(cacheable = true)
    public static userInfoWrapper fetchAccountHierarchy(Id accountId){
        
        userInfoWrapper userInfoWrap = new userInfoWrapper();
        
        // Map of intel acc Id to Tv accs
        Map<Id,List<Account>> mapSample1 = new Map<Id,List<Account>>();
        
        Id usrId = UserInfo.getUserId();
            
		user userRecord = [select id, Name, Contact.Account.Name from user where id =:usrId];           
            
        //Intel Account Id
        account accRecord = [select id from account where id =: userRecord.Contact.Account.Id];
        
        //List of Top Virtual Accounts
        List<account> accList = [select id, Name from account where Core_MDF_Parent_Fund_Account__c  =: accRecord.Id];
        
        //map of TV acc Id to N1 accs
        Map<Id,List<Account>> mapSample2 = new Map<Id,List<Account>>();
        
        //map of N1 acc Id to N2 accs
        Map<Id,List<Account>> mapSample3 = new Map<Id,List<Account>>();
        
        mapSample1.put(accRecord.Id,accList);
        
        for(Account a:accList){
            List<Account> accList1 = [select id, Name from account where Core_MDF_Parent_Fund_Account__c  =: a.Id];
            mapSample2.put(a.Id,accList1);
        	
            for(Account acc:accList1){
				List<Account> accList2 = [select id, Name from account where Core_MDF_Parent_Fund_Account__c  =: acc.Id];
            	mapSample3.put(acc.Id,accList2);           
        	}
        }
        
        userInfoWrap.mapOfIntelAccountIdToTVAccountList = mapSample1;
        userInfoWrap.mapOfTVAccountIdToN1AccountList = mapSample2;
        userInfoWrap.mapOfN1AccountIdToN2AccountList = mapSample3;
        
        return userInfoWrap; */
        
        /*List<String> accountList = new list<String>();
        
        Account accountRecord = [Select Id, Core_MDF_Parent_Fund_Account__r.Id, 
                                        Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Id, 
                                        Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Id, 
                                 		Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Id,
                                        Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Id  
                                        From Account where id =: accountId];
        if(accountRecord.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Id != null){
            accountList.add(accountRecord.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.name);
        }
        if(accountRecord.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Id != null){
            accountList.add(accountRecord.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.name);
        }
        if(accountRecord.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Id != null){
            accountList.add(accountRecord.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.name);
        }
        if(accountRecord.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Id != null){
            accountList.add(accountRecord.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.name);
        }
        if(accountRecord.Core_MDF_Parent_Fund_Account__r.Id != null){
            accountList.add(accountRecord.Core_MDF_Parent_Fund_Account__r.name);
        }
        return accountList;*/
   // }
    
   /* public class userInfoWrapper{
        @AuraEnabled
        public Map<Id,List<Account>> mapOfIntelAccountIdToTVAccountList;
        @AuraEnabled
        public Map<Id,List<Account>> mapOfTVAccountIdToN1AccountList;
        @AuraEnabled
        public Map<Id,List<Account>> mapOfN1AccountIdToN2AccountList;
    }*/
    
}