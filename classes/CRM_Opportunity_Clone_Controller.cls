/**************************************************
 Apex Class Name:  CRM_Opportunity_Clone_Controller
Version     : 1.0 
Created Date: 4/21/2025
**************************************************/
public without sharing class CRM_Opportunity_Clone_Controller {
 	public static final String  NOT_SUBMITTED_TEXT        = 'Not Submitted';
    public static final String  OWNER_TEXT                = 'Owner';
    public static final String  PENDING_TEXT              = 'Pending';
    public static final Integer QUALIFY_PROBABILITY       = 15;
    public static final String  QUALIFY_TEXT              = 'Qualify';
    public static final String  QUALIFY_FORECAST_CATEGORY_TEXT = 'Omitted';
    public static final String  VENDOR_TEXT               = 'Vendor';
    public static final String  TECH_OWNER_SEGMENTS       = 'Embedded,Compute';
    public static final String  YES_TEXT                  = 'Yes';
    public static final String  NO_TEXT                   ='No';
    public static final String  DEF_COMPLIANCE_STATUS     ='On Hold – Review in Progress';  //US103708-If Clone Opp has MAG Flag is true,then default value for Compliance status.      
    public static final String  DEF_COMPLIANCE_SUB_STATUS ='AR - Owner to fill out MAG Questionnaire';   //US103708-If Clone Opp has MAG Flag is true,then default value for Compliance Sub Status.  
    public String  searchMessage { get; set; }                     // Actual error message
    public String  searchSeverity { get; set; }                   // Actual error message
    @AuraEnabled public Boolean searchShowMessage { get; set; }                  // Flag to render error message if user didn't enter value for search criteria    
    @AuraEnabled public Boolean searchShowPage { get; set; }                     // Flag to control page display - don't show page for inactive accounts.
    @AuraEnabled public Boolean opportunityFeaturesSelected { get; set; }
    @AuraEnabled public Boolean opportunityPartnersSelected { get; set; } 
    @AuraEnabled public Boolean opportunityProductSelected { get; set; } 
    @AuraEnabled public Boolean opportunitySolutionSelected { get; set; }
    @AuraEnabled public Boolean opportunityTeamSelected { get; set; }
    
    @AuraEnabled public Boolean showInactiveOppFeatures { get; set; }
    @AuraEnabled public Boolean showInactiveOppPartner { get; set; }
    @AuraEnabled public Boolean showInactiveOppProduct { get; set; }
    @AuraEnabled public Boolean showInactiveOppTeam { get; set; }
    
    //US103708-  Start -Decalred below fields are notes and attachment added by rajesh //
    @AuraEnabled Public Boolean showNote                 {get;set;}
    @AuraEnabled Public Boolean showAttachment           {get;set;}
    @AuraEnabled Public Boolean showContentlink          {get;set;}
  	@AuraEnabled Public Boolean isAttachment             {get;set;}
    @AuraEnabled Public Boolean isAttachmentSelected     {get;set;}
    @AuraEnabled Public List<Note> noteList              {get;set;} 
    @AuraEnabled Public List<Attachment> attList          {get;set;}
    Public List<ContentDocumentLink> contDocLink{get;set;}
    //US103708-  End -Decalred below fields are notes and attachment added by rajesh //
    
    @AuraEnabled public Boolean showOppFeatures { get; set; }
    @AuraEnabled public Boolean showOppPartner { get; set; }
    @AuraEnabled public Boolean showOpportunityProductOption { get; set; }  
    @AuraEnabled public Boolean showOpportunitySolution { get; set; } 
    public Opportunity currentOpportunity { get; set; }    
    public static List<Core_Opportunity_Features__c> lstInactiveOppFeatures { get; set; } 
    public static List<Core_Opportunity_Partner__c>  lstInactiveOppPartner { get; set; } 
    public static List<OpportunityLineItem>          lstInactiveOppProduct { get; set; } 
    public static List<OpportunityTeamMember>        lstInactiveOppTeam { get; set; } 
    public List<OpportunityTeamMember>        lstOppTeam { get; set; }
    public List<TeamMemberSelectionWrapper>   lstSelectOppTeam { get; set; }    
    public static boolean isPartner = false;                        //Added by Ashwin for defect fix on US95566
    public List<Id> listUserIdToClearDescription  { get; set; }  


    @AuraEnabled(cacheable = true)
    public static Map<String,Object> cloneMainOpp(Id oppId){
        Integer iQueryCount;
        
        Boolean showOppFeatures;
        Boolean showOppPartner;
        Boolean showOpportunityProductOption;
        Boolean showOpportunitySolution;
        Boolean isAttachment;
        
        Boolean showAttachment;
        Boolean showNote;
        Boolean showContentlink;
        
        Boolean showInactiveOppFeatures;
        Boolean showInactiveOppPartner;
        Boolean showInactiveOppProduct;
        Boolean showInactiveOppTeam;
       
        Map<String, Boolean> showFlag = new Map<String, Boolean>();
        Map<String, Object> inactiveEntity = new Map<String, Object>();
        Map<String, Object> combinedMap = new Map<String,Object>();
        
        String searchMessage;
        String searchSeverity ;
        Boolean searchShowMessage;
        Boolean searchShowPage ;
        Boolean opportunityFeaturesSelected;
        Boolean opportunityPartnersSelected;
        Boolean opportunityProductSelected;
        Boolean opportunitySolutionSelected; 
        Boolean opportunityTeamSelected;
        Boolean isAttachmentSelected;
        
        
        List<Core_Opportunity_Features__c> lstInactiveOppFeatures = new List<Core_Opportunity_Features__c>();
        List<Core_Opportunity_Partner__c>  lstInactiveOppPartner = new List<Core_Opportunity_Partner__c>();
        List<OpportunityLineItem>  lstInactiveOppProduct = new List<OpportunityLineItem>();
        List<OpportunityTeamMember> lstInactiveOppTeam = new List<OpportunityTeamMember>();
        List<OpportunityTeamMember>  lstOppTeam = new List<OpportunityTeamMember>();
        List<Attachment> attList = new List<Attachment>();
        List<Note> noteList   = new List<Note>();
        List<ContentDocumentLink> contDocLink = new List<ContentDocumentLink>();
        
        
        Opportunity currentOpp =[SELECT Id, Name, Owner.IsActive, Core_Technical_Owner__r.isActive, Account.Name, Account.RecordType.Name,core_Sales_Segments__c, Core_Consumption_Market__c,Core_Product_Application__c,Core_Product_Segment__c,
                              Account.Core_Military_Aerospace_and_Government__c, Core_Military_Aerospace_Govmt_End_Use__c,Core_Intel_Platform__c,Core_First_Customer_Ship_Date__c,CloseDate, Core_Volume__c,Core_Production_End_Date__c,Core_Manufacturing_Geo__c,Core_Solution_Area__c,Pricebook2Id                  
                              FROM Opportunity  WHERE Id = :oppId WITH SECURITY_ENFORCED];
        
        currentOpp.Core_Military_Aerospace_Govmt_End_Use__c = null;
        //error message handle -- need to handle
        String accountRecordTypeName = currentOpp.Account.RecordType.Name;
        if (accountRecordTypeName != NULL && accountRecordTypeName.contains('Inactive')) {                 
            searchMessage    += '                                                           ' + 
                'Account \"' + currentOpp.Account.Name + '\" is inactive.  Cannot clone opportunities from inactive accounts".';
            searchSeverity    = 'error';            
            searchShowMessage = true;
            searchShowPage    = false;
        } 
        
        if (currentOpp.Core_Sales_Segments__c != NULL && TECH_OWNER_SEGMENTS.contains(currentOpp.Core_Sales_Segments__c)) {        
            if (currentOpp.Core_Technical_Owner__c == NULL || currentOpp.Core_Technical_Owner__r.isActive == false) {                 
                searchMessage    += '                                                           ' + 
                    'An active Technical Owner is required.  Opportunity Owner will be cloned as new Technical Owner.';
                searchSeverity    = 'info';            
                searchShowMessage = true;
            }                
        }
        // error message handle --- need to handle
   		// Descriptive features
        lstInactiveOppFeatures = [SELECT Core_Feature_Type__c, Core_Feature_Name__c, IsDeleted,Core_Feature_Set__r.Core_Active__c
                                  FROM Core_Opportunity_Features__c
                                  WHERE Core_Opportunity__c = :currentOpp.Id
                                  AND Core_Feature_Set__r.Core_Active__c = false WITH SECURITY_ENFORCED
                                  LIMIT 2000 ];    //TWC3123-5310 - Added WITH SECURITY_ENFORCED                             
        showInactiveOppFeatures = lstInactiveOppFeatures.size() > 0;
        
        iQueryCount = Database.CountQuery('SELECT COUNT() ' + 
                                          'FROM Core_Opportunity_Features__c ' + 
                                          'WHERE Core_Opportunity__c = \'' + currentOpp.Id + '\'' + 
                                          '  AND IsDeleted = false');
        showOppFeatures = iQueryCount > 0;
        system.debug(showOppFeatures);
        //Opportunity Partners
        lstInactiveOppPartner = [SELECT Core_Partner__r.Name, Core_Partner_Role__c, Core_Partner_Type__c,
                                 Core_Partner_Program__c, Core_Partner__r.Core_Deactivated__c
                                 FROM Core_Opportunity_Partner__c
                                 WHERE Core_Opportunity__c = :currentOpp.Id
                                 AND (Core_Partner__r.Core_Deactivated__c = true OR Core_Partner_Role__c = :VENDOR_TEXT) WITH SECURITY_ENFORCED
                                 LIMIT 2000]; //TWC3123-5310 - Added WITH SECURITY_ENFORCED
        showInactiveOppPartner = lstInactiveOppPartner.size() > 0;
        
        iQueryCount = Database.CountQuery('SELECT COUNT() ' + 
                                          'FROM Core_Opportunity_Partner__c ' + 
                                          'WHERE Core_Opportunity__c = \'' + currentOpp.Id + '\'' + 
                                          '  AND Core_Partner__r.Core_Deactivated__c = false ' + 
                                          '  AND Core_Partner_Role__c != \'' + VENDOR_TEXT + '\'');
        showOppPartner = iQueryCount > 0;
        //Opportunity Product
        lstInactiveOppProduct = [SELECT Name, Core_Product_Type__c, Quantity, TotalPrice, Core_Status__c, Product2.IsActive, Product2.isDeleted 
                                 FROM OpportunityLineItem
                                 WHERE Opportunity.Id = :currentOpp.Id
                                 AND (Product2.IsActive=false OR Product2.isDeleted=true) WITH SECURITY_ENFORCED
                                 LIMIT 2000]; //TWC3123-5310 - Added WITH SECURITY_ENFORCED
        
        showInactiveOppProduct = lstInactiveOppProduct.size() > 0;
        
        iQueryCount = Database.CountQuery('SELECT COUNT() ' + 
                                          'FROM OpportunityLineItem ' + 
                                          'WHERE Opportunity.Id = \'' + currentOpp.Id + '\'' + 
                                          '  AND Product2.IsActive = true ' + 
                                          '  AND Product2.isDeleted = false');
        
        showOpportunityProductOption = iQueryCount > 0;
        //Solutions
        iQueryCount = Database.CountQuery('SELECT COUNT() ' + 
                                          'FROM Opportunity_Solution_Area__c ' + 
                                          'WHERE Core_Opportunity__c = \'' + currentOpp.Id + '\'');
        
        showOpportunitySolution = iQueryCount > 0;
        //Attachments and Notes
        attList=new List<Attachment>([SELECT Id from Attachment where parentId=:currentOpp.Id WITH SECURITY_ENFORCED]);
        
        notelist=new List<Note>([SELECT Id FROM Note where ParentId =:currentOpp.Id WITH SECURITY_ENFORCED]);  
        contDocLink=new List<ContentDocumentLink>([SELECT ContentDocumentId,LinkedEntityId,ShareType,Visibility FROM ContentDocumentLink WHERE LinkedEntityId=:currentOpp.Id WITH SECURITY_ENFORCED]);
        showAttachment=attList.size()>0;  
        showNote=notelist.size()>0;
        showContentlink=contDocLink.size()>0; 
        if(showAttachment || showNote || showContentlink){
            isAttachment = true;
        }
        // Opp team
        lstInactiveOppTeam = [SELECT Name, TeamMemberRole, Core_Team_Member_Geo__c, User.IsActive
                              FROM OpportunityTeamMember
                              WHERE OpportunityId = :currentOpp.Id
                              AND User.IsActive = false WITH SECURITY_ENFORCED
                              LIMIT 2000];//TWC3123-5310 - Added WITH SECURITY_ENFORCED 
        system.debug('lstInactiveOppTeam 195'+lstInactiveOppTeam);
        showInactiveOppTeam = lstInactiveOppTeam.size() > 0;
        //Storing booleans in Map
        showFlag.put('showOppFeatures',showOppFeatures);
        showFlag.put('showOppPartner',showOppPartner);
        showFlag.put('showOpportunityProductOption',showOpportunityProductOption);
        showFlag.put('showOpportunitySolution',showOpportunitySolution);
        showFlag.put('isAttachment',isAttachment);
        showFlag.put('showContentlink',showContentlink);
        showFlag.put('showNote',showNote);
        showFlag.put('showAttachment',showAttachment);
        showFlag.put('showInactiveOppFeatures',showInactiveOppFeatures);
        showFlag.put('showInactiveOppPartner',showInactiveOppPartner);
        showFlag.put('showInactiveOppProduct',showInactiveOppProduct);
        showFlag.put('showInactiveOppTeam',showInactiveOppTeam);
        
        //String inactive lists in a different map
        inactiveEntity.put('inactiveOppTeam',lstInactiveOppTeam);
        system.debug('lstInactiveOppTeam '+lstInactiveOppTeam);
        inactiveEntity.put('inactiveOppDescFts',lstInactiveOppFeatures);
        inactiveEntity.put('inactiveOppPartner',lstInactiveOppPartner);
        inactiveEntity.put('inactiveOppProducts',lstInactiveOppProduct);
        
        //nested map
        combinedMap.put('showFlags',showFlag);
        combinedMap.put('inactiveLists',inactiveEntity);
        
        return combinedMap;
    }
    
    @AuraEnabled(cacheable = true)
    public static List<OpportunityTeamMember> getOppTeamMembers(Id oppId){
        return [SELECT UserId,Name, OpportunityAccessLevel, TeamMemberRole, Core_Team_Member_Geo__c
                      FROM OpportunityTeamMember
                      WHERE OpportunityId = :oppId
                      AND User.IsActive = true
                      LIMIT 2000];
    }
    
    public Pagereference cancelClone() { 
        return new PageReference('/' + currentOpportunity.Id);
    }
    public pagereference toggleDisplay() {    
        return NULL;
    }  
    @AuraEnabled
    public static ID continueClone(Id oppId,String newOppName, Date newOppDD, String newOppMINDS,String payload,List<Id>teamIds) {
        
        List<Attachment> attList = new List<Attachment>();
        List<Note> noteList   = new List<Note>();
        List<ContentDocumentLink> contDocLink = new List<ContentDocumentLink>();
        
        GetSelectionsEntities wrapper = (GetSelectionsEntities) JSON.deserialize(payload,GetSelectionsEntities.class);
        system.debug(oppId+' '+newOppName+' '+newOppDD+' '+newOppMINDS+' '+wrapper.showentities+' '+wrapper.showselections);
        
        Opportunity currentOpp =[SELECT Id, Name, Owner.IsActive, Core_Technical_Owner__r.isActive, Account.Name, Account.RecordType.Name,core_Sales_Segments__c, Core_Consumption_Market__c,Core_Product_Application__c,Core_Product_Segment__c,
                              Account.Core_Military_Aerospace_and_Government__c, Core_Military_Aerospace_Govmt_End_Use__c,Core_Intel_Platform__c,Core_First_Customer_Ship_Date__c,CloseDate, Core_Volume__c,Core_Production_End_Date__c,Core_Manufacturing_Geo__c,Core_Solution_Area__c,Pricebook2Id                  
                              FROM Opportunity  WHERE Id = :oppId WITH SECURITY_ENFORCED];
        //US102793 : Added a Custom Label to store the error messages -- Ashwin
        List<String> errMsgList = System.label.Core_Opp_CloneCont_Msgs.split(';');
        String strFields = getAllFields('Opportunity');        
        String oppQuery = 'SELECT Core_Technical_Owner__r.Profile.Name, ' + strFields + ' FROM Opportunity WHERE Id = \'' + oppId + '\'';       
        
        //TWC3123-5376: codescan fix : Avoid Untrusted/Unescaped Variables in DML Query(possible soql injection)-added String.escapeSingleQuotes
        Opportunity oppRec = Database.query(String.escapeSingleQuotes(oppQuery).replaceAll('\\\\', '')); //(oppQuery);
        //oppRec.Opportunity_Focus__c = ''; // Areefa
        //US103708-Added logic for insert the Clone Opportunity added by-Rajesh.   
        oppRec=insertCloneOpportunity(oppRec,currentOpp,newOppName,newOppDD,newOppMINDS);
        
        oppRec.Core_Renewal_Opportunity_Id__c = null;
        oppRec.Core_Renewed_Opportunity_Ind__c = false;
        
        //START - Added by Ashwin for defect fix on US95566 - Checking if the products have invalid pricebook
        map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
        if(mapFunctionalityNameTriggerExecution.containsKey('opptyCloneErrorMsg') && mapFunctionalityNameTriggerExecution.get('opptyCloneErrorMsg').Core_Active__c){
            List<OpportunityLineItem> oliList1 = new List<OpportunityLineItem>();
            oliList1 = [SELECT id, Product2Id FROM OpportunityLineItem WHERE OpportunityId = :currentOpp.Id WITH SECURITY_ENFORCED ]; //TWC3123-5310 - Added WITH SECURITY_ENFORCED 
            Set<Id> pId2Set = new Set<Id>();
            for(OpportunityLineItem oli : oliList1){
                pId2Set.add(oli.Product2Id);
            }
            /*List<PricebookEntry> pbeList = new List<PricebookEntry>();
            pbeList = [SELECT id, Product2Id, isActive FROM Pricebookentry WHERE Product2Id IN :pId2Set AND isActive = true WITH SECURITY_ENFORCED];//TWC3123-5310 - Added WITH SECURITY_ENFORCED
            if(pbeList.isEmpty() && opportunityProductSelected && showOpportunityProductOption){
                //US102793 : Modified the error message -- Ashwin
                Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, errMsgList[0]));
                return null;
            }*/
        }
        //END - Added by Ashwin for defect fix on US95566 - Checking if the products have invalid pricebook
        
        // Added by Bharath for INC12183970 as part of TWC3123-3556
        if(wrapper.showselections.selectedOppSolutions && wrapper.showentities.showOpportunitySolution){
            oppRec.Core_has_Solution__c = true;
        }else{
            oppRec.Core_has_Solution__c = false;
        }
        //Added for TWC3123-3499 - to not populate Concatenation values if Solutions are not copied
        if(!wrapper.showselections.selectedOppSolutions)
            {
                oppRec.Core_Concatenated_Application_workload__c = null;
                oppRec.Core_Concatenated_Industry_use_case__c = null;
                oppRec.Core_Concatenated_Technology_Enabled__c = null;
            }
        //End of Change - TWC3123-3499
        Pricebook2 pb2;
        pb2 = [SELECT Id FROM pricebook2 WHERE IsStandard = false WITH SECURITY_ENFORCED LIMIT 1]; 
        if(oppRec.Core_Channel_Opportunity_Ind__c){         
            if(pb2 != null && oppRec.PriceBook2Id == pb2.Id){
                isPartner = true;
            }
        } 
        try{  
            insert oppRec; 
            //run this method only when isPartner is true-added by Raga
            if(isPartner){
                updateOppPriceBook(oppRec.Id);   
            }               
        }catch(DmlException e){
            //US102793 : Modified the error message -- Ashwin
           // Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, errMsgList[1]));
           // Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
          
           throw new AuraHandledException(e.getDmlMessage(0));
        }
         
        
        // CloneTeam has special logic to reflect user selections.
        // The Opportunity Owner and Technical Owner are created automatically by the Opportunity trigger handler.
        
        if (wrapper.showselections.selectedOppTeamMembers)
            cloneTeam(oppRec.Id,teamIds);
        
        if (wrapper.showselections.selectedDescFeat && wrapper.showentities.showOppFeatures)
            cloneFeatures(currentOpp.Id, oppRec.Id);
        
        if (wrapper.showselections.selectedOppPartners && wrapper.showentities.showOppPartner)
            clonePartners(currentOpp.Id, oppRec.Id);
        
        if (wrapper.showselections.selectedOppProducts && wrapper.showentities.showOpportunityProductOption){
            //Call for Partner Oppty(Disti)-Added by Raga
            if(isPartner){
                String strFields1 = getAllFields('OpportunityLineItem');
                cloneProductsPartners(currentOpp.Id, oppRec.Id,strFields1);
            }
            else{
                cloneProducts(currentOpp.Id,oppRec.Id);
            }
        }
        
        if (wrapper.showentities.showOpportunitySolution && wrapper.showselections.selectedOppSolutions)
            cloneSolutions(currentOpp.Id, oppRec.Id);
        
        if(wrapper.showselections.selectedOppAttachments && wrapper.showentities.showAttachment){
            //TWC3123-1565-Notes & Attachment queries were modified to remove body field in constructor, as it was adding the view state.
            attList=new List<Attachment>([SELECT Id, Body, Name, ParentId, ContentType, Parent.Type,BodyLength,Description from Attachment where parentId=:currentOpp.Id]);
            insertCloneOppAttachment(oppRec.Id,attList);
        }
        
        if(wrapper.showselections.selectedOppAttachments && wrapper.showentities.showNote){
            //TWC3123-1565-Notes & Attachment queries were modified to remove body field in constructor, as it was adding the view state.
            notelist=new List<Note>([SELECT Id, Body,ParentId,Title  FROM Note where ParentId =:currentOpp.Id WITH SECURITY_ENFORCED]);//TWC3123-5310 - Added WITH SECURITY_ENFORCED
            insertCloneNote(oppRec.Id,notelist);
        }
        if(wrapper.showselections.selectedOppAttachments && wrapper.showentities.showContentlink){
            contDocLink=new List<ContentDocumentLink>([SELECT ContentDocumentId,LinkedEntityId,ShareType,Visibility FROM ContentDocumentLink WHERE LinkedEntityId=:currentOpp.Id WITH SECURITY_ENFORCED]);
            insertCloneOppContentDocumentLink(oppRec.Id,contDocLink);
        }
        
         
        
        
            
            
       /* 
       
       
     
        //US103708-Start-Getting copied attachment or notes from existing opportunity to Clone Opp//
       
       */
        //US103708-End-Getting copied attachment or notes from existing opportunity to Clone Opp//
        
        //redirecting to opportunity detail page
        /*PageReference pageRef = new PageReference('/' + oppRec.Id);
        pageRef.setRedirect(true);
        return pageRef;*/
        //The below code has been commented as per new lightning migration part added by Sougata//
        /*PageReference pageRef = new PageReference('/' + oppRec.Id + '/e?retURL=/' + oppRec.Id);
            System.debug('#50 pageRef: ' + pageRef.getURL());        
            System.debug('#51 OpptyId - '+oppRec.Id);
            List<OpportunityLineItem> oliList = [SELECT id, Name FROM OpportunityLineItem WHERE OpportunityId = :oppRec.Id];
            System.debug('#52 OpptyLineItems  - '+oliList);
            pageRef.setRedirect(true);
        */
        return oppRec.Id;
    } 
    
    //START - Added by Ashwin for defect fix on US95566 - Making the default Pricebook to Partner
    @future
    public static void updateOppPriceBook(Id newOppId) { 
        List<Core_Log_Entry__c> logEntries = new List<Core_Log_Entry__c>();
        Map<String, Core_LogEntry_Switch__c> logSwitch = Core_LogEntry_Switch__c.getall();
        Opportunity newOpp =[Select Id,PriceBook2Id from opportunity where id=:newOppId WITH SECURITY_ENFORCED];//TWC3123-5310 - Added WITH SECURITY_ENFORCED
        pricebook2 pb2 = [SELECT Id FROM pricebook2 WHERE IsStandard = false WITH SECURITY_ENFORCED LIMIT 1 ];//TWC3123-5310 - Added WITH SECURITY_ENFORCED
              
        newOpp.PriceBook2Id = pb2.Id;
        try{
            //TWC3123-5310 added if-isUpdateable
            if (Schema.sObjectType.Opportunity.isUpdateable()) {
                update newOpp;
            }
        }catch(Exception e){//TWC3123-5310 - commented system.debug and added log entry stamp to log error
            logEntries.add(new Core_Log_Entry__c(Core_Message__c ='Error',Core_Details__c = e.getMessage(), Core_Origin__c='Core_Opportunity_Clone_Controller.updateOppPriceBook', Core_Severity__c='High', Core_When__c=System.Now(), Core_Project__c = 'Sales Evolve'));
            if(!logEntries.isEmpty() && !logSwitch.isEmpty()){
                if(logSwitch.get('Core_LogEntry_Check') != null && logSwitch.get('Core_LogEntry_Check').Is_Selected__c){ 
                    insert logEntries;
           
                }}}
                    
    }
    //END - Added by Ashwin for defect fix on US95566 - Making the default Pricebook to Partner 
    
    /*
* Method name  : insertClonedOpportunity
* Description  : This method will be insert the Clone Opportunity on US103708 added by rajesh.
* Return Type  : Opportunity
* Parameter    : Oldopportunity,currentOpportunity.
*/         
    public static Opportunity insertCloneOpportunity(Opportunity oppRec,Opportunity currentOpportunity,String newOppName, Date newOppDD, String newOppMINDS){
        Id dealOpppRecTypeId =  Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Core_Deal_Opportunity').getRecordTypeId();
        Id designOpppRecTypeId =  Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Core_Design_Opportunity').getRecordTypeId();
            //Start*********************Below  Fields getting cloned conditionally*******************//
        Pricebook2 pb2; //Added by Ashwin for defect fix on US95566    
        oppRec.Id                                      = NULL;      
        oppRec.Name                                    = newOppName;                                                            
        oppRec.CreatedById                             = UserInfo.getUserId();
        oppRec.CreatedDate                             = DateTime.now();
        oppRec.LastModifiedById                        = UserInfo.getUserId();
        oppRec.LastModifiedDate                        = DateTime.now();
        oppRec.OwnerId                                 = UserInfo.getUserId();  
        oppRec.Core_Bypass_Field_Validation__c         = true;
        oppRec.Core_Flag_for_Deletion__c               = false;
        oppRec.Core_Approval_Status__c                 = NOT_SUBMITTED_TEXT;
        oppRec.Core_PW_Approval_Status__c              = NOT_SUBMITTED_TEXT;  //Added by Madhu for TWC3123-4113- Making PW approval status similer to DW.
        oppRec.Core_PW_Amount__c                       = NULL; //Added by Darshi for TWC3123-5031- Making PW Amount null.
        oppRec.Core_Opp_Strategic_Opportunity__c       = NULL; //Added by Madhu for  TWC3123-4260 - Strategic Opportunity Flag convtered from checkbox to Picklist So False marked as NULL.
        oppRec.Core_Military_Aerospace_Govmt_End_Use__c= newOppMINDS;
        oppRec.Pricebook2Id = currentOpportunity.Pricebook2Id; // added for TWC3123-2361
        oppRec.Core_Contact_Roles_Count__c = 0;// Added by Shiva
        OppRec.Core_IsClone__c = true; // added for TWC3123-2361
        oppRec.Opportunity_Focus__c = '';
        oppRec.CRM_Opportunity_Revenue__c = 0;
           for (Schema.FieldSetMember fsm : SObjectType.Opportunity.FieldSets.OPTY_VBS_FieldSet.getFields()) {
               String fieldPath = fsm.getFieldPath();
               if (String.valueOf(fsm.getType())=='BOOLEAN')
               {
                 OppRec.put(fieldPath, FALSE);
               }
               else
               {
                   OppRec.put(fieldPath, NULL);
               }
           }
      
        /* END US247790 - Decision Date needs to be added as a mandatory field on the cloning screen */
        if((oppRec.StageName != NULL) &&(oppRec.StageName.contains('Win') || oppRec.StageName.contains('Lost') || oppRec.StageName.contains('Cancelled'))){
           
            oppRec.Probability                     = QUALIFY_PROBABILITY;
            oppRec.Core_Loss_Cancel_Details__c     = NULL;
            oppRec.Core_Loss_Cancel_Reason__c      = NULL;            
        }
       
        //Areefa: For PCC, Cloning opportunit should not copy partner user as Technical owner.so making blank for 'Intel-Led' opportunity
        if(oppRec.Core_Technical_Owner__r.Profile.Name=='Partner'){
            oppRec.Core_Technical_Owner__c= NULL;
        }
       
        if(oppRec.Core_Sales_Segments__c != NULL && TECH_OWNER_SEGMENTS.contains(oppRec.Core_Sales_Segments__c)){        
            
            if(currentOpportunity.Core_Technical_Owner__c == NULL || 
               currentOpportunity.Core_Technical_Owner__r.isActive == FALSE)
                oppRec.Core_Technical_Owner__c         =oppRec.OwnerId;
        }
        //START - Added by Ashwin for defect fix on US95566 - Checking if the channel oppty id is populated then make them blank.
        pb2 = [SELECT Id FROM pricebook2 WHERE IsStandard = false WITH SECURITY_ENFORCED LIMIT 1];//TWC3123-5310 - Added WITH SECURITY_ENFORCED
        if(oppRec.Core_Channel_Opportunity_Ind__c){         
            oppRec.Core_Channel_Opportunity_Ind__c = false;
            oppRec.Core_Design_Registration_Id__c  = null;  
            if(pb2 != null && oppRec.PriceBook2Id == pb2.Id){
                isPartner = true;
            }
        }   
        //END - Added by Ashwin for defect fix on US95566 - Making the default Pricebook to Partner 
        
        /* START  Added by Laxmana for US247790 - Decision Date needs to be added as a mandatory field on the cloning screen */
        oppRec.CloseDate = newOppDD; 
        /* End - US247790 - Decision Date needs to be added as a mandatory field on the cloning screen */
        if(oppRec.Core_Opportunity_Type__c != null && oppRec.Core_Opportunity_Type__c.CONTAINS('Design')){
          
         
            oppRec.Core_Solution_Area__c                =NULL;
            if(oppRec.Core_Opportunity_Coverage_Nm__c==Core_CRM_Utility.getCRMLabel('Core_OpportunityPartnerProgram')){
                oppRec.Core_Opportunity_Coverage_Nm__c  = Core_CRM_Utility.getCRMLabel('Core_OpportunitySellerProgram');
                
                oppRec.Core_Coverage_Type_Nm__c = NULL;
            }
          
           
           //Added a check to verify if LOV is active before cloning 
            List<Schema.PicklistEntry> entries = Opportunity.Core_Intel_Platform__c.getDescribe().getPickListValues();
            
            for (Schema.PicklistEntry entry : entries) {
                if(entry.getValue() == currentOpportunity.Core_Intel_Platform__c && entry.isActive()){
                    oppRec.Core_Intel_Platform__c = currentOpportunity.Core_Intel_Platform__c ;
                    break;
                }else{
                    oppRec.Core_Intel_Platform__c = null;
                }
            }
            
        }
        else{
            //Added by Devashish as a part of TWC3123-3505, not copying fields in case of Non-Design opportunity
            oppRec.Core_Competitive_Architecture__c =NULL;
            oppRec.Core_Volume__c                   =NULL;
            oppRec.Core_Production_End_Date__c      =NULL;
            oppRec.Core_Manufacturing_Geo__c        =NULL;
            //End- TWC3123-3505 - Devashish
            oppRec.Core_First_Customer_Ship_Date__c =null;
            oppRec.Core_Solution_Area__c=currentOpportunity.Core_Solution_Area__c;
            oppRec.Core_Intel_Platform__c = null;   // Added by Laxmana for US247790,  regression defect fix.
        }
        String CloneRecordtype;
        Opportunity queryRec;
        if(!test.isRunningTest()){
            queryRec = [select id,RecordType.Name, Core_Opportunity_Coverage_Nm__c ,Core_Coverage_Type_Nm__c  from Opportunity where Id=:currentOpportunity.Id];
            CloneRecordtype=queryRec.RecordType.Name;
        }else{
            CloneRecordtype ='New Opportunity';
        }     
        if(CloneRecordtype !='Solution Group'){
            oppRec.Core_Commissionable__c =NO_TEXT;// As part of US TWC3123-6824 changed to NO 
            
        }
        
 
        //End *********************Below  Fields getting cloned conditionally*****************//
        
        
        //*************************Start Below fields are shouldn't be cloned***************************//
        
        //Making fields as false/null while cloning
        for (Schema.FieldSetMember fsm : SObjectType.Opportunity.FieldSets.CRM_Opportunity_Clone_Fieldset.getFields()) {
            String fieldPath = fsm.getFieldPath();
            if (String.valueOf(fsm.getType())=='BOOLEAN')
            {
              OppRec.put(fieldPath, FALSE);
            }
            else
            {
                OppRec.put(fieldPath, NULL);
            }
        }
        
        //TWC3123-6060 - Extend the EUSM fields Intel-Led Design Opportunities - added design record type check
        //TWC3123-6060 - added defaulting of 'Core' and blanking out 11 EUSM fields
        if(oppRec.Core_Opportunity_Coverage_Nm__c == 'Intel-Led Opportunity'  && (designOpppRecTypeId == oppRec.RecordTypeId || 
           (dealOpppRecTypeId == oppRec.RecordTypeId && (OppRec.Core_Opportunity_Type__c == 'Deal: Sell-to' || OppRec.Core_Opportunity_Type__c == 'Deal: Sell-through')))) {
               for (Schema.FieldSetMember fsm : SObjectType.Opportunity.FieldSets.EUSM_Fields.getFields()) {
                   String fieldPath = fsm.getFieldPath();
                   oppRec.put(fieldPath, NULL);
               }
               //TWC4767-3906 : we dont need this field anymore. 
               //oppRec.Opportunity_Focus__c = ''; //Core_CRM_Utility.getCRMLabel('OpportunityFocus_LOV_Core'); //TWC3123-6015 - Replacing Foundational with Core
               
           }

        
        
        //*************************End  Below fields are shouldn't be cloned***************************//
        Boolean isProductSegmentActive = false;
        for (Schema.PicklistEntry entryPS : Opportunity.Core_Product_Segment__c.getDescribe().getPicklistValues()) {
            if (entryPS.getLabel() == currentOpportunity.Core_Product_Segment__c) {
                isProductSegmentActive = entryPS.isActive();
                break;
            }
        }
        
        Boolean isProdApplicationActive = false;
        for (Schema.PicklistEntry entryPA : Opportunity.Core_Product_Application__c.getDescribe().getPicklistValues()) {
            if (entryPA.getLabel() == currentOpportunity.Core_Product_Application__c) {
                isProdApplicationActive = entryPA.isActive();
                break;
            }
        }
        
        Boolean isConsumptionMarketActive = false;
        for (Schema.PicklistEntry entryCM : Opportunity.Core_Consumption_Market__c.getDescribe().getPicklistValues()) {
            if (entryCM.getLabel() == currentOpportunity.Core_Consumption_Market__c) {
                isConsumptionMarketActive = entryCM.isActive();
                break;
            }
        }
        oppRec.Core_Product_Segment__c          = isProductSegmentActive ? currentOpportunity.Core_Product_Segment__c : NULL;
        oppRec.Core_Product_Application__c      = isProdApplicationActive && isProductSegmentActive ? currentOpportunity.Core_Product_Application__c : NULL;
        oppRec.Core_Consumption_Market__c       = isConsumptionMarketActive ? currentOpportunity.Core_Consumption_Market__c : NULL;
        oppRec.StageName = QUALIFY_TEXT; //Added by Devashish- TWC3123-3506 
        oppRec.ForecastCategoryName = QUALIFY_FORECAST_CATEGORY_TEXT;
        return oppRec;
    } 
    
    /*
* Method name  : insertClonedOppAttachment
* Description  : US103708-Insert the notes and attachments to clone Opportunity, if existing opportunity has attachment.
* Return Type  : void
* Parameter    : cloned Opportunity,List<Attachment> attList.
*/  
    Public static void insertCloneOppAttachment(Id newOppId,list <Attachment> attList){
        list<Attachment> lstAttachment=new list<Attachment>();  
        for(Attachment at: attList){
            Attachment cloneAtt= at.clone();
            cloneAtt.ParentId=newOppId;
            lstAttachment.add(cloneAtt);          
        }
        if(lstAttachment!= null && !(lstAttachment.isEmpty())){
            //TWC3123-5310 - Added isCreatable check
             if(Schema.sObjectType.Attachment.isCreateable()){
                 insert lstAttachment; 
             }
        }
    }     
    /*
* Method name  : insertClonedOppAttachment
* Description  : US103708-Insert the notes  to clone Opportunity, if existing opportunity has Note.
* Return Type  : void
* Parameter    : newOppId,List<Note> notelist.
*/      
    Public static void insertCloneNote(Id newOppId,List<Note> notelist){
        list<Note> lstNote=new list<Note>();    
        for(Note nt: notelist){
            Note cloneNote= nt.clone();
            cloneNote.ParentId=newOppId;
            lstNote.add(cloneNote);          
        }
        if(lstNote!= null && !(lstNote.isEmpty())){
            //TWC3123-5310 - Added isCreatable check
             if(Schema.sObjectType.Note.isCreateable()){
                 insert lstNote;   
             }  
        }
        
    } 
    /*
* Method name  : insertClonedOppAttachment
* Description  : US103708-This Method will be insert the attachment in ContentDocumentLink on lightning page.  
* Return Type  : void
* Parameter    : newOppId,List<ContentDocumentLink>contDocLink).
*/     
    Public static void insertCloneOppContentDocumentLink(Id newOppId,List<ContentDocumentLink>contDocLink){ 
        list<ContentDocumentLink> lstContentDoc=new list<ContentDocumentLink>();    
        for(ContentDocumentLink  doc: contDocLink){
            ContentDocumentLink  cloneDocLink= doc.clone();
            cloneDocLink.LinkedEntityId=newOppId;
            lstContentDoc.add(cloneDocLink);             
        }
        if(lstContentDoc != null && !(lstContentDoc.isEmpty())){
            //TWC3123-5310 - Added isCreatable check
             if(Schema.sObjectType.ContentDocumentLink.isCreateable()){
                 insert lstContentDoc;
             }
        }
    }     
    
    private static void cloneTeam(Id newOppId,List<Id>teamIds) { 
        Set <Id> setTeamMembers = new Set<Id>(teamIds);
        /*for (TeamMemberSelectionWrapper tmRec: lstSelectOppTeam) {        
            // Copy whatever has been selected and whatever is NOT readOnly.  The readOnly members will
            // be created automatically by opportunity trigger code.    
            if (tmRec.memberSelected && !tmRec.readOnly)
                setTeamMembers.add(tmRec.oppTeamMember.Id);
        }*/
        String strFields = getAllFields('OpportunityTeamMember');
        
        // This is being filtered by the lstSelectedOppTeam list
        //       
        String itemQuery = 'SELECT ' + strFields + ' ' + 
            'FROM OpportunityTeamMember ' + 
            'WHERE Id = :setTeamMembers';
        //TWC3123-5376: codescan fix : Avoid Untrusted/Unescaped Variables in DML Query(possible soql injection)-added String.escapeSingleQuotes
        List<OpportunityTeamMember> lstOppTeamMembers = Database.query(String.escapeSingleQuotes(itemQuery));
        
        for (OpportunityTeamMember itemRec : lstOppTeamMembers) {
            itemRec.Id            = NULL;
            itemRec.OpportunityId = newOppId;
            itemRec.Core_Description_of_Contribution__c= NULL;//TWC3123-4906 clear out desc of contribution while cloning
            
        }    
        //TWC3123-5310 - Added isCreatable check
             if(Schema.sObjectType.OpportunityTeamMember.isCreateable()){
                 insert lstOppTeamMembers;  
             }
    }
       
    private static void clonePartners(Id oldOppId, Id newOppId) { 
        
        String strFields = getAllFields('Core_Opportunity_Partner__c');
        
        String itemQuery = 'SELECT ' + strFields + ' ' + 
            'FROM Core_Opportunity_Partner__c ' +
            'WHERE Core_Opportunity__c = \'' + oldOppId + '\'' + 
            '  AND Core_Partner__r.Core_Deactivated__c = false ' + 
            '  AND Core_Partner_Role__c != \'' + VENDOR_TEXT + '\'';  
        //TWC3123-5376: codescan fix : Avoid Untrusted/Unescaped Variables in DML Query(possible soql injection)-added String.escapeSingleQuotes
        List<Core_Opportunity_Partner__c> lstInactiveOppPartner = Database.query(String.escapeSingleQuotes(itemQuery).replaceAll('\\\\', '')); //Database.query(itemQuery);
        system.debug('lstInactiveOppPartner'+lstInactiveOppPartner);
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
        //TWC3123-5310 - Added isCreatable check
             if(Schema.sObjectType.Core_Opportunity_Partner__c.isCreateable()){
                 insert lstInactiveOppPartner;
             }
    }
    
    @future   
    public static  void cloneProductsPartners(Id oldOppId, Id newOppId,String strFields) {  
        List<Core_Log_Entry__c> logEntries = new List<Core_Log_Entry__c>();
        Map<String, Core_LogEntry_Switch__c> logSwitch = Core_LogEntry_Switch__c.getall();
       Opportunity  Opptype = [select id,Core_Opportunity_Type__c  from Opportunity where Id=:oldOppId WITH SECURITY_ENFORCED];//TWC3123-5310 - Added WITH SECURITY_ENFORCED
        String itemQuery = 'SELECT ' + strFields + ' ' + 
            'FROM OpportunityLineItem ' + 
            'WHERE Opportunity.Id = \'' + oldOppId + '\'' + 
            '  AND Product2.IsActive = true ' + 
            '  AND Product2.isDeleted = false AND Product2.isDeleted = false AND Core_Status__c !=\'' + Label.Core_LineItem_Status + '\''; 
        //TWC3123-5376: codescan fix : Avoid Untrusted/Unescaped Variables in DML Query(possible soql injection)-added String.escapeSingleQuotes
        List<OpportunityLineItem> lstOppLineItem = Database.query(String.escapeSingleQuotes(itemQuery).replaceAll('\\\\', ''));
        
        List<OpportunityLineItem> lstNewOppLineItem = new List<OpportunityLineItem>();
        OpportunityLineItem newOppLineItem;
        
        for (OpportunityLineItem itemRec : lstOppLineItem) {
            newOppLineItem                            = itemRec.clone();
            newOppLineItem.Id                         = NULL;
            newOppLineItem.OpportunityId              = newOppId;    
            newOppLineItem.TotalPrice                 = NULL;  
            newOppLineItem.Core_Status__c             = PENDING_TEXT;  
            newOppLineItem.Core_Loss_Cancel_Reason__c = NULL;
            newOppLineItem.Core_Loss_Cancel_Details__c   = NULL;
            
            // BU Fields
            newOppLineItem.Core_Approved_BU_Product_Segment__c = NULL;
            newOppLineItem.Core_Approved_BU_Short_Name__c      = NULL;
            
            
            //START - Added by Laxmana for defect fix  DE28307- US176771 - When we clone an approved opportunity then following fields are not cleared from the Approvalinfo   
            newOppLineItem.Core_Opp_Approved_Sales_Group__c  =Null;
            newOppLineItem.CRM_DW_App_UCD_Customer_Name__c = Null;
            newOppLineItem.Core_Approved_Prime_Account_Name__c =Null;
            newOppLineItem.Core_Approved_Opp_Product_Segment__c =Null;
            newOppLineItem.Core_Approved_KPI_Product_Group__c = Null;
            newOppLineItem.Core_Opp_Approved_Oppty_Coverage__c = Null;
            // END - defect fix for DE28307- US176771 
            
            //START - Added by Ankita  on 30th Jan 2020 for US572823 - On Opportunity Products "Approved By" and all related Approve Fields are made to NULL while Opportunity Product cloning
            newOppLineItem.Core_Approved_By__c           = NULL;
            newOppLineItem.Core_Approved_Commissionable__c    = NULL;
            newOppLineItem.Core_Approved_Decision_Date__c    = NULL;
            newOppLineItem.Core_Approved_List_Price__c      = NULL;
            newOppLineItem.Core_Approved_Quantity__c      = NULL;
            newOppLineItem.Core_Approved_Sales_Price__c      = NULL;
            newOppLineItem.Core_Approved_Total_Price__c      = NULL;  
            newOppLineItem.Core_Approved_User_Id__c        = NULL;
            newOppLineItem.Core_Approved_Date__c         = NULL; 
            //END  - Added by Ankita  on 30th Jan 2020 for US572823 - On Opportunity Products "Approved By" and all related Approve Fields are made to NULL while Opportunity Product cloning
            
            //Added by Devashish as a part of TWC3123-3779, make all the newly created Production Win approval fields as null while cloning Opportunity Products
            newOppLineItem.Core_PW_Approved_By__c           = NULL;
            newOppLineItem.Core_PW_Approved_Quantity__c     = NULL;
            newOppLineItem.Core_PW_Approved_Sales_Price__c  = NULL;
            newOppLineItem.Core_PW_Approved_Total_Price__c  = NULL;
            newOppLineItem.Core_Production_Claim_Date__c    = NULL;
            newOppLineItem.Core_PW_Manager_Approved_Date__c = NULL;     
            //End - Added by Devashish as a part of TWC3123-3779, make all the newly created Production Win approval fields as null while cloning Opportunity Products
            
            //Added by Devashish as a part of TWC3123-4254, make all the newly created Production Win approval fields as null while cloning Opportunity Products
            newOppLineItem.Core_PW_Approved_BU_Short_Name__c        = NULL;
            newOppLineItem.Core_PW_Approved_Sales_Group__c          = NULL;
            newOppLineItem.Core_PW_Approved_BU_Product_Segment__c   = NULL;
            newOppLineItem.Core_PW_Approved_KPI_Product_Group__c    = NULL;
            newOppLineItem.CRM_PW_App_UCD_Customer_Name__c          = NULL;
            newOppLineItem.Core_PW_Approved_Prime_Account_Name__c   = NULL;
            newOppLineItem.Core_PW_Approved_Commissionable__c       = NULL;     
            //End - Added by Devashish as a part of TWC3123-4254, make all the newly created Production Win approval fields as null while cloning Opportunity Products
            
            //Added by Madhu as a part of TWC3123-4113, make all the newly created Production Win approval fields as null while cloning Opportunity Products
            if(Opptype.Core_Opportunity_Type__c.CONTAINS('Design')){
            newOppLineItem.Core_PW_Quantity__c          = newOppLineItem.Quantity;
            newOppLineItem.Core_PW_Sales_Price__c       = newOppLineItem.UnitPrice; 
            }else{
                newOppLineItem.Core_PW_Quantity__c          = NULL;
                 newOppLineItem.Core_PW_Sales_Price__c      = NULL;
            }
            //End - Added by Madhu as a part of TWC3123-4113, make all the newly created Production Win approval fields as null while cloning Opportunity Products
            
            newOppLineItem.Core_Approved_Opportunity_Product_App__c = NULL; //Added by Devashish - TWC3123-3897
            
            //START - Added by Ankita on 10th Feb 2020 for  US584490 - On Opportunity Products all related Risk Field needs to be cleared out on Opportunity Cloning.
            newOppLineItem.Core_At_Risk__c            = False;
            newOppLineItem.Core_Risk_Category__c        = NULL;
            newOppLineItem.Core_Risk_Priority__c        = NULL;
            newOppLineItem.Core_Risk_Reason1__c          = NULL;
            newOppLineItem.Core_Risk_Reason2__c          = NULL;
            newOppLineItem.Core_At_Risk_Status__c        = NULL;
            //END   - Added by Ankita on 10th Feb 2020 for  US584490 - On Opportunity Products all related Risk Field needs to be cleared out on Opportunity Cloning.
            //start -Biswa "TWC4767-1216" //On Clone , update Core_Design_Registration_Product_Id__c as NULL
            newOppLineItem.Core_Design_Registration_Product_Id__c = NULL;
            newOppLineItem.Failed_DDR_RecordID__c = NULL;
            //End -Biswa "TWC4767-1216"
            lstNewOppLineItem.add(newOppLineItem);
        }                     
          
        if (lstNewOppLineItem.size() > 0){
            try {
                //TWC3123-5310 - Added isCreatable check
             if(Schema.sObjectType.OpportunityLineItem.isCreateable()){
                Database.insert(lstNewOppLineItem, false);//TWC3123-5305-Added by Darshi
             }
            }
            catch (Exception err) {
                //TWC3123-5310 - commented system.debug and added log entry stamp to log error
            logEntries.add(new Core_Log_Entry__c(Core_Message__c ='Error',Core_Details__c = err.getMessage(), Core_Origin__c='Core_Opportunity_Clone_Controller.cloneProductsPartners', Core_Severity__c='High', Core_When__c=System.Now(), Core_Project__c = 'Sales Evolve'));
            if(!logEntries.isEmpty() && !logSwitch.isEmpty()){
                if(logSwitch.get('Core_LogEntry_Check') != null && logSwitch.get('Core_LogEntry_Check').Is_Selected__c){ 
                    insert logEntries;

                }}}    
        }
    }
    
    private static void cloneProducts(Id oldOppId, Id newOppId) { 
        List<Core_Log_Entry__c> logEntries = new List<Core_Log_Entry__c>();
        Map<String, Core_LogEntry_Switch__c> logSwitch = Core_LogEntry_Switch__c.getall();
        String strFields = getAllFields('OpportunityLineItem');
        Opportunity  Opptype = [select id,Core_Opportunity_Type__c  from Opportunity where Id=:oldOppId WITH SECURITY_ENFORCED];//TWC3123-5310 - Added WITH SECURITY_ENFORCED
        String itemQuery = 'SELECT ' + strFields + ' ' + 
            'FROM OpportunityLineItem ' + 
            'WHERE Opportunity.Id = \'' + oldOppId + '\'' + 
            '  AND Product2.IsActive = true ' + 
           '  AND Product2.isDeleted = false AND Core_Status__c !=\'' + Label.Core_LineItem_Status + '\''+'AND Core_Vendor_InActive__c!=true';  
        //TWC3123-5376: codescan fix : Avoid Untrusted/Unescaped Variables in DML Query(possible soql injection)-added String.escapeSingleQuotes
        List<OpportunityLineItem> lstOppLineItem = Database.query(String.escapeSingleQuotes(itemQuery).replaceAll('\\\\', ''));

        List<OpportunityLineItem> lstNewOppLineItem = new List<OpportunityLineItem>();
        OpportunityLineItem newOppLineItem;
        
        for (OpportunityLineItem itemRec : lstOppLineItem) {
            newOppLineItem                            = itemRec.clone();
            newOppLineItem.Id                         = NULL;
            newOppLineItem.OpportunityId              = newOppId;    
            newOppLineItem.TotalPrice                 = NULL;  
            newOppLineItem.Core_Status__c             = PENDING_TEXT;  
            newOppLineItem.Core_Loss_Cancel_Reason__c = NULL;
            newOppLineItem.Core_Loss_Cancel_Details__c   = NULL;
            //TWC4767-4238(bug) ---- Start
            newOppLineItem.Core_Lost_Sales_Price__c = NULL;
            newOppLineItem.Core_PW_Lost_Price__c = NULL;
            //TWC4767-4238(bug) ---- End
            // BU Fields
            newOppLineItem.Core_Approved_BU_Product_Segment__c = NULL;
            newOppLineItem.Core_Approved_BU_Short_Name__c      = NULL;
           
            //START - Added by Laxmana for defect fix  DE28307- US176771 - When we clone an approved opportunity then following fields are not cleared from the Approvalinfo   
            newOppLineItem.Core_Opp_Approved_Sales_Group__c  =Null;
            newOppLineItem.CRM_DW_App_UCD_Customer_Name__c     = Null;
            newOppLineItem.Core_Approved_Prime_Account_Name__c =Null;
            newOppLineItem.Core_Approved_Opp_Product_Segment__c =Null;
            newOppLineItem.Core_Approved_KPI_Product_Group__c = Null;
            newOppLineItem.Core_Opp_Approved_Oppty_Coverage__c = Null;
            // END - defect fix for DE28307- US176771    
             
            //START - Added by Ankita  on 30th Jan 2020 for US572823 - On Opportunity Products "Approved By" and all related Approve Fields are made to NULL while Opportunity Product cloning
           newOppLineItem.Core_Approved_By__c           = NULL;
            newOppLineItem.Core_Approved_Commissionable__c    = NULL;
            newOppLineItem.Core_Approved_Decision_Date__c    = NULL;
            newOppLineItem.Core_Approved_List_Price__c      = NULL;
            newOppLineItem.Core_Approved_Quantity__c      = NULL;
            newOppLineItem.Core_Approved_Sales_Price__c      = NULL;
            newOppLineItem.Core_Approved_Total_Price__c      = NULL;  
            newOppLineItem.Core_Approved_User_Id__c        = NULL;
            newOppLineItem.Core_Approved_Date__c         = NULL; 
          //END  - Added by Ankita  on 30th Jan 2020 for US572823 - On Opportunity Products "Approved By" and all related Approve Fields are made to NULL while Opportunity Product cloning 

            //Added by Devashish as a part of TWC3123-3779, make all the newly created Production Win approval fields as null while cloning Opportunity Products
            newOppLineItem.Core_PW_Approved_By__c           = NULL;
            newOppLineItem.Core_PW_Approved_Quantity__c     = NULL;
            newOppLineItem.Core_PW_Approved_Sales_Price__c  = NULL;
            newOppLineItem.Core_PW_Approved_Total_Price__c  = NULL;
            newOppLineItem.Core_Production_Claim_Date__c    = NULL;
            newOppLineItem.Core_PW_Manager_Approved_Date__c = NULL;     
            //End - Added by Devashish as a part of TWC3123-3779, make all the newly created Production Win approval fields as null while cloning Opportunity Products
            
            //Added by Devashish as a part of TWC3123-4254, make all the newly created Production Win approval fields as null while cloning Opportunity Products
            newOppLineItem.Core_PW_Approved_BU_Short_Name__c        = NULL;
            newOppLineItem.Core_PW_Approved_Sales_Group__c          = NULL;
            newOppLineItem.Core_PW_Approved_BU_Product_Segment__c   = NULL;
            newOppLineItem.Core_PW_Approved_KPI_Product_Group__c    = NULL;
            newOppLineItem.CRM_PW_App_UCD_Customer_Name__c      = NULL;
            newOppLineItem.Core_PW_Approved_Prime_Account_Name__c= NULL;
            newOppLineItem.Core_PW_Approved_Commissionable__c       = NULL;     
            //End - Added by Devashish as a part of TWC3123-4254, make all the newly created Production Win approval fields as null while cloning Opportunity Products
            
            //Added by Madhu as a part of TWC3123-4113, make all the newly created Production Win approval fields as null while cloning Opportunity Products
           
            if(Opptype.Core_Opportunity_Type__c.CONTAINS('Design')){     
                 newOppLineItem.Core_PW_Quantity__c         = newOppLineItem.Quantity;
                 newOppLineItem.Core_PW_Sales_Price__c       = newOppLineItem.UnitPrice;
            }else{
                newOppLineItem.Core_PW_Quantity__c          = NULL;
                 newOppLineItem.Core_PW_Sales_Price__c      = NULL;
            }
            //End - Added by Madhu as a part of TWC3123-4113, make all the newly created Production Win approval fields as null while cloning Opportunity Products
            
            newOppLineItem.Core_Approved_Opportunity_Product_App__c = NULL; //Added by Devashish - TWC3123-3897
                        
            //START - Added by Ankita on 10th Feb 2020 for  US584490 - On Opportunity Products all related Risk Field needs to be cleared out on Opportunity Cloning.
            newOppLineItem.Core_At_Risk__c            = False;
            newOppLineItem.Core_Risk_Category__c        = NULL;
            newOppLineItem.Core_Risk_Priority__c        = NULL;
            newOppLineItem.Core_Risk_Reason1__c          = NULL;
            newOppLineItem.Core_Risk_Reason2__c          = NULL;
            newOppLineItem.Core_At_Risk_Status__c        = NULL;
            newOppLineItem.Core_Product_Risk_Owner__c      = NULL;
            newOppLineItem.Core_Risk_Create_Date__c        = NULL;
            newOppLineItem.Core_Risk_End_Date__c        = NULL;
            newOppLineItem.Core_Risk_Detail__c          = NULL;
            
            //start -Jerin "US-0032829" //Replacing a WF "Core_OppProd_Clear_Approval_Fields" Field update with this code 
           
            newOppLineItem.Core_Approved_Opportunity_Owner__c = NULL;
    
            newOppLineItem.Core_Approved_Technical_Owner__c = NULL;
            
            //end -Jerin "US-0032829"
            
            //END   - Added by Ankita on 10th Feb 2020 for  US584490 - On Opportunity Products all related Risk Field needs to be cleared out on Opportunity Cloning.
            //start -Biswa "TWC4767-1216" //On Clone , update Core_Design_Registration_Product_Id__c as NULL
            newOppLineItem.Core_Design_Registration_Product_Id__c = NULL;
            newOppLineItem.Failed_DDR_RecordID__c = NULL;
            //End -Biswa "TWC4767-1216" 
            lstNewOppLineItem.add(newOppLineItem);
        }                     
          
        if (lstNewOppLineItem.size() > 0){
            try {
              //TWC3123-5310 - Added isCreatable check
             if(Schema.sObjectType.OpportunityLineItem.isCreateable()){
             Database.insert(lstNewOppLineItem, false);//TWC3123-5305-Added by 
                 
             }
            }
            catch (Exception err) {
                //TWC3123-5310 - commented system.debug and added log entry stamp to log error
            logEntries.add(new Core_Log_Entry__c(Core_Message__c ='Error',Core_Details__c = err.getMessage(), Core_Origin__c='Core_Opportunity_Clone_Controller.cloneProducts', Core_Severity__c='High', Core_When__c=System.Now(), Core_Project__c = 'Sales Evolve'));
            if(!logEntries.isEmpty() && !logSwitch.isEmpty()){
                if(logSwitch.get('Core_LogEntry_Check') != null && logSwitch.get('Core_LogEntry_Check').Is_Selected__c){ 
                    insert logEntries;
              }}}
        }
    }
    
    private static void cloneSolutions(Id oldOppId, Id newOppId) { 
        List<Core_Log_Entry__c> logEntries = new List<Core_Log_Entry__c>();
        Map<String, Core_LogEntry_Switch__c> logSwitch = Core_LogEntry_Switch__c.getall();
        String strFields = getAllFields('Opportunity_Solution_Area__c');
        system.debug('entered cloneSolutions method');
        String itemQuery = 'SELECT ' + strFields + ' ' + 
            'FROM Opportunity_Solution_Area__c ' + 
            'WHERE Core_Opportunity__c = \'' + oldOppId + '\'';   
        //TWC3123-5376: codescan fix : Avoid Untrusted/Unescaped Variables in DML Query(possible soql injection)-added String.escapeSingleQuotes
        List<Opportunity_Solution_Area__c> lstOppSolution = Database.query(String.escapeSingleQuotes(itemQuery).replaceAll('\\\\', ''));
        
        List<Opportunity_Solution_Area__c> lstNewSolution = new List<Opportunity_Solution_Area__c>();
        Opportunity_Solution_Area__c newOppSolution;
        
        for (Opportunity_Solution_Area__c itemRec : lstOppSolution) {
   
            itemRec.Id                        = NULL;
            itemRec.Core_Opportunity__c       = newOppId;    
            itemRec.CreatedById               = UserInfo.getUserId();
            itemRec.CreatedDate               = DateTime.now();
            itemRec.LastModifiedById          = UserInfo.getUserId();
            itemRec.LastModifiedDate          = DateTime.now();  
            
            lstNewSolution.add(itemRec);
        }                     
        System.debug(lstNewSolution.size()); 
        if (lstNewSolution.size() > 0){
            try {system.debug('999');
                 //TWC3123-5310 - Added isCreatable check
                if(Schema.sObjectType.Opportunity_Solution_Area__c.isCreateable()){
                    System.debug('1002');
                Database.insert(lstNewSolution, true);
                    System.debug('1004');
                }
            }
            catch (Exception err) {
                //TWC3123-5310 - commented system.debug and added log entry stamp to log error
            logEntries.add(new Core_Log_Entry__c(Core_Message__c ='Error',Core_Details__c = err.getMessage(), Core_Origin__c='CRM_Opportunity_Clone_Controller.cloneSolutions', Core_Severity__c='High', Core_When__c=System.Now(), Core_Project__c = 'Sales Evolve'));
            if(!logEntries.isEmpty() && !logSwitch.isEmpty()){
                if(logSwitch.get('Core_LogEntry_Check') != null && logSwitch.get('Core_LogEntry_Check').Is_Selected__c){ 
                    insert logEntries;
                }}}
        }
    }
    
    private static void cloneFeatures(Id OldOpp, Id newOppId) {
        
        // Re-using lstInactiveOppFeatures
        lstInactiveOppFeatures = [SELECT Core_Feature_Type__c, Core_Feature_Name__c, Core_Feature_Set__c
                                  FROM Core_Opportunity_Features__c
                                  WHERE Core_Opportunity__c = :OldOpp
                                  AND Core_Feature_Set__r.Core_Active__c = true
                                  AND IsDeleted = false WITH SECURITY_ENFORCED
                                  LIMIT 2000];  //TWC3123-5310 - Added WITH SECURITY_ENFORCED
        
        Core_Opportunity_Features__c oppFeature;                                              
        List<Core_Opportunity_Features__c> lstOppFeatures = new List<Core_Opportunity_Features__c>();
        for (Core_Opportunity_Features__c featureRec : lstInactiveOppFeatures) {
            oppFeature = new Core_Opportunity_Features__c();
            oppFeature.Core_Opportunity__c = newOppId;
            oppFeature.Core_Feature_Set__c = featureRec.Core_Feature_Set__c; 
            lstOppFeatures.add(oppFeature);
        }
        //TWC3123-5310 - Added isCreatable check
        if(Schema.sObjectType.Core_Opportunity_Features__c.isCreateable()){
        insert lstOppFeatures;
        }
    }
    
    //==========do not push to higher orgs===================================================
    
    //==========do not push to higher orgs===================================================
    
    
    @AuraEnabled(cacheable = true)
    public static String getAllFields(String sobjectname){
        System.debug('@Areefa getAllFields');
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
        System.debug('@Areefa allfields:::'+allfields);
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
    @AuraEnabled
    public static void testWrapper(String payload){
        GetSelectionsEntities wrapper = (GetSelectionsEntities) JSON.deserialize(payload,GetSelectionsEntities.class);
        system.debug('show solutions'+wrapper.showentities.showOpportunitySolution);
        system.debug('select solutions'+wrapper.showselections.selectedOppSolutions);
        System.debug('showSelections '+ (wrapper.showentities.showOpportunitySolution && wrapper.showselections.selectedOppSolutions));
        
    }

        public class showEntities {
            @AuraEnabled public Boolean showOppFeatures;
            @AuraEnabled public Boolean showOppPartner;
            @AuraEnabled public Boolean showOpportunityProductOption;
            @AuraEnabled public Boolean showOpportunitySolution;
            @AuraEnabled public Boolean isAttachment;
            @AuraEnabled public Boolean showAttachment;
            @AuraEnabled public Boolean showNote;
            @AuraEnabled public Boolean showContentlink;
            
        }
        
        public class showSelections{
            @AuraEnabled public Boolean selectedOppAttachments;
            @AuraEnabled public Boolean selectedOppSolutions;
            @AuraEnabled public Boolean selectedOppProducts;
            @AuraEnabled public Boolean selectedOppPartners;
            @AuraEnabled public Boolean selectedDescFeat;
            @AuraEnabled public Boolean selectedOppTeamMembers;
        }
    public class GetSelectionsEntities{
        @AuraEnabled public showEntities showentities;
        @AuraEnabled public showSelections showselections;
        
        public GetSelectionsEntities(){
            this.showentities = new showEntities();
            this.showselections = new showSelections();
        }
    }
    
    
    
        
}