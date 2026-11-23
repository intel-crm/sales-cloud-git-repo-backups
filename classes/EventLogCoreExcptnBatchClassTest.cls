@isTest 
public class EventLogCoreExcptnBatchClassTest {
    public static testMethod void testMethod1() 
    { 
        list<string> exceptionmsg = new list<string>();
        List<EventLogFile> EventLogFilelist=  [SELECT Id,EventType,CreatedDate,LogFileLength,LogDate,ApiVersion,LogFileContentType,Sequence,Interval,Logfile,LogFileFieldNames FROM EventLogFile  WHERE EventType = 'ApexUnexpectedException' AND CreatedDate = LAST_N_DAYS:7];
        list<Core_Exceptions__c> coreexcptnList = new list<Core_Exceptions__c>();  
        for (EventLogFile ELF :EventLogFilelist){   
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('Success');
            res.setStatusCode(200);
            String[] data = res.getBody().split('\\n');
            for(integer i = 1;i<data.size();i++){
                exceptionmsg.add(data[i].split(',')[4].replace('"','') +'-' + data[i].split(',')[5] + '\n' + data[i].split(',')[6].replace('"',''));                     
                string str = data[i].split(',')[5];
                System.debug(str);
                integer location = str.IndexOf(':');
                Integer sIndexValue = str.indexOf(': ');
                String classname = str.substringAfter(': ');
            }
        }     
            Core_Exceptions__c coreexception = new Core_Exceptions__c(); 
            coreexception.Core_Class_Name__c = 'Test'; 
            coreexception.Core_Exception__c = 'TestMessage';
            coreexception.Core_Unhandled_Exception__c = true;
            coreexcptnList.add(coreexception);     
            insert coreexcptnList;
            
            Test.setMock(HttpCalloutMock.class, new EventLogCoreExcptnBatchClassMock());
            Test.startTest();
            Id batchJobId = Database.executeBatch(new EventLogCoreExcptnBatchClass(), 200);
            Test.stopTest();
        }
    }