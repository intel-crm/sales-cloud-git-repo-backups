public class EventLogCoreExcptnBatchClass implements Database.Batchable<SObject>, Schedulable,Database.AllowsCallouts {
    public String query = 'SELECT Id,EventType,CreatedDate,LogFileLength,LogDate,ApiVersion,LogFileContentType,Sequence,Interval,Logfile,LogFileFieldNames FROM EventLogFile  WHERE EventType = \'ApexUnexpectedException\' AND CreatedDate = LAST_N_DAYS:7';
    list<string> exceptionmsg = new list<string>();
    string classname2;
    //START Method
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }
    
    //EXECUTE Method
    public void execute(Database.BatchableContext bc, List<EventLogFile> elflist) { 
        list<Core_Exceptions__c> coreexcptnList = new list<Core_Exceptions__c>();        
        for (EventLogFile ELF :elflist){           
            Core_Exceptions__c coreexception = new Core_Exceptions__c();            
            try{
                HttpRequest req = new HttpRequest();
                req.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm()+'/services/data/v55.0/sobjects/EventLogFile/'+ELF.Id+'/LogFile');
                req.setMethod('GET');
                req.setHeader('Content-Type', 'application/json;charset=UTF-8');
                req.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
                Http http = new Http();
                HTTPResponse res = http.send(req);
                String resp = res.getBody();
                system.debug('res-->'+resp); 
                String[] data = res.getBody().split('\\n');
                system.debug('data-->'+data[1].split(',')[5]);
                
                for(integer i = 1;i<data.size();i++){
                    exceptionmsg.add(data[i].split(',')[4].replace('"','') +'-' + data[i].split(',')[5] + '\n' + data[i].split(',')[6].replace('"','')); 
                    string str = data[i].split(',')[5];
                    System.debug(str);
                    integer location = str.IndexOf(':');
                    System.debug('location>>>'+location);
                    Integer sIndexValue = str.indexOf(': ');
                    String classname = str.substringAfter(': ');
                    System.debug('sIndexValue>>>'+sIndexValue);
                    System.debug('classname>>>'+classname);
                    
                    If(classname.indexOf('\'') == 0){
                        String classname1 = str.substringAfter('\'');
                        System.debug('classname1>>>'+classname1);                        
                        classname2 = classname1.substringBefore('\'');
                        System.debug('classname2>>>'+classname2);
                        
                        //Assign Class Name
                        coreexception.Core_Class_Name__c = classname2;
                        
                    }else{                       
                        String classname4 = classname.substringBefore('');
                        System.debug('classname4>>>'+classname4);
                        //Assign Class Name
                        coreexception.Core_Class_Name__c = classname4;
                    }        
                }                
            }
            catch (Exception e) {         
                System.debug('Error:' + e.getMessage() + 'LINE:' + e.getLineNumber());           
            }
            //Data Mapping-Copy Data from EventLogFile to Core_Exceptions__c object
            coreexception.Core_Exception__c = exceptionmsg[0];
            coreexception.Core_Unhandled_Exception__c = true;
            coreexcptnList.add(coreexception);        
        }
        insert coreexcptnList;
    }
    
    //FINISH Method 
    public void finish(Database.BatchableContext bc) {
        system.debug('JOB IS FINISHED');
    }    
    
    //Schedulable Batch
    public void execute(SchedulableContext sc) {
        Database.executeBatch(this, 200);
    }
    
}