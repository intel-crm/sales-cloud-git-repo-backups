/**************************************************************************************
Apex Class Name:  Core_Opportunity_Clone_Controller
Version     : 1.0 
Created Date: 2/19/16
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Brian Matthews              2/19/16                Initial Revision
* Ashwin Dash                19/May/2017             US64659 - The "Date Submitted for Approval", "Push Counter" and "Approved Date" field are made to NULL or '0' before cloning
* Ashwin Dash                04/Sep/2017             DE30448 - Adding check for Close date to make it to today's date before cloning
* Rajesh                     20/9/2017               DE30968-Added code for update compliance status is blank when Military, Aerospace, or Gov'mt End Use? field value is 'No' and MAGAccount is flag.
*************************************************************************************/
public class Core_Opportunity_Clone_Controller {
    
    public static final String  NOT_SUBMITTED_TEXT  = 'Not Submitted';
    public static final String  OWNER_TEXT          = 'Owner';
    public static final String  PENDING_TEXT        = 'Pending';
    public static final Integer QUALIFY_PROBABILITY = 15;
    public static final String  QUALIFY_TEXT        = 'Qualify';
    public static final String  VENDOR_TEXT         = 'Vendor';
    public static final String  TECH_OWNER_SEGMENTS = 'Embedded,Compute';
    public static final String  YES_TEXT            = 'Yes';
    public static final String  NO_TEXT             ='No';
    
    public String  searchMessage { get; set; }                      // Actual error message
    public String  searchSeverity { get; set; }                     // Actual error message
    public Boolean searchShowMessage { get; set; }                  // Flag to render error message if user didn't enter value for search criteria    
    public Boolean searchShowPage { get; set; }                     // Flag to control page display - don't show page for inactive accounts.

    public Boolean opportunityFeaturesSelected { get; set; }
    public Boolean opportunityPartnersSelected { get; set; } 
    public Boolean opportunityProductSelected { get; set; } 
    public Boolean opportunityTeamSelected { get; set; }

    public Boolean showInactiveOppFeatures { get; set; }
    public Boolean showInactiveOppPartner { get; set; }
    public Boolean showInactiveOppProduct { get; set; }
    public Boolean showInactiveOppTeam { get; set; }
    
    public Boolean showOppFeatures { get; set; }
    public Boolean showOppPartner { get; set; }
    public Boolean showOpportunityProductOption { get; set; }    

    public Opportunity currentOpportunity { get; set; }
    
    public List<Core_Opportunity_Features__c> lstInactiveOppFeatures { get; set; }
    public List<Core_Opportunity_Partner__c>  lstInactiveOppPartner { get; set; }
    public List<OpportunityLineItem>          lstInactiveOppProduct { get; set; }
    public List<OpportunityTeamMember>        lstInactiveOppTeam { get; set; }
    public List<OpportunityTeamMember>        lstOppTeam { get; set; }
    public List<TeamMemberSelectionWrapper>   lstSelectOppTeam { get; set; }

    // Constructor
    public Core_Opportunity_Clone_Controller(ApexPages.StandardController controller) {

        Integer iQueryCount;

        // Setting the flag to false which is used for showing error message if there are no records retrived for the search criteria
        searchMessage     = '';
        searchSeverity    = 'error';
        searchShowMessage = false;
        searchShowPage    = true;

        opportunityFeaturesSelected = true;
        opportunityPartnersSelected = true;
        opportunityProductSelected  = true;
        opportunityTeamSelected     = true;
        
        currentOpportunity = (Opportunity)controller.getRecord();
        currentOpportunity = [SELECT Id, Name, Owner.IsActive, Core_Technical_Owner__r.isActive, Account.Name, Account.RecordType.Name, 
                                     Core_Sales_Segments__c, Account.Core_Military_Aerospace_and_Government__c, Core_Military_Aerospace_Govmt_End_Use__c                                
                              FROM Opportunity 
                              WHERE Id = :currentOpportunity.Id];                
        System.debug('#91 currentOpportunity: ' + currentOpportunity + ';   currentOpportunity.Owner.IsActive:' + currentOpportunity.Owner.IsActive); 
        System.debug('#92 currentOpportunity.Owner: ' + currentOpportunity.Owner); 

        String accountRecordTypeName = currentOpportunity.Account.RecordType.Name;
        if (accountRecordTypeName != NULL && accountRecordTypeName.contains('Inactive')) {                 
            searchMessage    += '                                                           ' + 
                                'Account \"' + currentOpportunity.Account.Name + '\" is inactive.  Cannot clone opportunities from inactive accounts".';
            searchSeverity    = 'error';            
            searchShowMessage = true;
            searchShowPage    = false;
            return;
        } 

        if (currentOpportunity.Core_Sales_Segments__c != NULL && TECH_OWNER_SEGMENTS.contains(currentOpportunity.Core_Sales_Segments__c)) {        
            if (currentOpportunity.Core_Technical_Owner__c == NULL || currentOpportunity.Core_Technical_Owner__r.isActive == false) {                 
                searchMessage    += '                                                           ' + 
                                    'An active Technical Owner is required.  Opportunity Owner will be cloned as new Technical Owner.';
                searchSeverity    = 'info';            
                searchShowMessage = true;
            }                
        }
                        
        // O P P   F E A T U R E
        lstInactiveOppFeatures = [SELECT Core_Feature_Type__c, Core_Feature_Name__c, IsDeleted
                                  FROM Core_Opportunity_Features__c
                                  WHERE Core_Opportunity__c = :currentOpportunity.Id
                                    AND IsDeleted = true
                                  LIMIT 2000];                                  
        showInactiveOppFeatures = lstInactiveOppFeatures.size() > 0;

        iQueryCount = Database.CountQuery('SELECT COUNT() ' + 
                                          'FROM Core_Opportunity_Features__c ' + 
                                          'WHERE Core_Opportunity__c = \'' + currentOpportunity.Id + '\'' + 
                                          '  AND IsDeleted = false');
        showOppFeatures = iQueryCount > 0;
        System.debug('#63 showOppFeatures: ' + showOppFeatures);


        // O P P   P A R T N E R
        lstInactiveOppPartner = [SELECT Core_Partner__r.Name, Core_Partner_Role__c, Core_Partner_Type__c,
                                        Core_Partner_Program__c, Core_Partner__r.Core_Deactivated__c
                                 FROM Core_Opportunity_Partner__c
                                 WHERE Core_Opportunity__c = :currentOpportunity.Id
                                   AND (Core_Partner__r.Core_Deactivated__c = true OR Core_Partner_Role__c = :VENDOR_TEXT)
                                 LIMIT 2000];
        showInactiveOppPartner = lstInactiveOppPartner.size() > 0;

        iQueryCount = Database.CountQuery('SELECT COUNT() ' + 
                                          'FROM Core_Opportunity_Partner__c ' + 
                                          'WHERE Core_Opportunity__c = \'' + currentOpportunity.Id + '\'' + 
                                          '  AND Core_Partner__r.Core_Deactivated__c = false ' + 
                                          '  AND Core_Partner_Role__c != \'' + VENDOR_TEXT + '\'');
        showOppPartner = iQueryCount > 0;
        System.debug('#62 showOppPartner: ' + showOppPartner);


        // O P P   P R O D U C T
        lstInactiveOppProduct = [SELECT Name, Core_Product_Type__c, Quantity, TotalPrice, Core_Status__c, Product2.IsActive, Product2.isDeleted 
                                 FROM OpportunityLineItem
                                 WHERE Opportunity.Id = :currentOpportunity.Id
                                   AND (Product2.IsActive=false OR Product2.isDeleted=true)
                                 LIMIT 2000];

        showInactiveOppProduct = lstInactiveOppProduct.size() > 0;
        
        iQueryCount = Database.CountQuery('SELECT COUNT() ' + 
                                          'FROM OpportunityLineItem ' + 
                                          'WHERE Opportunity.Id = \'' + currentOpportunity.Id + '\'' + 
                                          '  AND Product2.IsActive = true ' + 
                                          '  AND Product2.isDeleted = false');
                                              
        showOpportunityProductOption = iQueryCount > 0;
        System.debug('#61 showOpportunityProductOption: ' + showOpportunityProductOption);


        // O P P   T E A M
        lstOppTeam = [SELECT Name, TeamMemberRole, Core_Team_Member_Geo__c, OpportunityAccessLevel
                      FROM OpportunityTeamMember
                      WHERE OpportunityId = :currentOpportunity.Id
                        AND User.IsActive = true
                      LIMIT 2000];                                 

        lstSelectOppTeam = new List<TeamMemberSelectionWrapper>();        
        for (OpportunityTeamMember otmRec : lstOppTeam) {
            if (otmRec.TeamMemberRole != NULL && otmRec.TeamMemberRole.contains(OWNER_TEXT) && (lstSelectOppTeam.size() > 0))
                lstSelectOppTeam.add(0, new TeamMemberSelectionWrapper(otmRec));
            else    
                lstSelectOppTeam.add(new TeamMemberSelectionWrapper(otmRec));
        }            

        lstInactiveOppTeam = [SELECT User.Name, TeamMemberRole, Core_Team_Member_Geo__c, User.IsActive
                              FROM OpportunityTeamMember
                              WHERE OpportunityId = :currentOpportunity.Id
                                AND User.IsActive = false
                              LIMIT 2000];
        showInactiveOppTeam = lstInactiveOppTeam.size() > 0;                              

    }


    public Pagereference cancelClone() {    
        PageReference pageRef = new PageReference('/' + currentOpportunity.Id);
        pageRef.setRedirect(true);
        return pageRef;
    }
 

    public pagereference toggleDisplay() {    
        return NULL;
    }

                    
    public pageReference continueClone() {

        String strFields = getAllFields('Opportunity');
        System.debug('#47 strFields: ' + strFields);        
        String oppQuery = 'SELECT ' + strFields + ' FROM Opportunity WHERE Id = \'' + currentOpportunity.Id + '\'';
        System.debug('#48 oppQuery: ' + oppQuery);        
        Opportunity oppRec = Database.query(oppQuery);

        oppRec.Id                              = NULL;    
        oppRec.Name                            = 'Clone of ' + oppRec.Name; 
        
        //Adding check for Close date to make it to today's date before cloning -- Ashwin
        if(oppRec.CloseDate < system.today()){
            oppRec.CloseDate = system.today();
        }
        if (oppRec.StageName != NULL) {       
            if (oppRec.StageName.contains('Win') || oppRec.StageName.contains('Lost') || oppRec.StageName.contains('Cancelled')) {
                oppRec.StageName                   = QUALIFY_TEXT;
                oppRec.Probability                 = QUALIFY_PROBABILITY;
                oppRec.Core_Loss_Cancel_Details__c = NULL;
                oppRec.Core_Loss_Cancel_Reason__c  = NULL;            
            }
        }
                                                                  
        oppRec.CreatedById                     = UserInfo.getUserId();
        oppRec.CreatedDate                     = DateTime.now();
        oppRec.LastModifiedById                = UserInfo.getUserId();
        oppRec.LastModifiedDate                = DateTime.now();
        oppRec.Core_Bypass_Field_Validation__c = true;        

        oppRec.Core_Flag_for_Deletion__c       = false;
        oppRec.Core_Reason_for_Deletion__c     = NULL;
        oppRec.Core_External_ID__c             = NULL;

        oppRec.LeadSource                      = NULL;
        oppRec.Core_Project_Timeframe__c       = NULL;         
        oppRec.Core_Product_Interest__c        = NULL;
        oppRec.Core_Project_Size__c            = NULL;
        oppRec.Core_project_Phase__c           = NULL;
        oppRec.Core_Current_Architecture__c    = NULL;        

        // Reset the approval process
        oppRec.Core_Approval_Status__c         = NOT_SUBMITTED_TEXT;

        // The User doing the clone becomes the new owner.
        oppRec.OwnerId = UserInfo.getUserId();
                
        if (oppRec.Core_Sales_Segments__c != NULL && TECH_OWNER_SEGMENTS.contains(oppRec.Core_Sales_Segments__c)) {        
            if (currentOpportunity.Core_Technical_Owner__c == NULL || currentOpportunity.Core_Technical_Owner__r.isActive == FALSE )
                oppRec.Core_Technical_Owner__c = oppRec.OwnerId;
        }
       
      //DE30968-Added the code whenever opp is cloning,if opp MAG is false and Military End user is no ,then  update the compliance status is blank-Rajesh.
         if(!(currentOpportunity.Account.Core_Military_Aerospace_and_Government__c) && currentOpportunity.Core_Military_Aerospace_Govmt_End_Use__c == NO_TEXT) {
            oppRec.Core_Compliance_Comments__c         = NULL;    
            oppRec.Core_Private_Compliance_Comments__c = NULL;
            oppRec.Core_Compliance_Status__c           = NULL;
            oppRec.Core_Compliance_Sub_Status__c       = NULL;
            System.debug('#83 oppRec.Core_Compliance_Status__c: ' + oppRec.Core_Compliance_Status__c);
        }
        //START - US64659 - The "Date Submitted for Approval", "Push Counter" and "Approved Date" field are made to NULL or '0' before cloning - 19-May-2017 - Ashwin 
        oppRec.Core_Date_Submitted_for_Approval__c = null;
        oppRec.Core_Approved_Date__c = null;
        oppRec.Core_Push_Counter__c = null;
        //END - US64659 - The "Date Submitted for Approval", "Push Counter" and "Approved Date" field are made to NULL or '0' before cloning - 19-May-2017 - Ashwin 
        
        System.debug('#49 oppRec: ' + oppRec);            
                                                     
        insert oppRec;
        System.debug('#84 oppRec.Core_Compliance_Status__c: ' + oppRec.Core_Compliance_Status__c);
        System.debug('#85 oppRec.Core_Compliance_Sub_Status__c: ' + oppRec.Core_Compliance_Sub_Status__c);

        // CloneTeam has special logic to reflect user selections.
        // The Opportunity Owner and Technical Owner are created automatically by the Opportunity trigger handler.
        if (opportunityTeamSelected)
            cloneTeam(oppRec.Id);

        if (opportunityFeaturesSelected && showOppFeatures)
            cloneFeatures(currentOpportunity.Id, oppRec.Id);
        
        if (opportunityPartnersSelected && showOppPartner)
            clonePartners(currentOpportunity.Id, oppRec.Id);

        if (opportunityProductSelected && showOpportunityProductOption)
            cloneProducts(currentOpportunity.Id, oppRec.Id);

        PageReference pageRef = new PageReference('/' + oppRec.Id + '/e?retURL=/' + oppRec.Id);
        System.debug('#50 pageRef: ' + pageRef.getURL());        

        pageRef.setRedirect(true);
        return pageRef;            
    } 


    private void cloneTeam(Id newOppId) { 

        Set <Id> setTeamMembers = new Set<Id>();
        for (TeamMemberSelectionWrapper tmRec: lstSelectOppTeam) {
        
            // Copy whatever has been selected and whatever is NOT readOnly.  The readOnly members will
            // be created automatically by opportunity trigger code.    
            if (tmRec.memberSelected && !tmRec.readOnly)
                setTeamMembers.add(tmRec.oppTeamMember.Id);
        }

        String strFields = getAllFields('OpportunityTeamMember');

        // This is being filtered by the lstSelectedOppTeam list
        //       
        String itemQuery = 'SELECT ' + strFields + ' ' + 
                           'FROM OpportunityTeamMember ' + 
                           'WHERE Id = :setTeamMembers';
                           
        List<OpportunityTeamMember> lstOppTeamMembers = Database.query(itemQuery);

        for (OpportunityTeamMember itemRec : lstOppTeamMembers) {
            itemRec.Id            = NULL;
            itemRec.OpportunityId = newOppId;    
        }                     

        insert lstOppTeamMembers;
        System.debug('#66 lstOppTeamMembers: ' + lstOppTeamMembers);   
    }


    private void clonePartners(Id oldOppId, Id newOppId) { 

        String strFields = getAllFields('Core_Opportunity_Partner__c');
        
        String itemQuery = 'SELECT ' + strFields + ' ' + 
                           'FROM Core_Opportunity_Partner__c ' +
                           'WHERE Core_Opportunity__c = \'' + oldOppId + '\'' + 
                           '  AND Core_Partner__r.Core_Deactivated__c = false ' + 
                           '  AND Core_Partner_Role__c != \'' + VENDOR_TEXT + '\'';
        System.debug('#23 itemQuery: ' + itemQuery);   
                           
        List<Core_Opportunity_Partner__c> lstInactiveOppPartner = Database.query(itemQuery);

        for (Core_Opportunity_Partner__c partRec : lstInactiveOppPartner) {
            partRec.Id                        = NULL;
            partRec.Core_Opportunity__c       = newOppId; 
            partRec.Core_Partner_Program__c   = NULL;         
            partRec.Core_Joint_Opportunity__c = NULL;
            partRec.CreatedById               = UserInfo.getUserId();
            partRec.CreatedDate               = DateTime.now();
            partRec.LastModifiedById          = UserInfo.getUserId();
            partRec.LastModifiedDate          = DateTime.now();            
        }    
        insert lstInactiveOppPartner;
    }
    
    
    private void cloneProducts(Id oldOppId, Id newOppId) { 
        String strFields = getAllFields('OpportunityLineItem');
        
        String itemQuery = 'SELECT ' + strFields + ' ' + 
                           'FROM OpportunityLineItem ' + 
                           'WHERE Opportunity.Id = \'' + oldOppId + '\'' + 
                           '  AND Product2.IsActive = true ' + 
                           '  AND Product2.isDeleted = false'; 
        System.debug('#23 itemQuery: ' + itemQuery);   
                           
        List<OpportunityLineItem> lstOppLineItem = Database.query(itemQuery);

        List<OpportunityLineItem> lstNewOppLineItem = new List<OpportunityLineItem>();
        OpportunityLineItem newOppLineItem;

        for (OpportunityLineItem itemRec : lstOppLineItem) {
            newOppLineItem                            = itemRec.clone();
            newOppLineItem.Id                         = NULL;
            newOppLineItem.OpportunityId              = newOppId;    
            newOppLineItem.TotalPrice                 = NULL;  
            newOppLineItem.Core_Status__c             = PENDING_TEXT;  
            newOppLineItem.Core_Loss_Cancel_Reason__c = NULL;
            
           // BU Fields
            newOppLineItem.Core_Approved_BU_Product_Segment__c = NULL;
            newOppLineItem.Core_Approved_BU_Short_Name__c      = NULL;
            newOppLineItem.Core_BU_Product_Segment__c          = NULL;
            newOppLineItem.Core_BU_Short_Name__c               = NULL;            
            
            lstNewOppLineItem.add(newOppLineItem);
        }                     

        System.debug('#24 lstNewOppLineItem: ' + lstNewOppLineItem);   
        if (lstNewOppLineItem.size() > 0)
            try {
                Database.insert(lstNewOppLineItem, false);
            }
            catch (Exception err) {
                System.debug('#41 Core_Opportunity_Clone_Controller->cloneProducts: ' + err.getMessage());
                System.debug('#42 Core_Opportunity_Clone_Controller->cloneProducts->exception: ' + err);
                System.debug('#43 Core_Opportunity_Clone_Controller->cloneProducts->lstNewOppLineItem: ' + lstNewOppLineItem);
            }    
            
        System.debug('#25 lstNewOppLineItem: ' + lstNewOppLineItem);   
    }
    

    private void cloneFeatures(Id OldOpp, Id newOppId) {

        // Re-using lstInactiveOppFeatures
        lstInactiveOppFeatures = [SELECT Core_Feature_Type__c, Core_Feature_Name__c, Core_Feature_Set__c
                                  FROM Core_Opportunity_Features__c
                                  WHERE Core_Opportunity__c = :OldOpp
                                    AND Core_Feature_Set__r.Core_Active__c = true
                                    AND IsDeleted = false
                                  LIMIT 2000];  
                                              
        Core_Opportunity_Features__c oppFeature;                                              
        List<Core_Opportunity_Features__c> lstOppFeatures = new List<Core_Opportunity_Features__c>();
        for (Core_Opportunity_Features__c featureRec : lstInactiveOppFeatures) {
            oppFeature = new Core_Opportunity_Features__c();
            oppFeature.Core_Opportunity__c = newOppId;
            oppFeature.Core_Feature_Set__c = featureRec.Core_Feature_Set__c; 
            lstOppFeatures.add(oppFeature);
        }
        insert lstOppFeatures;
    }

    
    public String getAllFields(String sobjectname)
    {
        Map<String, Schema.SObjectField> fields = Schema.getGlobalDescribe().get(sobjectname).getDescribe().SObjectType.getDescribe().fields.getMap();

        List<String> accessiblefields = new List<String>();
        for(Schema.SObjectField field : fields.values()){
            if(field.getDescribe().isAccessible())
                accessiblefields.add(field.getDescribe().getName());
        }

        String allfields='';
        for(String fieldname : accessiblefields)
            allfields += fieldname+',';
            
        allfields = allfields.subString(0, allfields.length()-1);
        
        System.debug('#56 allFields: ' + allFields);
        
        return allfields;
    }
 
 
    public class TeamMemberSelectionWrapper {
        public OpportunityTeamMember oppTeamMember { get; set; } 
        public Boolean memberSelected { get; set; }
    
        public String name { 
            get { 
                if (oppTeamMember == NULL)
                    return NULL;
                else    
                    return oppTeamMember.Name;
            }
        } 

        public String teamMemberRole {
            get { 
                if (oppTeamMember == NULL)
                    return NULL;
                else    
                    return oppTeamMember.TeamMemberRole;
            } 
            
            set; 
        } 

        public String opportunityAccessLevel {
            get { 
                if (oppTeamMember == NULL)
                    return NULL;
                else    
                    return oppTeamMember.OpportunityAccessLevel;
            } 
            
            set; 
        } 

        public String core_Team_Member_Geo {
            get { 
                if (oppTeamMember == NULL)
                    return NULL;
                else    
                    return oppTeamMember.Core_Team_Member_Geo__c;
            } 
            
            set; 
        } 

        public Boolean readOnly { 
            get { 
                if (oppTeamMember == NULL)
                    return true;
                else  
                    return (oppTeamMember.TeamMemberRole.contains(OWNER_TEXT));
            }
        } 

        public TeamMemberSelectionWrapper(OpportunityTeamMember pOppTeamMember) { 
            oppTeamMember  = pOppTeamMember;
            memberSelected = true;            
        }
 
    }                  
}