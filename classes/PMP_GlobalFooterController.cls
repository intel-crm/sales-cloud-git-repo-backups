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
        communityHelpURL = System.Label.PMP_IPA_HelpLink;
        return communityHelpURL;
    }
}