global class CRM_OpportunitySLAEmailBatch implements Database.Batchable<SObject>, Database.Stateful {
    
    // Constants - Load SLA Config and Opportunity Coverage once as static variables
    public static final Map<String, CRM_Opportunity_SLA_Config__mdt> SLA_CONFIG_MAP = loadSLAConfig();
    public static final List<String> STAGE_NAMES = Core_CRM_Utility.getCRMLabel('CRM_Opp_SLA_Stage_Names').split(',');
    public static final String FROM_EMAIL_ADDRESS = System.Label.Core_SetFromEmailAddress;
    public static final Integer LOWEST_SLA_THRESHOLD = Integer.valueOf(Core_CRM_Utility.getCRMLabel('CRM_Opp_SLA_Lowest_Threshold'));
    public static final String SELLER_REPORT_ID = Core_CRM_Utility.getCRMLabel('CRM_SLA_Seller_Report_Id'); 
    public static final String MANAGER_REPORT_ID = Core_CRM_Utility.getCRMLabel('CRM_SLA_Manger_Report_Id');
    public static final String INTEL_LOGO = System.Label.CRM_IntelLogo;
    public static final List<String> RECORD_TYPE_NAME = Core_CRM_Utility.getCRMLabel('CRM_Opp_SLA_RecordType').split(',');
    public static final String CONTACT_ROLE_ERROR = Core_CRM_Utility.getCRMLabel('CRM_SLA_Contact_Role_Error_Message');
    public static final String QUERY_CONDITIONS = Core_CRM_Utility.getCRMLabel('CRM_Opp_SLA_Query_Condition');
    public static final Date TODAY_DATE = Date.today();
     public static final String POP_ERROR = Core_CRM_Utility.getCRMLabel('CRM_Opp_SLA_POP_Error');
    
    
    // Static methods to load constants
    private static Map<String, CRM_Opportunity_SLA_Config__mdt> loadSLAConfig() {
        Map<String, CRM_Opportunity_SLA_Config__mdt> configMap = new Map<String, CRM_Opportunity_SLA_Config__mdt>();
        try {
            for (CRM_Opportunity_SLA_Config__mdt config : [SELECT CRM_Record_Type__c, CRM_Stage_Name__c, CRM_SLA_Breach_1__c, CRM_SLA_Breach_2__c, CRM_Required_Fields__c, CRM_Opportunity_Coverage__c 
                FROM CRM_Opportunity_SLA_Config__mdt]) 
            {
                String key = config.CRM_Record_Type__c + '|' + config.CRM_Stage_Name__c;
                system.debug('INSIDE SLA CONFIG:'+config+' KEY IS:'+key);
                configMap.put(key, config);
            }
           
        } catch (Exception e) {
             Core_Log_Entry__c logEntry = new Core_Log_Entry__c(Core_Message__c = 'Error', Core_Details__c = e.getMessage(), Core_Origin__c = 'CRM_OpportunitySLAEmailBatch.loadSLAConfig', Core_Severity__c = 'Low', 
               Core_When__c = System.Now(), Core_Project__c = 'Sales CRM');          
            insert logEntry;
        }
        return configMap;
    }
    
    // Enhanced Opportunity Wrapper Classes
    public class OpportunityBreachWrapper {
        public Opportunity opportunity { get; set; }
        public Id opportunityId { get; set; }
        public String opportunityName { get; set; }
        public String opportunityUrl { get; set; }
        public String pipelineStage { get; set; }
        public Id recipientId { get; set; }
        public Boolean isOwnerRecipient { get; set; }
        public List<String> missingFields { get; set; }
        public Integer daysInStage { get; set; }
        public Boolean hasPOPAttachment { get; set; }
        public Boolean hasBusinessDecisionMaker { get; set; }
        
        public OpportunityBreachWrapper(Opportunity opp, Id recipient, Boolean isOwner) {
            this.opportunity = opp;
            this.opportunityId = opp.Id;
            this.opportunityName = opp.Name;
            this.opportunityUrl = URL.getOrgDomainUrl().toExternalForm()+ '/' + opp.Id;
            this.pipelineStage = opp.StageName;
            this.recipientId = recipient;
            this.isOwnerRecipient = isOwner;
            this.missingFields = new List<String>();
            this.daysInStage = Integer.valueOf(opp.Core_Days_in_Current_Stage__c);
            this.hasPOPAttachment = false; // Default value
            this.hasBusinessDecisionMaker = false; // Default value
        }
        
        public void setPOPAttachment(Boolean hasPOP) {
            this.hasPOPAttachment = hasPOP;
        }
        
        public void setBusinessDecisionMaker(Boolean hasBDM) {
            this.hasBusinessDecisionMaker = hasBDM;
        }
    }
    
    public class RecipientEmailWrapper {
        public Id recipientId { get; set; }
        public List<OpportunityBreachWrapper> breachedOpportunities { get; set; }
        
        public RecipientEmailWrapper(Id recipient) {
            this.recipientId = recipient;
            this.breachedOpportunities = new List<OpportunityBreachWrapper>();
        }
        
        public void addOpportunityBreach(OpportunityBreachWrapper breach) {
            this.breachedOpportunities.add(breach);
        }
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        /*return Database.getQueryLocator(
           [SELECT Id, Name, AccountId, Core_Opportunity_Type__c, CloseDate, Description, StageName, RecordType.Name, RecordTypeId,
                  Core_Days_in_Current_Stage__c, Core_Status_Update__c, Core_Product_Application__c,
                   Core_Product_Segment__c, Core_Consumption_Market__c, Core_Technical_Owner__c, Core_Intel_Platform__c, 
                   Core_Competitive_Architecture__c, Core_Product_Count__c, Core_Contact_Roles_Count__c, 
                   Core_First_Customer_Ship_Date__c, OwnerId, Owner.ManagerId, Owner.isActive, Core_Opportunity_Coverage_Nm__c
            FROM Opportunity 
            WHERE StageName IN :STAGE_NAMES 
            AND Core_Days_in_Current_Stage__c >= :LOWEST_SLA_THRESHOLD 
            AND CreatedDate >= :TWO_MONTHS_BACK 
            AND RecordType.Name IN :RECORD_TYPE_NAME
            ORDER BY OwnerId
        ]
);*/
       String query = 'SELECT Id, Name, AccountId, Core_Opportunity_Type__c, CloseDate, Description, StageName, RecordType.Name, RecordTypeId,Core_Days_in_Current_Stage__c, Core_Status_Update__c, Core_Product_Application__c,Core_Product_Segment__c, Core_Consumption_Market__c, Core_Technical_Owner__c, Core_Intel_Platform__c, Core_Competitive_Architecture__c, Core_Product_Count__c, Core_Contact_Roles_Count__c,Core_First_Customer_Ship_Date__c, OwnerId, Owner.ManagerId, Owner.isActive, Core_Opportunity_Coverage_Nm__c,Core_Commissionable__c FROM Opportunity '+ QUERY_CONDITIONS;
       system.debug('INSIDE QUERY IS:'+query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Opportunity> scope) {
        Set<Id> ownerIds = new Set<Id>();
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        List<PRM_EmailLog__c> logList = new List<PRM_EmailLog__c>();
        
        // Extract owner IDs
        for (Opportunity opp : scope) {
            if (opp.OwnerId != null) {
                ownerIds.add(opp.OwnerId);
            }
            if (opp.OwnerId != null && opp.Owner.ManagerId != null) {
                ownerIds.add(opp.Owner.ManagerId);
            }
        }

        // Load configuration data - now using constants
        Map<String, User> userMap = populateUserMap(ownerIds);
        Map<String, CRM_Opportunity_SLA_Config__mdt> configMap = SLA_CONFIG_MAP;
        Map<String, EmailTemplate> templateMap = loadTemplates();
      
        // Process opportunities and create breach wrappers
        List<OpportunityBreachWrapper> allBreaches = processOpportunityBreaches(scope, userMap, configMap);
        
        // Enhanced validation for Design stage opportunities
        processDesignStageValidations(allBreaches);
        
        // Process missing fields for all breaches
        processMissingFields(allBreaches, configMap);
        
        Map<String,Boolean> userWithSLAMap = checkSLAEmailPS(ownerIds);
        
        // Group breaches by recipient using wrapper
        List<RecipientEmailWrapper> recipientEmails = groupBreachesByRecipient(allBreaches,userWithSLAMap);
        
        // Build and send emails
        buildAndSendEmails(recipientEmails, userMap, templateMap, emails, logList);
        // Send the emails in bulk
        if (!emails.isEmpty()) {
            try {
                Messaging.SendEmailResult[] results = Messaging.sendEmail(emails);
                if(!logList.isEmpty()){
                 insert logList;   
                }
            } catch (Exception e) {
                handleException(e);
            }
        }
    }

    global void finish(Database.BatchableContext bc) {
       
    }

    // Core Processing Methods
    private List<OpportunityBreachWrapper> processOpportunityBreaches(List<Opportunity> scope, Map<String, User> userMap, Map<String, CRM_Opportunity_SLA_Config__mdt> configMap) {
        List<OpportunityBreachWrapper> breaches = new List<OpportunityBreachWrapper>();
        
        for (Opportunity opp : scope) {
            String key = getKey(opp.RecordType.Name, opp.StageName);
            system.debug('INSIDE KEY:'+key+' RECORD TYPE:'+opp.RecordType.Name+' OPP NAME:'+opp.Name);
            system.debug('INSIDE CONFIGMAP:'+configMap.keySet());
            CRM_Opportunity_SLA_Config__mdt config = configMap.get(key);
            List<String> coverageSet = String.isNotBlank(config.CRM_Opportunity_Coverage__c) ? config.CRM_Opportunity_Coverage__c.split(';') : new List<String>();
  
            if (config == null) continue;
            
            Integer days = Integer.valueOf(opp.Core_Days_in_Current_Stage__c);
            Id recipientId = determineRecipient(opp, days, config, userMap);
            
            if (recipientId != null && coverageSet.contains(opp.Core_Opportunity_Coverage_Nm__c)) {
                Boolean isOwnerRecipient = (recipientId == opp.OwnerId);
                breaches.add(new OpportunityBreachWrapper(opp, recipientId, isOwnerRecipient));
            }
        }
        
        return breaches;
    }
    
    private Id determineRecipient(Opportunity opp, Integer days, CRM_Opportunity_SLA_Config__mdt config, Map<String, User> userMap) {
        // Check if opportunity falls within SLA breach windows
        if (days > config.CRM_SLA_Breach_1__c && days <= config.CRM_SLA_Breach_1__c + 7 && opp.Owner.IsActive) {
            return opp.OwnerId; // Email to owner if within the first breach window
        } 
        
        if (days > config.CRM_SLA_Breach_2__c && days <= (config.CRM_SLA_Breach_2__c + 7)) {
            User owner = userMap.get(opp.OwnerId);
            if (owner != null && owner.ManagerId != null && owner.Manager.IsActive) {
                return owner.ManagerId; // Email to manager if within the second breach window
            }
        }
        
        return null;
    }
    
    private void processDesignStageValidations(List<OpportunityBreachWrapper> allBreaches) {
        // Filter Design stage opportunities
        List<OpportunityBreachWrapper> designStageBreaches = new List<OpportunityBreachWrapper>();
        Set<Id> designStageOppIds = new Set<Id>();
        
        for (OpportunityBreachWrapper breach : allBreaches) {
            if (breach.opportunity.StageName == 'Design') {
                designStageBreaches.add(breach);
                designStageOppIds.add(breach.opportunity.Id);
            }
        }
        
        if (designStageBreaches.isEmpty()) return;
        
        // Process POP attachments validation
        processPOPAttachments(designStageBreaches, designStageOppIds);
        
        // Process Business Decision Maker validation
        processBusinessDecisionMakers(designStageBreaches, designStageOppIds);
    }
    
    private void processPOPAttachments(List<OpportunityBreachWrapper> designBreaches, Set<Id> oppIds) {
        Set<Id> oppsWithPOP = new Set<Id>();
        String POP = '%' + Label.Core_Performance_indicator + '%';
        String POP1 = '%' + Label.Core_Performance_indicator1 + '%';
        
        if (oppIds.size() > 0) {
            // Check Attachments
            for (Attachment att : [SELECT ParentId FROM Attachment WHERE ParentId IN :oppIds AND (Name LIKE :POP OR Name LIKE :POP1)]) {
                oppsWithPOP.add(att.ParentId);
            }
            
            // Check Notes
            for (Note note : [SELECT ParentId FROM Note WHERE ParentId IN :oppIds AND (Title LIKE :POP OR Title LIKE :POP1)]) {
                oppsWithPOP.add(note.ParentId);
            }
            
            // Check Content Documents
            for (ContentDocumentLink cdl : [SELECT LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :oppIds AND ContentDocument.Title LIKE '%POP%']) {
                oppsWithPOP.add(cdl.LinkedEntityId);
            }
        }
        
        // Update wrapper objects with POP attachment status
        for (OpportunityBreachWrapper breach : designBreaches) {
            breach.setPOPAttachment(oppsWithPOP.contains(breach.opportunity.Id));
        }
    }
    
    private void processBusinessDecisionMakers(List<OpportunityBreachWrapper> designBreaches, Set<Id> oppIds) {
        Set<Id> oppsWithBDM = new Set<Id>();
        
        // Query OpportunityContactRoles for Business Decision Makers
        for (AggregateResult result : [SELECT OpportunityId, COUNT(Id) total FROM OpportunityContactRole WHERE OpportunityId IN :oppIds AND Role = 'Business Decision Maker' GROUP BY OpportunityId])
        {
            Integer count = (Integer) result.get('total');
            if (count > 0) {
                oppsWithBDM.add((Id) result.get('OpportunityId'));
            }
        }
        
        // Update wrapper objects with Business Decision Maker status
        for (OpportunityBreachWrapper breach : designBreaches) {
            breach.setBusinessDecisionMaker(oppsWithBDM.contains(breach.opportunity.Id));
        }
    }
    
    private List<RecipientEmailWrapper> groupBreachesByRecipient(List<OpportunityBreachWrapper> breaches, Map<String,Boolean> userWithSLAMap) {
        Map<Id, RecipientEmailWrapper> recipientMap = new Map<Id, RecipientEmailWrapper>();
        
        for (OpportunityBreachWrapper breach : breaches) {
            // Check if user has SLA access before processing
            Boolean hasAccess = userWithSLAMap != null && userWithSLAMap.containsKey(String.valueOf(breach.recipientId)) ? userWithSLAMap.get(String.valueOf(breach.recipientId)) : false;
            if (hasAccess) {
                if (!recipientMap.containsKey(breach.recipientId)) {
                    recipientMap.put(breach.recipientId, new RecipientEmailWrapper(breach.recipientId));
                }
                recipientMap.get(breach.recipientId).addOpportunityBreach(breach);
            }
        }
        
        return recipientMap.values();
    }
    
    private void processMissingFields(List<OpportunityBreachWrapper> breaches, Map<String, CRM_Opportunity_SLA_Config__mdt> configMap) {
        for (OpportunityBreachWrapper breach : breaches) {
            String key = getKey(breach.opportunity.RecordType.Name, breach.opportunity.StageName);
            CRM_Opportunity_SLA_Config__mdt config = configMap.get(key);
            
            // Process required fields
            if (config != null && String.isNotBlank(config.CRM_Required_Fields__c)) {
                List<String> missingFields = getMissingFields(breach.opportunity, config.CRM_Required_Fields__c);
                breach.missingFields.addAll(missingFields);
            }
            
            // Process Design stage custom logic using wrapper properties
            if (breach.opportunity.StageName == 'Design') {
                List<String> customLogicErrors = checkCustomLogicWithWrapper(breach);
                breach.missingFields.addAll(customLogicErrors);
            }
        }
    }
    
    private void buildAndSendEmails(List<RecipientEmailWrapper> recipientEmails, Map<String, User> userMap, Map<String, EmailTemplate> templateMap,
                                  List<Messaging.SingleEmailMessage> emails, List<PRM_EmailLog__c> logList) {
        for (RecipientEmailWrapper recipientEmail : recipientEmails) {
            
            User recipient = userMap.get(recipientEmail.recipientId);
            if (recipient == null) continue;
            
            // Determine template based on first opportunity's recipient type
            OpportunityBreachWrapper firstBreach = recipientEmail.breachedOpportunities[0];
            Id templateId = firstBreach.isOwnerRecipient ? templateMap.get('CRM_Opportunity_SLA_Breach_Seller').Id : templateMap.get('CRM_Opportunity_SLA_Breach_Supervisor').Id;
            String templateName = firstBreach.isOwnerRecipient ? 'CRM_Opportunity_SLA_Breach_Seller': 'CRM_Opportunity_SLA_Breach_Supervisor';
            String templateBody = firstBreach.isOwnerRecipient ? templateMap.get('CRM_Opportunity_SLA_Breach_Seller').HtmlValue : templateMap.get('CRM_Opportunity_SLA_Breach_Supervisor').HtmlValue;
            
            Id reportId = firstBreach.isOwnerRecipient ? SELLER_REPORT_ID: MANAGER_REPORT_ID;
            String reportURL = URL.getOrgDomainUrl().toExternalForm() + '/lightning/r/Report/' + reportId + '/view';
            
            // Generate HTML table rows with appropriate format
            Boolean isManagerEmail = !firstBreach.isOwnerRecipient;
            List<String> rows = generateEmailRows(recipientEmail.breachedOpportunities, isManagerEmail, userMap);
            String htmlTable = generateHtmlTable(rows, isManagerEmail);
            
            // Build email
            Messaging.SingleEmailMessage email = buildEmailWithTemplate(firstBreach.opportunity, recipient, templateId, htmlTable,reportURL,templateBody,isManagerEmail);
            system.debug('INSIDE MAIL:'+email);
            emails.add(email);
            
            Map<String,String> emptyIdAddressMap = new Map<String,String>();
			Map<String,User>  emptyContactIdUserMap= new Map<String,User>();
            
            logList.addAll(PRM_EmailUtility.createEmailLogsBasedOnType(email,'Sales CRM',emptyIdAddressMap,emptyContactIdUserMap,userMap,'English',templateName));
        }
    }
    
    private List<String> generateEmailRows(List<OpportunityBreachWrapper> breaches, Boolean isManagerEmail, Map<String, User> userMap) {
        List<String> rows = new List<String>();
        for (OpportunityBreachWrapper breach : breaches) {
            String missingFieldsStr = String.join(breach.missingFields, ', ');
            
            if (isManagerEmail) {
                // Manager email format with additional columns
                User owner = userMap.get(breach.opportunity.OwnerId);
                String ownerName = owner != null ? owner.Name : 'Unknown';
                String ownerStatus = owner != null ? (owner.IsActive ? 'Active' : 'Inactive') : 'Unknown';
                
                rows.add('<tr>' +
                        '<td>' + breach.opportunity.Id + '</td>' +
                        '<td><a href="' + breach.opportunityUrl + '">' + breach.opportunity.Name + '</a></td>' +
                        '<td>' + ownerName + '</td>' +
                        '<td>' + ownerStatus + '</td>' +
                        '<td>' + breach.opportunity.StageName + '</td>' +
                        '<td>' + breach.daysInStage + '</td>' +
                        '<td>' + missingFieldsStr + '</td>' +
                        '</tr>');
            } else {
                // Owner email format (original format)
                rows.add('<tr>' +
                        '<td>' + breach.opportunity.Id + '</td>' +
                        '<td><a href="' + breach.opportunityUrl + '">' + breach.opportunity.Name + '</a></td>' +
                        '<td>' + breach.opportunity.StageName + '</td>' +
                        '<td>' + breach.daysInStage + '</td>' +
                        '<td>' + missingFieldsStr + '</td>' +
                        '</tr>');
            }
        }
        return rows;
    }

    // Helper Methods
    public List<String> checkCustomLogicWithWrapper(OpportunityBreachWrapper breach) {
        List<String> missingLogicString = new List<String>();
        Id designRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Design Opportunity').getRecordTypeId();
        Id dealRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Deal Opportunity').getRecordTypeId();
        
        Opportunity opp = breach.opportunity;
        
        if (opp.RecordTypeId == dealRecordTypeId || opp.RecordTypeId == designRecordTypeId) {
            if (!breach.hasPOPAttachment && opp.StageName == 'Design' && breach.opportunity.Core_Commissionable__c== 'Yes') {
                missingLogicString.add(POP_ERROR);
            }
            if (!breach.hasBusinessDecisionMaker && opp.StageName == 'Design') {
                missingLogicString.add(System.Label.Core_Opp_Deal_SellTo_Error_Message);
            }
        }
        return missingLogicString;
    }

    public Map<String, User> populateUserMap(Set<Id> ownerIds){
         Map<String, User> userMap = new Map<String, User> ();
         if (!ownerIds.isEmpty()) {
             userMap.putAll([SELECT Id, Name, IsActive, Email, ManagerId, Manager.Email, Manager.IsActive FROM User WHERE Id IN :ownerIds]);
         }  
        return userMap;
    }
        
    public Map<String, EmailTemplate> loadTemplates() {
        Map<String,EmailTemplate > templateMap = new Map<String, EmailTemplate>();
        for (EmailTemplate tmpl : [SELECT Id, DeveloperName,Name,HtmlValue FROM EmailTemplate WHERE DeveloperName IN ('CRM_Opportunity_SLA_Breach_Seller','CRM_Opportunity_SLA_Breach_Supervisor')]) {
            templateMap.put(tmpl.DeveloperName, tmpl);
        }
        return templateMap;
    }
    
     public static Map<String,Boolean> checkSLAEmailPS(Set<Id> ownerId){
        Map<String, Boolean> userWithSLAAccess = new Map<String, Boolean>();
        Set<Id> usersWithPermission = new Set<Id>();
        
        String dynamicCondition = Core_CRM_Utility.getCRMLabel('CRM_Opp_SLA_PS_Query');
        
        String query;
        
        // Check if dynamic condition string exists
        if (String.isNotBlank(dynamicCondition)) {
            // Use the dynamic condition
            query = 'SELECT AssigneeId, PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId IN :ownerId ' + dynamicCondition;
        } else {
            // Default query when string is not there
            query = 'SELECT AssigneeId, PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId IN :ownerId';
        }
        
        // Execute the dynamic query
        List<PermissionSetAssignment> psaList = Database.query(query);
        
        for (PermissionSetAssignment psa : psaList) {
            usersWithPermission.add(psa.AssigneeId);
        }
        
        // Build the result map
        for (Id userId : ownerId) {
            userWithSLAAccess.put(String.valueOf(userId), usersWithPermission.contains(userId));
        }
    return userWithSLAAccess;
}

    public String getKey(String recordType, String stage) {
        return recordType + '|' + stage;
    }
    
    public List<String> getMissingFields(Opportunity opp, String requiredFieldsString) {
        List<String> missing = new List<String>();
        List<String> fields = requiredFieldsString.split(';');
        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Opportunity.fields.getMap();
        Id designRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Design Opportunity').getRecordTypeId();
        Id dealRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Deal Opportunity').getRecordTypeId();

        for (String field : fields) {
            field = field.trim();
            if (fieldMap.containsKey(field)) {
                Object val = opp.get(field);
                if (val == null || val instanceof String && ((String) val).trim() == '') {
                    String label = fieldMap.get(field).getDescribe().getLabel();
                    missing.add(label);
                }
                if(opp.RecordTypeId == dealRecordTypeId || opp.RecordTypeId == designRecordTypeId) {
                	if (opp.Core_Product_Count__c == 0 && field == 'Core_Product_Count__c' && opp.StageName == 'Develop') {
               			missing.add(System.Label.Core_Opp_Product_Count);
                	}
             	    if (opp.Core_Contact_Roles_Count__c == 0 && field == 'Core_Contact_Roles_Count__c' && opp.StageName == 'Define') {
               			missing.add(CONTACT_ROLE_ERROR);
                     }
                 }
            }
        }
        return missing;
    }

    public String generateHtmlTable(List<String> rows, Boolean isManagerEmail) {
        String headerRow;
        
        if (isManagerEmail) {
            // Manager email header with additional columns
            headerRow = '<tr style="background-color: #f2f2f2;">' +
                       '<th>Opportunity ID</th>' +
                       '<th>Opportunity Name</th>' +
                       '<th>Owner</th>' +
                       '<th>Owner Status</th>' +
                       '<th>Pipeline Stage</th>' +
                       '<th>Days in Stage</th>' +
                       '<th>Required Fields</th>' +
                       '</tr>';
        } else {
            // Owner email header (original format)
            headerRow = '<tr style="background-color: #f2f2f2;">' +
                       '<th>Opportunity ID</th>' +
                       '<th>Opportunity Name</th>' +
                       '<th>Pipeline Stage</th>' +
                       '<th>Days in Stage</th>' +
                       '<th>Required Fields</th>' +
                       '</tr>';
        }
        
        return '<br/>' +
               '<table border="1" cellpadding="6" cellspacing="0" style="border-collapse: collapse;">' +
               headerRow +
               String.join(rows, '') +
               '</table>';
    }

    public Messaging.SingleEmailMessage buildEmailWithTemplate(Opportunity opp, User recipient, Id templateId, String htmlTable, String reportURL,String tempBody,Boolean isManagerEmail) {
        /*Messaging.SingleEmailMessage renderResult = Messaging.renderStoredEmailTemplate(templateId, recipient.Id, opp.Id);
        String templateBody = renderResult.getHtmlBody();*/
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

       String templateBody = tempBody;
       email.setTemplateId(templateId);
       email.setTargetObjectId(recipient.Id);
       email.setOrgWideEmailAddressId(FROM_EMAIL_ADDRESS);
       email.setSaveAsActivity(false);
       email.setSubject(isManagerEmail ? 'Weekly Summary: Opportunities Requiring Review Sales CRM' :  'Weekly Summary: Opportunities Requiring Updates Sales CRM');
       String nameWithTable = templateBody.replace('[NAME]', recipient.Name);
       String bodyWithTable = nameWithTable.replace('[REQUIRED_FIELDS]', htmlTable);
       String finalBody = bodyWithTable.replace('[REPORT_LINK]', reportURL);
       String finalBodyWithLogo = finalBody.replace('[LOGO_URL]', INTEL_LOGO);
       email.setHtmlBody(finalBodyWithLogo);
    
        return email;
    }
    
    private void handleException(Exception e) {
        Core_Log_Entry__c ExcepLog = new Core_Log_Entry__c(Core_Message__c = 'Error:' + e.getMessage(),
                                                          Core_Details__c = 'Line number: ' + e.getLineNumber() + ', Stack trace: ' + e.getStackTraceString(),
                                                          Core_Origin__c = 'CRM_OpportunitySLAEmailBatch', Core_Severity__c = 'High',
                                                          Core_When__c = System.Now(), Core_Project__c = 'Sales CRM', Core_sObjectId__c = '');
        insert ExcepLog;
    }
}