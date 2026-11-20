/*************************************************************************************************
Class Name  : Core_AccountRecommendations_Controller
Created Date: Jun 05, 2015
Function    : Visualforce controller code for the Account Recommendations page, to present product
              recommendations for an account, and accept input on their usefulness
Modification Log :
* Developer         Date          Description
* ----------------------------------------------------------------------------                 
* Dave Hood         05/05/2015    Original version
**************************************************************************************************/

// Note: had to make this "without sharing" so that the Save method will work if the user is
// on the account team with Read access (not just Read/Write)
public without sharing class Core_AccountRecommendations_Controller {
    
    private ApexPages.StandardController controller;
    
    public Core_Account_Recommendations__c recs { get; set; }	// Recommendations we're looking at
    
    public Account acct { get; set; }	// Account corresponding to recommendations we're looking at
    
    public Boolean isAccessAllowed { get; set; }	// Whether or not the user should see the page
    
    // Starting values for the 3 feedback items, when the page first comes up, so we know if they've changed
    // (to know whether or not to write to the 3 fields that store the user who last changed each)
    private String feedback1InitialValue;
    private String feedback2InitialValue;
    private String feedback3InitialValue;
    
    // Users who last handled each of the 3 feedback items, so we can retrieve and update Names and potentially
    // other info on the screen (won't work if we just have the recommendations fields and user IDs in them)
    public User feedback1User { get; set; }
    public User feedback2User { get; set; }
    public User feedback3User { get; set; }
    
    private User currentUser { get; set; }		// Current user, so we can use it to overwrite feedback1/2/3 users
    
    // For the feedback options, we need to store & display different values
    public List<SelectOption> getFeedbackOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', Label.Core_Account_Recomm_Feedback_Needed));
        options.add(new SelectOption('1', Label.Core_Account_Recomm_Feedback_Positive));
        options.add(new SelectOption('0', Label.Core_Account_Recomm_Feedback_Negative));
        return options;
    }

    // Constructor
    public Core_AccountRecommendations_Controller(ApexPages.StandardController con) {
        
        controller = con;
        
        // Page only functions when the ID of the recommendations is passed in
        if (ApexPages.currentPage().getParameters().get('Id') != null) {
            
            recs = (Core_Account_Recommendations__c) con.getRecord();
            
            // Page only functions if there's an account associated with the recommendations
            if (recs.Core_Account__c != null) {
                
                acct = [select Id, Name from Account where Id = :recs.Core_Account__c limit 1];
                
                // Check to see access to this page is allowed
                isAccessAllowed = accessCheck();
                
                if (isAccessAllowed) {
                    feedback1InitialValue = recs.Core_Feedback_1_Indicator__c;
                    feedback2InitialValue = recs.Core_Feedback_2_Indicator__c;
                    feedback3InitialValue = recs.Core_Feedback_3_Indicator__c;
                    
                    // If the user who last touched each recommendation exists, pull their user info (need to pull them
                    // into actual variables separate from the recommendations so VF re-rending after AJAX call works)
                    if (recs.Core_Feedback_1_User__c != null)
                        feedback1User = [select Id, Name from User where Id = :recs.Core_Feedback_1_User__c limit 1][0];
                    if (recs.Core_Feedback_2_User__c != null)
                        feedback2User = [select Id, Name from User where Id = :recs.Core_Feedback_2_User__c limit 1][0];
                    if (recs.Core_Feedback_3_User__c != null)
                        feedback3User = [select Id, Name from User where Id = :recs.Core_Feedback_3_User__c limit 1][0];
                    
                    // Get the current user so we can use it later to overwrite feedback1/2/3 users
                    currentUser = [select Id, Name from User where Id = :UserInfo.getUserId() limit 1][0];
                }
                else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Core_Account_Recomm_Access_Controlled)); 
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Core_Account_Recomm_Access_Acct_Team));
                }
            }
        }
    }
    
    public PageReference onLoad() {        
        
        // If recommendations ID wasn't passed to the page, see if Account ID was passed. If so, use that to
        // pull the recommendations ID, and redirect back to this page, passing the ID.
        if (ApexPages.currentPage().getParameters().get('Id') == null) {
            
            if (ApexPages.currentPage().getParameters().get('AccountId') != null) {
                
                Id accountId = ApexPages.currentPage().getParameters().get('AccountId');
                Id recId;
                
                List<Core_Account_Recommendations__c> recs = [select Id from Core_Account_Recommendations__c where Core_Account__c = :accountId limit 1];
                
                if ((recs != null) && (recs.size() == 1)) {
                    recId = recs[0].Id;
                    //recId = [select Id from Core_Account_Recommendations__c where Core_Account__c = :accountId limit 1][0].Id;
                    PageReference redirectPage = ApexPages.currentPage();
                    redirectPage.getParameters().put('Id', recId);
                    return redirectPage.setRedirect(true);
                }
                else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.Core_Account_Recomm_No_Recommendations));
                    return null;
                }
            }
            else
                return null;
        }
        else {
            if (isAccessAllowed) {
                // If the recommendations hadn't been viewed yet, mark them as viewed
                if (recs.Core_Recommendations_Viewed__c == false) {
                    recs.Core_Recommendations_Viewed__c = true;
                    update recs;
                }
            }
            return null;
        }
    }
    
    private Boolean accessCheck() {
        
        Id userId = UserInfo.getUserId();
        
        // Check to see if the user has Edit access to the account through any mechanism: account ownership,
        // account team, territory, role hierarchy, manual sharing, etc.
        List<UserRecordAccess> accessQuery = [select RecordId, HasEditAccess from UserRecordAccess where RecordId = :acct.Id and UserId = :userId];
        
        Boolean hasEditAccess = accessQuery[0].HasEditAccess;
        
        // If the user has Edit access, then 
        if (hasEditAccess) {
            return true;
        }
        else {
            // Check to see if the user is on the Account Team (with Read access)
            List<AccountTeamMember> acctTeamQuery = [select Id from AccountTeamMember where AccountId = :acct.Id and UserId = :userId];
            
            if ((acctTeamQuery == null) || (acctTeamQuery.size() == 0)) {
                
                // Check to see if the user is in the Executive Access group
                List<GroupMember> execGroupQuery = [select Id from GroupMember
                                                    where GroupId in (select Id from group where DeveloperName = :Label.Core_Account_330_Executive_Access)
                                                    and UserOrGroupId = :userId];
                
                if ((execGroupQuery == null) || (execGroupQuery.size() == 0))
                    return false;
                else
                    return true;	// If there are rows, it means the user is in the group
            }
            else
                return true; 	// User is on the Account Team
        }
    }
    
    public PageReference saveFeedback() {
        
        if (feedback1InitialValue != recs.Core_Feedback_1_Indicator__c) {
            recs.Core_Feedback_1_Timestamp__c = Datetime.now();
            recs.Core_Feedback_1_User__c = currentUser.Id;            
            feedback1User = currentUser;
        }
        if (feedback2InitialValue != recs.Core_Feedback_2_Indicator__c) {
            recs.Core_Feedback_2_Timestamp__c = Datetime.now();
            recs.Core_Feedback_2_User__c = currentUser.Id;            
            feedback2User = currentUser;
        }
        if (feedback3InitialValue != recs.Core_Feedback_3_Indicator__c) {
            recs.Core_Feedback_3_Timestamp__c = Datetime.now();
            recs.Core_Feedback_3_User__c = currentUser.Id;
            feedback3User = currentUser;
        }
        
        update recs;
        return null;
    }
    
    public PageReference goToAccount() {
        if ((recs != null) && (recs.Core_Account__c != null))
        	return new PageReference('/' + recs.Core_Account__c);
        else
            return null;
    }
}