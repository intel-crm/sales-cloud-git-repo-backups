/****************************************************************************************************************************************
 * Class Name  : Core_MDF_CCP_OwnerTransfer
 * Version     : 1.0
 * Created Date: 04-21-2022
 * Modification Log :
 * Developer :Chaithanya Lakshman                Date:04-21-2022               Description:CCP Ownership Transfer
 * ---------------------------------------------------------------------------------------------------------------------------------------
 *****************************************************************************************************************************************/


public class Core_MDF_CCP_OwnerTransfer {
    
    public static final string ORIGIN = 'Core_MDF_CCP_OwnerTransfer'; 
    public static final string INFOSEVERITY = 'Info';
    public static final string PROJECT = 'Core_MDF__CCP'; //project name
    public static final String ORGWIDE_EMAIL=System.label.core_MDF_CCP_FromEmail; //from email id
    
    // method to update ownership which calls batch with size of 20 records  
    @AuraEnabled(cacheable=true)
        public static void updateRecords(String oldOwner,String newOwner,String objectSelected){
        System.debug('line 163'+objectSelected);  
        List<String> selectedObject=new List<String>();
        String errorMsg=''; //to store the errorMsg
        String recordId;    //to store failed recordId
        selectedObject=objectSelected.split(',');
            
            if(selectedObject.size()>0){
                for(Integer i=0;i<selectedObject.size();i++){
                    System.debug(selectedObject[i]+'objectname');
					Core_MDF_CCP_UpadateOwnerDetailsOnObject ownerUpdate= new Core_MDF_CCP_UpadateOwnerDetailsOnObject(selectedObject[i],oldOwner,newOwner,errorMsg,recordId);
                    Database.executeBatch(ownerUpdate,20);
                }
            }
            
        }
        
        
        
        
   //method to fetch user data     
    @AuraEnabled(cacheable=true)
    public static List<SObjectResult> getUser(String userName){
      List<User> userList =new List<User>();
       List<SObJectResult> sObjectResultList = new List<SObJectResult>();
     
           if(String.isNotEmpty(userName)) {
             String query = 'Select Id,Name ';
             if(userName instanceOf Id)
                {
                    string searchText = '\'' + String.escapeSingleQuotes(userName) + '\'';
                query = query+' FROM '+'User'+' WHERE Id =' + searchText.trim();
                system.debug(query);
                for(User userlist1 : Database.Query(query)) 
                {
                    System.debug('valid id');
                    System.debug(userName);
                    sObjectResultList.add(new SObjectResult(userlist1.Name, userlist1.Id));
                }
               }
                
               else{
                string searchText = '\'' + String.escapeSingleQuotes(userName) + '%\'';
                query = query+' FROM '+'User'+' WHERE Name like ' + searchText.trim();
                system.debug(query);
                for(User userlist1 : Database.Query(query)) 
                {
                    System.debug('valid id');
                    System.debug(userName);
                    sObjectResultList.add(new SObjectResult(userlist1.Name, userlist1.Id));
                }
               
               }
         
           }
        return sObjectResultList;
    }
    //method to fetch account     
    @AuraEnabled(cacheable=true)
    public static List<SObjectResult> searchAccount(String accountName){
      List<Account> accList =new List<Account>();
       List<SObJectResult> sObjectResultList = new List<SObJectResult>();
     
           if(String.isNotEmpty(accountName)) {
             String query = 'Select Id,Name,';
                    string searchText = '\'' + String.escapeSingleQuotes(accountName) + '%\'';
                query = query+' FROM '+'Account'+'Where'+'RecordType.Name=\'Intel Account\''+'and Core_MDF_CoMarketingActive__c=true and owner.Profile.Name in'+'(\'System Administrator\',\'IT Admin\')'+searchText.trim();
                system.debug(query);
                for( Account acclist1 : Database.Query(query)) 
                {
                    System.debug('valid id');
                    System.debug(accountName);
                    sObjectResultList.add(new SObjectResult(acclist1.Name, acclist1.Id));
                }
               
         
           }
        return sObjectResultList;
    }
       
      public class SObjectResult {
        @AuraEnabled
        public String recName;
        @AuraEnabled
        public Id recId;


 public SObJectResult(String recNameTemp, Id recIdTemp) {
            recName = recNameTemp;
            recId = recIdTemp;
        }
        public SObjectResult() {

        }
    }
    
     @AuraEnabled (cacheable=true)
    public static List<pickListWrapper> fetchObjectData() {
        List<pickListWrapper> tempWrapperList = new List<pickListWrapper>();
        for(CCP_OwnerTransferObject__mdt temp: [SELECT Id,Object_Name__c,Object_Api_Name__c FROM CCP_OwnerTransferObject__mdt  where Active__c = true order by Object_Name__c]){
            tempWrapperList.add(new pickListWrapper(temp.Object_Name__c,temp.Object_Api_Name__c));
        }
        return tempWrapperList;
    }
	
	//method to fetch custom metadata records configured
     @AuraEnabled (cacheable=true)
    public static List<pickListWrapper> fetchObjectDataMeta(String objectName) {
        List<pickListWrapper> tempWrapperList = new List<pickListWrapper>();
        List<String> objectvalues=new List<String>();
        objectvalues=objectName.split(',');
        System.debug(objectvalues+'values');
            for(CCP_OwnerTransferObject__mdt temp: [SELECT Id,Object_Api_Name__c,Object_Name__c FROM CCP_OwnerTransferObject__mdt  where Active__c = true and Object_Name__c IN: objectvalues order by Object_Name__c]){
            tempWrapperList.add(new pickListWrapper(temp.Object_Name__c,temp.Object_Api_Name__c));
        }
        return tempWrapperList;
    }
    //method to fetch the number of records of all SObects
  @AuraEnabled(cacheable=true)
    public static Map<String,Integer> getRecords(Id ownerId,String objectName,String objectLabel){
        List<String> sObjectname=new List<String>();
         List<String> sObjectlabel=new List<String>();
        Map<String,Integer> countValue=new Map<String,Integer>();
        sObjectname =objectName.split(',');
        sObjectlabel=objectLabel.split(',');
        
        System.debug('split'+sObjectname);
        for (integer i=0;i<sObjectname.size();i++)
        {  
           String objectNameInput=sObjectname[i];
           String objectLabelInput=sObjectlabel[i];
           String queryString= 'SELECT Count() FROM '+objectNameInput+' where OwnerId =\''+ownerId+'\'';
           Integer count=Database.countquery(queryString);
           countValue.put(objectLabelInput,count);
        }
        return countValue;
    }
    
      public without sharing class pickListWrapper{
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        public pickListWrapper(String label,String value){
            this.label = label;
            this.value = value;
        }
    }
    
    //Method to send email to the user who performed ownership transfer
    public static Boolean sendEmailOnExcpetion(String loggedInUserId, String objectSelected ,String errorMsg){
        
            List<Messaging.SingleEmailMessage> mails =new List<Messaging.SingleEmailMessage>();
            OrgWideEmailAddress orgWideEmailAdd = [SELECT Id, Address, DisplayName from OrgWideEmailAddress where Address=:ORGWIDE_EMAIL];//query email address 
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<String> sendTo = new List<String>();
           // List<String> sendToBcc = new List<String>();
            system.debug('object'+objectSelected+'error'+errorMsg);
            sendTo.add(loggedInUserId); 
           // sendToBcc=System.Label.Sales_Support_Email_ID.split(',');
            mail.setToAddresses(sendTo);
           // mail.setBccAddresses(sendToBcc);
            mail.setSubject(System.Label.Core_MDF_CCP_OwnerTransferEmailSubject); 
            mail.setHtmlBody(getEmailTemplateBody(loggedInUserId,objectSelected,errorMsg));
            mail.setOrgWideEmailAddressId(orgWideEmailAdd.Id);
            mails.add(mail);
            system.debug('mail'+mails);
            
            if(mails.size()>0){
                Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);//sending mail 
                
                if (results[0].success) 
                {   
                    System.debug('The email was sent successfully.');
                    return true;
                    
                } else {
                    System.debug('The email failed to send: ' +  results[0].errors[0].message);
                }
            }
        
        return false;   
    }
//email template 
 public static String getEmailTemplateBody( String loggedInUserId,String objectSelected ,String errorMsg){
        
       // String logoUrl = System.Label.Sales_Intel_Logo;       
        List<Object> parameters = new List<Object> { loggedInUserId,objectSelected,errorMsg};
        String emailBody = System.Label.Core_MDF_CCP_OwnerTransferEmail;//email body template 
	    String formattedEmailBody = String.format(emailBody, parameters);
        return formattedEmailBody;
    }
}