Public without sharing class internalUserEV {
    
    
    public Id conObj {get;set;}
    public Id requestorId {get;set;}
    Static Set<String> setEntitlementName = new Set<String>();
    
    /*
Method Name: sendEmail()
return : null
Description: This method send email to user  .*/
    
        @InvocableMethod(label='Send Notification To Requestor' description='Notify requestor on A&E grant access status' category='Contact')
    public static void sendEmail(List<Id> contactId)
    {   
        
    }
    
}