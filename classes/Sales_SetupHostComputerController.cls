/*********************************************************************************************************************
Version       : 1.0
Created Date  : Apr 2021
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Shivam Vishwakarma        19-Apr-2021             salesSetupHostComputer LWC Component Controller
* ---------------------------------------------------------------------------------------------------------*/
public with sharing class Sales_SetupHostComputerController {
    /***************************************
    * Method : getUserDetails - Get User's Active Status, Contact & Account Id
    * param : uId : User Id
    * Developer : Shivam Vishwakarma
    ****************************************/
    @AuraEnabled
    public static User getUserDetails( Id uId ){     
        List<User> loggedInUserList = [SELECT Id, Email, UserType, Contact.Id, Contact.AccountId, FirstName, LastName,Country, IsActive  FROM User WHERE Id=:uId LIMIT 1];            
        if(!loggedInUserList.isEmpty() &&  loggedInUserList[0].IsActive==true && loggedInUserList[0].Contact.Id != null){
            return loggedInUserList[0];
        }
        else if(!loggedInUserList.isEmpty() && loggedInUserList[0].IsActive==true && loggedInUserList[0].UserType != System.label.Sales_PowerPartnerUserType){
            Map<String, User> emailUserIdMap = new Map<String, User>();
            emailUserIdMap.put(loggedInUserList[0].Email, loggedInUserList[0]);
            Contact con = new Contact();
            con.id = Sales_CreateLicenseContactUser_Utility.createLicenseContactUsers(emailUserIdMap);
            loggedInUserList[0].Contact = con;
            return loggedInUserList[0];
        }
        else{
            return null;
        }
    }  
    /***************************************
    * Method : getDelegateContactIds 
    * Developer : Shivam Vishwakarma
    ****************************************/
    @AuraEnabled 
    public static List<Id> getDelegateContactIds(Id primarycontactId){
        Set<Id> contactIdSet = new Set<Id>();
        List<Sales_License_Admin_Delegate__c> dlgsList = [Select Id, Sales_License_PrimaryAdmin_Contact__c, Sales_License_DlgAdmin_Contact__c, Sales_License_isActive__c 
                                                          From Sales_License_Admin_Delegate__c Where Sales_License_PrimaryAdmin_Contact__c=:primarycontactId and  Sales_License_isActive__c = true];
        for(Sales_License_Admin_Delegate__c primDlgAdmRecord : dlgsList){
            contactIdSet.add(primDlgAdmRecord.Sales_License_DlgAdmin_Contact__c);
        }
        return new List<Id>(contactIdSet);
    }
    @AuraEnabled(cacheable=true)
    public static Boolean checkLicesnseExpirationDate(Id hostId)
    {
        Boolean isExpiryDtInFuture=false;
        if(hostId!=null)
        {
            Sales_Host__c hostinfo = [SELECT Id,Sales_isActiveHost__c,(Select Id From Licenses__r limit 1) FROM Sales_Host__c where Id =:hostId];
            if(hostinfo.Licenses__r != null && hostinfo.Licenses__r.size() > 0 ) {
                if(hostinfo.Sales_isActiveHost__c==true)
                {
                    for(Sales_License__c license1:[SELECT Id,Sales_License_Expiration_Date_Dt__c,Sales_License_Host_Node_Id__c from Sales_License__c  WHERE Sales_License_Host_Node_Id__c =: hostId]) 
                    {    
                        if(license1.Sales_License_Expiration_Date_Dt__c>= System.today() || license1.Sales_License_Expiration_Date_Dt__c==null)
                        { 
                            isExpiryDtInFuture=true;
                            break;
                        }
                        else 
                        {    isExpiryDtInFuture=false;
                        }
                    }
                }
            } 
            else
            {
                isExpiryDtInFuture=false;
            }  
        }
        return isExpiryDtInFuture;  
    }
    @AuraEnabled
    public static void checkHostActivationStatus(Id HostId) 
    {    
        List<Sales_Host__c> hostList= new List<Sales_Host__c>();
        for(Sales_Host__c hostinfo:[SELECT Id,Sales_isActiveHost__c from Sales_Host__c where Id =: hostId])
        {  
            if(hostinfo.Sales_isActiveHost__c)
            {
                hostinfo.Sales_isActiveHost__c=false;
                hostList.add(hostinfo);             
            }
            else if(!hostinfo.Sales_isActiveHost__c)
            {
                hostinfo.Sales_isActiveHost__c=true;
                hostList.add(hostinfo);             
            }
        }
        if(hostList.size()>0)
        {
            update hostList;
        }
    }
}