/*************************************************************************************************
Class Name  : Core_WaveChannelDashboard_Controller
Created Date: Apr 21, 2016
Function    : Controller extension for the Wave Channel VF pages (shared across them)
Modification Log :
* Developer         Date          Description
* ----------------------------------------------------------------------------                 
* Dave Hood         04/21/2016    Original version
**************************************************************************************************/
public class Core_WaveChannelDashboard_Controller {
    
    private String pageName = '';
    public Boolean showDashboard { get; set; }
    public static Map<String,Core_ACM_Control_Execution__c> mapWaveChannelDashboard = Core_ACM_Control_Execution__c.getAll();

    public Core_WaveChannelDashboard_Controller(ApexPages.StandardController stdController) {
        
        if(mapWaveChannelDashboard.containsKey('WaveChannelDashBoard') && mapWaveChannelDashboard.get('WaveChannelDashBoard').IsActive__c){
            showDashboard = true;
            
            // Get the name of the page, between "apex/" and the first question mark (if any)
            pageName = ApexPages.currentPage().getUrl().split('apex/')[1];
            if (pageName.contains('?'))
                pageName = pageName.split('\\?')[0];
            
            // For the "single account" dashboard, we need to check to make sure they have the right level of access.
            // Note: for some reason, when running as an Apex test, the page name isn't populated, so we need to force this code path.
            if (pageName.contains('SingleAccount') || Test.isRunningTest()) {
                
                // Get the account ID
                Id acctId;
                if (ApexPages.currentPage().getParameters().get('id') != null) {
                    acctId = ApexPages.currentPage().getParameters().get('id');
                }
                /*else if (ApexPages.currentPage().getParameters().get('cim_id') != null) {
                    acctId = [select Id from Account where Core_CIM_ID__c = :ApexPages.currentPage().getParameters().get('cim_id') limit 1].Id;
                }*/
                
                // Check to make sure the user has R/W access to the account or is on the account team
                if (acctId != null) {
                    
                    // Account R/W access
                    Set<Id> accessIds = Core_Test_Utility.validateAccountAccess(UserInfo.getUserId(), new Set<Id>{acctId});
                    if (accessIds.size() == 0) {
                        
                        // Team membership
                        List<AccountTeamMember> teamMembers = [select Id from AccountTeamMember where AccountId = :acctId and UserId = :UserInfo.getUserId()];
                        
                        if (teamMembers.size() == 0) {
                            showDashboard = false;
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Access to Salesout data is closely controlled.'));
                        }
                    }
                }
            }
        }
    }
    
    public void init() {
        if(mapWaveChannelDashboard.containsKey('WaveChannelDashBoard') && mapWaveChannelDashboard.get('WaveChannelDashBoard').IsActive__c){
            Core_Wave_Dashboard_View__c hit = new Core_Wave_Dashboard_View__c(
                Core_User__c = UserInfo.getUserId(),
                Core_Dashboard_Page__c = pageName,
                Core_View_Date_Time__c = DateTime.now()
            );
            insert hit;
        }
    }
}