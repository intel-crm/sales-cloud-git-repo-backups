public class recordDetails{
    public  id recId{get;set;}
    public List<Core_IPS_Project__c> recDetail;
    public ApexPages.StandardController con;
    public recordDetails(ApexPages.StandardController controller){
        con = controller; 
        System.debug('**************Verify con is here**************'+con);
          Core_IPS_Project__c rec= (Core_IPS_Project__c)controller.getRecord();
          System.debug('**************Verify Id is here**************'+rec);
          if(rec !=null)        
             recId = rec.id;
           System.debug('**************Verify Id is here**************'+recId);
        User loggedUser = [Select Id, Name, Profile.Name,ProfileId From User Where Id =:UserInfo.getUserId()];
        System.debug('**************Verify loggedUser is here**************'+loggedUser);
        
     }   
    public PageReference redirPage() 
    {
        try
        {             
            Id profileId = UserInfo.getprofileid();
            String profileName = [Select Id, Name from Profile where Id =: profileId ].Name;
            System.debug('Profile name:'+profileName );
            
            if(profileName.equals('System Administrator'))
            {
                PageReference p = new PageReference('/' + Core_IPS_Project__c.SObjectType.getDescribe().getKeyPrefix() + '/e');
                Map<String, String> m = p.getParameters();
                m.putAll(ApexPages.currentPage().getParameters());                       
                m.put('nooverride', '1');                        
                p.setRedirect(true);
                System.debug('p:'+p);
                return p;
            }
            else
            {                                
                return null;
            }
        }
        catch(Exception l_objEx)
        {            
            String l_stMsg = 'Exception while redirecting to Samples & Literature VF page.';
            String l_stErrMessage = l_objEx.getTypeName()+': '+l_stMsg;
            System.debug(l_stErrMessage);
            return null;
        }
    }
    public PageReference saveNew() {
        try{
        con.save();
            system.debug('con'+con);
        Schema.DescribeSObjectResult describeResult = con.getRecord().getSObjectType().getDescribe(); 
        system.debug('describeResult'+describeResult);
        PageReference pr = new PageReference('/' + describeResult.getKeyPrefix() + '/e'); 
        system.debug('pr'+pr);
        pr.setRedirect(true); 
        return pr;      
    }
        catch (System.DMLException e){
            //ApexPages.addmessages(e); 
            return null;
        }
    }
  }