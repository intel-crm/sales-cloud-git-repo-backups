public class Core_IPS_ContactloginDisclaimer 
{
    public string docBody{get;set;}
    public  Core_IPS_ContactloginDisclaimer() 
    {
     List<Document> doc = [select id,body from Document where name='NDAConfidential' limit 1];
        if(doc.size()>0)
        docBody = doc[0].Body.toString(); 
    }
    public PageReference redirect() 
    {
        User u = [select Id, ContactId,userType from User where Id = :UserInfo.getUserId()];
        List<Contact> con = [select id, Core_IPS_NDA_Acceptance_Date__c from Contact where id=:u.ContactId limit 1];
        if(u.userType=='PowerCustomerSuccess')
        {   
            con[0].Core_IPS_NDA_Acceptance_Date__c = System.today();
            update con;
        }
        PageReference pg= new PageReference('/500/o');
        pg.setRedirect(true);
        return pg;
    }

    public PageReference Cancel()
    {
        PageReference pg= new PageReference('/secur/logout.jsp');
        pg.setRedirect(true);
        return pg;
    }

    public PageReference redirectAutomate()
    {
        boolean flag=true;    
           
    
        List<User> u = [select Id, ContactId,userType from User where Id = :UserInfo.getUserId()];        
    
        List<Contact> con = [select id, Core_IPS_NDA_Acceptance_Date__c from Contact where id=:u[0].ContactId limit 1];
        if(u[0].userType=='PowerCustomerSuccess')
        {            
            if(con[0].Core_IPS_NDA_Acceptance_Date__c != null)  
            {
               system.debug(con[0].Core_IPS_NDA_Acceptance_Date__c + '>=' + System.today().adddays(-Integer.valueOf(System.Label.NDA_Acceptance_Time)));
                if(con[0].Core_IPS_NDA_Acceptance_Date__c >= System.today().adddays(-Integer.valueOf(System.Label.NDA_Acceptance_Time)) )
                    flag = true;            
                 else
                    flag = false;            
            }
            else
            {
             flag = false;
            }
            
        }       
  
        if(flag==false){
            return null;
        }
        else
        {
            PageReference pg= new PageReference('/500/o');
            pg.setRedirect(true);
            return pg;
            //return null;
        }    
    }
}