/*********************************************************************************************************************
Class Name    : Pilot_Sales_TransferPrimaryAdmin
Version       : 1.0
Created Date  : Sep 2021
Function      :  

Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Shalini Kumari            24/09/2021              Pilot Project for testing framework.
* ************************************************************************************************************************************************/
public without sharing class Pilot_Sales_TransferPrimaryAdmin {
        
    public static final string ORIGIN = 'Sales_TransferPrimaryAdmin';
    public static final string CRITICALSEVERITY = 'Critical';
    public static final string INFOSEVERITY = 'Info';
    public static final string SUCCESSSEVERITY = 'Operation Completed Successfully!';
    public static final string FAILSEVERITY = 'Operation Failed!';
    public static final string HOSTOBJECTNAME = 'Sales_Host__c';
    public static final string LICENSEOBJECTNAME = 'Sales_License__c';
    public static final string LICENSEADMINDELEGATEOBJECTNAME = 'Sales_License_Admin_Delegate__c';
    public static final string PROJECT = 'PSG Sales';
    
    @AuraEnabled
    public static void transferPrimaryAdmin(Id fromPrimayAdmin, Id toPrimaryAdmin){      
        
        List<Sales_License_Admin_Delegate__c> dlgAdminToDeactivateList = new List<Sales_License_Admin_Delegate__c>();                
        
        system.debug('@@Inside transferPrimaryAdmin fromPrimayAdmin:'  +fromPrimayAdmin+  ' toPrimaryAdmin:'   +toPrimaryAdmin);
        
        //checking the from and to contact Id is not null
        if(fromPrimayAdmin!=null && toPrimaryAdmin!=null && fromPrimayAdmin!=toPrimaryAdmin){            
            try{                                
                /*
* Step 1: Check if there exists any Active License Admin Delegate Object record where FromContact is Primary Admin & ToContact is a Delegate to the Primary Admin - Deactivate the record 
* Reason : We have Validation rule on Sales_License_Admin_Delegate__c object : Delegate Admin Contact and Primary Admin Contact cannot be same.
*/                        
                //for(Sales_License_Admin_Delegate__c delRec : [SELECT Id,Sales_License_PrimaryAdmin_Contact__c,Sales_License_DlgAdmin_Contact__c,Sales_License_isActive__c 
                //                                              FROM Sales_License_Admin_Delegate__c 
                //                                              WHERE Sales_License_PrimaryAdmin_Contact__c=:fromPrimayAdmin AND Sales_License_DlgAdmin_Contact__c=:toPrimaryAdmin AND Sales_License_isActive__c=true] ){
                for(Sales_License_Admin_Delegate__c delRec : SEL_Sales_License_Admin_Delegate.newInstance().selectByPrimaryAndDelContactIds(fromPrimayAdmin,toPrimaryAdmin)){
                                                                  delRec.Sales_License_isActive__c = false;  
                                                                  dlgAdminToDeactivateList.add(delRec);
                                                              }
                if(!dlgAdminToDeactivateList.isEmpty())
                    update dlgAdminToDeactivateList;
                
                /*
* Step 2: Call a Queuable method that can transfer the Primary Admin on Licenses, Hosts & License Admin Delegate Records
* Reason : To overcome CPU Limit Exceeded Issue.
*/        	                
                if(!Test.isRunningTest())				// Only to avoid Chaining of Jobs in Test Class
                    System.enqueueJob(new processLicenseAdminDlgRecords(fromPrimayAdmin,toPrimaryAdmin));        
                /* As per Salesforce Docs --> 
* You can’t chain queueable jobs in an Apex test. Doing so results in an error.
* To avoid getting an error, you can check if Apex is running in test context by calling Test.isRunningTest() before chaining jobs.
*/
                
            }catch(Exception e){
                System.debug('@@Sales_TransferPrimaryAdmin Error --> '+ e.getMessage());   
                Core_Log_Entry.logEntryWithDetails(Sales_TransferPrimaryAdmin.ORIGIN, Sales_TransferPrimaryAdmin.PROJECT,'',Sales_TransferPrimaryAdmin.INFOSEVERITY,'Transferring Primary Admin from:'+fromPrimayAdmin+' to:'+toPrimaryAdmin+' .','Error Occurred While Initialing the Primary Admin Transfer Process : '+ e.getMessage()+' , Stack trace: '+e.getStackTraceString(),'', '', '');	
            } 
        }
    }//End of method 
    
    
    public class processLicenseAdminDlgRecords implements Queueable {
        
        Id fromPrimayAdmin, toPrimaryAdmin;                
        public processLicenseAdminDlgRecords(Id fromCon, Id toCon) {
            this.fromPrimayAdmin = fromCon;
            this.toPrimaryAdmin = toCon;    
        }
        
        public void execute(QueueableContext context) {
            List<Sales_License_Admin_Delegate__c> delegatedAdminList = new List<Sales_License_Admin_Delegate__c>();
            List<Sales_License_Admin_Delegate__c> origDelegatedAdminList = new List<Sales_License_Admin_Delegate__c>();
            Boolean successAdmDlg=true;   
            system.debug('@@Inside processLicenseAdminDlgRecords fromPrimayAdmin:'  +fromPrimayAdmin+  ' toPrimaryAdmin:'   +toPrimaryAdmin);
            //Map<Id,Contact> contactDetailsMap= new Map<Id,Contact>([Select Id,Name,Email from Contact where Id=:fromPrimayAdmin OR Id=:toPrimaryAdmin]);
            Map<Id,Contact> contactDetailsMap= new Map<Id,Contact>(SEL_Contact.newInstance().selectByPrimaryOrDelIds(fromPrimayAdmin, toPrimaryAdmin));
            String fromPrimAdmName=contactDetailsMap.get(fromPrimayAdmin)?.Name;
            String toPrimAdmName=contactDetailsMap.get(toPrimaryAdmin)?.Name;
            
            try{                        
                //origDelegatedAdminList = [SELECT Id,Sales_License_PrimaryAdmin_Contact__c,Sales_License_isActive__c FROM Sales_License_Admin_Delegate__c WHERE Sales_License_PrimaryAdmin_Contact__c=:fromPrimayAdmin AND Sales_License_isActive__c=true];
                origDelegatedAdminList = SEL_Sales_License_Admin_Delegate.newInstance().selectByPrimaryIdsAndIsActive(fromPrimayAdmin);
                for(Sales_License_Admin_Delegate__c salesDelegateAdmin:origDelegatedAdminList){
                    salesDelegateAdmin.Sales_License_PrimaryAdmin_Contact__c=toPrimaryAdmin;
                    delegatedAdminList.add(salesDelegateAdmin);
                }
                if(!delegatedAdminList.isEmpty()){
                    update delegatedAdminList;
                }
                
            }catch(Exception e){
                System.debug('@@Error occurred during transferring licenses admin delegate--> '+e.getMessage());        
                successAdmDlg=false;
                Core_Log_Entry.logEntryWithDetails(Sales_TransferPrimaryAdmin.ORIGIN, Sales_TransferPrimaryAdmin.PROJECT,'',Sales_TransferPrimaryAdmin.CRITICALSEVERITY,'Transferring Primary Admin from:'+fromPrimayAdmin+' to:'+toPrimaryAdmin+' .','Error Occurred While transferring Primary Admin on License Admin Delegate : '+ e.getMessage()+' , Stack trace: '+e.getStackTraceString(),'', Sales_TransferPrimaryAdmin.LICENSEADMINDELEGATEOBJECTNAME, '');	
            }  
            
            //Log Success & Chain this job to next job by submitting the next job
            if(successAdmDlg==true){                
                Core_Log_Entry.logEntryWithDetails(Sales_TransferPrimaryAdmin.ORIGIN, Sales_TransferPrimaryAdmin.PROJECT,'',Sales_TransferPrimaryAdmin.INFOSEVERITY,'Transferring Primary Admin from:'+fromPrimayAdmin+' to:'+toPrimaryAdmin+' .','Successfully transferred Primary Admin on License Admin Delegates!','','', '');	
                if(!Test.isRunningTest())
                    System.enqueueJob(new processHostRecords(fromPrimayAdmin,toPrimaryAdmin, origDelegatedAdminList));
            }else{
                //Send mail                
                Sales_TransferPrimaryAdmin.sendEmail(fromPrimayAdmin, toPrimaryAdmin, 'Transfer Primary Admin Operation Failed!', 'This mail is to inform you that the Transfer Primary Admin Operation from '+fromPrimAdmName+' to '+toPrimAdmName+' has Failed!', 'Please try again. If issue persists, please contact IT support at '+ System.Label.sales_IT_Support);
            }
            
        }
    }
    
    
    public class processHostRecords implements Queueable {
        Id fromPrimayAdmin, toPrimaryAdmin;
        List<Sales_License_Admin_Delegate__c> origDelegatedAdminList = new List<Sales_License_Admin_Delegate__c>();
        public processHostRecords(Id fromCon, Id toCon, List<Sales_License_Admin_Delegate__c> beforeDlgAdmRecords) {
            this.fromPrimayAdmin = fromCon;
            this.toPrimaryAdmin = toCon;    
            this.origDelegatedAdminList = beforeDlgAdmRecords;
        }
        
        public void execute(QueueableContext context) {
            List<Sales_Host__c> origHostList = new List<Sales_Host__c>();
            List<Sales_Host__c> hostList = new List<Sales_Host__c>();
            Boolean successHost=true;                   
            system.debug('@@Inside processHostRecords fromPrimayAdmin:'  +fromPrimayAdmin+  ' toPrimaryAdmin:'   +toPrimaryAdmin);
            //Map<Id,Contact> contactDetailsMap= new Map<Id,Contact>([Select Id,Name,Email from Contact where Id=:fromPrimayAdmin OR Id=:toPrimaryAdmin]);
            Map<Id,Contact> contactDetailsMap= new Map<Id,Contact>(SEL_Contact.newInstance().selectByPrimaryOrDelIds(fromPrimayAdmin, toPrimaryAdmin));
            String fromPrimAdmName=contactDetailsMap.get(fromPrimayAdmin)?.Name;
            String toPrimAdmName=contactDetailsMap.get(toPrimaryAdmin)?.Name;
            
            
            // A. Host Records
            try{                            
                //origHostList = [SELECT Id,Name,Sales_Contact__c FROM Sales_Host__c WHERE Sales_Contact__c=:fromPrimayAdmin];
                origHostList = SEL_Sales_Host.newInstance().selectByContactId(fromPrimayAdmin);
                for(Sales_Host__c hostrec : origHostList){
                    hostrec.Sales_Contact__c=toPrimaryAdmin;
                    hostList.add(hostrec);
                }
                if(!hostList.isEmpty()){
                    update hostList;
                }
            }catch(Exception e){
                System.debug('@@Error occurred during transferring hosts --> '+e.getMessage());                  
                successHost=false;
                Core_Log_Entry.logEntryWithDetails(Sales_TransferPrimaryAdmin.ORIGIN, Sales_TransferPrimaryAdmin.PROJECT,'',Sales_TransferPrimaryAdmin.CRITICALSEVERITY,'Transferring Primary Admin from:'+fromPrimayAdmin+' to:'+toPrimaryAdmin+' .','Error Occurred While transferring Primary Admin on Hosts : '+ e.getMessage()+' , Stack trace: '+e.getStackTraceString(),'', Sales_TransferPrimaryAdmin.HOSTOBJECTNAME, '');	
            }
            
            if(successHost==false){
                System.debug('hosts Failed --> Roll back initiation begins ...');
                if(origDelegatedAdminList!=null && !(origDelegatedAdminList).isEmpty()){
                    System.debug('Rolling back License Admin Delegate Changes...');
                    update origDelegatedAdminList;
                }    
                //Send mail                
                Sales_TransferPrimaryAdmin.sendEmail(fromPrimayAdmin, toPrimaryAdmin, 'Transfer Primary Admin Operation Failed!', 'This mail is to inform you that the Transfer Primary Admin Operation from '+fromPrimAdmName+' to '+toPrimAdmName+' has Failed!', 'Please try again. If issue persists, please contact IT support at '+ System.Label.sales_IT_Support);
            }else{
                // Chain this job to next job by submitting the next job            
                Core_Log_Entry.logEntryWithDetails(Sales_TransferPrimaryAdmin.ORIGIN, Sales_TransferPrimaryAdmin.PROJECT,'',Sales_TransferPrimaryAdmin.INFOSEVERITY,'Transferring Primary Admin from:'+fromPrimayAdmin+' to:'+toPrimaryAdmin+' .','Successfully transferred Primary Admin on Hosts!','','', '');	
                if(!Test.isRunningTest())
                    System.enqueueJob(new processLicenseRecords(fromPrimayAdmin,toPrimaryAdmin,origHostList,origDelegatedAdminList));
            }                       
            
        }
    }
    
    public class processLicenseRecords implements Queueable {
        
        Id fromPrimayAdmin, toPrimaryAdmin;
        List<Sales_Host__c> origHostList = new List<Sales_Host__c>();
        List<Sales_License_Admin_Delegate__c> origDelegatedAdminList = new List<Sales_License_Admin_Delegate__c>();
        public processLicenseRecords(Id fromCon, Id toCon, List<Sales_Host__c> beforeHost, List<Sales_License_Admin_Delegate__c> beforeDlgAdmRecords) {
            this.fromPrimayAdmin = fromCon;
            this.toPrimaryAdmin = toCon;    
            this.origHostList = beforeHost;
            this.origDelegatedAdminList = beforeDlgAdmRecords;
        }
        
        public void execute(QueueableContext context) {
            List<Sales_License__c> licenseList = new List<Sales_License__c>();
            List<Sales_License__c> origLicenseList = new List<Sales_License__c>();
            Boolean successLicense=true;                        
            //Map<Id,Contact> contactDetailsMap= new Map<Id,Contact>([Select Id,Name,Email from Contact where Id=:fromPrimayAdmin OR Id=:toPrimaryAdmin]);
            Map<Id,Contact> contactDetailsMap= new Map<Id,Contact>(SEL_Contact.newInstance().selectByPrimaryOrDelIds(fromPrimayAdmin, toPrimaryAdmin));
            String fromPrimAdmName=contactDetailsMap.get(fromPrimayAdmin)?.Name;
            String toPrimAdmName=contactDetailsMap.get(toPrimaryAdmin)?.Name;
            
            //B. License Records            
            try{                                    
                //origLicenseList = [SELECT Id,Name,Sales_License_Primary_Admin_Contact__c FROM Sales_License__c WHERE Sales_License_Primary_Admin_Contact__c=:fromPrimayAdmin];               
                origLicenseList = SEL_Sales_License.newInstance().selectByPrimaryContactId(fromPrimayAdmin);               
                for(Sales_License__c salesLicenserec : origLicenseList){
                    salesLicenserec.Sales_License_Primary_Admin_Contact__c=toPrimaryAdmin;                    
                    licenseList.add(salesLicenserec);
                }
                if(!licenseList.isEmpty()){
                    update licenseList;
                }
                
            }catch(Exception e){
                System.debug('@@Error occurred during transferring licenses --> '+e.getMessage());        
                successLicense=false;                
                Core_Log_Entry.logEntryWithDetails(Sales_TransferPrimaryAdmin.ORIGIN, Sales_TransferPrimaryAdmin.PROJECT,'',Sales_TransferPrimaryAdmin.CRITICALSEVERITY,'Transferring Primary Admin from:'+fromPrimayAdmin+' to:'+toPrimaryAdmin+' .','Error Occurred While transferring Primary Admin on Licenses : '+ e.getMessage()+' , Stack trace: '+e.getStackTraceString(),'', Sales_TransferPrimaryAdmin.LICENSEOBJECTNAME, '');	
            }                                                                 
            
            if(successLicense==false){
                System.debug('licenses Failed --> Roll back initiation begins ...');
                if(origDelegatedAdminList!=null && !(origDelegatedAdminList).isEmpty()){
                    System.debug('Rolling back License Admin Delegate Changes...');
                    update origDelegatedAdminList;
                }  
                if(origHostList!=null && !(origHostList).isEmpty()){
                    System.debug('Rolling back Host Changes...');
                    update origHostList;
                }           
                //Send mail                
                Sales_TransferPrimaryAdmin.sendEmail(fromPrimayAdmin, toPrimaryAdmin, 'Transfer Primary Admin Operation Failed!', 'This mail is to inform you that the Transfer Primary Admin Operation from '+fromPrimAdmName+' to '+toPrimAdmName+' has Failed!', 'Please try again. If issue persists, please contact IT support at '+ System.Label.sales_IT_Support);
            }else{
                //Success logs
                Core_Log_Entry.logEntryWithDetails(Sales_TransferPrimaryAdmin.ORIGIN, Sales_TransferPrimaryAdmin.PROJECT,'',Sales_TransferPrimaryAdmin.INFOSEVERITY,'Transferring Primary Admin from:'+fromPrimayAdmin+' to:'+toPrimaryAdmin+' .','Successfully transferred Primary Admin on Licenses!','','', '');	                
                //Send mail                
                Sales_TransferPrimaryAdmin.sendEmail(fromPrimayAdmin, toPrimaryAdmin, 'Transfer Primary Admin Operation Completed Successfully!', 'This mail is to inform you that the Transfer Primary Admin Operation from '+fromPrimAdmName+' to '+toPrimAdmName+' has Completed Successfully!', '');
            }
            
        }
    }
    
    /*
public static void sendFinalSuccessFailureLog(Boolean isSuccess, Id fromPrimayAdmin, Id toPrimaryAdmin ){
if(isSuccess==true){
Core_Log_Entry.logEntryWithDetails(Sales_TransferPrimaryAdmin.ORIGIN, Sales_TransferPrimaryAdmin.PROJECT,'',Sales_TransferPrimaryAdmin.SUCCESSSEVERITY,'','Transferring Primary Admin from:'+fromPrimayAdmin+' to:'+toPrimaryAdmin+' completed successfully!.','','', '');	
}
else{
Core_Log_Entry.logEntryWithDetails(Sales_TransferPrimaryAdmin.ORIGIN, Sales_TransferPrimaryAdmin.PROJECT,'',Sales_TransferPrimaryAdmin.FAILSEVERITY,'','Transferring Primary Admin from:'+fromPrimayAdmin+' to:'+toPrimaryAdmin+' failed, Please refer earlier log entries to understand the reason of failure!.','','', '');	
}
}*/    
    
    
    
    
    // Method to frame Email Template with data in it
    public static String getEmailTemplateBody(String subject, String bodyMessage , String errorMessage){        
        String logoUrl = System.Label.Sales_Intel_Logo;       
        List<Object> parameters = new List<Object>{logoUrl, subject, bodyMessage, errorMessage};
            String emailBody = System.Label.Sales_TransferAdmin_Email_Body;		//Email Template Formatted Body
        String formattedEmailBody = String.format(emailBody, parameters);
        return formattedEmailBody;
    }
    
    
    public static void sendEmail(Id fromPrimayAdmin,Id toPrimaryAdmin, String subjectLine, String emailBody, String errorMsg ){
        String ORGWIDE_EMAIL=System.Label.Sales;		//wsm-postmaster@intel.com        
        //OrgWideEmailAddress orgWideEmailAdd = [SELECT Id, Address, DisplayName from OrgWideEmailAddress where Address=:ORGWIDE_EMAIL];		//query email address 
        OrgWideEmailAddress orgWideEmailAdd = [SELECT Id, Address, DisplayName from OrgWideEmailAddress where Address=:ORGWIDE_EMAIL];		//query email address 
        
        Id orgId = [Select Id From organization].Id;		//Source organization: 00D2D000000E9ZKUA0	        
        subjectLine += ' (Source organization: '+String.valueOf(orgId)+')';
        
        String loggedInUserEmail = [Select Id, Email from User where Id=:UserInfo.getUserId()].Email;		//Logged In User should receive the success/failure mail
        
        List<Messaging.SingleEmailMessage> mails =new List<Messaging.SingleEmailMessage>();    
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> sendTo = new List<String>();
        sendTo.add(loggedInUserEmail); 		//Adding Recepient to List
        mail.setToAddresses(sendTo);           
        mail.setSubject(subjectLine); 			
        mail.setHtmlBody(getEmailTemplateBody(subjectLine,emailBody,errorMsg));
        mail.setOrgWideEmailAddressId(orgWideEmailAdd.Id);
        mails.add(mail);
        
        if(mails.size()>0){
            Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);//sending mail                 
            if (results[0].success) 
            {   
                System.debug('The email was sent successfully.');
                
            } else {
                System.debug('The email failed to send: ' +  results[0].errors[0].message);
                Core_Log_Entry.logEntryWithDetails(Sales_TransferPrimaryAdmin.ORIGIN, Sales_TransferPrimaryAdmin.PROJECT,'',Sales_TransferPrimaryAdmin.INFOSEVERITY,'Transferring Primary Admin from:'+fromPrimayAdmin+' to:'+toPrimaryAdmin+' .','Some error occurred during sending Email! Error: '+  results[0].errors[0].message,'','', '');	                
            }
        }
    }    
    
    

}