trigger Core_PortalUser_Deactive_Trigger on User (before update) {
    
    if(Trigger.isBefore && Trigger.isUpdate){
        Map<Id, User> oldUserMap = Trigger.oldMap;
        Set<String> setContactIdOfUsers = new Set<String>();
        for (User usr : Trigger.new){
            if(usr.IsPortalEnabled){
                setContactIdOfUsers.add(usr.ContactId);
            }
        }
        
        Map<Id, Contact> mapContactIdWithContact = new Map<Id, Contact>([Select Id, Core_Enterprise_Id__c From Contact Where Id IN: setContactIdOfUsers]);
        
        for(User usr: Trigger.new){
            User oldUser = oldUserMap.get(usr.Id);
            if(oldUser.IsActive != usr.IsActive && !usr.IsActive && usr.IsPortalEnabled && mapContactIdWithContact.get(usr.ContactId).Core_Enterprise_Id__c != usr.FederationIdentifier){
               // usr.IsPortalEnabled = false;
               // usr.FederationIdentifier = null;
            }
        }
    }
}