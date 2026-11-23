trigger Core_PortalUser_Deactive_Trigger on User (before update) {  
    if(Trigger.isBefore && Trigger.isUpdate){
        Map<Id, User> oldUserMap = Trigger.oldMap;
        
        for(User usr: Trigger.new){
            User oldUser = oldUserMap.get(usr.Id);
            if(oldUser.IsActive != usr.IsActive && !usr.IsActive && usr.Contact.Core_Enterprise_Id__c != usr.FederationIdentifier){
                if (usr.IsPortalEnabled){
                    usr.IsPortalEnabled = false;
                    usr.FederationIdentifier = null;
                    usr.Core_WWID__c = null;
                } 
            }
        }   
    }
}