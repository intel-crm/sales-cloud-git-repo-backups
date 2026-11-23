/***************************************************************************
Class Name    : Sales_TransferPrimaryAdminBatch
Version       : 1.0
Created Date  : 10 March 2023           
Modification Log :
* Developer                 Date                    Description
* ------------------------------------------------------------------------------------------------------------------------
* Ranjit        10/03/2023              Batch Class to handle the transfer of records for Primary Admin.
*****************************************************************************************************************************************/
global class Sales_TransferPrimaryAdminBatch implements Database.Batchable<sObject>, Database.Stateful {
    global Map<String,String> objToLabelList=new Map<String,String>{
        'Sales_License_Admin_Delegate__c'=>'License Admin Delegate',
            'Sales_License__c'=>'License',
            'Sales_Host__c'=>'Host'};
                
    global List<string> objList= new list<string>{'Sales_License_Admin_Delegate__c','Sales_License__c','Sales_Host__c'};
    global Map<Id,Contact> contactDetailsMap;
    global string fromPrimAdmName;
    global string toPrimAdmName;
    global string fromPrimaryAdmin;
    global string toPrimaryAdmin;
    global integer index=0;
    global static final string CRITICALSEVERITY = 'Critical';
    global static final string PROJECT = 'PSG Sales';
    global  Map<String,List<RecordWrapper>> errorMap=new Map<String,List<RecordWrapper>>();
    global  Map<String,Integer> objTotalCountMap=new Map<String,Integer>();
    global Sales_TransferPrimaryAdminBatch(Id fromCon, Id toCon){
        this.fromPrimaryAdmin = fromCon;
        this.toPrimaryAdmin = toCon;
    }
    public Database.QueryLocator start(Database.BatchableContext BC){
        contactDetailsMap= new Map<Id,Contact>([SELECT Id,Name,Email FROM Contact WHERE Id=:fromPrimaryAdmin OR Id=:toPrimaryAdmin]);
        fromPrimAdmName=contactDetailsMap.get(fromPrimaryAdmin)?.Name;
        toPrimAdmName=contactDetailsMap.get(toPrimaryAdmin)?.Name;
        String obj=objList[index];
        String query;
        if(obj=='Sales_License_Admin_Delegate__c'){ 
            query='SELECT Id,Name, Sales_License_PrimaryAdmin_Contact__c, Sales_License_isActive__c FROM Sales_License_Admin_Delegate__c WHERE Sales_License_PrimaryAdmin_Contact__c =: fromPrimaryAdmin AND Sales_License_isActive__c = true';
        }else if(obj=='Sales_License__c'){
            query='SELECT Id,Name,Sales_License_Primary_Admin_Contact__c FROM Sales_License__c WHERE Sales_License_Primary_Admin_Contact__c=:fromPrimaryAdmin';
        }else if(obj=='Sales_Host__c'){
            query='SELECT Id,Name,Sales_Contact__c FROM Sales_Host__c WHERE Sales_Contact__c=:fromPrimaryAdmin';
        }        
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC,List<sObject> records){
        string obj=objList[index]; 
        try{ 
            if(obj=='Sales_License_Admin_Delegate__c'){
                Integer count=objTotalCountMap.containsKey(obj)    ?      objTotalCountMap.get(obj)     : 0;
                List<Sales_License_Admin_Delegate__c> delegatedAdminList = new List<Sales_License_Admin_Delegate__c>();                
                for(Sales_License_Admin_Delegate__c record:(List<Sales_License_Admin_Delegate__c> )records){ 
                    count=count+1;
                    record.Sales_License_PrimaryAdmin_Contact__c=toPrimaryAdmin;
                    delegatedAdminList.add(record);
                }
                if(!delegatedAdminList.isEmpty()){
                    List<Database.SaveResult> result=Database.update(delegatedAdminList,false);
                    List<RecordWrapper> errorList= errorMap.containsKey(obj) ? errorMap.get(obj) : new List<RecordWrapper>();
                    for(Integer i=0;i<result.size(); i++){
                        Database.SaveResult sr= result[i];
                        if (!sr.isSuccess()) {
                            String msg=getErrorAsString(sr.getErrors());
                            errorList.add(new RecordWrapper(sr.getId(),delegatedAdminList[i].Name,'Failure',msg));
                        }                        
                    }
                    errorMap.put(obj,errorList); 
                } 
                objTotalCountMap.put(obj,count);
            }else if(obj=='Sales_License__c'){
                List<Sales_License__c> licenseList = new List<Sales_License__c>();
                Integer count=objTotalCountMap.containsKey(obj)  ?  objTotalCountMap.get(obj)  : 0;
                for(Sales_License__c salesLicenserec:(List<Sales_License__c>)records){
                    count=count+1;
                    salesLicenserec.Sales_License_Primary_Admin_Contact__c=toPrimaryAdmin;                    
                    licenseList.add(salesLicenserec);
                }
                if(!licenseList.isEmpty()){
                    List<Database.SaveResult> result=Database.update(licenseList,false);
                    List<RecordWrapper> errorList= errorMap.containsKey(obj) ? errorMap.get(obj) : new List<RecordWrapper>();
                    for(Integer i=0;i<result.size(); i++){
                        Database.SaveResult sr = result[i];
                        if (!sr.isSuccess()) {
                            String msg=getErrorAsString(sr.getErrors());
                            errorList.add(new RecordWrapper(sr.getId(),licenseList[i].Name,'Failure',msg));
                        }                        
                    }
                    errorMap.put(obj,errorList); 
                } 
                objTotalCountMap.put(obj,count);
            }else if(obj=='Sales_Host__c'){                
                List<Sales_Host__c> hostList = new List<Sales_Host__c>();
                Integer count=objTotalCountMap.containsKey(obj)  ?  objTotalCountMap.get(obj)  : 0;                
                for(Sales_Host__c hostrec : (List<Sales_Host__c>)records){
                    count=count+1;
                    hostrec.Sales_Contact__c=toPrimaryAdmin;
                    hostList.add(hostrec);
                }
                if(!hostList.isEmpty()){
                    List<Database.SaveResult> result=Database.update(hostList,false);
                    List<RecordWrapper> errorList= errorMap.containsKey(obj) ? errorMap.get(obj) : new List<RecordWrapper>();
                    for(Integer i=0;i<result.size(); i++){
                        Database.SaveResult sr = result[i];
                        if (!sr.isSuccess()) {
                            String msg=getErrorAsString(sr.getErrors());
                            errorList.add(new RecordWrapper(sr.getId(),hostList[i].Name,'Failure',msg));
                        }                        
                    }
                    errorMap.put(obj,errorList);
                }
                objTotalCountMap.put(obj,count);                
            }
        }catch(Exception e){     
            Core_Log_Entry.logEntryWithDetails(obj, Sales_TransferPrimaryAdmin.PROJECT,'',Sales_TransferPrimaryAdmin.CRITICALSEVERITY,'Transferring Primary Admin from:'+fromPrimaryAdmin+' to:'+toPrimaryAdmin+' .','Error Occurred While transferring Primary Admin on '+ obj +' : '+ e.getMessage()+' , Stack trace: '+e.getStackTraceString(),'', obj, '');
        }        
    }
    public void finish(Database.BatchableContext BC){
        //List<RecordWrapper> errorlst=new List<RecordWrapper>();
        List<Messaging.EmailFileAttachment> attachList=new List<Messaging.EmailFileAttachment>();
        if(index+1==objList.size()){
            PRM_Execution_Controls__c customSettingRec = PRM_Execution_Controls__c.getInstance(userInfo.getUserId());
            delete customSettingRec;
            String tableBody='License Transfer Result from  ' + '<b>'+fromPrimAdmName+ '</b>' + ' to  '+ '<b>'+toPrimAdmName+ '</b> '+'<br></br> <table class="t">';
            tableBody+='<tr><th class="t2">Object Name</th><th class="t2">Total Records</th><th class="t2">Success</th><th class="t2">Failure</th></tr>';
            for(String obj:objList){
                Integer totalCount=objTotalCountMap.containsKey(obj)?objTotalCountMap.get(obj):0;
                Integer failures=(errorMap.containsKey(obj) && errorMap.get(obj)!=null)?errorMap.get(obj).size():0;
                Integer success=totalCount-failures;
                tableBody+='<tr><td class="t1">'+objToLabelList.get(obj)+'</td><td class="t1">'+totalCount+'</td><td class="t1">'+success+'</td><td class="t1">'+failures+'</td></tr>';
                if(errorMap.containsKey(obj) && !errorMap.get(obj).isEmpty()){
                    List<RecordWrapper> errList=errorMap.get(obj);
                    String csvContent='Id,Record Number,Result,Error Message\n';
                    for(RecordWrapper rw: errList){
                        csvContent=csvContent+''+rw.recordId+','+rw.Name+','+rw.Result+','+rw.Message+'\n';                 
                    }
                    Messaging.EmailFileAttachment attach=new Messaging.EmailFileAttachment();
                    attach.setContentType('text/csv');
                    attach.setFilename(objToLabelList.get(obj) + '.csv');
                    attach.setInline(true);
                    attach.Body=Blob.valueOf(csvContent); 
                    attachList.add(attach);
                }
            }
            tableBody+='</table>';
            String subjectLine='';
            EmailTemplate tempId = [SELECT Id, HTMLValue,Subject, Body, Name FROM EmailTemplate WHERE DeveloperName = 'Sales_TransferPrimaryAdminBatch_Email_Template']; 
            Id orgId = [Select Id From organization].Id;			        
            subjectLine += '( Source organization: '+String.valueOf(orgId)+' )';
            String ORGWIDE_EMAIL=System.Label.Sales;
            String loggedInUserEmail = [Select Id, Email from User where Id=:UserInfo.getUserId()].Email;
            OrgWideEmailAddress orgWideEmailAdd = [SELECT Id, Address, DisplayName from OrgWideEmailAddress where Address=:ORGWIDE_EMAIL limit 1];
            List<String> sendTo = new List<String>();
            sendTo.add(loggedInUserEmail);
            Savepoint sp = Database.setSavepoint();
            Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();
            mail1.setTemplateId(tempId.Id);
            mail1.setTargetObjectId(Userinfo.getUserId());
            mail1.setToAddresses(new List<String>{Userinfo.getUserEmail()});
            mail1.setSaveAsActivity(false);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail1});
            Database.rollback(sp);      
            String emailBody=mail1.getHtmlBody();
            emailBody=emailBody.replace('OUTPUT_TABLE_COMES_HERE',tableBody );
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setOrgWideEmailAddressId(orgWideEmailAdd.Id);
            mail.setToAddresses(sendTo);
            mail.setHtmlBody(emailBody);
            mail.setSubject(subjectLine);
            if(!attachList.isEmpty()){
                mail.setFileAttachments(attachList);
            }
            Messaging.SendEmailResult[] result = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
        }else{
            Sales_TransferPrimaryAdminBatch tpBatch=new Sales_TransferPrimaryAdminBatch(fromPrimaryAdmin,toPrimaryAdmin);
            tpBatch.index=index+1;
            tpBatch.errorMap=errorMap;
            tpBatch.objTotalCountMap=objTotalCountMap;
            tpBatch.fromPrimaryAdmin=fromPrimaryAdmin;
            tpBatch.toPrimaryAdmin=toPrimaryAdmin;
            Database.executeBatch(tpBatch,Integer.ValueOf(System.Label.Sales_TransferPrimaryAdminBatchSize));
        }       
    }
    public class RecordWrapper{
        public String recordId;
        public String Name;
        public String Result;
        Public String Message;
        public RecordWrapper(String recordId,String Name,String Result,String Message){
            this.recordId=recordId;
            this.Name=Name;
            this.Result=Result;
            this.Message=Message;
        }
    }
    public String getErrorAsString(Database.Error[] errors){
        List<String> errorList=new List<String>();
        for(Database.Error error:errors){
            if(error.getMessage()!=null){
                errorList.add(error.getMessage());
            }
        }
        return String.join(errorList, ';');
    }
}