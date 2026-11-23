@istest
private class Core_AAQC_ViewCase_CTRL_Test{
    
    public static testmethod void TestYesMessage(){  
        
            Case c= new Case();
            c.Origin = 'My Origin';
            c.Subject= 'Ask commision case subject';
            c.Core_AAQC_Commissions_Severity__c='test';
            insert c; 
           //commented for classic EOL-Tejaswini
         //   PageReference pageRef = Page.Core_IPS_ViewCase;
            ApexPages.currentPage().getParameters().put('message','ClosedYes');
            ApexPages.currentPage().getParameters().put('id', String.valueOf(c.Id));
            ApexPages.currentPage().getParameters().put('referer','CaseCloseOnEmail');
            ApexPages.StandardController sc = new ApexPages.StandardController(c);
            Core_AAQC_ViewCase_CTRL cont = new Core_AAQC_ViewCase_CTRL(sc);
        
    }
    public static testmethod void TestNoMessage(){  
        
            Case c= new Case();
            c.Origin = 'My Origin';
            c.Subject= 'Ask commision case subject';
            c.Core_AAQC_Commissions_Severity__c='test';
            insert c; 
           
        //commented for classic EOL-Tejaswini
         //   PageReference pageRef = Page.Core_IPS_ViewCase;
            ApexPages.currentPage().getParameters().put('message','ClosedNo');
            ApexPages.currentPage().getParameters().put('id', String.valueOf(c.Id));
            ApexPages.currentPage().getParameters().put('referer','CaseCloseOnEmail');
            ApexPages.StandardController sc = new ApexPages.StandardController(c);
            Core_AAQC_ViewCase_CTRL cont = new Core_AAQC_ViewCase_CTRL(sc);
        
    }
}