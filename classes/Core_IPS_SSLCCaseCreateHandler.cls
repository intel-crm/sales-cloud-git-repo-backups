/* Popcornapps 6/13/2018 Fixed Outlook client issue   */
public class Core_IPS_SSLCCaseCreateHandler{
 
    public static String createCase(String emailPlainText ){
        String message=null;
        Boolean jsonFormat=true;
        Map<String, Object> mapCase=null;
        Case cs=new Case();
        // Email json parsing
        try{
           mapCase = (Map<String, Object>)JSON.deserializeUntyped(emailPlainText);
            
        }catch(Exception ex){
            message='JSON Sent is not correct :: '+emailPlainText+'Exception:: '+ex.getMessage();
            jsonFormat=false;
            return message;
           // return null;
        }
        // Case Subject
        /**--US1038991--08/07/2021--HARITHA--FLS Check for security vulnerability--**/        
        if (Schema.sObjectType.Case.fields.subject.isCreateable()) {     cs.subject=(String)mapCase.get('subject'); } 
        Object caseDesc=mapCase.get('Description');
        String jsonDescModified = JSON.serialize(caseDesc);
        jsonDescModified  = jsonDescModified.replaceall('\\",','<br/>');
        jsonDescModified  = jsonDescModified.replaceall('&lt;br/&gt;','<br/>');
        jsonDescModified  = jsonDescModified.replaceall('&lt;br /&gt;','<br/>');
        jsonDescModified  = jsonDescModified.replaceall('\"','');
        jsonDescModified  = jsonDescModified.replaceall('&quot;','"');
        jsonDescModified = jsonDescModified.replaceall('\\}','');
        jsonDescModified = jsonDescModified.replaceall('\\{','');
        // Case Description
        if (Schema.sObjectType.Case.fields.Core_Issue_Description__c.isCreateable()) { /**--US1038991--08/07/2021--HARITHA--FLS Check for security vulnerability--**/        
            cs.Core_Issue_Description__c=jsonDescModified;
        }
        if(cs.Core_Issue_Description__c != null) {
        
            string  strDescValue =  Core_Utility.replaceSpecialChar(cs.Core_Issue_Description__c);
            //cs.Description = Core_Utility.replaceHtmlTags(strDescValue);
            if (Schema.sObjectType.Case.fields.Description.isCreateable()) { /**--US1038991--08/07/2021--HARITHA--FLS Check for security vulnerability--**/        
                cs.Description = jsonDescModified.replaceall('<br/>','\n');
            }  
        }   
        Map<String, Object> mapCaseDescription=(Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(caseDesc));
        // Case Supplied Mail
        if (Schema.sObjectType.Case.fields.SuppliedEmail.isCreateable()) { /**--US1038991--08/07/2021--HARITHA--FLS Check for security vulnerability--**/        
            cs.SuppliedEmail=(String)mapCaseDescription.get('Contact Email');
        }
        //Default Data Setting Up
        //Supported Product
        Core_IPS_SSLCCase_DefaultData__c ProductData=Core_IPS_SSLCCase_DefaultData__c.getInstance('Supported_Product');
        if (Schema.sObjectType.Case.fields.Core_IPS_Product_name__c.isCreateable()) { /**--US1038991--08/07/2021--HARITHA--FLS Check for security vulnerability--**/        
            cs.Core_IPS_Product_name__c=ProductData.Core_IPS_Default_Data__c;
        }
        if (Schema.sObjectType.Case.fields.Core_IPS_Supported_Product__c.isCreateable()) { /**--US1038991--08/07/2021--HARITHA--FLS Check for security vulnerability--**/        
            
        }
        // Project 
        Core_IPS_SSLCCase_DefaultData__c ProjectData=Core_IPS_SSLCCase_DefaultData__c.getInstance('Project');
        if (Schema.sObjectType.Case.fields.Core_IPS_Project_Case__c.isCreateable()) { /**--US1038991--08/07/2021--HARITHA--FLS Check for security vulnerability--**/        
            cs.Core_IPS_Project_Case__c=ProjectData.Core_IPS_Default_data_Id__c;
        }
        // Case Type
        Core_IPS_SSLCCase_DefaultData__c CaseTypeData=Core_IPS_SSLCCase_DefaultData__c.getInstance('Case Type');
        if (Schema.sObjectType.Case.fields.Core_CaseType__c.isCreateable()) {  cs.Core_CaseType__c=CaseTypeData.Core_IPS_Default_Data__c; }  
           /**--US1038991--08/07/2021--HARITHA--FLS Check for security vulnerability--**/        
        //Case Category        
        Core_IPS_SSLCCase_DefaultData__c CaseCategoryData=Core_IPS_SSLCCase_DefaultData__c.getInstance('Case Category');
        if (Schema.sObjectType.Case.fields.Core_External_Issue_Category__c.isCreateable()) { cs.Core_External_Issue_Category__c=CaseCategoryData.Core_IPS_Default_Data__c; }
        /**--US1038991--08/07/2021--HARITHA--FLS Check for security vulnerability--**/     
        if (Schema.sObjectType.Case.fields.Core_Case_Issue_Category__c.isCreateable()) { /**--US1038991--08/07/2021--HARITHA--FLS Check for security vulnerability--**/        
            cs.Core_Case_Issue_Category__c=CaseCategoryData.Core_IPS_Default_data_Id__c;
        }
        //Case SubCategory
        Core_IPS_SSLCCase_DefaultData__c CaseSubCategoryData=Core_IPS_SSLCCase_DefaultData__c.getInstance('Case Subcategory');
        if (Schema.sObjectType.Case.fields.Core_External_Issue_Subcategory__c.isCreateable()) { cs.Core_External_Issue_Subcategory__c=CaseSubCategoryData.Core_IPS_Default_Data__c;}
         /**--US1038991--08/07/2021--HARITHA--FLS Check for security vulnerability--**/        
        if (Schema.sObjectType.Case.fields.Core_Case_Issue_Sub_Category__c.isCreateable()) { /**--US1038991--08/07/2021--HARITHA--FLS Check for security vulnerability--**/        
            cs.Core_Case_Issue_Sub_Category__c=CaseSubCategoryData.Core_IPS_Default_data_Id__c;
        }
        //Case Issue Source
        Core_IPS_SSLCCase_DefaultData__c IssueSourceData=Core_IPS_SSLCCase_DefaultData__c.getInstance('Issue Source');
        if (Schema.sObjectType.Case.fields.Core_IPS_Issue_source__c.isCreateable()) { cs.Core_IPS_Issue_source__c=IssueSourceData.Core_IPS_Default_Data__c; }
        /**--US1038991--08/07/2021--HARITHA--FLS Check for security vulnerability--**/
        // Case Record Type
        String recordTypeNoContactCase = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('IPS No Assigned Contact Case').getRecordTypeId();
        if (Schema.sObjectType.Case.fields.recordtypeID.isCreateable()) { /**--US1038991--08/07/2021--HARITHA--FLS Check for security vulnerability--**/
            cs.recordtypeID =  recordTypeNoContactCase;
        }
        if(jsonFormat){    
            try{        
                insert cs;
            }catch(DmlException e){
                message='Case Insert Problem :: '+JSON.serialize(cs)+'Exception:: '+e.getMessage();
                return message;
             // return null;
            }   
            // Creating environment Detail
            //Getting New EDQ
            Core_IPS_SSLCCase_DefaultData__c EnvDetailsData=Core_IPS_SSLCCase_DefaultData__c.getInstance('Case Subcategory Detail');
            Core_IPS_Response__c lstCoreResponse = new Core_IPS_Response__c();
            if (Schema.sObjectType.Core_IPS_Response__c.fields.Core_IPS_Case__c.isCreateable()) { /**--US1038991--08/07/2021--HARITHA--FLS Check for security vulnerability--**/
                lstCoreResponse.Core_IPS_Case__c =cs.id;
            }
            if (Schema.sObjectType.Core_IPS_Response__c.fields.Core_IPS_Answer__c.isCreateable()) { /**--US1038991--08/07/2021--HARITHA--FLS Check for security vulnerability--**/
                lstCoreResponse.Core_IPS_Answer__c= EnvDetailsData.Core_IPS_Default_Data__c;
            }
            if (Schema.sObjectType.Core_IPS_Response__c.fields.Core_IPS_Question_Master__c.isCreateable()) { /**--US1038991--08/07/2021--HARITHA--FLS Check for security vulnerability--**/
                lstCoreResponse.Core_IPS_Question_Master__c= EnvDetailsData.Core_IPS_Default_data_Id__c;
            }
            insert lstCoreResponse;
            //Old EDQ 
            /*Core_IPS_Environment_Details__c envdet=new Core_IPS_Environment_Details__c();
            envdet.name=EnvDetailsData.Name;
            envdet.Core_Case__c =cs.id;
            envdet.Core_Question__c= EnvDetailsData.Name;
            envdet.Core_Answer__c= EnvDetailsData.Core_IPS_Default_Data__c;
            envdet.Core_Agent_Only__c=true;
            insert envdet;*/
            // Send Mail
            sendMailAfterCaseCreate(cs.id);} return message;
       // return null;
    }
    
    Public static void sendMailAfterCaseCreate(Id caseId){
            Case caseObj=[select id,subject,casenumber,Core_Issue_Description__c ,SuppliedEmail from case where id=:caseId];
            // Step 0: Create a master list to hold the emails we'll send
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            
            // Step 1: Create a new Email
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            EmailTemplate emailTemplate = [Select id,Subject, HtmlValue, Body from EmailTemplate where name =: Label.Core_IPS_SSLC_Case_Create_Template];
            
            // Step 2: Set list of people who should get the email
            List<String> sendTo = new List<String>();
            sendTo.add(caseObj.SuppliedEmail);
            mail.setToAddresses(sendTo);
            mail.setOrgWideEmailAddressId(system.label.Core_IPS_SSLC_From_Address); 

            // Step 3:Optional
            List<String> ccTo = new List<String>();
            ccTo.add(system.label.Core_IPS_SSLC_CC_Address);
            mail.setCcAddresses(ccTo);
            mail.setTemplateId(emailTemplate.id);
            String emailSubject= emailTemplate.Subject;
            emailSubject= emailSubject.replace('{!Case.CaseNumber}', caseObj.CaseNumber);
            emailSubject= emailSubject.replace('{!Case.Subject}', caseObj.Subject); 
        	String htmlBody = emailTemplate.HtmlValue;
        	htmlBody = htmlBody.replace('{!Case.CaseNumber}', caseObj.CaseNumber);	
            htmlBody = htmlBody.replace('{!Case.Subject}', caseObj.Subject);
            htmlBody = htmlBody.replace('{!Case.Description}', caseObj.Core_Issue_Description__c );
            htmlBody = htmlBody.replace('<!','&lt;!');
            htmlBody = htmlBody.replace(']]>',']]&gt;');
            htmlBody = htmlBody.replace('&lt;![CDATA[','');
            htmlBody = htmlBody.replace(']]&gt;','');
           
           /* String plainBody = emailTemplate.Body;
            plainBody= plainBody.replace('{!Case.CaseNumber}', caseObj.CaseNumber);
            plainBody= plainBody.replace('{!Case.Subject}', caseObj.Subject);
            plainBody= plainBody.replace(']]>','');*/
            
            // Step 4. Set email contents - you can use variables!
            mail.setSubject(emailSubject);
            mail.setHtmlBody(htmlBody );
            
            // Step 5. Add your email to the master list
            mails.add(mail);
            // Step 6: Send all emails in the master list
            Messaging.sendEmail(mails);
        }
}