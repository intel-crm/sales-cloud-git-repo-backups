/***************************************************************************
Class Name    : Sales_TransferPrimaryAdmin
Version       : 1.0
Created Date  : August 2021           
Modification Log :
* Developer                 Date                    Description
* -----------------------------------------------------------------------------------------------------------------------
* Shivam Vishwakarma        15/08/2021              Optimized Tranfer Primary Admin Operation Class.
*****************************************************************************************************************************************/
public without sharing class Sales_TransferPrimaryAdmin{
    public static final string ORIGIN = 'Sales_TransferPrimaryAdmin';
    public static final string CRITICALSEVERITY = 'Critical';
    public static final string INFOSEVERITY = 'Info';
    //public static final string SUCCESSSEVERITY = 'Operation Completed Successfully!';--Unused
    //public static final string FAILSEVERITY = 'Operation Failed!';--Unused
    //public static final string HOSTOBJECTNAME = 'Sales_Host__c';--unused
    //public static final string LICENSEOBJECTNAME = 'Sales_License__c';--Unused
    //public static final string LICENSEADMINDELEGATEOBJECTNAME = 'Sales_License_Admin_Delegate__c';--Unused
    public static final string PROJECT = 'PSG Sales';
    //public static Map<String,String> transferAdmin_License_Map=new Map<String,String>();--Unused
    //public static Map<String,String> transferAdmin_Host_Map=new Map<String,String>();--Unused
    //public static Map<Id,String> transferAdminLicenseIdNameMap=new Map<Id,String>();--Unused
    //public static Map<Id,String> transferPriAdminHostIdNameMap=new Map<Id,String>();--Unused
    //public static List<String> recordsToMail=new List<String>();--Unused
    public static Boolean attachmentToBeShared=true;
    public static Boolean ByPassingAddErrorOfHost=false;
    @AuraEnabled
    public static void transferPrimaryAdmin(Id fromPrimayAdmin, Id toPrimaryAdmin){   
        PRM_Execution_Controls__c customSettingRec = new PRM_Execution_Controls__c();
        customSettingRec.SetupOwnerId = userInfo.getUserId();
        customSettingRec.BypassValidationInTransferAdmin__c = true;
        insert customSettingRec;
        List<Sales_License_Admin_Delegate__c> dlgAdminToDeactivateList = new List<Sales_License_Admin_Delegate__c>();                
        if(fromPrimayAdmin!=null && toPrimaryAdmin!=null && fromPrimayAdmin!=toPrimaryAdmin){            
            try{                                
                for(Sales_License_Admin_Delegate__c delRec : [SELECT Id,Sales_License_PrimaryAdmin_Contact__c,Sales_License_DlgAdmin_Contact__c,Sales_License_isActive__c 
                                                              FROM Sales_License_Admin_Delegate__c 
                                                              WHERE Sales_License_PrimaryAdmin_Contact__c=:fromPrimayAdmin AND Sales_License_DlgAdmin_Contact__c=:toPrimaryAdmin AND Sales_License_isActive__c=true] ){
                                                                  delRec.Sales_License_isActive__c = false;  
                                                                  dlgAdminToDeactivateList.add(delRec);
                                                              }
                if(!dlgAdminToDeactivateList.isEmpty())
                    update dlgAdminToDeactivateList;
                if(!Test.isRunningTest())				
                    Id jobId=Database.executeBatch(new Sales_TransferPrimaryAdminBatch(fromPrimayAdmin,toPrimaryAdmin),Integer.ValueOf(System.Label.Sales_TransferPrimaryAdminBatchSize));
            }catch(Exception e){
                Core_Log_Entry.logEntryWithDetails(Sales_TransferPrimaryAdmin.ORIGIN, Sales_TransferPrimaryAdmin.PROJECT,'',Sales_TransferPrimaryAdmin.INFOSEVERITY,'Transferring Primary Admin from:'+fromPrimayAdmin+' to:'+toPrimaryAdmin+' .','Error Occurred While Initialing the Primary Admin Transfer Process : '+ e.getMessage()+' , Stack trace: '+e.getStackTraceString(),'', '', '');	
            } 
        }
    }
    /*public class processLicenseAdminDlgRecords implements Queueable {
        Id fromPrimayAdmin, toPrimaryAdmin;                
        public processLicenseAdminDlgRecords(Id fromCon, Id toCon) {
            this.fromPrimayAdmin = fromCon;
            this.toPrimaryAdmin = toCon;    
        }
        public void execute(QueueableContext context) {
            List<Sales_License_Admin_Delegate__c> delegatedAdminList = new List<Sales_License_Admin_Delegate__c>();
            List<Sales_License_Admin_Delegate__c> origDelegatedAdminList = new List<Sales_License_Admin_Delegate__c>();
            List<Sales_License_Admin_Delegate__c> revertDelegatedAdminList ; 
            Boolean successAdmDlg=true;   
            Map<Id,Contact> contactDetailsMap= new Map<Id,Contact>([Select Id,Name,Email from Contact where Id=:fromPrimayAdmin OR Id=:toPrimaryAdmin]);
            String fromPrimAdmName=contactDetailsMap.get(fromPrimayAdmin)?.Name;
            String toPrimAdmName=contactDetailsMap.get(toPrimaryAdmin)?.Name;
            try{                        
                origDelegatedAdminList = [SELECT Id,Sales_License_PrimaryAdmin_Contact__c,Sales_License_isActive__c FROM Sales_License_Admin_Delegate__c WHERE Sales_License_PrimaryAdmin_Contact__c=:fromPrimayAdmin AND Sales_License_isActive__c=true];
                revertDelegatedAdminList=[SELECT Id,Sales_License_PrimaryAdmin_Contact__c,Sales_License_isActive__c FROM Sales_License_Admin_Delegate__c WHERE Sales_License_PrimaryAdmin_Contact__c=:fromPrimayAdmin AND Sales_License_isActive__c=true];
                for(Sales_License_Admin_Delegate__c salesDelegateAdmin:origDelegatedAdminList){
                    salesDelegateAdmin.Sales_License_PrimaryAdmin_Contact__c=toPrimaryAdmin;
                    delegatedAdminList.add(salesDelegateAdmin);
                }
                if(!delegatedAdminList.isEmpty()){
                    update delegatedAdminList;
                }
            }catch(Exception e){
                successAdmDlg=false;
                Core_Log_Entry.logEntryWithDetails(Sales_TransferPrimaryAdmin.ORIGIN, Sales_TransferPrimaryAdmin.PROJECT,'',Sales_TransferPrimaryAdmin.CRITICALSEVERITY,'Transferring Primary Admin from:'+fromPrimayAdmin+' to:'+toPrimaryAdmin+' .','Error Occurred While transferring Primary Admin on License Admin Delegate : '+ e.getMessage()+' , Stack trace: '+e.getStackTraceString(),'', Sales_TransferPrimaryAdmin.LICENSEADMINDELEGATEOBJECTNAME, '');	
            }  
            if(successAdmDlg==true){                
                Core_Log_Entry.logEntryWithDetails(Sales_TransferPrimaryAdmin.ORIGIN, Sales_TransferPrimaryAdmin.PROJECT,'',Sales_TransferPrimaryAdmin.INFOSEVERITY,'Transferring Primary Admin from:'+fromPrimayAdmin+' to:'+toPrimaryAdmin+' .','Successfully transferred Primary Admin on License Admin Delegates!','','', '');	
                if(!Test.isRunningTest())
                    System.enqueueJob(new processLicenseRecords(fromPrimayAdmin,toPrimaryAdmin, revertDelegatedAdminList));
            }else{
                Sales_TransferPrimaryAdmin.sendEmail(fromPrimayAdmin, toPrimaryAdmin, 'Transfer Primary Admin Operation Failed!', 'This mail is to inform you that the Transfer Primary Admin Operation from '+fromPrimAdmName+' to '+toPrimAdmName+' has Failed!', 'Please try again. If issue persists, please contact IT support at ');
            }
        }
    }
    public class processHostRecords implements Queueable {
        Id fromPrimayAdmin, toPrimaryAdmin;
        List<Sales_License__c> origLicenseList = new List<Sales_License__c>();
        List<Sales_License_Admin_Delegate__c> origDelegatedAdminList = new List<Sales_License_Admin_Delegate__c>();
        public processHostRecords(Id fromCon, Id toCon,List<Sales_License__c> beforeLicense, List<Sales_License_Admin_Delegate__c> beforeDlgAdmRecords) {
            this.fromPrimayAdmin = fromCon;
            this.toPrimaryAdmin = toCon;    
            this.origLicenseList = beforeLicense;
            this.origDelegatedAdminList = beforeDlgAdmRecords;
        }
        public void execute(QueueableContext context) {
            List<Sales_Host__c> origHostList = new List<Sales_Host__c>();
            List<Sales_Host__c> hostList = new List<Sales_Host__c>();
            Boolean successHost=true;                   
            Map<Id,Contact> contactDetailsMap= new Map<Id,Contact>([Select Id,Name,Email from Contact where Id=:fromPrimayAdmin OR Id=:toPrimaryAdmin]);
            String fromPrimAdmName=contactDetailsMap.get(fromPrimayAdmin)?.Name;
            String toPrimAdmName=contactDetailsMap.get(toPrimaryAdmin)?.Name;	
            Map<String,String> transferAdminErrorMap=new Map<String,String>();
            Map<Id,String> transferAdminHostIdNameMap=new Map<Id,String>();
            ByPassingAddErrorOfHost=true;
            try{                            
                origHostList = [SELECT Id,Name,Sales_Contact__c FROM Sales_Host__c WHERE Sales_Contact__c=:fromPrimayAdmin];
                for(Sales_Host__c hostrec : origHostList){
                    hostrec.Sales_Contact__c=toPrimaryAdmin;
                    hostList.add(hostrec);
                }
                if(!hostList.isEmpty()){
                    Savepoint sp = Database.setSavepoint();
                    Database.SaveResult[] recHostList=Database.update(hostList,false);			
                    for(Database.SaveResult iterSaveResultHost:recHostList){
                        if (!iterSaveResultHost.isSuccess()) {
                            for(Database.Error err : iterSaveResultHost.getErrors()) {	
                                transferAdminErrorMap.put(iterSaveResultHost.getId(),err.getMessage());									
                            }
                        }
                    }	
                    if(!transferAdminErrorMap.isEmpty()){	
                        for(Sales_Host__c suceesHostList: [select id, Name from Sales_Host__c where id in:transferAdminErrorMap.keySet()]){
                            transferAdminHostIdNameMap.put(suceesHostList.id,suceesHostList.name);
                        }
                        for (String keyOfHost : transferAdminErrorMap.keySet()) {
                            recordsToMail.add(transferAdminHostIdNameMap.get(keyOfHost)+','+'Host Information'+','+transferAdminErrorMap.get(keyOfHost));
                        }
                    }
                    Database.rollback(sp);							
                    update hostList;
                }
            }catch(Exception e){
                successHost=false;
                Core_Log_Entry.logEntryWithDetails(Sales_TransferPrimaryAdmin.ORIGIN, Sales_TransferPrimaryAdmin.PROJECT,'',Sales_TransferPrimaryAdmin.CRITICALSEVERITY,'Transferring Primary Admin from:'+fromPrimayAdmin+' to:'+toPrimaryAdmin+' .','Error Occurred While transferring Primary Admin on Hosts : '+ e.getMessage()+' , Stack trace: '+e.getStackTraceString(),'', Sales_TransferPrimaryAdmin.HOSTOBJECTNAME, '');	
            }
            if(successHost==false){
                if(origDelegatedAdminList!=null && !(origDelegatedAdminList).isEmpty()){
                    update origDelegatedAdminList;
                }    
                if(origLicenseList!=null && !(origLicenseList).isEmpty()){
                    update origLicenseList;
                }           
                Sales_TransferPrimaryAdmin.sendEmail(fromPrimayAdmin, toPrimaryAdmin, 'Transfer Primary Admin Operation Failed!', 'This mail is to inform you that the Transfer Primary Admin Operation from '+fromPrimAdmName+' to '+toPrimAdmName+' has Failed!', 'Please try again. If issue persists, please contact IT support at ');
            }else{
                attachmentToBeShared=false;
                Core_Log_Entry.logEntryWithDetails(Sales_TransferPrimaryAdmin.ORIGIN, Sales_TransferPrimaryAdmin.PROJECT,'',Sales_TransferPrimaryAdmin.INFOSEVERITY,'Transferring Primary Admin from:'+fromPrimayAdmin+' to:'+toPrimaryAdmin+' .','Successfully transferred Primary Admin on Hosts!','','', '');	
                Sales_TransferPrimaryAdmin.sendEmail(fromPrimayAdmin, toPrimaryAdmin, 'Transfer Primary Admin Operation Completed Successfully!', 'This mail is to inform you that the Transfer Primary Admin Operation from '+fromPrimAdmName+' to '+toPrimAdmName+' has Completed Successfully!', '');                      
            }
        }
    }
    public class processLicenseRecords implements Queueable {
        Id fromPrimayAdmin, toPrimaryAdmin;
        List<Sales_License_Admin_Delegate__c> origDelegatedAdminList = new List<Sales_License_Admin_Delegate__c>();
        public processLicenseRecords(Id fromCon, Id toCon,List<Sales_License_Admin_Delegate__c> beforeDlgAdmRecords) {
            this.fromPrimayAdmin = fromCon;
            this.toPrimaryAdmin = toCon;    
            this.origDelegatedAdminList = beforeDlgAdmRecords;
        }
        public void execute(QueueableContext context) {
            List<Sales_License__c> licenseList = new List<Sales_License__c>();
            List<Sales_License__c> origLicenseList = new List<Sales_License__c>();
            List<Sales_License__c> revertLicenseList = new List<Sales_License__c>();
            Boolean successLicense=true;                        
            Map<Id,Contact> contactDetailsMap= new Map<Id,Contact>([Select Id,Name,Email from Contact where Id=:fromPrimayAdmin OR Id=:toPrimaryAdmin]);
            String fromPrimAdmName=contactDetailsMap.get(fromPrimayAdmin)?.Name;
            String toPrimAdmName=contactDetailsMap.get(toPrimaryAdmin)?.Name;
            try{                                    
                origLicenseList = [SELECT Id,Name,Sales_License_Primary_Admin_Contact__c FROM Sales_License__c WHERE Sales_License_Primary_Admin_Contact__c=:fromPrimayAdmin];               
                revertLicenseList=[SELECT Id,Name,Sales_License_Primary_Admin_Contact__c FROM Sales_License__c WHERE Sales_License_Primary_Admin_Contact__c=:fromPrimayAdmin];
                for(Sales_License__c salesLicenserec : origLicenseList){
                    salesLicenserec.Sales_License_Primary_Admin_Contact__c=toPrimaryAdmin;                    
                    licenseList.add(salesLicenserec);
                }
                if(!licenseList.isEmpty()){
                    Savepoint sp1 = Database.setSavepoint();
                    Database.SaveResult[] recLicenseList=Database.update(licenseList,false);
                    for(Database.SaveResult iterSaveResultLicense:recLicenseList){
                        if (!iterSaveResultLicense.isSuccess()) {
                            for(Database.Error err : iterSaveResultLicense.getErrors()) {	
                                transferAdmin_License_Map.put(iterSaveResultLicense.getId(),err.getMessage());									
                            }					
                        }
                    }
                    if(!transferAdmin_License_Map.isEmpty())
                    {
                        ByPassingAddErrorOfHost=true;
                        for(Sales_License__c licList :[select id, Name from Sales_License__c where Id=:transferAdmin_License_Map.keySet()]){
                            transferAdminLicenseIdNameMap.put(licList.id,licList.name);
                        }
                        for (String keyOfLicenseRecord : transferAdmin_License_Map.keySet()) {							
                            recordsToMail.add(transferAdminLicenseIdNameMap.get(keyOfLicenseRecord)+','+'License'+','+transferAdmin_License_Map.get(keyOfLicenseRecord));
                        }				
                        List<Sales_Host__c> tempHostList = new List<Sales_Host__c>();
                        List<Sales_Host__c> dummyHostList = [SELECT Id,Name,Sales_Contact__c FROM Sales_Host__c WHERE Sales_Contact__c=:fromPrimayAdmin];
                        for(Sales_Host__c hostrec : dummyHostList){
                            hostrec.Sales_Contact__c=toPrimaryAdmin;
                            tempHostList.add(hostrec);
                        }			
                        if(!tempHostList.isEmpty()){
                            Database.SaveResult[] recHostList=Database.update(tempHostList,false);
                            for(Database.SaveResult iterSaveResultHost:recHostList){
                                if (!iterSaveResultHost.isSuccess()) {
                                    for(Database.Error err : iterSaveResultHost.getErrors()) {	
                                        transferAdmin_Host_Map.put(iterSaveResultHost.getId(),err.getMessage());									
                                    }					
                                }
                            }
                            for(Sales_Host__c suceesHostList: [select id, Name from Sales_Host__c where id in:transferAdmin_Host_Map.keySet()]){
                                transferPriAdminHostIdNameMap.put(suceesHostList.id,suceesHostList.name);
                            }
                            for (String keyOfHostRecord : transferAdmin_Host_Map.keySet()) {								
                                recordsToMail.add(transferPriAdminHostIdNameMap.get(keyOfHostRecord)+','+'Host Information'+','+transferAdmin_Host_Map.get(keyOfHostRecord));
                            }
                        }
                    }						
                    Database.rollback(sp1);	
                    update licenseList;
                }
            }catch(Exception e){
                successLicense=false;                
                Core_Log_Entry.logEntryWithDetails(Sales_TransferPrimaryAdmin.ORIGIN, Sales_TransferPrimaryAdmin.PROJECT,'',Sales_TransferPrimaryAdmin.CRITICALSEVERITY,'Transferring Primary Admin from:'+fromPrimayAdmin+' to:'+toPrimaryAdmin+' .','Error Occurred While transferring Primary Admin on Licenses : '+ e.getMessage()+' , Stack trace: '+e.getStackTraceString(),'', Sales_TransferPrimaryAdmin.LICENSEOBJECTNAME, '');	
            }                                                                 
            if(successLicense==false){
                if(origDelegatedAdminList!=null && !(origDelegatedAdminList).isEmpty()){
                    update origDelegatedAdminList;
                }  
                Sales_TransferPrimaryAdmin.sendEmail(fromPrimayAdmin, toPrimaryAdmin, 'Transfer Primary Admin Operation Failed!', 'This mail is to inform you that the Transfer Primary Admin Operation from '+fromPrimAdmName+' to '+toPrimAdmName+' has Failed!', 'Please try again. If issue persists, please contact IT support at ');
            }else{
                Core_Log_Entry.logEntryWithDetails(Sales_TransferPrimaryAdmin.ORIGIN, Sales_TransferPrimaryAdmin.PROJECT,'',Sales_TransferPrimaryAdmin.INFOSEVERITY,'Transferring Primary Admin from:'+fromPrimayAdmin+' to:'+toPrimaryAdmin+' .','Successfully transferred Primary Admin on Licenses!','','', '');	                
                if(!Test.isRunningTest())
                    System.enqueueJob(new processHostRecords(fromPrimayAdmin,toPrimaryAdmin,revertLicenseList,origDelegatedAdminList));
            }
        }
    }
    public static String getEmailTemplateBody(String subject, String bodyMessage , String errorMessage){        
        String logoUrl = System.Label.Sales_Intel_Logo;       
        List<Object> parameters = new List<Object>{logoUrl, subject, bodyMessage, errorMessage};
            String emailBody ='';
        if(String.isBlank(errorMessage)==false){
            emailBody = System.Label.Sales_TransferAdmin_Email_Body;
        }
        else{
            emailBody=System.Label.Sales_TransferAdmin_Email_Body1;
        }
        String formattedEmailBody = String.format(emailBody, parameters);
        return formattedEmailBody;
    }
    public static void sendEmail(Id fromPrimayAdmin,Id toPrimaryAdmin, String subjectLine, String emailBody, String errorMsg ){
        PRM_Execution_Controls__c t = PRM_Execution_Controls__c.getInstance(UserInfo.getOrganizationId());
        t.BypassValidationInTransferAdmin__c=false;
        update t;
        String ORGWIDE_EMAIL=System.Label.Sales;		
        OrgWideEmailAddress orgWideEmailAdd = [SELECT Id, Address, DisplayName from OrgWideEmailAddress where Address=:ORGWIDE_EMAIL];		
        Id orgId = [Select Id From organization].Id;		
        subjectLine += ' (Source organization: '+String.valueOf(orgId)+')';
        String loggedInUserEmail = [Select Id, Email from User where Id=:UserInfo.getUserId()].Email;		
        List<Messaging.SingleEmailMessage> mails =new List<Messaging.SingleEmailMessage>();    
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> sendTo = new List<String>();
        sendTo.add(loggedInUserEmail); 		
        mail.setToAddresses(sendTo);           
        mail.setSubject(subjectLine); 			
        mail.setHtmlBody(getEmailTemplateBody(subjectLine,emailBody,errorMsg));
        mail.setOrgWideEmailAddressId(orgWideEmailAdd.Id);
        if(attachmentToBeShared==true){
            String csvFile;
            String csvColumnHeader='Record name,Record Type,Issue\n';
            List<String> csvRowValues=new List<String>();
            csvFile=csvColumnHeader+String.join(recordsToMail,'\n');
            Messaging.EmailFileAttachment attach=new Messaging.EmailFileAttachment();
            attach.setContentType('text/csv');
            attach.setFilename('Failed records on ' +  DateTime.now() + '.csv');
            attach.setInline(true);
            attach.Body=Blob.valueOf(csvFile);
            if(attach!=NULL){
                mail.setFileAttachments(new Messaging.EmailFileAttachment[]{attach});
            }
        }
        mails.add(mail);
        if(mails.size()>0){
            Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
            if (results[0].success) 
            {   
            } else {
                Core_Log_Entry.logEntryWithDetails(Sales_TransferPrimaryAdmin.ORIGIN, Sales_TransferPrimaryAdmin.PROJECT,'',Sales_TransferPrimaryAdmin.INFOSEVERITY,'Transferring Primary Admin from:'+fromPrimayAdmin+' to:'+toPrimaryAdmin+' .','Some error occurred during sending Email! Error: '+  results[0].errors[0].message,'','', '');	                
            }
        }
    }*/   
}