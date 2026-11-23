/****************************************************************************************************************************************
* Class Name  : PMP_TaxonomyUploadQueueable 
* Version     : 1.0 
* Created Date: 04-11-2019
* Modification Log :
* Developer                       Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Infosys - Sangeetha Ganta     04/11/2019                    US329999 - Queueable class for Taxonomy upload
* PMP Team                       05/10/2019                   US358688 - Update
  Yashasvi Aggarwal              07/10/2021                   USTWC1824-880  -  Update
* ****************************************************************************************************************************************/
public with sharing class PMP_TaxonomyUploadQueueable implements Queueable {
    
    @TestVisible private List<String> staticResourceNames = new List<String>();// Lst of modified static resources
    @TestVisible private String currentFileNameToProcess ;// current processing static resource name
    @TestVisible private Map<String,Decimal> processOrderByName = new Map<String,Decimal>();
    @TestVisible private String jobInitiatedFrom ; // Variable to identify from which class the job is running
    @TestVisible private DateTime jobStartTime ; // Variable to capture the job start time
    @TestVisible private Core_Batch_header__c batchHeader; //Fetch email distribution list for the current batch class
    @TestVisible private Core_Batch_Processing__c batchProcessing; // to store batch information
    @TestVisible private Batch_Processing_Line_Item__c batchProcessingLineItem ; // to store batch processing line items data
    @TestVisible private boolean abortProcess ; // to identify category file processing is failed
    @TestVisible private boolean errorOccured ; // If any record got failed in the transcation
    @TestVisible private String errorEmailTemplateName = 'PMP_Error_in_Syncup_of_Taxonomy_files'; //Email template name used to send an email in case of any error occured while processing the file
    @TestVisible private String successEmailTemplateName = 'PMP_Successful_Syncup_of_Taxonomy_files';//Email template name used to send an email after successfylly processing the file
    
    
    //Constructor - initialise few variables
    public PMP_TaxonomyUploadQueueable(List<String> staticResourceNames)
    {
        this.staticResourceNames = staticResourceNames ;
        this.jobInitiatedFrom = 'PMP_TaxonomyUploadQueueable';
        this.jobStartTime = System.Now();
        this.abortProcess = false;
        this.errorOccured = false;
        this.batchProcessing = new Core_Batch_Processing__c();
    }
    public void execute(QueueableContext context) 
    {
        try{   
        //Fetch PMP_TaxonomyUploadQueueable record from Core batch header object
            batchHeader = [Select id,Last_Run_Date_Time__c,Email_Distribution_List__c from Core_Batch_Header__c 
                           WHERE name = :jobInitiatedFrom limit 1];
            
            batchProcessing = new Core_Batch_Processing__c();
            batchProcessing.Batch_Header__c = batchHeader.id;
            batchProcessing.Core_Email_Distribution_List__c = batchHeader.Email_Distribution_List__c;
            batchProcessing.Core_Salesforce_Job_Id__c = context.getJobId();
            batchProcessing.Core_Start_Date_Time__c = jobStartTime; 
            insert batchProcessing;
        
           
            batchProcessingLineItem = new Batch_Processing_Line_Item__c(Batch_Processing__c = batchProcessing.id);
            
            List<Database.UpsertResult> totalRecords = new List<Database.UpsertResult>(); // Total no of records processed 
            String className = '';
            //If any static resource is avaiable for process
            if(!staticResourceNames.isEmpty()) {
                
                currentFileNameToProcess = staticResourceNames[0]; // current processing file name
                
                
                //preparing the class name dynamically based on current staticresource file name
                className = 'PMP_'+currentFileNameToProcess;
                
        
                //instantiating processing class name dynamically
                Type t = Type.forName(className);
                PMP_ProcessTaxonomyJSON processTaxonomy = (PMP_ProcessTaxonomyJSON)t.newInstance();
                
                //processing the data
                totalRecords = processTaxonomy.processData(currentFileNameToProcess);
        
                //inserting processed results info
                abortProcess = createBatchProcessingLineItem(totalRecords,batchProcessingLineItem,currentFileNameToProcess);
                
                
                //Send email about the success/failure records information
                sendEmailNotification();
                
                //remove the first static resource once it is processed    
                staticResourceNames.remove(0);
                
                //if all files are processed the taxonomy platform cache will be cleared
                if(staticResourceNames.size()==0){
                    //Clearing Taxonomy Platform cache as new taxonomies are loaded[US851334]
                    PMP_Utility.clearTaxonomyPlatformCache();
                }
                
                // If no files left or any error on category English file then we have to stop enqueuing jobs else continue for queuing other jobs
                if((staticResourceNames.size()>=1 && !abortProcess)) { // If 
                    //Adding this class as a job on the queue
                    System.enqueueJob(new PMP_TaxonomyUploadQueueable(staticResourceNames));
                } 
                //IPA2.0 - As part of TWC729-7977 commented the reference of publishFutureUpdateOfferings
                /*else
                {   //Calling the batch class to publish and republish the offerings
                    PMP_PublishFutureUpdateOfferings publishFutureUpdateOfferings = new PMP_PublishFutureUpdateOfferings();   
                    Database.executebatch(publishFutureUpdateOfferings,1); 
                }*/
            }           
        }
        catch(Exception e) {
            
            //update batch processing data 
            /*batchProcessing.Core_Email_Distribution_List__c = batchHeader.Email_Distribution_List__c;
            batchProcessing.Core_Salesforce_Job_Id__c = context.getJobId();
            batchProcessing.Core_Start_Date_Time__c = jobStartTime;*/
            batchProcessing.Core_Exception_Log__c= e.getMessage();
            errorOccured = true;
            Upsert batchProcessing;
            
            //remove the first static resource once it is processed (even an exception occured while processing it) 
            staticResourceNames.remove(0);
            
            // If no files left or any error on category English file then only we have to stop enqueuing jobs else continue for queuing jobs
            if(staticResourceNames.size()>=1 && currentFileNameToProcess != 'Hierarchy_English' && !abortProcess) { // If 
                //Adding this class as a job on the queue
                System.enqueueJob(new PMP_TaxonomyUploadQueueable(staticResourceNames));
            }
            //Send email about the failure records/exception information 
            sendEmailNotification();
        }        
    }
    
    /** 
    * @description create batch processing line item record with processed data information
    * @param saveResults - information about the processed data in the form of Database.UpsertResult[]
    * @param batchProcessingLineItem - Batch_Processing_Line_Item__c record instance with initial data
    * @param currentFileNameToProcess - current processed static resource file name
    * @return a Boolean 
    * Method Parameters - Database.UpsertResult[],Batch_Processing_Line_Item__c,String
    */
    @TestVisible
    private Boolean createBatchProcessingLineItem(Database.UpsertResult[] saveResults, Batch_Processing_Line_Item__c batchProcessingLineItem,String currentFileNameToProcess){
        
        Integer successRecordCount=0;
        String errorString='';
        Integer failedRecordCount = 0;
        Boolean shouldAbortProcess = false;
        
        // Iterate through the upsert results   
        for (Database.UpsertResult saveResult : saveResults) {                       
            // fetch all success DML id's in this set
            if(saveResult.isSuccess()) {                
                successRecordCount = successRecordCount+1;
            }
            else {
                failedRecordCount = failedRecordCount + 1;
                errorOccured = true;
                // Operation failed, so get all errors                
                for(Database.Error err : saveResult.getErrors()) { 
                    
                    errorString=errorString + err.getStatusCode() + ': ' + err.getMessage();                       
                } 
                //If any error on category English file the process should get aborted 
                if(currentFileNameToProcess == 'Hierarchy_English') {                       
                    shouldAbortProcess = true;
                }
            }
            
        }       
        //Insert batch processing line item record
        batchProcessingLineItem.Object_Type__c = currentFileNameToProcess;            
        batchProcessingLineItem.Core_Number_of_Updates__c = successRecordCount; 
        batchProcessingLineItem.Exception_Log__c='Total failed records: '+failedRecordCount;
        batchProcessingLineItem.Core_Change_Log__c=errorString;                      
        insert batchProcessingLineItem; 
        
        return shouldAbortProcess;
    }
    
    /** 
    * @description send email to the DL configured in batch header record releated to current class  
    * @return void 
    * Method Parameters - none
    */
    private void sendEmailNotification(){       
        
        //identify the email template name to send email
        String templateName = '';
        if(errorOccured) { // If any error consider error notification email
            templateName = errorEmailTemplateName;
        }else{ // else success notification email
            templateName = successEmailTemplateName;
        }
        
        //Fetch email template based on template name identified above
        EmailTemplate emailTemplate = [SELECT id, Body, subject FROM EmailTemplate WHERE DeveloperName =:templateName LIMIT 1];
        
        //get email body
        String plainBody = emailTemplate.Body; 
        
        //replace the file name( a static text in email template) with current static resouce name 
        plainBody = plainBody.replace('<Filename>', currentFileNameToProcess);// Replace the file name dynamically 
        
        //preparing single email message
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();        
        List<string> emailRecipientlist = new List<string>();
        emailRecipientlist.add(batchHeader.Email_Distribution_List__c);// Add email DL list 
        //emailRecipientlist.add('hariprakashX.narasanna@intel.com');//TODO : remove this after testing
        //emailRecipientlist.add('sangeethax.ganta@intel.com');
        email.setSubject(emailTemplate.subject);//set subject
        email.setToAddresses(emailRecipientlist);// set to address
        email.setPlainTextBody(plainBody);// set plain text body
        
        //send email 
        Messaging.SendEmailResult [] emailResult = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});    
    }
    
    /*************script to schduled this class************/
    // PMP_ScheduleTaxonomyUpload testschedule = new PMP_ScheduleTaxonomyUpload();
    // System.schedule('PMP_ScheduleTaxonomyUpload', '0 20 * * * ?', testschedule);  
}