@istest
private class Core_AAQC_Case_Ask_CommissionsCNTLR_Test{
    public static testmethod void commissions()
    {    
          Profile p = [SELECT Id FROM Profile WHERE Name='Sales Rep-BB'];
          User u = new User(Alias = 'salrep',
                            Email='SalesRepBB@example.com',
                            EmailEncodingKey='UTF-8',
                            LastName='Testing',
                            LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US',
                            ProfileId = p.Id,
                            TimeZoneSidKey='America/Los_Angeles',
                            UserName='Salestest12@example.com');
       System.runAs(u)
      {
        Case c= new Case();
        c.Origin = 'My Origin';
        c.Subject= 'Ask commision case subject';
        c.Core_AAQC_Commissions_Severity__c='test';
        insert c; 
        
        Core_AAQC_Commissions_Case__c com =new Core_AAQC_Commissions_Case__c ();
        com.Core_AAQC_Case__c=c.id;
        system.debug('afda'+com);
        insert com;
        
        PageReference pageRef = Page.Core_AAQC_Case_Ask_Commissions_Layout;
        ApexPages.currentPage().getParameters().put('typeOfPage','');
        ApexPages.currentPage().getParameters().put('id', String.valueOf(c.Id));
        ApexPages.currentPage().getParameters().put('typeOfPage','Edit');
        ApexPages.currentPage().getParameters().put('retURL','%2Fapexpages%2');
        ApexPages.StandardController sc = new ApexPages.StandardController(c);
        Core_AAQC_Case_Ask_Commissions_CNTLR cont = new Core_AAQC_Case_Ask_Commissions_CNTLR(sc);
        cont.customSaveDraft();
        cont.customSubmitCase();
        cont.customCancel(); 
        System.assertEquals(cont.objcase.Subject,'Ask commision case subject');
      }
      
      Case c1= new Case();
      c1.Origin = 'My Origin';
      insert c1; 
      ApexPages.currentPage().getParameters().put('typeOfPage','');
      ApexPages.currentPage().getParameters().put('retURL','');
      ApexPages.StandardController sc1 = new ApexPages.StandardController(c1);
      Core_AAQC_Case_Ask_Commissions_CNTLR cont1 = new Core_AAQC_Case_Ask_Commissions_CNTLR(sc1);
      cont1.customCancel();
      
      
      ApexPages.currentPage().getParameters().put('id',String.valueOf(c1.Id));
      ApexPages.currentPage().getParameters().put('typeOfPage','Edit');
      ApexPages.StandardController sc2 = new ApexPages.StandardController(c1);
      Core_AAQC_Case_Ask_Commissions_CNTLR cont2 = new Core_AAQC_Case_Ask_Commissions_CNTLR(sc2);
      cont2.customSubmitCase();
      
      Case c2= new Case();
      c2.Origin = 'My Origin';
      insert c2;
      ApexPages.StandardController sc3 = new ApexPages.StandardController(c2);
      Core_AAQC_Case_Ask_Commissions_CNTLR cont3 = new Core_AAQC_Case_Ask_Commissions_CNTLR(sc3);
      delete c2;
      cont3.customSubmitCase(); 
    }
    
    public static testmethod void Newcommissions()
    {    
          Profile p = [SELECT Id FROM Profile WHERE Name='Sales Rep-BB'];
          User u = new User(Alias = 'salrep',
                            Email='SalesRepBB@example.com',
                            EmailEncodingKey='UTF-8',
                            LastName='Testing',
                            LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US',
                            ProfileId = p.Id,
                            TimeZoneSidKey='America/Los_Angeles',
                            UserName='Salestest123@example.com');
      System.runAs(u)
      {
            Case c= new Case();
            c.Origin = 'My Origin';
            c.Subject= 'Ask commision case subject';
            c.Core_AAQC_Commissions_Severity__c='test';
            
            PageReference pageRef = Page.Core_AAQC_Case_Ask_Commissions_Layout;
            ApexPages.currentPage().getParameters().put('typeOfPage','NewCase');
            ApexPages.currentPage().getParameters().put('retURL','%2Fapexpages%2');
            ApexPages.StandardController sc = new ApexPages.StandardController(c);
            Core_AAQC_Case_Ask_Commissions_CNTLR cont = new Core_AAQC_Case_Ask_Commissions_CNTLR(sc);
            
            insert c; 
            
            Core_AAQC_Commissions_Case__c com =new Core_AAQC_Commissions_Case__c ();
            com.Core_AAQC_Case__c=c.id;
            system.debug('afda'+com);
            insert com;
            
            cont.customSaveDraft();
            cont.customSubmitCase();
            cont.customCancel(); 
            
      }
      
        Case c1= new Case();
        c1.Origin = 'My Origin';
        C1.Status ='Draft';
        c1.Core_AAQC_Commissions_Severity__c = null;
        
        ApexPages.currentPage().getParameters().put('typeOfPage','');
        ApexPages.currentPage().getParameters().put('retURL','');
        ApexPages.StandardController sc1 = new ApexPages.StandardController(c1);
        Core_AAQC_Case_Ask_Commissions_CNTLR cont1 = new Core_AAQC_Case_Ask_Commissions_CNTLR(sc1);
        
        cont1.customCancel();
        
        insert c1; 
        Core_AAQC_Commissions_Case__c com =new Core_AAQC_Commissions_Case__c ();
        com.Core_AAQC_Case__c=c1.id;
        insert com;
        
    }   
}