/*************************************************************************************************************************************************
* Class Name  : Core_IPS_Project_detail_override 
* Version     : 1.0 
* Created Date: 2 Dec 2018
* Modification Log :
* Developer                     Date                          Description
* ------------------------------------------------------------------------------------------------------------------------------------------------
* Vamsi                       2 Dec 2018                     Main Controller to detail view of Premier Support Projects As IPS External Customer 
**************************************************************************************************************************************************/
public class Core_IPS_Project_detail_override {
    
    public String externalCustomerProfileId=System.Label.Core_IPS_External_Customer_Profile_Id;
    public String partnerProfileId = System.Label.Core_IPS_Partner_Profile_Id;
    public String agentPartnerProfileId=System.Label.Core_IPS_Partner_AE_Profile_Id; 
    
    public ApexPages.StandardController stdContr = null;
    public Core_IPS_Project_detail_override(ApexPages.StandardController stdContr){
        this.stdContr=stdContr;
    }
    
    // redirecting the page based on loggedin user profile
    public PageReference redirectDetailPage(){
        User loggedInUser=[SELECT Id,Name,ProfileId FROM User WHERE Id=:UserInfo.getUserId()];
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
}