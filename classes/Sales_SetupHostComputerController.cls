/*********************************************************************************************************************
Version       : 1.0
Created Date  : Apr 2021

Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Shivam Vishwakarma        19-Apr-2021             salesSetupHostComputer LWC Component Controller
* ---------------------------------------------------------------------------------------------------------*/
@isTest
public with sharing class Sales_SetupHostComputerController {
    
    // If currently Logged In User is a Community user then only you can get the ContactId from User else it will be null for other profiles.
    
    /*
@AuraEnabled
public static List<Id> getContactIdandAccountId( Id uId ){      //uid: Logged In user's salesforce Id
List<Id> Ids = new List<Id>();
User loggedInUser = [SELECT Id, Contact.Id, Contact.AccountId FROM User WHERE Id=:uId];
if(loggedInUser.Contact.Id != null ){
Ids.add( loggedInUser.Contact.Id );
Ids.add( loggedInUser.Contact.AccountId );
system.debug( Ids );
}
return Ids;       //Returns List - [ContactId , AccountId] if User's contact id isn't null else returns an empty list.
}
*/
    
    /***************************************
* Method : getUserDetails - Get User's Active Status, Contact & Account Id
* param : uId : User Id
* Developer : Shivam Vishwakarma
****************************************/
/*    @AuraEnabled
    public static User getUserDetails( Id uId ){     
        User loggedInUser = [SELECT Id, Email, UserType, Country, Contact.Id, Contact.AccountId, FirstName, LastName, IsActive  FROM User WHERE Id=:uId];            
        if(loggedInUser!=null &&  loggedInUser.IsActive==true && loggedInUser.Contact.Id != null){
            return loggedInUser;
        }else if(loggedInUser.IsActive==true && loggedInUser.UserType != System.label.Sales_PowerPartnerUserType){
            Map<String, User> emailUserIdMap = new Map<String, User>();
            emailUserIdMap.put(loggedInUser.Email, loggedInUser);
            Contact con = new Contact();
            con.id = Sales_CreateLicenseContactUser_Utility.createLicenseContactUsers(emailUserIdMap);
        	loggedInUser.Contact = con;
            return loggedInUser;
        }
        else return null;  
    }  
    
    
    /***************************************
* Method : getIsValidContactId - Return if Contact selected during Host Creation is a Valid Contact or not.
* Developer : Shivam Vishwakarma
* Return Value : 
*  true => Selected Host is valid ,  false => Selected Host is invalid
****************************************/
   /* @AuraEnabled 
    public static Boolean getIsValidContactId(Id selectedContactId, Map<String,Id> ctIds){
        //Variables initialization
        Boolean result=false;
        Set<Id> contactIdSet = new Set<Id>();
        Map<Id,Id> delPrimaryContactMap = new Map<Id,Id>();
        
        //Processing Data           
        if(ctIds.containsKey('Sales_License_Primary_Admin_Contact__c'))
            contactIdSet.add(ctIds.get('Sales_License_Primary_Admin_Contact__c'));
        if(contactIdSet.size()>0){
            delPrimaryContactMap = Sales_LicenseGenerationGenericFunctions.validateDelegateUsers(contactIdSet);		//validate for delegate admins            
            if( contactIdSet.contains(selectedContactId) || (delPrimaryContactMap.values().contains(selectedContactId)) || 
               (ctIds.containsKey('Sales_License_Lic_User_Contact_ID__c') && ctIds.get('Sales_License_Lic_User_Contact_ID__c')==selectedContactId) ){			
                   result = true;
               }else{
                   result = false;
               }
        }        
        return result;        
    }*/
    
    /***************************************
* Method : getDelegateContactIds 
* Developer : Shivam Vishwakarma
****************************************/
/*    @AuraEnabled 
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
        
        System.debug('Host information'+hostId);
        if(hostId!=null)
        {
            Sales_Host__c hostinfo = [SELECT Id,Sales_isActiveHost__c,(Select Id From Licenses__r limit 1) FROM Sales_Host__c where Id =:hostId];
            //Checking if licenses are associated with the host
            if(hostinfo.Licenses__r != null && hostinfo.Licenses__r.size() > 0 ) {
                //checking if license associated are active
                if(hostinfo.Sales_isActiveHost__c==true)
                {
                    
                    for(Sales_License__c license1:[SELECT Id,Sales_License_Expiration_Date_Dt__c,Sales_License_Host_Node_Id__c from Sales_License__c  WHERE Sales_License_Host_Node_Id__c =: hostId]) 
                    {    
                        //checking the expiration date is in future or blank  
                        if(license1.Sales_License_Expiration_Date_Dt__c>= System.today() || license1.Sales_License_Expiration_Date_Dt__c==null)
                        { 
                            
                            isExpiryDtInFuture=true;
                            System.debug('Future date'+isExpiryDtInFuture);
                            break;
                        }
                        //if the expiration date is in past date
                        else 
                        {    isExpiryDtInFuture=false;
                         System.debug('Past date'+isExpiryDtInFuture);
                        }
                    }
                }
            } 
            else
            {
                isExpiryDtInFuture=false;
                System.debug('Licenses are not associated with this host');
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
         // Added by Bharath as per requirement from Jira ID TWC3144-31
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
*/    
}