/**************************************************************************************
Apex Class Name:  Core_MAGQuestionnaireController
Version     : 1.0 
Created Date: 24 JUN 2015
Function    : 
Modification Log :
* Developer           Date               Description
* ----------------------------------------------------------------------------   
* Dave Hood           Jun 24, 2015       Initial version
* Dave Hood           Jan 25, 2016       Changes for Spring 16 and shortening of the questionnaire
*************************************************************************************/
public class Core_MAGQuestionnaireController {
    
    private ApexPages.StandardController stdController;
    
    private Core_MAG_Questionnaire__c questionnaire;
    
    public Opportunity oppty { get; set; }
    
    public Integer numQuestions { get; set; }    
    public Boolean renderCommentSection { get; set; }
    public Boolean isLocked { get; set; }
    public Boolean isApprovedGuardrails { get; set; }
    
    private static final String APPROVED = 'Approved';
    private static final String APPROVED_WITH_GUARDRAILS = 'Approved with Guardrails';
    
    public Core_MAGQuestionnaireController(ApexPages.StandardController con) {
        
        stdController = con;
        String qstId = ApexPages.currentPage().getParameters().get('Id');
        
        if ((qstId != null) && (qstId != '')) {
            
            questionnaire = (Core_MAG_Questionnaire__c) stdController.getRecord();
            
            numQuestions = (Integer) questionnaire.Core_Number_of_Questions__c;
            
            List<Profile> profilesThatCanEdit = [select Id from Profile where Name = :Label.Core_Global_Export_Compliance_Profile_Name
                                                 or Name = :Label.Core_System_Admin_Profile_Name
                                                 or Name = :Label.Core_IT_Admin_Profile_Name];
            Set<Id> profileIdsThatCanEdit = (new Map<Id,Profile>(profilesThatCanEdit)).keySet();
            
            if (((questionnaire.Core_GEC_Comments__c != null) && (questionnaire.Core_GEC_Comments__c != '')) ||
                (profileIdsThatCanEdit.contains(UserInfo.getProfileId())))
                renderCommentSection = true;
            else
                renderCommentSection = false;
            
            if ((questionnaire.Core_Opportunity__r.Core_Compliance_Status__c == APPROVED) ||
                (questionnaire.Core_Opportunity__r.Core_Compliance_Status__c == APPROVED_WITH_GUARDRAILS))
                isLocked = true;
            if (questionnaire.Core_Opportunity__r.Core_Compliance_Status__c == APPROVED)
                isApprovedGuardrails = true;
            
            oppty = [select Id, Name, Core_Standard_Customer_Refresh__c from Opportunity where Id = :questionnaire.Core_Opportunity__c];
        }
    }
    
    public PageReference init() {
        
        // If MAG Questionnaire ID wasn't passed to the page, see if Opportunity ID was passed. If so, use that to
        // pull the questionnaire ID, and redirect back to this page, passing the ID. If questionnaire ID
        // doesn't exist, create a new record and redirect to it.
        // 
        String magId = ApexPages.currentPage().getParameters().get('Id');
        if ((magId == null) || (magId == '')) {
            
            if (ApexPages.currentPage().getParameters().get('OpportunityId') != null) {
                
                Id oppId = ApexPages.currentPage().getParameters().get('OpportunityId');
                Id qstId;
                
                List<Core_MAG_Questionnaire__c> existingQuestionnaire =
                    [select Id from Core_MAG_Questionnaire__c where Core_Opportunity__c = :oppId limit 1];
                    
                if ((existingQuestionnaire != null) && (existingQuestionnaire.size() > 0)) {
                    qstId = existingQuestionnaire[0].Id;
                }
                else {
                    existingQuestionnaire.add(createNewQuestionnaire(oppId));
                    insert existingQuestionnaire;
                    qstId = existingQuestionnaire[0].Id;
                    
                    Opportunity opp = [select Core_MAG_Questionnaire_ID__c from Opportunity where Id = :oppId];
                    opp.Core_MAG_Questionnaire_ID__c = qstId;
                    update opp;
                }
                
                PageReference redirectPage = ApexPages.currentPage();
                redirectPage.getParameters().put('Id', qstId);
                return redirectPage.setRedirect(true);
            }
            else
                return null;
        }
        else
            return null;
    }
    
    private Core_MAG_Questionnaire__c createNewQuestionnaire(Id oppId) {
        Core_MAG_Questionnaire__c newQuestionnaire = new Core_MAG_Questionnaire__c(
            Core_Opportunity__c = oppId,
            Core_Number_of_Questions__c = Integer.valueOf(Label.Core_MAG_Number_of_Questions),
            Core_Intro__c = Label.Core_MAG_Intro,
            Core_Q1__c = Label.Core_MAG_Q1,
            Core_Q2__c = Label.Core_MAG_Q2,
            Core_Q3__c = Label.Core_MAG_Q3,
            Core_Q4__c = Label.Core_MAG_Q4,
            Core_Q5__c = Label.Core_MAG_Q5,
            Core_Q6__c = Label.Core_MAG_Q6,
            Core_Q7__c = Label.Core_MAG_Q7,
            Core_Q8__c = Label.Core_MAG_Q8,
            Core_Q9__c = Label.Core_MAG_Q9,
            Core_Q10__c = Label.Core_MAG_Q10,
            Core_Q11__c = Label.Core_MAG_Q11,
            Core_Q12__c = Label.Core_MAG_Q12,
            Core_Q1_Textbox__c = Label.Core_MAG_Q1_Textbox,
            Core_Q2_Textbox__c = Label.Core_MAG_Q2_Textbox,
            Core_Q3_Textbox__c = Label.Core_MAG_Q3_Textbox,
            Core_Q4_Textbox__c = Label.Core_MAG_Q4_Textbox,
            Core_Q5_Textbox__c = Label.Core_MAG_Q5_Textbox,
            Core_Q6_Textbox__c = Label.Core_MAG_Q6_Textbox,
            Core_Q7_Textbox__c = Label.Core_MAG_Q7_Textbox,
            Core_Q8_Textbox__c = Label.Core_MAG_Q8_Textbox,
            Core_Q9_Textbox__c = Label.Core_MAG_Q9_Textbox,
            Core_Q10_Textbox__c = Label.Core_MAG_Q10_Textbox,
            Core_Q11_Textbox__c = Label.Core_MAG_Q11_Textbox,
            Core_Q12_Textbox__c = Label.Core_MAG_Q12_Textbox,
            Core_Outtro__c = Label.Core_MAG_Outtro
        );
        return newQuestionnaire;
    }
    
    public PageReference save() {
        stdController.save();
        update oppty;
        //return new PageReference('/' + oppty.Id);
        return null;
    }
    
    public PageReference cancel() {
        return new PageReference('/' + oppty.Id);
    }

    public PageReference gotoOpportunity() {
        if (oppty != null)
            return new PageReference('/' + oppty.Id);
        else
            return null;
    }
    
    public String convertedCreatedDate {
        get {
            DateTime createdDate = (DateTime) questionnaire.get('CreatedDate');
            return createdDate.format();
        }
    }
    
    public String convertedLastModifiedDate {
        get {
            DateTime lastModifiedDate = (DateTime) questionnaire.get('LastModifiedDate');
            return lastModifiedDate.format();
        }
    }
}