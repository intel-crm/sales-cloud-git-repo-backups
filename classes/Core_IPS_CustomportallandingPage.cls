public without sharing class Core_IPS_CustomportallandingPage {
    
    public  boolean  flag{get;set;}
    
    
    public void PageInit() 
    {   
        flag = true;
        User u = [select Id, ContactId,userType from User where Id = :UserInfo.getUserId()]; 
        List<Contact> con = [select id, Core_IPS_NDA_Acceptance_Date__c from Contact where id=:u.ContactId limit 1];
        
        if(u.userType=='PowerCustomerSuccess' || u.userType=='PowerPartner')
        {    
            
            if(con[0].Core_IPS_NDA_Acceptance_Date__c !=null)
            {
                if(con[0].Core_IPS_NDA_Acceptance_Date__c >= System.today().adddays(-Integer.valueOf(System.Label.NDA_Acceptance_Time)))              
                {
                    flag = true;
                }
                else 
                {           
                    flag = false;
                }
            }
            else
            {
                flag = false;
            }
        }  
        /* if(flag == false)       
{
PageReference pg = new PageReference('/secur/logout.jsp');
pg.setRedirect(true);
return pg;
}*/
        
    }
    
}