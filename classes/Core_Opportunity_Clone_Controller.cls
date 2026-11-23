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
* Ragamalika Mohanraj        20/9/2017               US95566-OPPTY: Update Oppty Cloning to Ignore New DR Fields
* Ashwin Dash                10/Apr/2018             US102793 : Updating Error message while cloning the Opportunity which is related to an Account that doesn't have a Sales Group
* Ashwin Dash                30/Mar/2018             US104064 : OPPTY: Add Strategic Opportunity Checkbox to layout and Stop it from being cloned.
* Rajesh                     19/July/2018            US103708- Opportunity Cloning enhancement,Notes&Attachments can be copied to the Clone Opp. 
* Laxmana Lenka              03/Feb/2019             US176771,US247790 ,  Decision Date needs to be added as a mandatory field on the cloning screen.
*************************************************************************************/
public class Core_Opportunity_Clone_Controller {   
    public static final String  NOT_SUBMITTED_TEXT        = 'Not Submitted';
    public static final String  OWNER_TEXT                = 'Owner';
    public static final String  PENDING_TEXT              = 'Pending';
    public static final Integer QUALIFY_PROBABILITY       = 15;
    public static final String  QUALIFY_TEXT              = 'Qualify';
    public static final String  VENDOR_TEXT               = 'Vendor';
    public static final String  TECH_OWNER_SEGMENTS       = 'Embedded,Compute';
    public static final String  YES_TEXT                  = 'Yes';
    public static final String  NO_TEXT                   ='No';
    public static final String  DEF_COMPLIANCE_STATUS     ='On Hold – Review in Progress';  //US103708-If Clone Opp has MAG Flag is true,then default value for Compliance status.      
    public static final String  DEF_COMPLIANCE_SUB_STATUS ='AR - Owner to fill out MAG Questionnaire';   //US103708-If Clone Opp has MAG Flag is true,then default value for Compliance Sub Status.  
    public String  searchMessage { get; set; }                     // Actual error message
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
    
    //US103708-  Start -Decalred below fields are notes and attachment added by rajesh //
    Public Boolean showNote                 {get;set;}
    public Boolean showNoteSelected         {get;set;}
    Public Boolean showAttachment           {get;set;}
    Public Boolean ShowAttachmentSelected   {get;set;}
    Public Boolean showContentlink          {get;set;}
    Public Boolean showContetlinkSelected   {get;set;}
    Public List<Note> noteList              {get;set;} 
    Public List<Attachment> attList          {get;set;}
    Public List<ContentDocumentLink> contDocLink{get;set;}
   //US103708-  End -Decalred below fields are notes and attachment added by rajesh //

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
    public static boolean isPartner = false;                        //Added by Ashwin for defect fix on US95566

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
        showNoteSelected            = true; 
        ShowAttachmentSelected      = true;
        showContetlinkSelected      = true;      
        currentOpportunity = (Opportunity)controller.getRecord();
        currentOpportunity = [SELECT Id, Name, Owner.IsActive, Core_Technical_Owner__r.isActive, Account.Name, Account.RecordType.Name,core_Sales_Segments__c, 
                              Account.Core_Military_Aerospace_and_Government__c, Core_Military_Aerospace_Govmt_End_Use__c,Core_Intel_Platform__c,Core_First_Customer_Ship_Date__c,CloseDate, Core_Volume__c,Core_Production_End_Date__c,Core_Manufacturing_Geo__c,Core_Solution_Area__c                              
                              FROM Opportunity  WHERE Id = :currentOpportunity.Id];
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
        
        
        //US103708-To check the size of Notes and attachment in Classic also lightning for ContentDocumentLink object added by rajesh
           attList=new List<Attachment>([SELECT Id, Body, Name, ParentId, ContentType, Parent.Type,BodyLength,Description from Attachment where parentId=:currentOpportunity.Id]);           
           notelist=new List<Note>([SELECT Id, Body,ParentId,Title  FROM Note where ParentId =:currentOpportunity.Id]);   
           contDocLink=new List<ContentDocumentLink>([SELECT ContentDocumentId,LinkedEntityId,ShareType,Visibility FROM ContentDocumentLink WHERE LinkedEntityId=:currentOpportunity.Id]);
           showAttachment=attList.size()>0;  
           showNote=notelist.size()>0;
           showContentlink=contDocLink.size()>0; 
        //US103708-Initialized below feilds are blanking out for required fields on page,So that use can able to fill out fields added by rajesh.
           currentOpportunity.Core_First_Customer_Ship_Date__c=null;
           currentOpportunity.Core_Solution_Area__c=null;
           /* START  Added by Laxmana for US247790 - Decision Date needs to be added as a mandatory field on the cloning screen */
           currentOpportunity.CloseDate=null; 
           /* END US247790 - Decision Date needs to be added as a mandatory field on the cloning screen */
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
        //US102793 : Added a Custom Label to store the error messages -- Ashwin
        List<String> errMsgList = System.label.Core_Opp_CloneCont_Msgs.split(';');
        String strFields = getAllFields('Opportunity');
        System.debug('#47 strFields: ' + strFields);        
        String oppQuery = 'SELECT ' + strFields + ' FROM Opportunity WHERE Id = \'' + currentOpportunity.Id + '\'';
        System.debug('#48 oppQuery: ' + oppQuery);        
        Opportunity oppRec = Database.query(oppQuery);
       
        //US103708-Added logic for insert the Clone Opportunity added by-Rajesh.   
        oppRec=insertCloneOpportunity(oppRec,currentOpportunity);
           
        //START - Added by Ashwin for defect fix on US95566 - Checking if the products have invalid pricebook
        map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
        if(mapFunctionalityNameTriggerExecution.containsKey('opptyCloneErrorMsg') && mapFunctionalityNameTriggerExecution.get('opptyCloneErrorMsg').Core_Active__c){
            List<OpportunityLineItem> oliList1 = new List<OpportunityLineItem>();
            oliList1 = [SELECT id, Product2Id FROM OpportunityLineItem WHERE OpportunityId = :currentOpportunity.Id];
            Set<Id> pId2Set = new Set<Id>();
            for(OpportunityLineItem oli : oliList1){
                pId2Set.add(oli.Product2Id);
            }
            List<PricebookEntry> pbeList = new List<PricebookEntry>();
            pbeList = [SELECT id, Product2Id, isActive FROM Pricebookentry WHERE Product2Id IN :pId2Set AND isActive = true];
            if(pbeList.isEmpty() && opportunityProductSelected && showOpportunityProductOption){
                //US102793 : Modified the error message -- Ashwin
                Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, errMsgList[0]));
                return null;
            }
        }
        //END - Added by Ashwin for defect fix on US95566 - Checking if the products have invalid pricebook
        
        try{  
             insert oppRec; 
            //run this method only when isPartner is true-added by Raga
            if(isPartner){
                updateOppPriceBook(oppRec.Id);   
            }               
        }catch(Exception e){
            //US102793 : Modified the error message -- Ashwin
            Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, errMsgList[1]));
            Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
            return null;
        }
       
        // CloneTeam has special logic to reflect user selections.
        // The Opportunity Owner and Technical Owner are created automatically by the Opportunity trigger handler.
        if (opportunityTeamSelected)
            cloneTeam(oppRec.Id);

        if (opportunityFeaturesSelected && showOppFeatures)
            cloneFeatures(currentOpportunity.Id, oppRec.Id);
        
        if (opportunityPartnersSelected && showOppPartner)
            clonePartners(currentOpportunity.Id, oppRec.Id);

        if (opportunityProductSelected && showOpportunityProductOption){
        //Call for Partner Oppty(Disti)-Added by Raga
            if(isPartner){
                String strFields1 = getAllFields('OpportunityLineItem');
                cloneProductsPartners(currentOpportunity.Id, oppRec.Id,strFields1);
            }
            else{
                cloneProducts(currentOpportunity.Id,oppRec.Id);
            }
        }
        //US103708-Start-Getting copied attachment or notes from existing opportunity to Clone Opp//
         if(ShowAttachmentSelected && showAttachment)
          insertCloneOppAttachment(oppRec.Id,attList);
      
          if(showNoteSelected && showNote) 
          insertCloneNote(oppRec.Id,notelist);
      
          if(showContetlinkSelected && showContentlink)
          insertCloneOppContentDocumentLink(oppRec.Id,contDocLink);
         //US103708-End-Getting copied attachment or notes from existing opportunity to Clone Opp//
         
         //redirecting to opportunity detail page
          PageReference pageRef = new PageReference('/' + oppRec.Id);
          pageRef.setRedirect(true);
          return pageRef;
         //The below code has been commented as per new lightning migration part added by Sougata//
         /*PageReference pageRef = new PageReference('/' + oppRec.Id + '/e?retURL=/' + oppRec.Id);
         System.debug('#50 pageRef: ' + pageRef.getURL());        
         System.debug('#51 OpptyId - '+oppRec.Id);
         List<OpportunityLineItem> oliList = [SELECT id, Name FROM OpportunityLineItem WHERE OpportunityId = :oppRec.Id];
         System.debug('#52 OpptyLineItems  - '+oliList);
         pageRef.setRedirect(true);
         */
    } 

    //START - Added by Ashwin for defect fix on US95566 - Making the default Pricebook to Partner
    @future
    public static void updateOppPriceBook(Id newOppId) { 
        Opportunity newOpp =[Select Id,PriceBook2Id from opportunity where id=:newOppId];
        pricebook2 pb2 = [SELECT Id FROM pricebook2 WHERE IsStandard = false LIMIT 1];
        //if(isPartner){          
            newOpp.PriceBook2Id = pb2.Id;
            try{
                update newOpp;
            }catch(Exception e){
                System.debug('***Exception Oppty - '+e.getMessage());
            }
        //}            
    }
  //END - Added by Ashwin for defect fix on US95566 - Making the default Pricebook to Partner 
  
      /*
    * Method name  : insertClonedOpportunity
    * Description  : This method will be insert the Clone Opportunity on US103708 added by rajesh.
    * Return Type  : Opportunity
    * Parameter    : Oldopportunity,currentOpportunity.
    */         
 public static Opportunity insertCloneOpportunity(Opportunity oppRec,Opportunity currentOpportunity){
 
      //Start*********************Below  Fields getting cloned conditionally*******************//
        Pricebook2 pb2; //Added by Ashwin for defect fix on US95566    
        oppRec.Id                                      = NULL;      
        oppRec.Name                                    = 'Clone of ' + oppRec.Name;                                                            
        oppRec.CreatedById                             = UserInfo.getUserId();
        oppRec.CreatedDate                             = DateTime.now();
        oppRec.LastModifiedById                        = UserInfo.getUserId();
        oppRec.LastModifiedDate                        = DateTime.now();
        oppRec.OwnerId                                 = UserInfo.getUserId();  
        oppRec.Core_Bypass_Field_Validation__c         = true;
        oppRec.Core_Flag_for_Deletion__c               = false;
        oppRec.Core_Approval_Status__c                 = NOT_SUBMITTED_TEXT;
        oppRec.Core_Opp_Strategic_Opportunity__c       = false;
       
        /* START  commneted below lines of code by Laxmana for US247790 - Decision Date needs to be added as a mandatory field on the cloning screen */
          //Adding check for Close date to make it to today's date before cloning -- Ashwin
           // if(oppRec.CloseDate < system.today()){ // Laxmana added
         //    oppRec.CloseDate = system.today();
         //}
        /* END US247790 - Decision Date needs to be added as a mandatory field on the cloning screen */
            if((oppRec.StageName != NULL) &&(oppRec.StageName.contains('Win') || oppRec.StageName.contains('Lost') || oppRec.StageName.contains('Cancelled'))){
                oppRec.StageName                       = QUALIFY_TEXT;
                oppRec.Probability                     = QUALIFY_PROBABILITY;
                oppRec.Core_Loss_Cancel_Details__c     = NULL;
                oppRec.Core_Loss_Cancel_Reason__c      = NULL;            
            }
                            
        if(oppRec.Core_Sales_Segments__c != NULL && TECH_OWNER_SEGMENTS.contains(oppRec.Core_Sales_Segments__c)){        
           if(currentOpportunity.Core_Technical_Owner__c == NULL || currentOpportunity.Core_Technical_Owner__r.isActive == FALSE)
                oppRec.Core_Technical_Owner__c         =oppRec.OwnerId;
        }
        //START - Added by Ashwin for defect fix on US95566 - Checking if the channel oppty id is populated then make them blank.
         pb2 = [SELECT Id FROM pricebook2 WHERE IsStandard = false LIMIT 1];
         if(oppRec.Core_Channel_Opportunity_Ind__c){         
            oppRec.Core_Channel_Opportunity_Ind__c = false;
            oppRec.Core_Design_Registration_Id__c  = null;  
            if(pb2 != null && oppRec.PriceBook2Id == pb2.Id){
                isPartner = true;
            }
        }   
        //END - Added by Ashwin for defect fix on US95566 - Making the default Pricebook to Partner 
        //DE30968-Added the code whenever opp is cloning,if opp MAG is false and Military End user is no ,then  update the compliance status is blank-Rajesh.
        if(!(currentOpportunity.Account.Core_Military_Aerospace_and_Government__c)) {
            oppRec.Core_Compliance_Comments__c         = NULL;    
            oppRec.Core_Private_Compliance_Comments__c = NULL;
            oppRec.Core_Compliance_Status__c           = NULL;
            oppRec.Core_Compliance_Sub_Status__c       = NULL;
            oppRec.Core_Military_Aerospace_Govmt_End_Use__c=Null;    
        }
        else{
            oppRec.Core_Compliance_Status__c=DEF_COMPLIANCE_STATUS;           
            oppRec.Core_Compliance_Sub_Status__c=DEF_COMPLIANCE_SUB_STATUS;       
            oppRec.Core_Compliance_Comments__c=NULL;         
            oppRec.Core_Private_Compliance_Comments__c=NUll;
            oppRec.Core_Military_Aerospace_Govmt_End_Use__c=Null;    
        }
         /* START  Added by Laxmana for US247790 - Decision Date needs to be added as a mandatory field on the cloning screen */
            oppRec.CloseDate = currentOpportunity.CloseDate; 
         /* End - US247790 - Decision Date needs to be added as a mandatory field on the cloning screen */
         if(oppRec.Core_Opportunity_Type__c != null && oppRec.Core_Opportunity_Type__c.CONTAINS('Design')){
             oppRec.Core_First_Customer_Ship_Date__c=currentOpportunity.Core_First_Customer_Ship_Date__c;
             oppRec.Core_Solution_Area__c                =NULL;
             oppRec.Core_Intel_Platform__c = currentOpportunity.Core_Intel_Platform__c ;// Added by Laxmana for US247790,  regression defect fix.

          }
          else{
              oppRec.Core_First_Customer_Ship_Date__c=null;
              oppRec.Core_Solution_Area__c=currentOpportunity.Core_Solution_Area__c;
              oppRec.Core_Intel_Platform__c = null;   // Added by Laxmana for US247790,  regression defect fix.
          }
           String CloneRecordtype;
           if(!test.isRunningTest()){
          CloneRecordtype=[select id,RecordType.Name from Opportunity where Id=:currentOpportunity.Id].RecordType.Name;
          }else{
          CloneRecordtype ='New Opportunity';
          }     
         if(CloneRecordtype !='Solution Group'){
            oppRec.Core_Commissionable__c                  =YES_TEXT;
            
          }
                 
         //End *********************Below  Fields getting cloned conditionally*****************//
        
        
        //*************************Start Below fields are shouldn't be cloned***************************//
          
          oppRec.Core_Competitive_Architecture__c                =NULL;
          oppRec.Core_Status_Update__c                           =NULL;
          oppRec.Core_Volume__c                                  =NULL;
          oppRec.Core_Production_End_Date__c                     =NULL;
          oppRec.Core_Manufacturing_Geo__c                       =NULL;
          oppRec.Core_Solution_Type__c                           =NULL;
          oppRec.Core_Solution_Detail__c                         =NULL;
          oppRec.Core_Risk_Reason__c                             =NULL;
          oppRec.Core_Support_Requested__c                       =NULL;
          oppRec.Core_At_Risk_Created_Date__c                    =NULL;
          oppRec.Core_Support_Completed__c                       =FALSE; 
          oppRec.Core_Approved_Opportunity_Region__c             =NULL;
          oppRec.Core_Standard_Customer_Refresh__c               =FALSE; 
          OPPRec.Core_MAG_Questionnaire_ID__c                    =NULL;
          
         //START  Added by Laxmana for US247790 - below fields should not clone. Found part of regression testing//
          OPPRec.Core_Lead_Conversion_Point__c=null;
          OPPRec.Core_Competitor_Architecture__c = null;
          OPPRec.CampaignId=null;
          OPPRec.Core_Opportunity_Facts_ID__c=null;
          OPPRec.Core_Business_Unit_Territory__c=null;
          OPPRec.Core_Business_Unit_Territory_Name__c=null; 
          OPPRec.Core_Marketing_Tactic_ID__c =null;
          //END US247790 fields should not clone. Found part of regression testing//
          
        //Start-- The below fields are added newly as compared with existing code--//
          oppRec.Core_Reason_for_Deletion__c     = NULL;
          oppRec.Core_External_ID__c             = NULL;

       //Added for stopping Solution Area and SOlution Play from Cloning - US99302 -- by Ashwin        
          oppRec.Core_Solution_Focus__c         = null;        
          oppRec.Core_Solution_Focus_Area__c     = null;       
          oppRec.Core_Solution_Play__c           = null;       
       //START - Added by Ashwin for defect fix on US95566 - Checking if the channel oppty id is populated then make them blank       
          oppRec.LeadSource                      = NULL;     
          oppRec.Core_Project_Timeframe__c       = NULL;                 
          oppRec.Core_Product_Interest__c        = NULL;     
          oppRec.Core_Project_Size__c            = NULL;     
          oppRec.Core_project_Phase__c           = NULL;     
          oppRec.Core_Current_Architecture__c    = NULL;   

     //START - US64659 - The "Date Submitted for Approval", "Push Counter" and "Approved Date" field are made to NULL or '0' before cloning - 19-May-2017 - Ashwin      
         oppRec.Core_Date_Submitted_for_Approval__c = null;     
         oppRec.Core_Approved_Date__c = null;       
         oppRec.Core_Push_Counter__c = null;        
     //END - US64659 - The "Date Submitted for Approval", "Push Counter" and "Approved Date" field are made to NULL or '0' before cloning - 19-May-2017 - Ashwin     
    //End-- The below fields are added newly as compared with existing code--//

        //*************************End  Below fields are shouldn't be cloned***************************//
        
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
             insert lstAttachment; 
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
             insert lstNote;     
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
             insert lstContentDoc;
           }
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
    
    @future   
    public static  void cloneProductsPartners(Id oldOppId, Id newOppId,String strFields) {    
        
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
                
            //START - Added by Laxmana for defect fix  DE28307- US176771 - When we clone an approved opportunity then following fields are not cleared from the Approvalinfo   
            newOppLineItem.Core_Opp_Approved_Sales_Group__c  =Null;
            newOppLineItem.Core_Approved_Prime_Account_Name__c =Null;
            newOppLineItem.Core_Approved_Opp_Product_Segment__c =Null;
            newOppLineItem.Core_Approved_KPI_Product_Group__c = Null;
            newOppLineItem.Core_Opp_Approved_Oppty_Coverage__c = Null;
           // END - defect fix for DE28307- US176771 
            
            lstNewOppLineItem.add(newOppLineItem);
        }                     

        System.debug('#24 lstNewOppLineItem: ' + lstNewOppLineItem);   
        if (lstNewOppLineItem.size() > 0){
            try {
                Database.insert(lstNewOppLineItem, true);
            }
            catch (Exception err) {
                System.debug('#100 Exception: ' + err.getMessage()); 
            }    
        }
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
        //START - Added by Laxmana for defect fix  DE28307- US176771 - When we clone an approved opportunity then following fields are not cleared from the Approvalinfo   
            newOppLineItem.Core_Opp_Approved_Sales_Group__c  =Null;
            newOppLineItem.Core_Approved_Prime_Account_Name__c =Null;
            newOppLineItem.Core_Approved_Opp_Product_Segment__c =Null;
            newOppLineItem.Core_Approved_KPI_Product_Group__c = Null;
            newOppLineItem.Core_Opp_Approved_Oppty_Coverage__c = Null;
         // END - defect fix for DE28307- US176771           
            
            lstNewOppLineItem.add(newOppLineItem);
        }                     

        System.debug('#24 lstNewOppLineItem: ' + lstNewOppLineItem);   
        if (lstNewOppLineItem.size() > 0){
            try {
                Database.insert(lstNewOppLineItem, true);
            }
            catch (Exception err) {
                System.debug('#41 Core_Opportunity_Clone_Controller->cloneProducts: ' + err.getMessage());
                System.debug('#42 Core_Opportunity_Clone_Controller->cloneProducts->exception: ' + err);
                System.debug('#43 Core_Opportunity_Clone_Controller->cloneProducts->lstNewOppLineItem: ' + lstNewOppLineItem);
            }    
            
            System.debug('#25 lstNewOppLineItem: ' + lstNewOppLineItem);   
        }
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