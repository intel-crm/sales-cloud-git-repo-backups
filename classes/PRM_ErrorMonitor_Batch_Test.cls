@isTest
public class PRM_ErrorMonitor_Batch_Test {
    @TestSetup
    //test data creation
    static void setupData(){   
        
        List<Account> listacc=new List<Account>();
        List<PRM_Value_Exchange_Recommendation__c> listrecom = new List<PRM_Value_Exchange_Recommendation__c>();
        List<Core_OnePartner_Inbound_Message__c> inbList = new List<Core_OnePartner_Inbound_Message__c>();
        List<Monitor_Log__c> logList = new List<Monitor_Log__c>();
        
        
        
        Account acc = new Account();
        acc.Name ='Testfname';
        acc.Core_Account_Type__c ='Distributor';
        acc.Industry ='Agriculture';
        acc.Core_IPA_Partner_Role__c = 'Service Provider';
        acc.Core_Account_Type__c='Cloud Service Provider (CSP)';
        acc.BillingCity='213123Bengaluru';
        acc.BillingCountry='India';
        acc.BillingStreet='214212th Floor,ITPL,Brookfield';
        acc.BillingPostalCode='560037323';
        acc.Core_User_Defined_Website__c = 'www.yxyzabc.com';
        listacc.add(acc); 
        //system.debug('Account'+acc);
        
        Account acn = new Account();
        acn.Name ='Testlname';
        acn.Core_Account_Type__c ='Distributor';
        acn.Industry ='Agriculture';
        acn.Core_IPA_Partner_Role__c = 'Service Provider';
        acn.Core_Account_Type__c='Cloud Service Provider (CSP)';
        acn.BillingCity='Bengaluru343434';
        acn.BillingCountry='India';
        acn.BillingStreet='32324th Floor,ITPL,Brookfield';
        acn.BillingPostalCode='2323560037';
        acn.Core_User_Defined_Website__c = 'www.testabc.com';
        listacc.add(acn); 
        
        
        Account act = new Account();
        act.Name ='Testname';
        act.Core_Account_Type__c ='Distributor';
        act.Industry ='Agriculture';
        act.Core_IPA_Partner_Role__c = 'Service Provider';
        act.Core_Account_Type__c='Cloud Service Provider (CSP)';
        act.BillingCity='123Bengaluru';
        act.BillingCountry='India';
        act.BillingStreet='4th Floor,ITPL,Brookfield';
        act.BillingPostalCode='3232560037';
        act.Core_User_Defined_Website__c = 'www.hujhabc.com';
        listacc.add(act);
        
        Account acnt = new Account();
        acnt.Name ='Testflname';
        acnt.Core_Account_Type__c ='Distributor';
        acnt.Industry ='Agriculture';
        acnt.Core_IPA_Partner_Role__c = 'Service Provider';
        acnt.Core_Account_Type__c='Cloud Service Provider (CSP)';
        acnt.BillingCity='Bengaluru2133';
        acnt.BillingCountry='India';
        acnt.BillingStreet='32r2434th Floor,ITPL,Brookfield';
        acnt.BillingPostalCode='560037';
        acnt.Core_User_Defined_Website__c = 'www.ewreweabc.com';
        
        Account accnt = new Account();
        accnt.Name ='Testaccname';
        accnt.Core_Account_Type__c ='Distributor';
        accnt.Industry ='Agriculture';
        accnt.Core_IPA_Partner_Role__c = 'Service Provider';
        accnt.Core_Account_Type__c='Cloud Service Provider (CSP)';
        accnt.BillingCity='4532Bengaluru';
        accnt.BillingCountry='India';
        accnt.BillingStreet='32243424th Floor,ITPL,Brookfield';
        accnt.BillingPostalCode='560037121';
        accnt.Core_User_Defined_Website__c = 'www.erfrabc.com';
        listacc.add(accnt);
        
        Account acc1 = new Account();
        acc1.Name ='TestBatchFailure';
        acc1.Core_Account_Type__c ='Distributor';
        acc1.Industry ='Agriculture';
        acc1.Core_IPA_Partner_Role__c = 'Service Provider';
        acc1.Core_Account_Type__c='Cloud Service Provider (CSP)';
        acc1.BillingCity='3424Bengaluru1231';
        acc1.BillingCountry='India';
        acc1.BillingStreet='1231234th Floor,ITPL,Brookfield5432';
        acc1.BillingPostalCode='56003712312';
        acc1.Core_User_Defined_Website__c = 'www.dfdfdabc.com';
        listacc.add(acc1);
        
        
        insert listacc;
        
        ChannelProgram cp = new ChannelProgram(); 
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        
        ChannelProgramLevel cpl=new ChannelProgramLevel();
        cpl.Name='Gold';
        cpl.ProgramId=cp.Id;
        insert cpl;
        
        for(Account account : listacc){
            PRM_Value_Exchange_Recommendation__c recm = new PRM_Value_Exchange_Recommendation__c();
            recm.PRM_Account_Id__c = account.Id;
            recm.PRM_Tier_Id__c = cpl.Id;
            recm.PRM_Partner_Role_Nm__c = account.Core_IPA_Partner_Role__c;
            recm.PRM_Recommendation_Type_Nm__c = 'OPID';
            recm.PRM_Recommendation_Status_Nm__c = 'In Process' ;
            recm.PRM_Grouping_Method_Nm__c = 'LINEOFBUSNS';
            listrecom.add(recm);
        }
        
        
        
        PRM_Value_Exchange_Recommendation__c recm = new PRM_Value_Exchange_Recommendation__c();
        recm.PRM_Account_Id__c = acc.Id;
        recm.PRM_Tier_Id__c = cpl.Id;
        recm.PRM_Partner_Role_Nm__c = acc.Core_IPA_Partner_Role__c;
        recm.PRM_Recommendation_Type_Nm__c = 'OPID';
        recm.PRM_Recommendation_Status_Nm__c = 'In Process' ;
        recm.PRM_Grouping_Method_Nm__c = 'LINEOFBUSNS';
        listrecom.add(recm);
        //system.debug('OPID Recm --> '+recm);
        
        PRM_Value_Exchange_Recommendation__c recm1 = new PRM_Value_Exchange_Recommendation__c();
        recm1.PRM_Account_Id__c = acn.Id;
        recm1.PRM_Tier_Id__c = cpl.Id;
        recm1.PRM_Partner_Role_Nm__c = acn.Core_IPA_Partner_Role__c;
        recm1.PRM_Recommendation_Type_Nm__c = 'OPID';
        recm1.PRM_Recommendation_Status_Nm__c = 'In Process';
        recm1.PRM_Grouping_Method_Nm__c = 'LINEOFBUSNS';
        listrecom.add(recm1);
        //system.debug('OPID Recm --> '+recm1);
        
        PRM_Value_Exchange_Recommendation__c recm4 = new PRM_Value_Exchange_Recommendation__c();
        recm4.PRM_Account_Id__c = acn.Id;
        recm4.PRM_Tier_Id__c = cpl.Id;
        recm4.PRM_Partner_Role_Nm__c = acn.Core_IPA_Partner_Role__c;
        recm4.PRM_Recommendation_Type_Nm__c = 'OPID';
        recm4.PRM_Recommendation_Status_Nm__c = 'In Process';
        recm4.PRM_Grouping_Method_Nm__c = 'LINEOFBUSNS';
        listrecom.add(recm4);
        TriggerHandler.bypass('PRM_VXRecommendation_Handler');
        insert listrecom;
        TriggerHandler.clearbypass('PRM_VXRecommendation_Handler');
        
        list<PRM_Value_Exchange_Recommendation__c> updateLst=new list<PRM_Value_Exchange_Recommendation__c>();
        PRM_Value_Exchange_Recommendation__c recm2 = [select id,PRM_Recommendation_Status_Nm__c from 
                                                      PRM_Value_Exchange_Recommendation__c where id =:recm1.id];
        
        recm2.PRM_Recommendation_Status_Nm__c = 'Failed';
        
        updateLst.add(recm2);
        
        PRM_Value_Exchange_Recommendation__c recm3 = [select id,PRM_Account_Id__c, PRM_Recommendation_Status_Nm__c from 
                                                      PRM_Value_Exchange_Recommendation__c where id =:recm.id];
        
        recm3.PRM_Recommendation_Status_Nm__c = 'Waiting for CIM response' ;
        
        
        updateLst.add(recm3);
        
        update updateLst;
        for(PRM_Value_Exchange_Recommendation__c  rec: listrecom){
            Core_OnePartner_Inbound_Message__c inb = new Core_OnePartner_Inbound_Message__c();
            inb.Core_SalesCloud_AccountID__c = acc.Id;
            inb.Error_Description__c = 'ERROR';        
            inbList.add(inb);
        }
        
        
        Core_OnePartner_Inbound_Message__c inb = new Core_OnePartner_Inbound_Message__c();
        inb.Core_SalesCloud_AccountID__c = acc.Id;
        inb.Error_Description__c = 'ERROR';        
        inbList.add(inb);
        
        
        
        Datetime yesterday = Datetime.now().addDays(-1);
        Test.setCreatedDate(recm.Id, yesterday);
        Test.setCreatedDate(recm1.Id, yesterday);
        
        Datetime dt = Datetime.now().addDays(-2);
        
        PRM_ErrorMonitor_Batch obj = new PRM_ErrorMonitor_Batch();
        obj.execute(null,listrecom);
        
        Monitor_Log__c mLog = new Monitor_Log__c();
        mLog.Account_ID__c = act.Id;
        mLog.Status__c = 'Failed';
        mLog.Integration_Type__c = 'Opid Not Received';
        mLog.Error_Message__c = 'Inbound Not Received';
        logList.add(mLog); 
        
        Monitor_Log__c mLog1 = new Monitor_Log__c();
        mLog1.Account_ID__c = acnt.Id;
        mLog1.Status__c = 'Failed';
        mLog1.Integration_Type__c = 'Opid Not Received';
        mLog1.Error_Message__c = 'Inbound Not Received';      
        logList.add(mLog1); 
        
        Monitor_Log__c mLog2 = new Monitor_Log__c();
        mLog2.Account_ID__c = accnt.Id;
        mLog2.Status__c = 'Failed';
        mLog2.Integration_Type__c = 'Opid Inbound Failure';
        mLog2.Error_Message__c = 'ERROR';
        logList.add(mLog2);
        
        Insert logList;
        
        
        
        Test.setCreatedDate(mLog.Id, dt);
        Test.setCreatedDate(mLog1.Id, dt);
        Test.setCreatedDate(mLog2.Id, dt);
        
        Datetime tomorrow = Datetime.now().addDays(2);
        
        Core_OnePartner_Inbound_Message__c inb1 = new Core_OnePartner_Inbound_Message__c();
        inb1.Core_SalesCloud_AccountID__c = mLog.Account_ID__c;
        inbList.add(inb1);
        
        Core_OnePartner_Inbound_Message__c inb2 = new Core_OnePartner_Inbound_Message__c();
        inb2.Core_SalesCloud_AccountID__c = mLog1.Account_ID__c;
        inb2.Error_Description__c = 'ERROR';
        inbList.add(inb2);
        
        Core_OnePartner_Inbound_Message__c inb3 = new Core_OnePartner_Inbound_Message__c();
        inb3.Core_SalesCloud_AccountID__c = mLog2.Account_ID__c;
        inb3.Error_Description__c = 'ERROR';
        inbList.add(inb3);
        
        
        
        Insert inbList;
        
        
        Test.setCreatedDate(inb1.Id, tomorrow);
        Test.setCreatedDate(inb2.Id, tomorrow);
        Test.setCreatedDate(inb3.Id, tomorrow);
        
    } 
    @isTest
    public static void testError(){
        Test.startTest();
        
        PRM_ErrorMonitorScheduler batchschedule = new PRM_ErrorMonitorScheduler();
        String cronExpression = '0 0 0/1 1/1 * ? *';
        system.schedule('Batch Test' , cronExpression , batchschedule);
        
        Test.stopTest();
    }
    
    @isTest
    public static void testError1(){
        
        PRM_Value_Exchange_Recommendation__c recm2 = [select id,PRM_Recommendation_Status_Nm__c, PRM_Account_Id__c
                                                      from PRM_Value_Exchange_Recommendation__c limit 1 ];
        
        recm2.PRM_Recommendation_Status_Nm__c = 'OPID In Process';
        Update recm2;
        
        Datetime oldDate = Datetime.now().addDays(-10);
        
        Core_OnePartner_Inbound_Message__c inb101 = new Core_OnePartner_Inbound_Message__c();
        inb101.Core_SalesCloud_AccountID__c = recm2.PRM_Account_Id__c;
        inb101.CreatedDate = oldDate;       
        
        insert inb101;
        
        Test.startTest();        
        PRM_ErrorMonitorScheduler batchschedule = new PRM_ErrorMonitorScheduler();
        String cronExpression = '0 0 0/1 1/1 * ? *';
        system.schedule('Batch Test' , cronExpression , batchschedule);
        
        Test.stopTest();
        
    }
    
    @isTest
    public static void test3(){
        Set<Id> setOfRec = new Set<Id>();
        List<Core_OnePartner_Inbound_Message__c> inbList = new List<Core_OnePartner_Inbound_Message__c>();
        List<PRM_Value_Exchange_Recommendation__c> opidList = [SELECT Id, PRM_Account_Id__c,CreatedDate 
                                                               FROM PRM_Value_Exchange_Recommendation__c limit 3];
        
        For(PRM_Value_Exchange_Recommendation__c opid : opidList){            
            Core_OnePartner_Inbound_Message__c inb1 = new Core_OnePartner_Inbound_Message__c();
            inb1.Core_SalesCloud_AccountID__c = opid.PRM_Account_Id__c;
            inb1.Core_Status__c = 'DISCARDED';
            inb1.CreatedDate = System.now();
            setOfRec.add(opid.Id);
            //system.debug('opid -->'+opid);
            opid.PRM_Recommendation_Status_Nm__c = 'OPID In Process';
            inbList.add(inb1);                        
        }
        Update opidList;
        List<PRM_Value_Exchange_Recommendation__c> opidList1 = [SELECT Id, PRM_Account_Id__c,CreatedDate FROM PRM_Value_Exchange_Recommendation__c 
                                                                WHERE Id NOT IN : setOfRec limit 5];
        
        Datetime oldDate = System.now().addDays(-10);
        //system.debug('oldDate -->'+oldDate);
        For(PRM_Value_Exchange_Recommendation__c opid : opidList1){            
            Core_OnePartner_Inbound_Message__c inb1 = new Core_OnePartner_Inbound_Message__c();
            inb1.Core_SalesCloud_AccountID__c = opid.PRM_Account_Id__c;
            inb1.CreatedDate = oldDate;
            opid.PRM_Recommendation_Status_Nm__c = 'OPID In Process';
            inbList.add(inb1);            
        }
        Update opidList1;
        insert inbList;
        
        //system.debug('inbound List'+inbList);
        //system.debug('inbound List size()'+inbList.size());
        for (Core_OnePartner_Inbound_Message__c inbound: inbList){
            //system.debug('inbound Created date'+inbound.Createddate);
            //system.debug('inbound s'+inbound);
        }
        
        Test.startTest();        
        PRM_ErrorMonitorScheduler batchschedule = new PRM_ErrorMonitorScheduler();
        String cronExpression = '0 0 0/1 1/1 * ? *';
        system.schedule('Batch Test' , cronExpression , batchschedule);
        
        Test.stopTest();
        
    }
 /*   
    
    @isTest
    public static void test4(){
        List<Account> accListToInsert = new List<Account>();
        Id intelAccRecType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();  
        
        List<Core_OnePartner_Inbound_Message__c> inbList = new List<Core_OnePartner_Inbound_Message__c>();
        List<PRM_Value_Exchange_Recommendation__c> listrecom = new List<PRM_Value_Exchange_Recommendation__c>();
        For(integer i =0 ; i<= 25 ; i++){
            Integer IntrandomNumber = Integer.valueof((Math.random() * 1000));
            Integer IntrandomNumber1 = Integer.valueof((Math.random() * 1000));
            Account acc = new Account();
            acc.Name =IntrandomNumber+'Testfname'+IntrandomNumber;
            acc.Core_Account_Type__c ='Distributor';
            acc.Industry ='Agriculture';
            acc.Core_IPA_Partner_Role__c = 'Service Provider';
            acc.Core_Account_Type__c='Cloud Service Provider (CSP)';
            acc.BillingCity=IntrandomNumber1+'44th Floor'+IntrandomNumber;
            acc.BillingCountry='India';
            acc.BillingStreet=IntrandomNumber+'44th Floor'+IntrandomNumber1;
            acc.BillingPostalCode=IntrandomNumber1+'56'+IntrandomNumber;
            acc.Core_User_Defined_Website__c = IntrandomNumber+'abc.com';
            accListToInsert.add(acc); 
        }
        
        insert accListToInsert;
        ChannelProgram cp = [SELECT Id FROM ChannelProgram limit 1];
        ChannelProgramLevel cpl = [SELECT Id FROM ChannelProgramLevel limit 1];
        
        For(Account acc : accListToInsert){
            PRM_Value_Exchange_Recommendation__c recm1 = new PRM_Value_Exchange_Recommendation__c();
            recm1.PRM_Account_Id__c = acc.Id;
            recm1.PRM_Tier_Id__c = cpl.Id;
            recm1.PRM_Partner_Role_Nm__c = acc.Core_IPA_Partner_Role__c;
            recm1.PRM_Recommendation_Type_Nm__c = 'OPID';
            recm1.PRM_Recommendation_Status_Nm__c = 'In Process';
            recm1.PRM_Grouping_Method_Nm__c = 'LINEOFBUSNS';
            recm1.CreatedDate = System.now();
            listrecom.add(recm1);
        }
        insert listrecom;
        Datetime oldDate = System.now();           
        
        For (PRM_Value_Exchange_Recommendation__c opid : listrecom){
            //system.debug('======>OPID '+opid);
            opid.PRM_Recommendation_Status_Nm__c = 'OPID In Process';
            Core_OnePartner_Inbound_Message__c inb101 = new Core_OnePartner_Inbound_Message__c();
            inb101.Core_SalesCloud_AccountID__c = opid.PRM_Account_Id__c;
            inb101.CreatedDate = oldDate;
            inbList.add(inb101);
        }
        
        Update listrecom;
        insert inbList;
        
        
        For (Core_OnePartner_Inbound_Message__c inb101 : inbList){
            //system.debug('======>inb101 '+inb101);
            inb101.Core_Status__c = 'DISCARDED';
        }
        Update inbList;
        
        
        Test.startTest(); 
        PRM_ErrorMonitor_Batch obj = new PRM_ErrorMonitor_Batch();
        obj.execute(null,listrecom);
        
        PRM_ErrorMonitorScheduler batchschedule = new PRM_ErrorMonitorScheduler();
        String cronExpression = '0 0 0/1 1/1 * ? *';
        system.schedule('Batch Test' , cronExpression , batchschedule);        
        Test.stopTest();        
    }
    
    
    @isTest
    public static void test5(){
        List<Account> accListToInsert = new List<Account>();
        Id intelAccRecType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();  
        
        List<Core_OnePartner_Inbound_Message__c> inbList = new List<Core_OnePartner_Inbound_Message__c>();
        List<PRM_Value_Exchange_Recommendation__c> listrecom = new List<PRM_Value_Exchange_Recommendation__c>();
        For(integer i =0 ; i<= 25 ; i++){
            Integer IntrandomNumber = Integer.valueof((Math.random() * 1000));
            Integer IntrandomNumber1 = Integer.valueof((Math.random() * 1000));
            Account acc = new Account();
            acc.Name =IntrandomNumber+'Testfname'+IntrandomNumber;
            acc.Core_Account_Type__c ='Distributor';
            acc.Industry ='Agriculture';
            acc.Core_IPA_Partner_Role__c = 'Service Provider';
            acc.Core_Account_Type__c='Cloud Service Provider (CSP)';
            acc.BillingCity=IntrandomNumber+'ITPL,Bengaluru'+IntrandomNumber1;
            acc.BillingCountry='India';
            acc.BillingStreet=IntrandomNumber1+'Brookfield'+IntrandomNumber;
            acc.BillingPostalCode=IntrandomNumber1+'0037';
            acc.Core_User_Defined_Website__c = IntrandomNumber1+'abc.com';
            accListToInsert.add(acc); 
        }
        
        insert accListToInsert;
        ChannelProgram cp = [SELECT Id FROM ChannelProgram limit 1];
        ChannelProgramLevel cpl = [SELECT Id FROM ChannelProgramLevel limit 1];
        
        For(Account acc : accListToInsert){
            PRM_Value_Exchange_Recommendation__c recm1 = new PRM_Value_Exchange_Recommendation__c();
            recm1.PRM_Account_Id__c = acc.Id;
            recm1.PRM_Tier_Id__c = cpl.Id;
            recm1.PRM_Partner_Role_Nm__c = acc.Core_IPA_Partner_Role__c;
            recm1.PRM_Recommendation_Type_Nm__c = 'OPID';
            recm1.PRM_Recommendation_Status_Nm__c = 'In Process';
            recm1.PRM_Grouping_Method_Nm__c = 'LINEOFBUSNS';
            recm1.CreatedDate = System.now();
            listrecom.add(recm1);
        }
        insert listrecom;
        Datetime oldDate = System.now() - 2 ;           
        
        For(PRM_Value_Exchange_Recommendation__c opid : listrecom){
            opid.PRM_Recommendation_Status_Nm__c = 'OPID In Process';
            Core_OnePartner_Inbound_Message__c inb101 = new Core_OnePartner_Inbound_Message__c();
            inb101.Core_SalesCloud_AccountID__c = opid.PRM_Account_Id__c;
            inb101.CreatedDate = oldDate;
            inbList.add(inb101);
        }
        
        Update listrecom;
        insert inbList;
        
        Test.startTest(); 
        PRM_ErrorMonitor_Batch obj = new PRM_ErrorMonitor_Batch();
        obj.execute(null,listrecom);
        
        PRM_ErrorMonitorScheduler batchschedule = new PRM_ErrorMonitorScheduler();
        String cronExpression = '0 0 0/1 1/1 * ? *';
        system.schedule('Batch Test' , cronExpression , batchschedule);        
        Test.stopTest();        
    }
    
    
    @isTest
    public static void test6(){
        List<Account> accListToInsert = new List<Account>();
        Id intelAccRecType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();  
        
        List<Core_OnePartner_Inbound_Message__c> inbList = new List<Core_OnePartner_Inbound_Message__c>();
        List<PRM_Value_Exchange_Recommendation__c> listrecom = new List<PRM_Value_Exchange_Recommendation__c>();
        For(integer i =0 ; i<= 25 ; i++){
            Integer IntrandomNumber = Integer.valueof((Math.random() * 1000));
            Integer IntrandomNumber1 = Integer.valueof((Math.random() * 1000));
            Integer IntrandomNumber2 = Integer.valueof((Math.random() * 1000));
            Account acc = new Account();
            acc.Name =IntrandomNumber+'Testfname'+IntrandomNumber;
            acc.Core_Account_Type__c ='Distributor';
            acc.Industry ='Agriculture';
            acc.Core_IPA_Partner_Role__c = 'Service Provider';
            acc.Core_Account_Type__c='Cloud Service Provider (CSP)';
            acc.BillingCity=IntrandomNumber+'Benga'+IntrandomNumber2;
            acc.BillingCountry='India';
            acc.BillingStreet=IntrandomNumber2+'4223,Brookfield'+IntrandomNumber;
            acc.BillingPostalCode=IntrandomNumber1+'560'+IntrandomNumber2;
            acc.Core_User_Defined_Website__c = IntrandomNumber1+'abc.com';
            accListToInsert.add(acc); 
        }
        
        insert accListToInsert;
        ChannelProgram cp = [SELECT Id FROM ChannelProgram limit 1];
        ChannelProgramLevel cpl = [SELECT Id FROM ChannelProgramLevel limit 1];
        
        For(Account acc : accListToInsert){
            PRM_Value_Exchange_Recommendation__c recm1 = new PRM_Value_Exchange_Recommendation__c();
            recm1.PRM_Account_Id__c = acc.Id;
            recm1.PRM_Tier_Id__c = cpl.Id;
            recm1.PRM_Partner_Role_Nm__c = acc.Core_IPA_Partner_Role__c;
            recm1.PRM_Recommendation_Type_Nm__c = 'OPID';
            recm1.PRM_Recommendation_Status_Nm__c = 'In Process';
            recm1.PRM_Grouping_Method_Nm__c = 'LINEOFBUSNS';
            recm1.CreatedDate = System.now();
            listrecom.add(recm1);
        }
        insert listrecom;
        Datetime oldDate = System.now() - 2 ;           
        
        For(PRM_Value_Exchange_Recommendation__c opid : listrecom){
            opid.PRM_Recommendation_Status_Nm__c = 'OPID In Process';
            Core_OnePartner_Inbound_Message__c inb101 = new Core_OnePartner_Inbound_Message__c();
            inb101.Core_SalesCloud_AccountID__c = opid.PRM_Account_Id__c;
            inb101.Error_Description__c = 'ERROR';
            inbList.add(inb101);
        }
        
        Update listrecom;
        insert inbList;
        
        Test.startTest(); 
        PRM_ErrorMonitor_Batch obj = new PRM_ErrorMonitor_Batch();
        obj.execute(null,listrecom);
        
        PRM_ErrorMonitorScheduler batchschedule = new PRM_ErrorMonitorScheduler();
        String cronExpression = '0 0 0/1 1/1 * ? *';
        system.schedule('Batch Test' , cronExpression , batchschedule);        
        Test.stopTest();        
    }
    
    
    @isTest
    public static void test7(){
        List<Account> accListToInsert = new List<Account>();
        Id intelAccRecType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();  
        
        List<Core_OnePartner_Inbound_Message__c> inbList = new List<Core_OnePartner_Inbound_Message__c>();
        List<PRM_Value_Exchange_Recommendation__c> listrecom = new List<PRM_Value_Exchange_Recommendation__c>();
        For(integer i =0 ; i<= 25 ; i++){
            Integer IntrandomNumber = Integer.valueof((Math.random() * 1000));
            Account acc = new Account();
            acc.Name =IntrandomNumber+'Testfname'+IntrandomNumber;
            acc.Core_Account_Type__c ='Distributor';
            acc.Industry ='Agriculture';
            acc.Core_IPA_Partner_Role__c = 'Service Provider';
            acc.Core_Account_Type__c='Cloud Service Provider (CSP)';
            acc.BillingCity='Bengaluru1212';
            acc.BillingCountry='India';
            acc.BillingStreet=IntrandomNumber+'4th Floor,ITPL,Brookfield'+IntrandomNumber;
            acc.BillingPostalCode='560037';
            acc.Core_User_Defined_Website__c = IntrandomNumber+'abc.com';
            accListToInsert.add(acc); 
        }
        
        insert accListToInsert;
        ChannelProgram cp = [SELECT Id FROM ChannelProgram limit 1];
        ChannelProgramLevel cpl = [SELECT Id FROM ChannelProgramLevel limit 1];
        
        For(Account acc : accListToInsert){
            PRM_Value_Exchange_Recommendation__c recm1 = new PRM_Value_Exchange_Recommendation__c();
            recm1.PRM_Account_Id__c = acc.Id;
            recm1.PRM_Tier_Id__c = cpl.Id;
            recm1.PRM_Partner_Role_Nm__c = acc.Core_IPA_Partner_Role__c;
            recm1.PRM_Recommendation_Type_Nm__c = 'OPID';
            recm1.PRM_Recommendation_Status_Nm__c = 'In Process';
            recm1.PRM_Grouping_Method_Nm__c = 'LINEOFBUSNS';
            recm1.CreatedDate = System.now();
            listrecom.add(recm1);
        }
        insert listrecom;
        
        For(PRM_Value_Exchange_Recommendation__c opid : listrecom){
            opid.PRM_Recommendation_Status_Nm__c = 'OPID In Process';
            Core_OnePartner_Inbound_Message__c inb101 = new Core_OnePartner_Inbound_Message__c();
            inb101.Core_SalesCloud_AccountID__c = opid.PRM_Account_Id__c;
            inb101.Core_Status__c = Label.PRM_INBOUNDMSG_PROCESSED;
            inbList.add(inb101);
        }
        
        Update listrecom;
        insert inbList;
        
        Test.startTest(); 
        PRM_ErrorMonitor_Batch obj = new PRM_ErrorMonitor_Batch();
        obj.execute(null,listrecom);
        
        PRM_ErrorMonitorScheduler batchschedule = new PRM_ErrorMonitorScheduler();
        String cronExpression = '0 0 0/1 1/1 * ? *';
        system.schedule('Batch Test' , cronExpression , batchschedule);        
        Test.stopTest(); 
               
    }
        */
}