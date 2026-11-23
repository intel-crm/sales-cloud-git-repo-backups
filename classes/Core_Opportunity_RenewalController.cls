/***************************************************************************************************** 
Class Name :    Core_Opportunity_RenewalController
Test Class :    Core_Opportunity_RenewalController_Test
Description:    Controller code for Renewing Opportunity
Created By :    Ealisha(Beatles)
******************************************************************************************************/
public without sharing class Core_Opportunity_RenewalController {

    public static final String  OWNER_TEXT                = 'Owner';
    public static List<Core_Opportunity_Features__c> lstInactiveOppFeatures { get; set; }
    public static List<TeamMemberSelectionWrapper>   lstSelectOppTeam { get; set; } 
    public static boolean isPartner = false; 
    public static List<OpportunityTeamMember>        lstOppTeam { get; set; }
/**************************************************************************************************************************************************************** 
    Method Name : Method to create skeleton for the renewal opportunity based on original opportunity data
*****************************************************************************************************************************************************************/     
    @InvocableMethod
    public static List<Id> createRenewalOpportunity(List<Opportunity> originalOpportunityInput){
        List<Core_Log_Entry__c> logEntries = new List<Core_Log_Entry__c>();
        Map<String, Core_LogEntry_Switch__c> logSwitch = Core_LogEntry_Switch__c.getall();
        
        List<Id> newOppId = new List<Id>();
        Integer iQueryCount;
        String  VENDOR_TEXT = 'Vendor';
        Opportunity originalOpportunity = originalOpportunityInput[0];
        //Opportunity currentOpportunity = [select id,name,Core_Military_Aerospace_Govmt_End_Use__c,Pricebook2Id,Core_Technical_Owner__c,CloseDate,Core_Intel_Platform__c,Core_Solution_Area__c,Core_Product_Segment__c,Core_Product_Application__c,Core_Consumption_Market__c from opportunity where id=:recordId][0];
        ApexPages.StandardController stdController = new ApexPages.StandardController(originalOpportunity);
        Core_Opportunity_Clone_Controller c = new Core_Opportunity_Clone_Controller(stdController);
        String strFields = c.getAllFields('Opportunity'); 
        String oppQuery = 'SELECT Core_Technical_Owner__r.Profile.Name, ' + strFields + ' FROM Opportunity WHERE Id = \'' + originalOpportunity.Id + '\'';       
        
        //codescan fix : Avoid Untrusted/Unescaped Variables in DML Query(possible soql injection)-added String.escapeSingleQuotes
        Opportunity oppRec = Database.query(String.escapeSingleQuotes(oppQuery).replaceAll('\\\\', '')); //(oppQuery);
        
        
        Opportunity renewalOpp = createRenewalOpportunitySkeleton(originalOpportunity,oppRec);
        
        //START - Checking if the products have invalid pricebook
        map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
        if(mapFunctionalityNameTriggerExecution.containsKey('opptyCloneErrorMsg') && mapFunctionalityNameTriggerExecution.get('opptyCloneErrorMsg').Core_Active__c){
            List<OpportunityLineItem> oliList1 = new List<OpportunityLineItem>();
            oliList1 = [SELECT id, Product2Id FROM OpportunityLineItem WHERE OpportunityId = :originalOpportunity.Id WITH SECURITY_ENFORCED ]; //TWC3123-5310 - Added WITH SECURITY_ENFORCED 
            Set<Id> pId2Set = new Set<Id>();
            for(OpportunityLineItem oli : oliList1){
                pId2Set.add(oli.Product2Id);
            }
            List<PricebookEntry> pbeList = new List<PricebookEntry>();
            pbeList = [SELECT id, Product2Id, isActive FROM Pricebookentry WHERE Product2Id IN :pId2Set AND isActive = true WITH SECURITY_ENFORCED];//TWC3123-5310 - Added WITH SECURITY_ENFORCED
            if(pbeList.isEmpty()){
                return null;
            }
        }
        //END - Checking if the products have invalid pricebook
        
       
        
            renewalOpp.Core_has_Solution__c = true;
            renewalOpp.Name = '[Renewal] '+originalOpportunity.Name;
            renewalOpp.Core_IsClone__c = false;
            renewalOpp.Core_Renewed_Opportunity_Ind__c = true;
            renewalOpp.Opportunity_Focus__c =''; //originalOpportunity.Opportunity_Focus__c; //TWC4767-3906 : we dont need this field anymore. 
            renewalOpp.CloseDate = originalOpportunity.CRM_VBS_Contract_Start_Date__c.addMonths(originalOpportunity.CRM_VBS_Contract_Lifetime_in_Months__c == null ? 12 : (Integer)originalOpportunity.CRM_VBS_Contract_Lifetime_in_Months__c);
        
        
        try{
        insert renewalOpp; 
            
                         
        }catch(Exception err){
            logEntries.add(new Core_Log_Entry__c(Core_Message__c ='Error',Core_Details__c = err.getMessage(), Core_Origin__c='Core_Opportunity_RenewalController.createRenewalOpportunity', Core_Severity__c='High', Core_When__c=System.Now(), Core_Project__c = 'Sales CRM'));
            if(!logEntries.isEmpty() && !logSwitch.isEmpty()){
                if(logSwitch.get('Core_LogEntry_Check') != null && logSwitch.get('Core_LogEntry_Check').Is_Selected__c){ 
                    insert logEntries;
                }}
            
            throw new AuraHandledException(err.getMessage());  
            
            
        }
        
        // CloneTeam has special logic to reflect user selections.
        // The Opportunity Owner and Technical Owner are created automatically by the Opportunity trigger handler.
        
        cloneTeam(c,originalOpportunity,renewalOpp.Id);
        
        iQueryCount = Database.CountQuery('SELECT COUNT() ' + 
                                          'FROM Core_Opportunity_Features__c ' + 
                                          'WHERE Core_Opportunity__c = \'' + originalOpportunity.Id + '\'' + 
                                          '  AND IsDeleted = false');
        Boolean showOppFeatures = iQueryCount > 0;  
        
        if (showOppFeatures)
           cloneFeatures(originalOpportunity.Id, renewalOpp.Id);
        
        iQueryCount = Database.CountQuery('SELECT COUNT() ' + 
                                          'FROM Core_Opportunity_Partner__c ' + 
                                          'WHERE Core_Opportunity__c = \'' + originalOpportunity.Id + '\'' + 
                                          '  AND Core_Partner__r.Core_Deactivated__c = false ' + 
                                          '  AND Core_Partner_Role__c != \'' + VENDOR_TEXT + '\'');
        Boolean showOppPartner = iQueryCount > 0;
        
        if (showOppPartner)
            clonePartners(c,originalOpportunity.Id, renewalOpp.Id);
        
        iQueryCount = Database.CountQuery('SELECT COUNT() ' + 
                                          'FROM OpportunityLineItem ' + 
                                          'WHERE Opportunity.Id = \'' + originalOpportunity.Id + '\'' + 
                                          '  AND Product2.IsActive = true ' + 
                                          '  AND Product2.isDeleted = false');
        
        Boolean showOpportunityProductOption = iQueryCount > 0;
        
        if (showOpportunityProductOption){
            //Call for Partner Oppty(Disti)-Added by Raga
            if(isPartner){
                String strFields1 = c.getAllFields('OpportunityLineItem');
                Core_Opportunity_Clone_Controller.cloneProductsPartners(originalOpportunity.Id, renewalOpp.Id,strFields1);
            }
            else{
                cloneProducts(c,originalOpportunity.Id,renewalOpp.Id);
            }
        }
        
        iQueryCount = Database.CountQuery('SELECT COUNT() ' + 
                                          'FROM Opportunity_Solution_Area__c ' + 
                                          'WHERE Core_Opportunity__c = \'' + originalOpportunity.Id + '\'');
        
        Boolean showOpportunitySolution = iQueryCount > 0;
        if (showOpportunitySolution)
            cloneSolutions(c,originalOpportunity.Id, renewalOpp.Id);
        newOppId.add(renewalOpp.Id);
        return newOppId;
    }
    
/**************************************************************************************************************************************************************** 
    Method Name : Method to create skeleton for the renewal opportunity based on original opportunity data
*****************************************************************************************************************************************************************/     
    public static Opportunity createRenewalOpportunitySkeleton(Opportunity originalOpportunity,Opportunity oppRec){
        
        //US103708-Added logic for insert the Clone Opportunity added by-Rajesh.   
        oppRec=Core_Opportunity_Clone_Controller.insertCloneOpportunity(oppRec,originalOpportunity);
        return oppRec;
    }
    
    
    public static void cloneSolutions(Core_Opportunity_Clone_Controller c,Id oldOppId, Id newOppId) { 
        List<Core_Log_Entry__c> logEntries = new List<Core_Log_Entry__c>();
        Map<String, Core_LogEntry_Switch__c> logSwitch = Core_LogEntry_Switch__c.getall();
        String strFields = c.getAllFields('Opportunity_Solution_Area__c');
        
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
         
        if (lstNewSolution.size() > 0){
            try {
                 //TWC3123-5310 - Added isCreatable check
                if(Schema.sObjectType.Opportunity_Solution_Area__c.isCreateable()){
                Database.insert(lstNewSolution, true);
                }
            }
            catch (Exception err) {
                //TWC3123-5310 - commented system.debug and added log entry stamp to log error
            logEntries.add(new Core_Log_Entry__c(Core_Message__c ='Error',Core_Details__c = err.getMessage(), Core_Origin__c='Core_Opportunity_Clone_Controller.cloneSolutions', Core_Severity__c='High', Core_When__c=System.Now(), Core_Project__c = 'Sales Evolve'));
            if(!logEntries.isEmpty() && !logSwitch.isEmpty()){
                if(logSwitch.get('Core_LogEntry_Check') != null && logSwitch.get('Core_LogEntry_Check').Is_Selected__c){ 
                    insert logEntries;
               }}}
        }
    }
    
    public static void cloneFeatures(Id OldOpp, Id newOppId) {
        
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
    
    
    public static void cloneTeam(Core_Opportunity_Clone_Controller c,Opportunity currentOpportunity,Id newOppId) { 
        Set <Id> setTeamMembers = new Set<Id>();
        lstOppTeam = [SELECT Name,UserId, TeamMemberRole, Core_Team_Member_Geo__c, OpportunityAccessLevel
                      FROM OpportunityTeamMember
                      WHERE OpportunityId = :currentOpportunity.Id
                      AND User.IsActive = true WITH SECURITY_ENFORCED
                      LIMIT 2000];
        List<Id> listUserID = new List<Id>();
        lstSelectOppTeam = new List<TeamMemberSelectionWrapper>();        
        for (OpportunityTeamMember otmRec : lstOppTeam) {
            listUserID.add(otmRec.UserId);
            if (otmRec.TeamMemberRole != NULL && otmRec.TeamMemberRole.contains(OWNER_TEXT) && (lstSelectOppTeam.size() > 0))
                lstSelectOppTeam.add(0, new TeamMemberSelectionWrapper(otmRec));
            else    
                lstSelectOppTeam.add(new TeamMemberSelectionWrapper(otmRec));
        }
        for (TeamMemberSelectionWrapper tmRec: lstSelectOppTeam) {        
            // Copy whatever has been selected and whatever is NOT readOnly.  The readOnly members will
            // be created automatically by opportunity trigger code.    
            if (tmRec.memberSelected && !tmRec.readOnly)
                setTeamMembers.add(tmRec.oppTeamMember.Id);
        }
        String strFields = c.getAllFields('OpportunityTeamMember');
        
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
       
    public static void clonePartners(Core_Opportunity_Clone_Controller c,Id oldOppId, Id newOppId) { 
        
        String strFields = c.getAllFields('Core_Opportunity_Partner__c');
        
        String itemQuery = 'SELECT ' + strFields + ' ' + 
            'FROM Core_Opportunity_Partner__c ' +
            'WHERE Core_Opportunity__c = \'' + oldOppId + '\'' + 
            '  AND Core_Partner__r.Core_Deactivated__c = false ' + 
            '  AND Core_Partner_Role__c != \'Vendor\'';  
        //TWC3123-5376: codescan fix : Avoid Untrusted/Unescaped Variables in DML Query(possible soql injection)-added String.escapeSingleQuotes
        List<Core_Opportunity_Partner__c> lstInactiveOppPartner = Database.query(String.escapeSingleQuotes(itemQuery).replaceAll('\\\\', '')); //Database.query(itemQuery);
        
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
    
    public static void cloneProducts(Core_Opportunity_Clone_Controller c,Id oldOppId, Id newOppId) { 
        List<Core_Log_Entry__c> logEntries = new List<Core_Log_Entry__c>();
        Map<String, Core_LogEntry_Switch__c> logSwitch = Core_LogEntry_Switch__c.getall();
        String strFields = c.getAllFields('OpportunityLineItem');
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
            newOppLineItem.Core_Status__c             = 'Pending';  
            newOppLineItem.Core_Loss_Cancel_Reason__c = NULL;
            newOppLineItem.Core_Loss_Cancel_Details__c   = NULL;
            
            // BU Fields
            newOppLineItem.Core_Approved_BU_Product_Segment__c = NULL;
            newOppLineItem.Core_Approved_BU_Short_Name__c      = NULL;
            //START - Added by Laxmana for defect fix  DE28307- US176771 - When we clone an approved opportunity then following fields are not cleared from the Approvalinfo   
            newOppLineItem.Core_Opp_Approved_Sales_Group__c    = Null;
            newOppLineItem.CRM_DW_App_UCD_Customer_Name__c     = Null;
            newOppLineItem.Core_Approved_Prime_Account_Name__c =Null;
            newOppLineItem.Core_Approved_Opp_Product_Segment__c = Null;
            newOppLineItem.Core_Approved_KPI_Product_Group__c   = Null;
            newOppLineItem.Core_Opp_Approved_Oppty_Coverage__c  = Null;
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