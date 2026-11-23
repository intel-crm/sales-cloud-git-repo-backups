trigger Core_UpdateIndirectAccountContact on AccountContactRelation (After insert,After Update) {
       
     Map<Id, Id> contactsByAccount = new Map<Id, Id>();
     Set<id> contactIds = new Set<id>();
     List<contact> contList = new List<contact>();
     
     for(AccountContactRelation Acccon: Trigger.new){
       if(Acccon.Isdirect == false){
          contactIds.add(Acccon.ContactId);
          contactsByAccount.put(Acccon.ContactId,Acccon.AccountId);
        }
     }
     
     for(contact cont:[SELECT Id,AccountId from contact where Id =: contactIds]){
        If(contactsByAccount.get(cont.Id) != null){
            cont.Indirect_Account__c = contactsByAccount.get(cont.Id);
            contList.add(cont);
        }
     }
     if(contList != Null){
        update contList;
     }
     
     
      
  
}