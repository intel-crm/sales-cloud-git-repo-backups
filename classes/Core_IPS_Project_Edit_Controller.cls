/*************************************************************************************************************************************************
* Class Name  : Core_IPS_Project_Edit_Controller 
* Version     : 1.0 
* Created Date: 2 Dec 2018
* Modification Log :
* Developer                     Date                          Description
* ------------------------------------------------------------------------------------------------------------------------------------------------
* Vamsi                       2 Dec 2018                     Main Controller to Edit of Premier Support Projects As IPS External Customer 
**************************************************************************************************************************************************/
public class Core_IPS_Project_Edit_Controller {
    public string externalCustomerProfileId=System.Label.Core_IPS_External_Customer_Profile_Id;
    public String partnerProfileId = System.Label.Core_IPS_Partner_Profile_Id;
    public String agentPartnerProfileId=System.Label.Core_IPS_Partner_AE_Profile_Id; 
    public User loggedInUser;
    public ApexPages.StandardController stdContr;
    
    public Core_IPS_Project_Edit_Controller(ApexPages.StandardController stdContr){
        this.stdContr = stdContr;
         loggedInUser=[SELECT Id,Name,ProfileId FROM User WHERE Id=:UserInfo.getUserId()];
    }  
    // redirect the page based on profiles.  internal user will see standar page and portal user will see custom vfpage
    public PageReference redirectDetailPage(){
       // User loggedInUser=[SELECT Id,Name,ProfileId FROM User WHERE Id=:UserInfo.getUserId()];
        system.debug('PRofile=========>>'+loggedInUser.ProfileId );
        if(loggedInUser.ProfileId != externalCustomerProfileId && loggedInUser.ProfileId != agentPartnerProfileId && loggedInUser.ProfileId != partnerProfileId )
        {
            String theUrl = '/' + stdContr.GetRecord().Get('Id') + '?nooverride=1';
            System.debug('theUrl=========>>'+theUrl );
            return new ApexPages.PageReference(theUrl).SetRedirect(true);
        }else{
            return null;
        }
    }
    public PageReference redirectEditPage() 
    {
        //User loggedInUser=[SELECT Id,Name,ProfileId FROM User WHERE Id=:UserInfo.getUserId()];
        system.debug('PRofile=========>>'+loggedInUser.ProfileId );
        if(loggedInUser.ProfileId != externalCustomerProfileId && loggedInUser.ProfileId != agentPartnerProfileId && loggedInUser.ProfileId != partnerProfileId )
        {
            PageReference pgRef = new PageReference('/' + Core_IPS_Project__c.SObjectType.getDescribe().getKeyPrefix() + '/e');
            Map<String, String> mapUrl = pgRef.getParameters();
            mapUrl.putAll(ApexPages.currentPage().getParameters());                       
            mapUrl.put('nooverride', '1');                        
            pgRef.setRedirect(true);
            System.debug('pgRef:'+pgRef);
            return pgRef;
        }
        else
        {                                
            return null;
        }
    }
    // redirect to Project creation page once clicked on Save & New
    public PageReference saveNew() {
        PageReference pgRefer;
        pgRefer = stdContr.save();
        system.debug('con'+stdContr);
        if (pgRefer != null)
        {
            Schema.DescribeSObjectResult describeResult = stdContr.getRecord().getSObjectType().getDescribe(); 
            pgRefer = new PageReference('/' + describeResult.getKeyPrefix() + '/e'); 
            system.debug('pr'+pgRefer);
            pgRefer.setRedirect(true); 
        }
        return pgRefer;      
    }
}