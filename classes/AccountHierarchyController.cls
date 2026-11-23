public class AccountHierarchyController {
  /*  @AuraEnabled  
    public static List<items> getAccountHierarchy(Id accountId) {  
        
        //Wrapper instance  
        List<items> finalWrp = new List<items>();  
        
        //Going upto 2 level only as per SOQL limit  
        for(Account acc : [ Select Id, Name, Type, ParentId, Parent.Name, Parent.Type, Parent.ParentId, Parent.Parent.Name, Parent.Parent.Type From Account Where Id =: accountId]) {  
            
            //populating wrapper  
            List<items> trP1 = new List<items>{new items(acc.Type, acc.Name, false, null)};  
            List<items> trP2 = new List<items>{new items(acc.Parent.Type, acc.Parent.Name, false, trP1)};  
            finalWrp.add(new items(acc.Parent.Parent.Type, acc.Parent.Parent.Name, false, trP2));  
        }             
        
        System.debug('finalWrp:::' + finalWrp);  
        // return wrapper  
        return finalWrp;    
    }  */
    
    @AuraEnabled
    public static list<wrapperclass> fetchAccounts()
    {
        wrapperclass[] wrapperlist = new List<wrapperclass>();
       
        list<Account> acctlsts=[select id,name,Parentid,Core_MDF_CoMarketingActive__c,Site,BillingState,Phone,Type,Owner.Alias from Account where recordtype.id='012o0000000GlzTAAS' and Core_MDF_CoMarketingActive__c=true ORDER BY Name ASC];
        System.debug('*******List of account-  '+acctlsts);
        for(Account acc:acctlsts)
        {
            List<Childwrap> proddetailslistobj = new List<Childwrap>();
            list<Account> chldacctlsts=[Select Id,Name,Parentid,Core_MDF_CoMarketingActive__c,Site,BillingState,Phone,Type,Owner.Alias From Account where recordtype.id=:'0121J000000yaFXQAY' and ParentId=:acc.id ORDER BY Name ASC];
            
            for(Account cacc:chldacctlsts)
            {
                list<Account> subchldacctlsts=[Select Id,Name,Parentid,Core_MDF_CoMarketingActive__c,Site,BillingState,Phone,Type,Owner.Alias From Account where recordtype.id=:'0121J000000yaFXQAY' and ParentId=:cacc.id ORDER BY Name ASC];
            
                Childwrap c = new Childwrap();
                c.chacc=cacc;
                c.subchldacclist=subchldacctlsts;
                proddetailslistobj.add(c);                
            }
            
            wrapperclass s = new wrapperclass();
            s.acc=acc;
            s.chldlistobj = proddetailslistobj;
            wrapperlist.add(s);
        }
         
       return wrapperlist;
    }
    
    @AuraEnabled
    public static List<account> fetchchildaccs(String accid)
    {
        List<Account> accs=[Select Id,Name From Account where recordtype.name=:'Core_MDF_Co_Marketing' and ParentId=:accid ORDER BY Name ASC];
        return accs;
    }
    
    public class wrapperclass
    {
        @AuraEnabled public Account acc{get;set;}
        @AuraEnabled public List<Childwrap> chldlistobj   {get;set;}
       
        public wrapperclass()
        {
            acc = new account();
        }
    }
    
    public class Childwrap{
        @AuraEnabled  public Account chacc{get;set;}
        //@AuraEnabled public integer childkssizee{get;set;}
        //@AuraEnabled public Accountchildtakk {get;set;}
            @AuraEnabled public list<account> subchldacclist{get;set;}
        
        public Childwrap() 
        {
           // childkssizee = 0;
            subchldacclist = new list<account>();
        }
    }
}