/****************************************************************************************************
Apex Class Name : Core_DRR_ApproveAllPendingProducts
Version         : 1.0 
Created Date    : 06/06/2018
Function        :This class used to Approves all the Pending Products after data validation on Design Registration products.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*Rajesh kumar                 09/08/2017            Created
*****************************************************************************************************/
public with sharing class Core_DRR_ApproveAllPendingProducts {
    public String alertMessage{get;set;}
    public String retUrl{get;set;}  
    public String designRegpProdId;  
    public static boolean isTrue{get;set;}
     
    public static final String LOG_ENTRY_ORIGIN   = 'Core_DRR_ApproveAllPendingProducts';
    public static final String LOG_ENTRY_PROJECT  = 'DDR Registration';
    public static final String LOG_ENTRY_SCOPE    = 'Approve All Pending Products';
    public static final String LOG_ENTRY_ERROR    = 'Error';
    public static final String LOG_ENTRY_SEVERITY = 'Medium';
    public static final String LOG_ENTRY_INFO     = 'Info';   
    public static final String PENDING_STATUS     = 'Pending';   
    public List<Core_Design_Registration_Product__c> designprods;
     
     
    public Core_Design_Registration__c ddrRecord;
    List<Core_Design_Registration_Product__c> allDesignRegProdslist=new List<Core_Design_Registration_Product__c>();
    List<Core_Design_Registration_Product__c> allDesignRegProdsInactivelist=new List<Core_Design_Registration_Product__c>();
    List<Core_Design_Registration_Product__c> allDesignRegProdsInEligiblelist=new List<Core_Design_Registration_Product__c>();
    // added for deal
    List<Core_Design_Registration_Product__c> allDesignRegProdsInActiveDealIneligiblelist=new List<Core_Design_Registration_Product__c>();
    List<Core_Design_Registration_Product__c> allDealRegProdslist=new List<Core_Design_Registration_Product__c>();
    List<Core_Design_Registration_Product__c> allDealRegProdsCompetitoractive=new List<Core_Design_Registration_Product__c>();
    List<Core_Design_Registration_Product__c> allDealRegProdsQuantity=new List<Core_Design_Registration_Product__c>();
    List<Core_Design_Registration_Product__c> allDealRegProdsDateCheck=new List<Core_Design_Registration_Product__c>();
    List<Core_Design_Registration_Product__c> allDesignRegProdsNullTargetResalePrice=new List<Core_Design_Registration_Product__c>();
    public Core_Design_Registration__c recordddr;
    public static Boolean isApprovedall = false;
    Integer ApprovedDrpcount = 0;
    Id DealProRecordTypeid;
    Id DealProRecordTypeidLock;
     
    public Core_DRR_ApproveAllPendingProducts (ApexPages.StandardSetController stdSetCtrl){
        List<Core_Design_Registration_Product__c> selectedProducts = stdSetCtrl.getSelected();
        DealProRecordTypeid = Schema.SObjectType.Core_Design_Registration_Product__c.getRecordTypeInfosByDeveloperName().get('PCC_Deal_Registration_Product_Partner').getRecordTypeId();
        DealProRecordTypeidLock = Schema.SObjectType.Core_Design_Registration_Product__c.getRecordTypeInfosByDeveloperName().get('PCC_Deal_Registration_Product_Locked').getRecordTypeId();
        
        //get DR id from URL
        designRegpProdId=apexpages.currentpage().getParameters().get('Id').escapeHtml4();
        //Get DDR Record
            ddrRecord=[SELECT Id, OwnerId,Core_Vertical_Market_Nm__c,Core_Opportunity_Id__r.StageName,Core_Intel_Platform_Nm__c,Core_End_Customer_Account_Id__r.RecordType.Name,Core_Product_Segment_Nm__c,Core_Product_Application_Nm__c,Core_Design_Registration_Status_Nm__c, RecordTypeId,Core_End_Customer_Account_Owner__c,Core_End_Customer_Account_Id__c,Core_Accepted_By_Id__c ,Core_Accepted_By_Id__r.DelegatedApproverId,PCC_Registration_Type__c from Core_Design_Registration__c where Id =: DesignRegpProdId WITH SYSTEM_MODE];         
        // check if products are selected in LIST from UI
        designprods = returnDesigns(designRegpProdId,selectedProducts);
     
        string drRegType = ddrRecord.PCC_Registration_Type__c;
    
        //PROCESS DRP to check eligibility
        for (Core_Design_Registration_Product__c designRegProd : designprods) {
            if(PENDING_STATUS.equals(designRegProd.Core_Design_Product_Status_Nm__c)){
            //if (designRegProd.Core_Locked_Ind__c == false) {
            //    allDesignRegProdslist.add(designRegProd);
            //}    
             if(!String.isEmpty(drRegType) && drRegType.contains('Design'))
            {
                designMethod(designRegProd);
            }
            else if(!String.isEmpty(drRegType) && drRegType.contains('Deal'))
            {
                dealMethod(designRegProd);   
            }
            }
            else {
                 if(designRegProd.Core_Design_Product_Status_Nm__c=='Approved')
                 {
                    ApprovedDrpcount++;
                 }
            }
        }
        if(ApprovedDrpcount==designprods.size()){
            isApprovedall =true;
        }
    }
        public void designMethod(Core_Design_Registration_Product__c designRegProd)
        {
            if (designRegProd.Core_Locked_Ind__c == false) {
              allDesignRegProdslist.add(designRegProd);
            }
            if(designRegProd.Core_Locked_Ind__c == false)
            {
                if (designRegProd.Core_DR_Eligible_Status__c == false) {
                allDesignRegProdsInEligiblelist.add(designRegProd);
              } 
              if (designRegProd.Core_Active_Status__c == false) {
                allDesignRegProdsInactivelist.add(designRegProd);
              }
              if (designRegProd.Core_Target_Resale_Amt__c == null || designRegProd.Core_Target_Resale_Amt__c == 0) {
            allDesignRegProdsNullTargetResalePrice.add(designRegProd);
        }
            }
        }
        public void dealMethod(Core_Design_Registration_Product__c designRegProd)
        {
            // added for deal
            if(designRegProd.Core_Locked_Ind__c == false){
                // for deal if date on deal product is in past
                if(designRegProd.PCC_Quote_Line_Pricing_Start_Date__c < Date.today() || designRegProd.PCC_Quote_Line_Pricing_End_Date__c < Date.today())
                {
            allDealRegProdsDateCheck.add(designRegProd);                
                }
                // for deal check if deal product is not active and deal is not deal eligible
                else if(designRegProd.PCC_Product_Additional_Attribute__r.Is_Product_Active__c == false || designRegProd.PCC_Deal_Eligible_Status__c == false )
            {
              allDesignRegProdsInActiveDealIneligiblelist.add(designRegProd);
            }
                // competitor product entered should be an active product
                else if(designRegProd.PCC_Competitor_Product__r.Pricing_Active_cb__c == false)
                {
                    allDealRegProdsCompetitoractive.add(designRegProd);
                }
                // Quantity should be greater than 0
                else if(designRegProd.Core_Full_Year_Qty__c == null || designRegProd.Core_Full_Year_Qty__c < 1){allDealRegProdsQuantity.add(designRegProd);
                }
            }
        
            if( designRegProd.Core_Locked_Ind__c == false)
            {
                allDealRegProdslist.add(designRegProd);
            }
        }
     
        public List<Core_Design_Registration_Product__c> returnDesigns(String DesignRegpProdId,List<Core_Design_Registration_Product__c> selectedProducts){
            List<Core_Design_Registration_Product__c> designprodsLst = new List<Core_Design_Registration_Product__c>();
            if(selectedProducts!=null && selectedProducts.size()>0){
                designprodsLst =[SELECT id, Core_Design_Product_Status_Nm__c,Core_Product_Id__r.Core_Avail_for_New_Designs__c, Core_DR_Eligible_Status__c,Core_Active_Status__c,Core_Locked_Ind__c,PCC_Deal_Eligible_Status__c,RecordTypeId,PCC_Product_Additional_Attribute__r.Is_Product_Active__c,Core_Design_Registration_Id__r.PCC_Registration_Type__c,PCC_Competitor_Product__r.Pricing_Active_cb__c,Core_Full_Year_Qty__c,PCC_Quote_Line_Pricing_Start_Date__c,PCC_Quote_Line_Pricing_End_Date__c,Core_Target_Resale_Amt__c FROM Core_Design_Registration_Product__c WHERE Core_Design_Registration_Id__c = :DesignRegpProdId  and id in :selectedProducts];}
                else{designprodsLst =[SELECT id, Core_Design_Product_Status_Nm__c,Core_Product_Id__r.Core_Avail_for_New_Designs__c, Core_DR_Eligible_Status__c,Core_Active_Status__c,Core_Locked_Ind__c,PCC_Deal_Eligible_Status__c,RecordTypeId,PCC_Product_Additional_Attribute__r.Is_Product_Active__c,Core_Design_Registration_Id__r.PCC_Registration_Type__c,PCC_Competitor_Product__r.Pricing_Active_cb__c,Core_Full_Year_Qty__c,PCC_Quote_Line_Pricing_Start_Date__c,PCC_Quote_Line_Pricing_End_Date__c,Core_Target_Resale_Amt__c FROM Core_Design_Registration_Product__c WHERE Core_Design_Registration_Id__c = :DesignRegpProdId];    
                }
                return designprodsLst;
        }
    //To check the dr status before Approve All/Reject All DR products -->Shivini 
    public static  boolean coreDRStatus(Core_Design_Registration__c recordddr)
    {
        if(recordddr.Core_Design_Registration_Status_Nm__c=='Cancelled'||recordddr.Core_Design_Registration_Status_Nm__c=='Rejected'||recordddr.Core_Design_Registration_Status_Nm__c=='Abandoned'|| recordddr.Core_Opportunity_Id__r.StageName=='Production Win'){isTrue= true;
        }
        else{
            isTrue= false;
        }
        return isTrue;
    }
     
     
    //The below method is being called when user is clicked on ApproveAllPendingProducts List button //
    public PageReference approvalAllpendingProd() {      
        List<Core_Design_Registration_Product__c> updateDesignprodList=new List<Core_Design_Registration_Product__c>();
        Boolean isDeal = true;
        retUrl = String.escapeSingleQuotes(Url.getSalesforceBaseUrl().toExternalForm() + '/' +DesignRegpProdId);   
        //  Core_Design_Registration__c designReg=getDDRsoqlquery(DesignRegpProdId);
        String inactiveLovFields=Core_DDR_Accept_Approve_Reject_Design.ValidateInactiveLOVS(ddrRecord);
        Boolean drstatus=coreDRStatus(ddrRecord);
        Map<String,Map<String,Object>> lexMetadataMap = new Core_CustomMetadataObjectController('Core_Lex_AlertMessage__mdt').getAll();
        
        if(drstatus== true){
        alertMessage='Products cannot be added or edited.';    
        }
        else if(ddrRecord.PCC_Registration_Type__c.contains('Design'))
        {if (allDesignRegProdslist.size() == 0){ 
                alertMessage ='There are no pending products on this Design Registration to Approve.';
            }        
            else if(allDesignRegProdsInactivelist.size() > 0){ 
                alertMessage ='There are  Inactive Products added on this Design Registration, please remove the inactive products to proceed with Approval.';
            }else if(allDesignRegProdsInEligiblelist.size() > 0){
                alertMessage ='There are  Ineligible Products added on this Design Registration, please remove the Ineligible products to proceed with Approval.';
            }
            else if(allDesignRegProdsNullTargetResalePrice.size() > 0){
                alertMessage ='Target Resale Price is required for approval. There are ' + allDesignRegProdsNullTargetResalePrice.size() + ' product(s) with missing or zero Target Resale Price. Please populate valid Target Resale Price for all products before approving.';
            }
            else if(String.isNotBlank(InactiveLovFields)){ 
                alertMessage='Current selected values of the following fields'+'"'+InactiveLovFields+'"'+'on this record are inactive. Please select a valid value and retry submission ';
            } 
            else if(ddrRecord.Core_End_Customer_Account_Id__r.RecordType.Name=='Inactive Account' 
                    || ddrRecord.Core_End_Customer_Account_Id__r.RecordType.Name=='CoMarketing' ){alertMessage='Current selected value of the field'+'"'+ 'End Customer Account'+'"'+' on this record is not a valid value anymore. Please select a valid value and retry submission ';
                    }
            else{
                for(Core_Design_Registration_Product__c desp:allDesignRegProdslist){desp.Core_Design_Product_Status_Nm__c='Approved';
                    updateDesignprodList.add(desp);
                }
                try{
                    update updateDesignprodList;
                        alertMessage = updateDesignprodList.size() + ' Pending Design Registration Product/s Approved successfully.';
                    if(Test.isRunningTest()){throw new System.DMLException();}
                }catch(Exception e){
                    alertMessage = LabelConfiguration__mdt.getInstance('Core_DDR_Button_Exceptions').Value__c;
                    Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,'', '' ,'' ,'Core_DRR_ApproveAllPendingProducts.approvalAllpendingProd' ,'' ,e);
                } 
            }
        }
        else if(ddrRecord.PCC_Registration_Type__c.contains('Deal'))
        {  
            Boolean hasCustomPermission = FeatureManagement.checkPermission('PCC_Deal_Reg_Internal_Admin_Custom');                     
            if (!PCC_InvocableMethods.isAuthorizedUser(ddrRecord) || !hasCustomPermission){
                alertMessage = LabelConfiguration__mdt.getInstance('PCC_Unauthorized_User_Error').Value__c;
            }
            else if(allDealRegProdslist.size() == 0 && ddrRecord.PCC_Registration_Type__c.contains('Deal')){
                if(isApprovedall==true){
                    alertMessage= lexMetadataMap.containsKey('Deal_Products_already_approved') ? String.valueOf(lexMetadataMap.get('Deal_Products_already_approved').get('Core_Alert_Message__c')) : '';}
                 else{
                 alertMessage = lexMetadataMap.containsKey('Deal_has_no_pending_products') ? String.valueOf(lexMetadataMap.get('Deal_has_no_pending_products').get('Core_Alert_Message__c')) : '';}             }  
            
            // added for deal
            else if(allDealRegProdsDateCheck.size() > 0)
            {
                alertMessage = lexMetadataMap.containsKey('Deal_Product_Past_Date') ? String.valueOf(lexMetadataMap.get('Deal_Product_Past_Date').get('Core_Alert_Message__c')) : '';
            }
          else if(allDesignRegProdsInActiveDealIneligiblelist.size() > 0){
            alertMessage = lexMetadataMap.containsKey('Deal_Product_Not_Active_Not_Deal_Eligibl') ? String.valueOf(lexMetadataMap.get('Deal_Product_Not_Active_Not_Deal_Eligibl').get('Core_Alert_Message__c')) : '';
          }
            else if(allDealRegProdsCompetitoractive.size() > 0){
            alertMessage = lexMetadataMap.containsKey('Deal_Product_Competitor_Active') ? String.valueOf(lexMetadataMap.get('Deal_Product_Competitor_Active').get('Core_Alert_Message__c')) : '';
          }
            else if(allDealRegProdsQuantity.size() > 0){
            alertMessage = lexMetadataMap.containsKey('Deal_Product_Quantity') ? String.valueOf(lexMetadataMap.get('Deal_Product_Quantity').get('Core_Alert_Message__c')) : '';
          }/*
            else if(String.isNotBlank(InactiveLovFields)){ 
                alertMessage='Current selected values of the following fields'+'"'+InactiveLovFields+'"'+'on this record are inactive. Please select a valid value and retry submission ';
            } 
            else if(ddrRecord.Core_End_Customer_Account_Id__r.RecordType.Name=='Inactive Account' 
                    || ddrRecord.Core_End_Customer_Account_Id__r.RecordType.Name=='CoMarketing' ){
                        alertMessage='Current selected value of the field'+'"'+ 'End Customer Account'+'"'+' on this record is not a valid value anymore. Please select a valid value and retry submission ';
                    }*/
            else{
                for(Core_Design_Registration_Product__c desp:allDealRegProdslist){
                    desp.Core_Design_Product_Status_Nm__c='Approved';
                    updateDesignprodList.add(desp);
                    if(desp.RecordTypeId != DealProRecordTypeid && desp.RecordTypeId != DealProRecordTypeidLock)
                    {
                        isDeal = false;
                    }
                }
                try{update updateDesignprodList;
                    alertMessage = updateDesignprodList.size() + ' Pending Deal Registration Product/s Approved successfully.';
                    if(Test.isRunningTest()){throw new System.DMLException();}
                }catch(Exception e){
                    alertMessage = LabelConfiguration__mdt.getInstance('Core_DDR_Button_Exceptions').Value__c;
                    Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,'', '' ,ddrRecord.Id ,'Core_Design_Registration_Product__c' ,'' ,e);
                } 
            }
        }
        
        return null;
    }
        
    }