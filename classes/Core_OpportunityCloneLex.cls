public class Core_OpportunityCloneLex {
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
   
    public static boolean isPartner = false;
    public static List<Core_Opportunity_Features__c> oppFeatures = new List<Core_Opportunity_Features__c>();
    public static List<Core_Opportunity_Partner__c> oppPtnrs = new List<Core_Opportunity_Partner__c>();
    public static List<OpportunityLineItem> oppPrdcts = new List<OpportunityLineItem>();
    public static List<Attachment> attList = new List<Attachment>();
    public static List<Note> notelist = new List<Note>();
    public static List<ContentDocumentLink> contDocLink = new List<ContentDocumentLink>();
    public static List<OpportunityLineItem> inactiveOppProduct = new List<OpportunityLineItem>();
    public static List<OpportunityTeamMember> lstInactiveOppTeam = new List<OpportunityTeamMember>();
    public static List<Core_Opportunity_Partner__c> inactiveOppPartner = new List<Core_Opportunity_Partner__c>();
    
    /*
    * Method name  : getExistingData
    * Description  : This method will show the related list if available to be cloned.
    * Return Type  : 
    * Parameter    : CurrentOppId.
    */     
    @auraEnabled
    public static wrapperRelatedList getExistingData(Id oppId){
        wrapperRelatedList wrRL = new wrapperRelatedList();
        oppFeatures = [SELECT id FROM Core_Opportunity_Features__c WHERE Core_Opportunity__c =:oppId AND IsDeleted = false];
        if(oppFeatures.size()>0){
            wrRL.isOppFeatures = true;
        }
        oppPtnrs = [SELECT id FROM Core_Opportunity_Partner__c WHERE Core_Opportunity__c =:oppId  AND Core_Partner__r.Core_Deactivated__c = false AND Core_Partner_Role__c !=:VENDOR_TEXT];
        if(oppPtnrs.size()>0){
            wrRL.isOppPtnrs = true;
        }
        oppPrdcts = [SELECT id FROM OpportunityLineItem WHERE Opportunity.Id =:oppId AND Product2.IsActive = true AND Product2.isDeleted = false];
        if(oppPrdcts.size()>0){
            wrRL.isOppPrdcts = true;
        }
        attList = [SELECT Id, Body, Name, ParentId, ContentType, Parent.Type,BodyLength,Description from Attachment where parentId=:oppId];           
        notelist = [SELECT Id, Body,ParentId,Title  FROM Note where ParentId =:oppId];   
        contDocLink = [SELECT ContentDocumentId,LinkedEntityId,ShareType,Visibility FROM ContentDocumentLink WHERE LinkedEntityId=:oppId];                                  
        system.debug('attList.size()'+attList.size());
        system.debug('notelist.size()'+notelist.size());
        system.debug('contDocLink.size()'+contDocLink.size()); 
        if(attList.size()>0 || notelist.size()>0 || contDocLink.size()>0){
            wrRL.isAttachment = true;
        }
        
        wrRL.lstOppTeam = [SELECT id, name, OpportunityAccessLevel, TeamMemberRole, Core_Team_Member_Geo__c FROM OpportunityTeamMember
                      WHERE OpportunityId = :oppId
                      AND User.IsActive = true
                      LIMIT 2000];                                 
        
        wrRL.lstSelectOppTeam = new List<TeamMemberSelectionWrapper>();        
        for (OpportunityTeamMember otmRec : wrRL.lstOppTeam) {
            if (otmRec.TeamMemberRole != NULL && otmRec.TeamMemberRole.contains(OWNER_TEXT) && (wrRL.lstSelectOppTeam.size() > 0))
                wrRL.lstSelectOppTeam.add(0, new TeamMemberSelectionWrapper(otmRec));
            else    
                wrRL.lstSelectOppTeam.add(new TeamMemberSelectionWrapper(otmRec));
        }            
        system.debug('lstSelectOppTeam-'+wrRL.lstSelectOppTeam);
        lstInactiveOppTeam = [SELECT User.Name, TeamMemberRole, Core_Team_Member_Geo__c, User.IsActive
                              FROM OpportunityTeamMember
                              WHERE OpportunityId = :oppId
                              AND User.IsActive = false
                              LIMIT 2000];
        
        inactiveOppProduct = [SELECT Name, Core_Product_Type__c, Quantity, TotalPrice, Core_Status__c, Product2.IsActive, Product2.isDeleted 
                                 FROM OpportunityLineItem
                                 WHERE Opportunity.Id = :oppId
                                 AND (Product2.IsActive=false OR Product2.isDeleted=true)
                                 LIMIT 2000];
        if(inactiveOppProduct.size()>0){
            wrRL.inactiveOppProduct = true;
            wrRL.inactiveOppProductList = inactiveOppProduct; 
        }
        
        inactiveOppPartner = [SELECT Name, Core_Partner__r.Name, Core_Partner_Role__c, Core_Partner_Type__c,
                                 Core_Partner_Program__c, Core_Partner__r.Core_Deactivated__c
                                 FROM Core_Opportunity_Partner__c
                                 WHERE Core_Opportunity__c = :oppId
                                 AND (Core_Partner__r.Core_Deactivated__c = true OR Core_Partner_Role__c = :VENDOR_TEXT)
                                 LIMIT 2000];
        if(inactiveOppPartner.size()>0){
            wrRL.inactiveOppPartner = true;
            wrRL.inactiveOppPartnerList = inactiveOppPartner; 
        }
        
        return wrRL;
    }
    /*
    * Method name  : saveData
    * Description  : This method will be clone the Opp.
    * Return Type  : 
    * Parameter    : CurrentOppId.
    */     
    @auraEnabled
    public static void saveData(Id oppId, Boolean onCheckOppFeatures, Boolean onCheckOppPtnrs, Boolean onCheckOppPrdcts, Boolean onCheckAttachment){
        attList = [SELECT Id, Body, Name, ParentId, ContentType, Parent.Type,BodyLength,Description from Attachment where parentId=:oppId];
        notelist = [SELECT Id, Body,ParentId,Title  FROM Note where ParentId =:oppId];
        contDocLink = [SELECT ContentDocumentId,LinkedEntityId,ShareType,Visibility FROM ContentDocumentLink WHERE LinkedEntityId=:oppId];
        //InactiveOppProduct = [SELECT Name, Core_Product_Type__c, Quantity, TotalPrice, Core_Status__c, Product2.IsActive, Product2.isDeleted FROM OpportunityLineItem WHERE Opportunity.Id = :oppId AND (Product2.IsActive=false OR Product2.isDeleted=true) LIMIT 2000];
        List<String> errMsgList = System.label.Core_Opp_CloneCont_Msgs.split(';');
        String strFields = getAllFields('Opportunity');
        String oppQuery = 'SELECT ' + strFields + ' FROM Opportunity WHERE Id = \'' + oppId + '\'';  
        Opportunity oppRec = Database.query(oppQuery);
        
        //US103708-Added logic for insert the Clone Opportunity added by-Rajesh.   
        oppRec = insertCloneOpportunity(oppRec,oppRec);
        try{
            insert oppRec; 
            if(isPartner){
                updateOppPriceBook(oppRec.Id);   
            } 
        }
        catch(exception e){
            system.debug('ExceptionLineNumber'+e.getLineNumber());
            system.debug('Exception'+e.getMessage());
        }
        /*List<Core_Opportunity_Features__c> oppFeatures = [SELECT id FROM Core_Opportunity_Features__c WHERE Core_Opportunity__c =:oppId AND IsDeleted = false];
        List<Core_Opportunity_Partner__c> oppPtnrs = [SELECT id FROM Core_Opportunity_Partner__c WHERE Core_Opportunity__c =:oppId  AND Core_Partner__r.Core_Deactivated__c = false AND Core_Partner_Role__c !=:VENDOR_TEXT];
        List<OpportunityLineItem> oppPrdcts = [SELECT id FROM OpportunityLineItem WHERE Opportunity.Id =:oppId AND Product2.IsActive = true AND Product2.isDeleted = false];
        List<Attachment> attList = [SELECT Id, Body, Name, ParentId, ContentType, Parent.Type,BodyLength,Description from Attachment where parentId=:oppId];           
        List<Note> notelist = [SELECT Id, Body,ParentId,Title  FROM Note where ParentId =:oppId];   
        List<ContentDocumentLink> contDocLink = [SELECT ContentDocumentId,LinkedEntityId,ShareType,Visibility FROM ContentDocumentLink WHERE LinkedEntityId=:oppId];                                  
        if(attList.size()>0 || notelist.size()>0 || contDocLink.size()>0){
            isAttachment = true;
        }*/
        if(onCheckOppFeatures){
            cloneFeatures(oppId, oppRec.Id);
        }
        if(onCheckOppPtnrs){
            clonePartners(oppId, oppRec.Id);
        }
        if(onCheckOppPrdcts){
            system.debug('isPartner-'+isPartner);
            if(isPartner){
                String strFields1 = getAllFields('OpportunityLineItem');
                cloneProductsPartners(oppId, oppRec.Id,strFields1);
            }
            else{
                cloneProducts(oppId,oppRec.Id);
            }
        }
        if(onCheckAttachment )
            insertCloneOppAttachment(oppRec.Id,attList);
        
        if(onCheckAttachment ) 
            insertCloneNote(oppRec.Id,notelist);
        
        if(onCheckAttachment)
            insertCloneOppContentDocumentLink(oppRec.Id,contDocLink);
        
    }
    
    /*
    * Method name  : cloneFeatures
    * Description  : This method will be insert the Clone Features.
    * Return Type  : 
    * Parameter    : Oldopportunity,newOpp.
    */         
    public static void cloneFeatures(Id OldOpp, Id newOppId) {
        
        List<Core_Opportunity_Features__c>lstInactiveOppFeatures = [SELECT Core_Feature_Type__c, Core_Feature_Name__c, Core_Feature_Set__c
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
    
    /*
    * Method name  : clonePartners
    * Description  : This method will be insert the Clone Partners.
    * Return Type  : 
    * Parameter    : Oldopportunity,newOpp.
    */   
    public static void clonePartners(Id oldOppId, Id newOppId) { 
        
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
        oppRec.Core_Opp_Strategic_Opportunity__c       = NULL;  //Added by Madhu for TWC3123-4260 - Strategic Opportunity Flag convtered from checkbox to Picklist So False marked as NULL.
        oppRec.Core_Military_Aerospace_Govmt_End_Use__c= currentOpportunity.Core_Military_Aerospace_Govmt_End_Use__c;
        
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
        /*if(!(currentOpportunity.Account.Core_Military_Aerospace_and_Government__c)) {
            oppRec.Core_Compliance_Comments__c         = NULL;    
            oppRec.Core_Private_Compliance_Comments__c = NULL;
            oppRec.Core_Compliance_Status__c           = NULL;
            oppRec.Core_Compliance_Sub_Status__c       = NULL;
        }
        else{
            oppRec.Core_Compliance_Status__c=DEF_COMPLIANCE_STATUS;           
            oppRec.Core_Compliance_Sub_Status__c=DEF_COMPLIANCE_SUB_STATUS;       
            oppRec.Core_Compliance_Comments__c=NULL;         
            oppRec.Core_Private_Compliance_Comments__c=NUll;
        }*/
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
        /*String CloneRecordtype;
        if(!test.isRunningTest()){
            CloneRecordtype=[select id,RecordType.Name from Opportunity where Id=:currentOpportunity.Id].RecordType.Name;
        }else{
            CloneRecordtype ='New Opportunity';
        }     
        if(CloneRecordtype !='Solution Group'){
            oppRec.Core_Commissionable__c=YES_TEXT;
            
        }*/
        
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
        oppRec.Core_Solution_Detail_IOTG__c                    =NULL;
        oppRec.CORE_SOLUTION_DETAIL_DCG_CCG__C                 =NULL;
        oppRec.Core_Support_Completed__c                       =FALSE; 
        oppRec.Core_Approved_Opportunity_Region__c             =NULL;
        oppRec.Core_Standard_Customer_Refresh__c               =FALSE; 
        OPPRec.Core_MAG_Questionnaire_ID__c                    =NULL;
         oppRec.Core_Compliance_Status__c=NULL;           
         oppRec.Core_Compliance_Sub_Status__c=NULL; 
        oppRec.Core_Last_KPI_Update__c=NULL;
        
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
        
        //START - Added by Ankita  on 30th Jan 2020 for US572823 - On Opportunity "Approved By" and all related Approve Fields are made to NULL while Opportunity cloning
        oppRec.Core_Approved_By__c               = NULL;
        oppRec.Core_Submit_For_Approval__c          = False;
        opprec.Core_System_First_Approved_Sales_Group__c  = NULL;
        oppRec.Core_Approved_Opportunity_Coverage__c     = NULL;  
        //END  - Added by Ankita  on 30th Jan 2020 for US572823 - On Opportunity "Approved By" and all related Approve Fields are made to NULL while Opportunity cloning
        
        //START - Added by Ankita on 10th Feb 2020 for  US584490 - On Opportunity and Opportunity Products At Risk Field needs to be cleared out on Opportunity Cloning.
        oppRec.Core_At_Risk__c                 = False;
        oppRec.Core_At_Risk_Created_Date__c          = NULL;
        oppRec.Core_Support_Requested__c          = NULL;
        //End   - Added by Ankita on 10th Feb 2020 for  US584490 - On Opportunity and Opportunity Products At Risk Field needs to be cleared out on Opportunity Cloning.
        //End-- The below fields are added newly as compared with existing code--//
        
        //*************************End  Below fields are shouldn't be cloned***************************//
        
        return oppRec;
    }
    
    /*
    * Method name  : getAllFields
    * Description  : 
    * Return Type  : 
    * Parameter    : String sobjectname
    */  
    public static String getAllFields(String sobjectname)
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
    
    /*
    * Method name  : cloneProductsPartners
    * Description  : clone Opp Products
    * Return Type  : 
    * Parameter    : old Opp id, new Opp id
    */  
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
            //newOppLineItem.Core_BU_Product_Segment__c          = NULL;
            //newOppLineItem.Core_BU_Short_Name__c               = NULL; 
            
            //START - Added by Laxmana for defect fix  DE28307- US176771 - When we clone an approved opportunity then following fields are not cleared from the Approvalinfo   
            newOppLineItem.Core_Opp_Approved_Sales_Group__c  =Null;
            newOppLineItem.CRM_DW_App_UCD_Customer_Name__c      =Null;
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
            
            //START - Added by Ankita on 10th Feb 2020 for  US584490 - On Opportunity Products all related Risk Field needs to be cleared out on Opportunity Cloning.
            newOppLineItem.Core_At_Risk__c            = False;
            newOppLineItem.Core_Risk_Category__c        = NULL;
            newOppLineItem.Core_Risk_Priority__c        = NULL;
            newOppLineItem.Core_Risk_Reason1__c          = NULL;
            newOppLineItem.Core_Risk_Reason2__c          = NULL;
            newOppLineItem.Core_At_Risk_Status__c        = NULL;
            //END   - Added by Ankita on 10th Feb 2020 for  US584490 - On Opportunity Products all related Risk Field needs to be cleared out on Opportunity Cloning.
            
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
    
    /*
    * Method name  : cloneProducts
    * Description  : clone Opp Products
    * Return Type  : 
    * Parameter    : old Opp id, new Opp id
    */  
    public static void cloneProducts(Id oldOppId, Id newOppId) { 
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
            //newOppLineItem.Core_BU_Product_Segment__c          = NULL;
            //newOppLineItem.Core_BU_Short_Name__c               = NULL; 
            //START - Added by Laxmana for defect fix  DE28307- US176771 - When we clone an approved opportunity then following fields are not cleared from the Approvalinfo   
            newOppLineItem.Core_Opp_Approved_Sales_Group__c  =Null;
            newOppLineItem.CRM_DW_App_UCD_Customer_Name__c   =Null;
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
            //END   - Added by Ankita on 10th Feb 2020 for  US584490 - On Opportunity Products all related Risk Field needs to be cleared out on Opportunity Cloning.
            
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
    Public static void insertCloneOppContentDocumentLink(Id newOppId,List<ContentDocumentLink>contDocLink){
        system.debug('in insert doc');
        list<ContentDocumentLink> lstContentDoc=new list<ContentDocumentLink>();
        for(ContentDocumentLink  doc: contDocLink){
            ContentDocumentLink  cloneDocLink= doc.clone();
            cloneDocLink.LinkedEntityId=newOppId;
            lstContentDoc.add(cloneDocLink);
        }
        if(lstContentDoc != null && !(lstContentDoc.isEmpty())){
            system.debug('before insert doc');
            insert lstContentDoc;
        }
    }
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
    public class TeamMemberSelectionWrapper {
        @auraenabled
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
    
    public class wrapperRelatedList{
        @auraEnabled
        public boolean isOppFeatures{get;set;}
        @auraEnabled
        public boolean isOppPtnrs{get;set;}
        @auraEnabled
        public boolean isOppPrdcts{get;set;}
        @auraEnabled
        public boolean isAttachment{get;set;}
        @auraEnabled
        public List<OpportunityTeamMember> lstOppTeam{get;set;}
        @auraEnabled
        public List<TeamMemberSelectionWrapper> lstSelectOppTeam{get;set;}
        @auraEnabled
        public boolean inactiveOppProduct{get;set;}
        @auraEnabled
        public List<OpportunityLineItem> inactiveOppProductList{get;set;}
        @auraEnabled
        public List<Core_Opportunity_Partner__c> inactiveOppPartnerList{get;set;}
        @auraEnabled
        public boolean inactiveOppPartner{get;set;}
    }
    
    
    
}