/****************************************************************************************************************************************
* Class Name  : PMP_GlobalFooterController 
* Version     : 1.0 
* Created Date: 09-12-2019
* Modification Log :
*
* Developer                           Date                          Description
* -------------------------------------------------------------------------------------------------------------------------------------------
* ONYX Team                  09-12-2019                    Created for accessing community help URL
**********************************************************************************************************************************************/
public class PMP_GlobalFooterController {

    public PMP_GlobalFooterController() {}
    
    public String communityHelpURL;
    public String getCommunityHelpURL(){
        Network myNetwork = [SELECT Id FROM Network WHERE Name = :PMP_Utility.getValue('Marketplace_Community_Name') ];
        communityHelpURL = Network.getLoginUrl(myNetwork.Id);
      
         communityHelpURL = communityHelpURL.substringBeforeLast('/') ;
        
        //Sandhya : we need to check if SFDC outofthe box method will return "/s" at the end         
        if(!communityHelpURL.endsWith('/s')){
            communityHelpURL = communityHelpURL + '/s';
        }        
        //remove the word login from the communiyt URL and append with help
        communityHelpURL  = communityHelpURL + PMP_Utility.getValue('Community_Help_URL');
        return communityHelpURL;
    }
}