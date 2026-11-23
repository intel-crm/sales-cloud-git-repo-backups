/********************************************************************************************************************************************************************
Apex Class Name: CRM_Alertwatch 
Version: 1.0
Created Date: 11/11/2024
Function: Alert Watch is used to send emails based on Audit Trail data
Modification Log :
* Developer Date Description
* ----------------------------------------------------------------------------
* Shijas KM 11/11/2024 Original Version developed
*******************************************************************************************************************************************************************/
public with sharing class CRM_Alertwatch {    
    public static void GetAuditTrailData(){
       
        List<SetupAuditTrail> lst_aw_response= new List<SetupAuditTrail>();
        Try{
            String excludedUsersEmailLabel = getAlertwatchValues('AuditTrailExcludedUserEmails');
            String sectionsLabel = getAlertwatchValues('AuditTrailSections'); 
            // Split the excluded user names into a list
            List<String> excludedUsersList = excludedUsersEmailLabel.split(';');
            List<String> sectionsList = sectionsLabel.split(';');
            // Construct the dynamic query
            String query = 'SELECT ';
             if (String.isNotBlank(getAlertwatchValues('AuditTrailSelectFields'))) {            
                query = query  + getAlertwatchValues('AuditTrailSelectFields');
            }
            
             if (String.isNotBlank(getAlertwatchValues('AuditTrailWhereCondition'))) {            
                query = query +  ' FROM SetupAuditTrail WHERE ' + getAlertwatchValues('AuditTrailWhereCondition');
            }
            // Add conditions for excluded user names
            if (!excludedUsersList.isEmpty()) {
                query += ' AND CreatedBy.Email NOT IN (\'' + String.join(excludedUsersList, '\',\'') + '\')';
            } 
            query += ' ORDER BY CreatedDate DESC';
            
            List<SetupAuditTrail> lstAuditTrail = Database.query(query);
            for (SetupAuditTrail rec : lstAuditTrail) {
                if (sectionsList.contains(rec.Section)) {
                    lst_aw_response.add(rec);                    
                }
            }           
            SendEmail(lst_aw_response);          
            
        }catch (Exception e) {
          
           // logEntries.add(new Core_Log_Entry__c(Core_Message__c = 'Message',Core_Details__c = e.getStackTraceString() , Core_Origin__c='AlertWatch', Core_Severity__c='Low', Core_When__c=System.Now(), Core_Project__c = 'Sales CRM'));    
        }
        finally { }
    }
    
    //Email Attachment CSV file creation
    private static Messaging.EmailFileAttachment generateCSVFile(List<SetupAuditTrail> lst_aw_response){
        String csvContent = 'Id,Modified Component,Modified By,Modified Date, Modification Details,Action\n';
        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        attachment.setContentType('text/csv');
        attachment.setFilename('AuditTrail_Notification' +'.csv');
        attachment.setInline(true);
        if(!lst_aw_response.isempty()){            
            for (SetupAuditTrail awData : lst_aw_response)
            {
                if (!String.isBlank(awData.Id)  && !String.isEmpty(awData.Id))
                {
                    string strModifiedDetails = String.escapeSingleQuotes(awData.Display);
                    strModifiedDetails  = strModifiedDetails.replace(',',' ');                
                    strModifiedDetails  = strModifiedDetails.replace('"',' ');               
                    strModifiedDetails  = strModifiedDetails.replace('\n',' ');
                    strModifiedDetails  = strModifiedDetails.replace('\r',' ');
                    csvContent = csvContent + ''+ awData.Id +','  + awData.Section + ',' +  awData.CreatedBy.Name + ',' + awData.CreatedDate + ','+ strModifiedDetails +  ','+ awData.Action + '\n';
                }
            } 
        }
        else
        {
            csvContent = csvContent + 'No Audit Trail Data Available';
        }
        if (String.isNotBlank(csvContent))
        {
            attachment.Body = (Blob.valueOf(csvContent));
        }
        return attachment;
    }     
    // Audit Trail email send with csv as attachment
    @TestVisible
    private static void SendEmail(List<SetupAuditTrail> lst_aw_response)
    {  
        List<OrgWideEmailAddress> orgWideEmailList = [select id, address from OrgWideEmailAddress where displayname = :'Intel Corporation-NoReply' limit 1];
        String orgWideEmailId = (orgWideEmailList!=null && orgWideEmailList.size()>0) ? orgWideEmailList[0].id : '';
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        List<User> lstUser  = [SELECT Id,Name FROM User WHERE Id IN ( SELECT UserOrGroupId  FROM GroupMember WHERE Group.Name ='Core_AlertWatchMembers')];
        for (User euser : lstUser)
        {               
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTargetObjectId(euser.Id); // Set the recipient's ID
            mail.setSaveAsActivity(false); // Must be false when sending to users
            mail.setOrgWideEmailAddressId(orgWideEmailId); 
             if (String.isNotBlank(getAlertwatchValues('AuditTrailsetReplyTo')))
        {      
            mail.setReplyTo(getAlertwatchValues('AuditTrailsetReplyTo'));  
            }      
            mail.setSubject('DEVSLS : Salesforce Audit Trail Notification'); 
            mail.setFileAttachments(new Messaging.EmailFileAttachment[] {generateCSVFile(lst_aw_response)}); 
            mail.setHtmlBody('Hi '+euser.Name + '<BR><BR>' +  'Please find the attached '+ '<B>'+ 'Audit Trail Details.' + '</B><BR><BR>' + 'Thanks' + '<BR>' + 'SF Team');          
            emails.add(mail);
        }
        Messaging.sendEmail(emails);
        
        system.debug('---------------Core_AlertWatch--------execute complete------' );
    }
    //Get alertwatchValue from Custom settings

    public static String getAlertwatchValues(String name){
// List<Core_MDF_CCP_Custom_Metadata_Utility__c> actDepMdtList = new List<Core_MDF_CCP_Custom_Metadata_Utility__c>();
       // List<Core_MDF_CCP_Custom_Metadata_Utility__c> metadataRecords = [SELECT ID FROM Core_MDF_CCP_Custom_Metadata_Utility__c];
      // List<Core_MDF_CCP_Custom_Metadata_Utility__c> mcs = Core_MDF_CCP_Custom_Metadata_Utility__c.getAll().values();
		// List<Core_MDF_CCP_Custom_Metadata_Utility__c> metaDataValues = new List<Core_MDF_CCP_Custom_Metadata_Utility__c>();
             //Core_MDF_Custom_Metadata_Utility.getCustomObjectRecords(whereClause);
        
        CRM_Alertwatch__c alertwatchValue = CRM_Alertwatch__c.getValues(name);
        
        if(alertwatchValue!=null){
            return alertwatchValue.AuditTrail_Value__c;
        }else{
            return '';
        }
    }
}