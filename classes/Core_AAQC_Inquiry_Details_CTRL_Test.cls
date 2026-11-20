@istest
private class Core_AAQC_Inquiry_Details_CTRL_Test{
    
    public static testmethod void TestMessage(){  
        
            Case c= new Case();
            c.Origin = 'My Origin';
            c.Subject= 'Ask commision case subject';
            c.Core_AAQC_Commissions_Severity__c='test';
            insert c; 
            
            Core_AAQC_Commissions_Case__c com =new Core_AAQC_Commissions_Case__c ();
            com.Core_AAQC_Case__c=c.id;
            system.debug('afda'+com);
            insert com;
            
            PageReference pageRef = Page.Core_AAQC_Commissions_Inquiry_Details;
            ApexPages.currentPage().getParameters().put('message',' Your Draft Has been Saved');
            ApexPages.currentPage().getParameters().put('id', String.valueOf(com.Id));
            ApexPages.currentPage().getParameters().put('referer','askCommissionpage');
            ApexPages.StandardController sc = new ApexPages.StandardController(c);
            Core_AAQC_Inquiry_Details_CTRL cont = new Core_AAQC_Inquiry_Details_CTRL(sc);
        
    }
    public static testmethod void TestYesMessage(){  
        
            Case c= new Case();
            c.Origin = 'My Origin';
            c.Subject= 'Ask commision case subject';
            c.Core_AAQC_Commissions_Severity__c='test';
            insert c; 
            
            Core_AAQC_Commissions_Case__c com =new Core_AAQC_Commissions_Case__c ();
            com.Core_AAQC_Case__c=c.id;
            system.debug('afda'+com);
            insert com;
           
        //commented for classic EOL-Tejaswini
         //   PageReference pageRef = Page.Core_IPS_ViewCase;
            ApexPages.currentPage().getParameters().put('message','ClosedYes');
            ApexPages.currentPage().getParameters().put('id', String.valueOf(c.Id));
            ApexPages.currentPage().getParameters().put('referer','CaseCloseOnEmail');
            ApexPages.StandardController sc = new ApexPages.StandardController(c);
            Core_AAQC_Inquiry_Details_CTRL cont = new Core_AAQC_Inquiry_Details_CTRL(sc);
        
    }
    public static testmethod void TestNoMessage(){  
        
            Case c= new Case();
            c.Origin = 'My Origin';
            c.Subject= 'Ask commision case subject';
            c.Core_AAQC_Commissions_Severity__c='test';
            insert c; 
            
            Core_AAQC_Commissions_Case__c com =new Core_AAQC_Commissions_Case__c ();
            com.Core_AAQC_Case__c=c.id;
            system.debug('afda'+com);
            insert com;
           
        //commented for classic EOL-Tejaswini
         //   PageReference pageRef = Page.Core_IPS_ViewCase;
            ApexPages.currentPage().getParameters().put('message','ClosedNo');
            ApexPages.currentPage().getParameters().put('id', String.valueOf(c.Id));
            ApexPages.currentPage().getParameters().put('referer','CaseCloseOnEmail');
            ApexPages.StandardController sc = new ApexPages.StandardController(c);
            Core_AAQC_Inquiry_Details_CTRL cont = new Core_AAQC_Inquiry_Details_CTRL(sc);
        
    }
}