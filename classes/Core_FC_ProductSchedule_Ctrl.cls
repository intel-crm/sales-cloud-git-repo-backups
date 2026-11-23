/******************************************************************************************************************************************
Class Name:  Core_FC_ProductSchedule_Ctrl
Version     : 1.0 
Created Date: 15 JAN 2021
Function    : Controller class for Core_FC_ProductSchedule lightning component
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sougata Sarkar             15/01/2021              Original Version
*****************************************************************************************************************************************/

public without sharing class Core_FC_ProductSchedule_Ctrl {
    
    public static final Set<String> lostCancelStatus = new Set<String>{'Lost','Cancelled','Deleted','On Hold','Production Lost','Production Cancelled'};
        public static final String ORGWIDE_EMAIL = System.Label.Core_SetFromEmailAddress;//Organization-Wide Email Address
    /*************************************************************************************************************
* Method name  : getOpportunityRecord
* Description  : Query to get the opportunity details
* Return Type  : Opportunity
* Parameter    : String oppId 
**************************************************************************************************************/
    public static Opportunity getOpportunityRecord(String oppId){
        return [SELECT id, Name, Owner.Manager.IsActive, Core_Technical_Owner__r.Manager.IsActive, Core_FC_Recall_Count__c, Core_Number_of_Quarters__c, OwnerId, Owner.Name, Account.Name, Owner.ManagerId, Owner.email, Owner.Manager.email, Owner.Manager.DelegatedApproverId, Owner.DelegatedApproverId, Core_Technical_Owner__c, Core_First_Customer_Ship_Date__c,Core_Opportunity_Type__c, Core_Technical_Owner__r.Name, Core_Technical_Owner__r.ManagerId, Core_Technical_Owner__r.Manager.email,StageName, RecordType.Name, RecordTypeId,Core_Opportunity_Coverage_Nm__c,Core_Coverage_Type_Nm__c FROM Opportunity WHERE id = :oppId];
    }
    
    @auraEnabled
    public static String open6QPSReport(String oppId){
        Map<String, Core_Sales_Report_URL__c> mapReport = Core_Sales_Report_URL__c.getAll();
        return mapReport.get('6QPS_Credit').Core_Report_URL__c;
    }
    
    /*************************************************************************************************************
* Method name  : getAllForecast
* Description  : Query to get all the forecast records
* Return Type  : List<Core_Opp_FC_Prod_Schedule__c>
* Parameter    : String oppId 
**************************************************************************************************************/
    public static List<Core_Opp_FC_Prod_Schedule__c> getAllForecast(String oppId){
        return [SELECT id, Core_Opp_FC_Claim_Date__c, Core_FC_Opportunity_Product__c, Core_Forecast_Old_Claim_Date__c, Core_Opp_FC_Opportunity__c, Core_Opp_Line_Item_RecordID__c, Core_Opp_FC_Product__c, Core_Opp_FC_Product__r.Name,Core_FC_Opportunity_Product__r.Quantity, Core_Opp_FC_Quarter_Date__c, Core_Opp_FC_Quarter__c, Core_Opp_FC_Quantity__c, Core_Opp_FC_isdeleted__c, lastModifiedDate, createdDate, Core_FC_4Q_Shed_Quantity__c, Core_FC_Last_Modified_Date__c, Core_FC_BU_Product_Segment__c, Core_FC_BU_Short_Name__c, Core_FC_Vendor__c, Core_FC_Vendor__r.Name, Core_Opp_FC_Approval_Status__c, Core_Opp_FC_Approved_Date__c, Core_Core_FC_Appvd_SalesPrice__c, Core_Opp_FC_Prod_Sales_Price__c, Core_Opp_FC_Sched_Revenue__c,Core_Is_Post_Win__c,Core_FC_Opportunity_Product__r.Core_IsPCCOpportunity_cb__c FROM Core_Opp_FC_Prod_Schedule__c WHERE Core_Opp_FC_Opportunity__c = :oppId AND Core_Opp_FC_isdeleted__c = false ORDER BY Core_FC_Opportunity_Product__c,Core_Opp_FC_Quarter_Date__c];
    }
    public static User checkIfPartnerUser(){
        User us = [select Id, Name, Profile.Name, UserRoleId from User where Id=:UserInfo.getUserId()];
        return us;
    }
    
    
    /*************************************************************************************************************
* Method name  : initializeForecast
* Description  : Initializing FCWrapper wrapper data to use in lightning component
* Return Type  : FCWrapper
* Parameter    : String oppId 
**************************************************************************************************************/
    @auraEnabled
    public static FCWrapper initializeForecast(string oppId){
        try{
            FCWrapper fcWrap = new FCWrapper();
            if(Core_FC_Product_Schedule_Permission__c.getInstance(UserInfo.getUserId()).Id <> null){
                fcWrap.fcCustomSetting = Core_FC_Product_Schedule_Permission__c.getInstance(UserInfo.getUserId());
            }else if(Core_FC_Product_Schedule_Permission__c.getInstance(UserInfo.getProfileId()).Id <> null){
                fcWrap.fcCustomSetting = Core_FC_Product_Schedule_Permission__c.getInstance(UserInfo.getProfileId());
            }else{
                fcWrap.fcCustomSetting = Core_FC_Product_Schedule_Permission__c.getOrgDefaults();
            }
            
            Opportunity opp = getOpportunityRecord(oppId);
            List<Opportunity> oppRecList = new List<Opportunity>();
            oppRecList.add(opp);
            fcWrap.oppRecord = opp;
            //TWC3123-5731 Start
            User usRec = checkIfPartnerUser();
            if(usRec.Profile.Name.contains('Partner')){
                fcWrap.isPartnerUser = true;
            }
            else{
                fcWrap.isPartnerUser = false;          
            }
            //TWC3123-5731 End
            //TWC3123-5771 Start
            Boolean isOppLock = Core_CRM_Utility.lockOpportunity(oppRecList);
            fcWrap.isOppLocked = isOppLock; 
            //TWC3123-5771 End
            //TWC3123-5772 Start
            String checkTotalQty = checkTotalQuantity(oppId);
            fcwrap.totalQuantityError = checkTotalQty;
            //TWC3123-5772 End
            if(opp.Core_First_Customer_Ship_Date__c==null&&opp.Core_Opportunity_Type__c.contains('Design'))
                fcWrap.isFirstCustmerShipDateEmpty = false;
            else
                fcWrap.isFirstCustmerShipDateEmpty = true;
            
            //TWC3123-5959 - If PCC Deal, add OO's delegate as DelegateApproved - added if condition
            if(opp.Core_Opportunity_Coverage_Nm__c == 'Partner-Led Opportunity' && opp.Core_Coverage_Type_Nm__c == 'Deal Registration')
            {
                if(opp.Owner.DelegatedApproverId != null && String.valueOf(opp.Owner.DelegatedApproverId) != ''){
                    fcWrap.delegatedApprover = [SELECT id, name, email, isActive FROM User WHERE id = :opp.Owner.DelegatedApproverId];//TWC3123-5903
                }
            }
            else
            {
                if(opp.Owner.Manager.DelegatedApproverId != null && String.valueOf(opp.Owner.Manager.DelegatedApproverId) != ''){
                    fcWrap.delegatedApprover = [SELECT id, name, email, isActive FROM User WHERE id = :opp.Owner.Manager.DelegatedApproverId];
                }
            }
            if(opp.OwnerId == UserInfo.getUserId() || opp.Core_Technical_Owner__c == UserInfo.getUserId()){
                fcWrap.isOwner = true;
            }
            if(opp.Owner.ManagerId == null || String.valueOf(opp.Owner.ManagerId) == ''){
                fcWrap.noManager = true;
            }
            if((UserInfo.getUserId() == opp.Owner.ManagerId || (fcWrap.delegatedApprover <> null && UserInfo.getUserId() == fcWrap.delegatedApprover.Id)) && !fcWrap.noManager){
                fcWrap.isManager = true;
            }
            
            //TWC3123-5959 - assigned values to 3 new variables for PCC Oppty - TO, OO, OO delegate
            if(opp.Core_Technical_Owner__c == UserInfo.getUserId()){
                fcWrap.isTechnicalOwner = true;
            }
            
            if(fcWrap.delegatedApprover <> null && UserInfo.getUserId() == fcWrap.delegatedApprover.Id){
                fcWrap.isDelegateManagerPCC = true;
            }
            
            if(opp.OwnerId == UserInfo.getUserId()){
                fcWrap.isOwnerPCC = true;
            }
            Map<Id,OpportunityLineItem> oppLineItemMap = new Map<Id,OpportunityLineItem>([select Id, Product2.Name, Core_Vendor__r.Name, Core_Vendor__c, Core_Status__c,Quantity, SBQQ__QuoteLine__c, SBQQ__QuoteLine__r.Pricing_Status_Nm__c,Core_IsPCCOpportunity_cb__c from OpportunityLineItem where OpportunityId =: oppId]);
            if(!oppLineItemMap.isEmpty()){
                fcWrap.oppProductCount = oppLineItemMap.size();
                for(OpportunityLineItem oppProd : oppLineItemMap.values()){
                    if(lostCancelStatus.contains(oppProd.Core_Status__c)){
                        fcWrap.invalidProductCount = fcWrap.invalidProductCount + 1;
                    }
                }
            }
            fcWrap = prepareFCDisplayWrapper(getProdSortForecastMapMethod(oppId), oppLineItemMap, fcWrap);
            return fcWrap;
        }catch(Exception e){
            PMP_Utility.logError(e, 'ProdScheduleError');
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /*************************************************************************************************************
* Method name  : prepareFCDisplayWrapper
* Description  : Helper method
* Return Type  : FCWrapper
* Parameter    : Map<Id, List<Core_Opp_FC_Prod_Schedule__c>> fcRecordMap, Map<Id,OpportunityLineItem> oppLineItemMap, FCWrapper fcWrap 
**************************************************************************************************************/
    public static FCWrapper prepareFCDisplayWrapper(Map<Id, List<Core_Opp_FC_Prod_Schedule__c>> fcRecordMap, Map<Id,OpportunityLineItem> oppLineItemMap, FCWrapper fcWrap){
        fcWrap.quarterTotalMap = new Map<String, Double>();
        fcWrap.fcDisplayWrapList = new List<FCDisplayWrapper>();
        fcWrap.dummyFcDisplayWrapList = new List<FCDisplayWrapper>();
        fcWrap.quarterStatusSet = new Set<QuarterStatusWrapper>();
        fcWrap.dummyQuarterStatusSet = new Set<QuarterStatusWrapper>();
        Set<String> qtStatusSet = new Set<String>();
        FCDisplayWrapper fcDisplayWrap;
        FCDisplayWrapper dummyFcDisplayWrap;
        List<ScheduledWrapper> scheduledWrapList;
        ScheduledWrapper scheduledWrap;
        String totalColumnName = System.Label.Core_FC_ForecastedQuantity;
        Integer prodCount = 0;
        Integer count;
        String addQuarterName = null;
        //TWC4767-3570 Bypass 6QPS recall limit for approvers on Partner Deal Opportunities
        String PCCDealSwitch = System.Label.CRM_ShowPCC_SubmitForApproval_6QPS;
        for(String prodId : fcRecordMap.keySet()){
            fcDisplayWrap = new FCDisplayWrapper();
            dummyFcDisplayWrap = new FCDisplayWrapper();
            fcDisplayWrap.productName = fcRecordMap.get(prodId)[0].Core_Opp_FC_Product__r.Name;
            fcDisplayWrap.productQuantity = fcRecordMap.get(prodId)[0].Core_FC_Opportunity_Product__r.Quantity;
            dummyFcDisplayWrap.productName = fcDisplayWrap.productName;
            dummyFcDisplayWrap.productQuantity = fcRecordMap.get(prodId)[0].Core_FC_Opportunity_Product__r.Quantity;
            fcDisplayWrap.isPostWin = fcRecordMap.get(prodId)[0].Core_Is_Post_Win__c;
            dummyFcDisplayWrap.isPostWin = fcRecordMap.get(prodId)[0].Core_Is_Post_Win__c;
            fcDisplayWrap.isDeleteSelected = false;
            dummyFcDisplayWrap.isDeleteSelected = false;
            if(!fcDisplayWrap.isPostWin){
                fcDisplayWrap.canDelete = false;
                dummyFcDisplayWrap.canDelete = false;
            }else{
                fcDisplayWrap.canDelete = true;
                dummyFcDisplayWrap.canDelete = true;
            }
            fcDisplayWrap.productId = prodId;
            dummyFcDisplayWrap.productId = fcDisplayWrap.productId;
            if(oppLineItemMap.containskey(fcRecordMap.get(prodId)[0].Core_Opp_Line_Item_RecordID__c) || fcRecordMap.get(prodId)[0].Core_Is_Post_Win__c ){
                fcDisplayWrap.validProduct = true;
            }else{
                fcDisplayWrap.validProduct = false;
            }
            dummyFcDisplayWrap.validProduct = fcDisplayWrap.validProduct;
            fcDisplayWrap.vendorName = fcRecordMap.get(prodId)[0].Core_FC_Vendor__r.Name;
            dummyFcDisplayWrap.vendorName = fcDisplayWrap.vendorName;
            fcDisplayWrap.vendorId = fcRecordMap.get(prodId)[0].Core_FC_Vendor__c;
            dummyFcDisplayWrap.vendorId = fcDisplayWrap.vendorId;
            fcDisplayWrap.scheduledList = new List<ScheduledWrapper>();
            dummyFcDisplayWrap.scheduledList = new List<ScheduledWrapper>();
            fcDisplayWrap.totalQuantity = dummyFcDisplayWrap.totalQuantity = 0;
            fcDisplayWrap.totalRevenue = 0;
            count = 0;
            for(Core_Opp_FC_Prod_Schedule__c fc : fcRecordMap.get(prodId)){
                
                if(fc.Core_Opp_FC_Approval_Status__c == 'Approved' || fc.Core_Opp_FC_Approval_Status__c == 'Submitted')
                    if(fcDisplayWrap.isPostWin){
                        fcDisplayWrap.canDelete = false;
                        dummyFcDisplayWrap.canDelete = false;
                    }
                if(oppLineItemMap.containskey(prodId)){
                    scheduledWrap = new ScheduledWrapper(fc.Core_Opp_FC_Quantity__c, fc.Core_Opp_FC_Sched_Revenue__c, fc.Core_Opp_FC_Quarter__c, fc, oppLineItemMap.get(prodId));
                }else{
                    scheduledWrap = new ScheduledWrapper(fc.Core_Opp_FC_Quantity__c, fc.Core_Opp_FC_Sched_Revenue__c, fc.Core_Opp_FC_Quarter__c, fc, null);
                }
                fcDisplayWrap.scheduledList.add(scheduledWrap);
                
                
                if(fc.Core_Opp_FC_Quantity__c <> null && fc.Core_Opp_FC_Quantity__c > 0){
                    fcDisplayWrap.totalQuantity = fcDisplayWrap.totalQuantity + fc.Core_Opp_FC_Quantity__c;
                }
                if(fc.Core_Opp_FC_Sched_Revenue__c <> null && fc.Core_Opp_FC_Sched_Revenue__c > 0){
                    fcDisplayWrap.totalRevenue = fcDisplayWrap.totalRevenue + fc.Core_Opp_FC_Sched_Revenue__c;
                }
                if(fc.Core_FC_Last_Modified_Date__c <> null){
                    fcDisplayWrap.lastModifiedDate = fc.Core_FC_Last_Modified_Date__c;
                }
                if(fcWrap.quarterTotalMap.containskey(fc.Core_Opp_FC_Quarter__c)){
                    fcWrap.quarterTotalMap.put(fc.Core_Opp_FC_Quarter__c, fcWrap.quarterTotalMap.get(fc.Core_Opp_FC_Quarter__c) + fc.Core_Opp_FC_Sched_Revenue__c);
                }else{
                    fcWrap.quarterTotalMap.put(fc.Core_Opp_FC_Quarter__c, fc.Core_Opp_FC_Sched_Revenue__c);
                }
                if(prodCount == 0){
                    if(fc.Core_Opp_FC_Approval_Status__c <> null && !fc.Core_Opp_FC_Approval_Status__c.equalsIgnoreCase('Pending')){
                        fcWrap.quarterStatusSet.add(new QuarterStatusWrapper(fc.Core_Opp_FC_Quarter__c, fc.Core_Opp_FC_Approval_Status__c));
                        qtStatusSet.add(fc.Core_Opp_FC_Approval_Status__c);
                    }else{
                        fcWrap.quarterStatusSet.add(new QuarterStatusWrapper(fc.Core_Opp_FC_Quarter__c, 'noValue'));
                        qtStatusSet.add('noValue');
                    }
                }
                if(count == fcRecordMap.get(prodId).size() - 1 && addQuarterName == null){
                    addQuarterName = getQuarter(fc.Core_Opp_FC_Quarter_Date__c.addMonths(3));
                }
                count = count + 1;
            }
            dummyFcDisplayWrap.scheduledList = fcDisplayWrap.scheduledList.clone();
            if(oppLineItemMap.containskey(prodId)){
                dummyFcDisplayWrap.scheduledList.add(new ScheduledWrapper(0, 0, addQuarterName, null, oppLineItemMap.get(prodId)));
            }else{
                dummyFcDisplayWrap.scheduledList.add(new ScheduledWrapper(0, 0, addQuarterName, null, null));
            }
            dummyFcDisplayWrap.totalQuantity = fcDisplayWrap.totalQuantity;
            dummyFcDisplayWrap.lastModifiedDate = fcDisplayWrap.lastModifiedDate;
            if(fcWrap.quarterTotalMap.containskey(totalColumnName)){
                fcWrap.quarterTotalMap.put(totalColumnName, fcWrap.quarterTotalMap.get(totalColumnName) + fcDisplayWrap.totalRevenue);
            }else{
                fcWrap.quarterTotalMap.put(totalColumnName, fcDisplayWrap.totalRevenue);
            }
            fcWrap.fcDisplayWrapList.add(fcDisplayWrap);
            fcWrap.dummyFcDisplayWrapList.add(dummyFcDisplayWrap);
            prodCount = prodCount + 1;
        }
        
        if(fcWrap.oppProductCount > 0 && fcWrap.quarterStatusSet.size() < 20 && fcWrap.invalidProductCount <> fcWrap.oppProductCount){
            fcWrap.canAddQuarter = true;
        }
        if(qtStatusSet.contains('Approved') || qtStatusSet.contains('Submitted') || (fcWrap.oppProductCount > 0 && fcWrap.invalidProductCount == fcWrap.oppProductCount)){
            fcWrap.canSchedQuarter = false;
        }
        if(qtStatusSet.contains('noValue')  ){
            fcWrap.canEditQuarter = true;
        }
        if(qtStatusSet.contains('Submitted')){
            fcWrap.canSubmitQuarter = false;
            fcWrap.canAppRejQuarter = true;
        }
        if(fcWrap.canSubmitQuarter && !fcWrap.canEditQuarter){
            fcWrap.canSubmitQuarter = false;
        }
        if(qtStatusSet.contains('Approved') && !fcWrap.canRecallApproval){
            if(fcWrap.fcCustomSetting.Core_IsAdmin__c && (fcWrap.oppRecord.Core_FC_Recall_Count__c == null || fcWrap.oppRecord.Core_FC_Recall_Count__c < 2)){
                fcWrap.canRecallApproval = true;
            }
            //TWC4767-3570 Bypass 6QPS recall limit for approvers on Partner Deal Opportunities
            else if(PCCDealSwitch.equalsIgnoreCase('true') && fcWrap.oppRecord.Core_Opportunity_Coverage_Nm__c == 'Partner-Led Opportunity' && fcWrap.oppRecord.Core_Coverage_Type_Nm__c == 'Deal Registration'){
                fcWrap.canRecallApproval = true;
            }else if(!fcWrap.fcCustomSetting.Core_IsAdmin__c && (fcWrap.oppRecord.Core_FC_Recall_Count__c == null || fcWrap.oppRecord.Core_FC_Recall_Count__c == 0)){
                fcWrap.canRecallApproval = true;
            }else{
                fcWrap.canRecallApproval = false;
            }
        }
        
        fcWrap.dummyQuarterStatusSet = fcWrap.quarterStatusSet.clone();
        fcWrap.quarterStatusSet.add(new QuarterStatusWrapper(totalColumnName, 'noValue'));
        fcWrap.dummyQuarterStatusSet.add(new QuarterStatusWrapper(addQuarterName,'noValue'));
        fcWrap.dummyQuarterStatusSet.add(new QuarterStatusWrapper(totalColumnName, 'noValue'));
        
        return fcWrap;
    }
    
    /*************************************************************************************************************
* Method name  : getProdSortForecastMapMethod
* Description  : Query all the forecast record and sort by quarter name and group by opportunityLineItem id
* Return Type  : Map<Id, List<Core_Opp_FC_Prod_Schedule__c>>
* Parameter    : string oppId 
**************************************************************************************************************/
    public static Map<Id, List<Core_Opp_FC_Prod_Schedule__c>> getProdSortForecastMapMethod(string oppId){
        List<Core_Opp_FC_Prod_Schedule__c> tempList;
        Map<Id, List<Core_Opp_FC_Prod_Schedule__c>> prodSortForecastMap = new Map<Id, List<Core_Opp_FC_Prod_Schedule__c>>();
        for(Core_Opp_FC_Prod_Schedule__c fc : getAllForecast(oppId)){
            tempList = new List<Core_Opp_FC_Prod_Schedule__c>();
            if(prodSortForecastMap.get(fc.Core_Opp_Line_Item_RecordID__c) != null){
                tempList = prodSortForecastMap.get(fc.Core_Opp_Line_Item_RecordID__c);
                tempList.add(fc); 
                prodSortForecastMap.put(fc.Core_Opp_Line_Item_RecordID__c, tempList);
            }else{
                tempList.add(fc);
                prodSortForecastMap.put(fc.Core_Opp_Line_Item_RecordID__c, tempList);
            }      
        }
        return prodSortForecastMap;
    }
    
    /*************************************************************************************************************
* Method name  : getQuarter
* Description  : Identify quarter name using date
* Return Type  : String
* Parameter    : Date quarterDate 
**************************************************************************************************************/
    public static String getQuarter(Date quarterDate){
        String qtName = String.valueOf(quarterDate.year()) + '-';
        Integer tempQt = 0;
        if(quarterDate.month() <= 3){
            tempQt = 1;
        }else if(quarterDate.month() <= 6){
            tempQt = 2;
        }else if(quarterDate.month() <= 9){
            tempQt = 3;
        }else{
            tempQt = 4;
        }
        qtName = qtName + 'Q' + tempQt;
        return qtName;
    }
    
    /*************************************************************************************************************
* Method name  : saveAll
* Description  : This method is called from component on click of Save button for either 'Add Quarter' or 'Edit' function
* Return Type  : void
* Parameter    : String fcDisplayWrapStr, String dummyFcDisplayWrapStr, Opportunity opp, String actionType 
**************************************************************************************************************/
    @auraEnabled
    public static void saveAll(String fcDisplayWrapStr, String dummyFcDisplayWrapStr, Opportunity opp, String actionType){
        List<Core_Opp_FC_Prod_Schedule__c> fcList = new List<Core_Opp_FC_Prod_Schedule__c>();
        Core_Opp_FC_Prod_Schedule__c fcRec;
        List<FCDisplayWrapper> fcDisplayWrapList = (List<FCDisplayWrapper>)System.JSON.deserialize(fcDisplayWrapStr, List<FCDisplayWrapper>.class);
        List<FCDisplayWrapper> dummyFcDisplayWrapList = (List<FCDisplayWrapper>)System.JSON.deserialize(dummyFcDisplayWrapStr, List<FCDisplayWrapper>.class);
        List<FCDisplayWrapper> finalWrapList;
        Map<Id, Core_Opp_FC_Prod_Schedule__c> allForecastMap = new Map<Id, Core_Opp_FC_Prod_Schedule__c>(getAllForecast(opp.Id));
        if(actionType.equalsIgnoreCase('addQuarter')){
            finalWrapList = dummyFcDisplayWrapList;
        }else{
            finalWrapList = fcDisplayWrapList;
        }
        for(FCDisplayWrapper fcDisplayWrap : finalWrapList){
            for(ScheduledWrapper schdWrap : fcDisplayWrap.scheduledList){
                if(schdWrap.fcRecord <> null){
                    if(allForecastMap.containskey(schdWrap.fcRecord.Id) && allForecastMap.get(schdWrap.fcRecord.Id).Core_Opp_FC_Quantity__c <> schdWrap.scheduledQuantity){
                        
                        fcRec = new Core_Opp_FC_Prod_Schedule__c();
                        fcRec.Id = schdWrap.fcRecord.Id;
                        fcRec.Core_Opp_FC_Quantity__c = schdWrap.scheduledQuantity;
                        fcList.add(fcRec);
                    }
                }else{
                    fcRec = new Core_Opp_FC_Prod_Schedule__c();
                    fcRec.Core_Opp_FC_Opportunity__c = fcDisplayWrap.scheduledList[fcDisplayWrap.scheduledList.size()-2].fcRecord.Core_Opp_FC_Opportunity__c;
                    fcRec.Core_Opp_Line_Item_RecordID__c = fcDisplayWrap.scheduledList[fcDisplayWrap.scheduledList.size()-2].fcRecord.Core_Opp_Line_Item_RecordID__c;
                    fcRec.Core_Opp_FC_Product__c = fcDisplayWrap.scheduledList[fcDisplayWrap.scheduledList.size()-2].fcRecord.Core_Opp_FC_Product__c; 
                    fcRec.Core_FC_BU_Product_Segment__c = fcDisplayWrap.scheduledList[fcDisplayWrap.scheduledList.size()-2].fcRecord.Core_FC_BU_Product_Segment__c;
                    fcRec.Core_FC_BU_Short_Name__c = fcDisplayWrap.scheduledList[fcDisplayWrap.scheduledList.size()-2].fcRecord.Core_FC_BU_Short_Name__c;
                    if(fcDisplayWrap.isPostWin){
                        fcRec.Core_FC_Opportunity_Product__c = fcDisplayWrap.scheduledList[fcDisplayWrap.scheduledList.size()-2].fcRecord.Core_FC_Opportunity_Product__c;
                    }else{
                        fcRec.Core_FC_Opportunity_Product__c = fcDisplayWrap.scheduledList[fcDisplayWrap.scheduledList.size()-2].fcRecord.Core_Opp_Line_Item_RecordID__c;    
                    }
                    fcRec.Core_Is_Post_Win__c = fcDisplayWrap.isPostWin;
                    fcRec.Core_Opp_FC_Quarter_Date__c = fcDisplayWrap.scheduledList[fcDisplayWrap.scheduledList.size()-2].fcRecord.Core_Opp_FC_Quarter_Date__c.addMonths(3);
                    fcRec.Core_Opp_FC_Quantity__c = schdWrap.scheduledQuantity;
                    fcRec.Core_Opp_FC_isdeleted__c = fcDisplayWrap.scheduledList[fcDisplayWrap.scheduledList.size()-2].fcRecord.Core_Opp_FC_isdeleted__c;
                    fcRec.Core_FC_4Q_Shed_Quantity__c = fcDisplayWrap.scheduledList[fcDisplayWrap.scheduledList.size()-2].fcRecord.Core_FC_4Q_Shed_Quantity__c;
                    fcRec.Core_FC_Last_Modified_Date__c = null;
                    fcRec.Core_FC_Vendor__c = fcDisplayWrap.scheduledList[fcDisplayWrap.scheduledList.size()-2].fcRecord.Core_FC_Vendor__c;
                    fcRec.Core_Opp_FC_Prod_Sales_Price__c = fcDisplayWrap.scheduledList[fcDisplayWrap.scheduledList.size()-2].fcRecord.Core_Opp_FC_Prod_Sales_Price__c;
                    // added check to not populate pending status when a new quarter is added
                    if(schdWrap.oppProduct == null && (!actionType.equalsIgnoreCase('addQuarter'))){
                        fcRec.Core_Opp_FC_Approval_Status__c = 'Pending';
                    }
                    fcList.add(fcRec);
                }
            }
        }
        try{
            upsert fcList;
            if(actionType.equalsIgnoreCase('addQuarter')){
                Opportunity oppRec = new Opportunity();
                oppRec.Id = opp.Id;
                if(opp.Core_Number_of_Quarters__c == null || opp.Core_Number_of_Quarters__c == 0){
                    oppRec.Core_Number_of_Quarters__c = Integer.valueOf(System.label.Core_FC_NumberOfQuarter) + 1;
                }else{
                    oppRec.Core_Number_of_Quarters__c = opp.Core_Number_of_Quarters__c + 1;
                }
                update oppRec;
            }
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /*************************************************************************************************************
* Method name  : updateFCRecallCountInOpp
* Description  : This method used to reset the Core_FC_Recall_Count__c field value to 0 once a quarter is approved
* Return Type  : void
* Parameter    : Opportunity opp 
**************************************************************************************************************/
    public static void updateFCRecallCountInOpp(Opportunity opp){
        Opportunity obj = new Opportunity();
        obj.Id = opp.Id;
        obj.Core_FC_Recall_Count__c = 0;
        update obj;
    }
    
    /*************************************************************************************************************
* Method name  : submitQuarterForApproval
* Description  : This method is called to submit a quarter for approval
* Return Type  : String
* Parameter    : String fcDisplayWrapStr, String quarterStatusString, Opportunity opp, User delegatedApp 
**************************************************************************************************************/
    @auraEnabled
    public static String submitQuarterForApproval(String fcDisplayWrapStr, String quarterStatusString, Opportunity opp, User delegatedApp){
        try{
            Boolean isZeroQuantity = true;
            Set<ID> userIdSet= new Set<ID>();
            String quarterName = '';
            boolean inactiveUsercheck=false;
            quarterName = approveRejectFunction(fcDisplayWrapStr, quarterStatusString, 'noValue', 'Submitted');
            List<FCDisplayWrapper> fcDisplayWrapList = (List<FCDisplayWrapper>)System.JSON.deserialize(fcDisplayWrapStr, List<FCDisplayWrapper>.class);
            for(Integer i=0; i<fcDisplayWrapList.size(); i++){
                for(Integer j=0; j<fcDisplayWrapList[i].scheduledList.size(); j++){
                    if(quarterName <> '' && fcDisplayWrapList[i].scheduledList[j].quarterName.equalsIgnoreCase(quarterName) && fcDisplayWrapList[i].scheduledList[j].scheduledQuantity > 0){
                        isZeroQuantity = false;
                        j = fcDisplayWrapList[i].scheduledList.size();
                        i = fcDisplayWrapList.size();
                        break;
                    }
                }
            }
            //TWC3123-5903 6QPS Quarter Submission: Check for inactive OO Manager and OO Manager Delegate for Non-PCC Deal Opp and throw error
            
            if(delegatedApp != null ){                
                if(!delegatedApp.isActive  && !(opp.Core_Opportunity_Coverage_Nm__c == 'Partner-Led Opportunity' && opp.Core_Coverage_Type_Nm__c == 'Deal Registration') ){
                   inactiveUsercheck=true;   
                }  
            }
            if( (!opp.Owner.Manager.IsActive  ) && !(opp.Core_Opportunity_Coverage_Nm__c == 'Partner-Led Opportunity' && opp.Core_Coverage_Type_Nm__c == 'Deal Registration')){
                inactiveUsercheck=true;  
            }
            
            if(inactiveUsercheck){
                
                AuraHandledException e = new AuraHandledException(Label.Core_Inactive_Owner_Or_User_Message);
                e.setMessage(Label.Core_Inactive_Owner_Or_User_Message);
                throw e;
            } 
            
            
            if(inactiveUsercheck== false){
                if(quarterName <> ''){
                    if(isZeroQuantity){
                        approveRejectFunction(fcDisplayWrapStr, quarterStatusString, 'noValue', 'Approved');
                        updateFCRecallCountInOpp(opp);
                    }else{
                        List<String> toList = new List<String>();
                        List<String> ccList = new List<String>();
                        
                        //TWC3123-5959 - If PCC Deal oppty, send email to Opportunity Owner and their delegate instead of managers
                        if(opp.Core_Opportunity_Coverage_Nm__c == 'Partner-Led Opportunity' && opp.Core_Coverage_Type_Nm__c == 'Deal Registration')
                        {
                            if(opp.ownerId <> null){
                                userIdSet.add(opp.OwnerId);
                                toList.add(opp.owner.email);
                                sendEmail(toList, ccList, opp, quarterName);
                            }
                            
                            if(delegatedApp <> null){
                                userIdSet.add(delegatedApp.Id);
                                toList.add(delegatedApp.email);     
                            }
                        }
                        
                        else{
                            if(opp.owner.ManagerId <> null){
                                userIdSet.add(opp.owner.ManagerId);
                                toList.add(opp.owner.Manager.email);
                            }
                            if(opp.Core_Technical_Owner__r.ManagerId!= null){
                                userIdSet.add(opp.Core_Technical_Owner__r.ManagerId);
                                toList.add(opp.Core_Technical_Owner__r.Manager.email);
                            }
                            if(delegatedApp <> null){
                                userIdSet.add(delegatedApp.Id);
                                toList.add(delegatedApp.email);
                            }
                            ccList.add(opp.owner.email);
                            sendEmail(toList, ccList, opp, quarterName);
                        }
                    }
                    Map<Id,OpportunityShare> oppShareMap=new Map<Id,OpportunityShare>();
                    List<OpportunityShare> opptyShareList = new List<OpportunityShare>();
                    for(OpportunityShare oppUserShareList : [SELECT Id, OpportunityId, UserOrGroupId, OpportunityAccessLevel, RowCause FROM OpportunityShare WHERE OpportunityId = :opp.Id]){
                        oppShareMap.put(oppUserShareList.UserOrGroupId,oppUserShareList);
                    }
                    if(!userIdSet.isempty()){
                        for(Id usId : userIdSet){
                            if(!oppShareMap.containskey(usId)){
                                opptyShareList.add(new OpportunityShare(OpportunityId=opp.Id, UserOrGroupId=usId, OpportunityAccessLevel='Edit'));
                            }
                        }
                    }
                    if(!opptyShareList.isEmpty() && !test.isRunningTest()){
                        insert opptyShareList;
                    }
                }
            }
            
            return quarterName;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
    /*************************************************************************************************************
* Method name  : approveQuarters
* Description  : This method is called to approve a quarter
* Return Type  : String
* Parameter    : String fcDisplayWrapStr, String quarterStatusString, Opportunity opp 
**************************************************************************************************************/
    @auraEnabled
    public static String approveQuarters(String fcDisplayWrapStr, String quarterStatusString, Opportunity opp){
        try{
            String quarterName = '';
            quarterName = approveRejectFunction(fcDisplayWrapStr, quarterStatusString, 'Submitted', 'Approved');
            updateFCRecallCountInOpp(opp);
            return quarterName;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /*************************************************************************************************************
* Method name  : rejectQuarters
* Description  : This method is called to reject a quarter
* Return Type  : String
* Parameter    : String fcDisplayWrapStr, String quarterStatusString
**************************************************************************************************************/
    @auraEnabled
    public static String rejectQuarters(String fcDisplayWrapStr, String quarterStatusString){
        try{
            String quarterName = '';
            quarterName = approveRejectFunction(fcDisplayWrapStr, quarterStatusString, 'Submitted', '');
            return quarterName;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /*************************************************************************************************************
* Method name  : approveRejectFunction
* Description  : This is a helper method for approve or reject a quarter
* Return Type  : String
* Parameter    : String fcDisplayWrapStr, String quarterStatusString, String currentStatus, String nextStatus
**************************************************************************************************************/
    public static String approveRejectFunction(String fcDisplayWrapStr, String quarterStatusString, String currentStatus, String nextStatus){
        List<Core_Opp_FC_Prod_Schedule__c> fcList = new List<Core_Opp_FC_Prod_Schedule__c>();
        Core_Opp_FC_Prod_Schedule__c fcRec;
        Map<String, String> quarterStatusMap = new Map<String, String>();
        String quarterName = '';
        String prevQuarter = getQuarter(date.today().addMonths(-3));
        List<FCDisplayWrapper> fcDisplayWrapList = (List<FCDisplayWrapper>)System.JSON.deserialize(fcDisplayWrapStr, List<FCDisplayWrapper>.class);
        Set<QuarterStatusWrapper> quarterStatusSet = (Set<QuarterStatusWrapper>)System.JSON.deserialize(quarterStatusString, Set<QuarterStatusWrapper>.class);
        for(QuarterStatusWrapper qtStatus : quarterStatusSet){
            quarterStatusMap.put(qtStatus.quarterName, qtStatus.quarterStatus);
        }
        boolean flag = false;
        for(FCDisplayWrapper fcDisplayWrap : fcDisplayWrapList){
            flag = false;
            for(Integer i=0; i<fcDisplayWrap.scheduledList.size(); i++){
                if(quarterStatusMap.get(fcDisplayWrap.scheduledList[i].quarterName).equalsIgnoreCase(currentStatus)){
                    if(currentStatus.equalsIgnoreCase('noValue') && nextStatus.equalsIgnoreCase('Submitted')){
                        if(Integer.valueOf(fcDisplayWrap.scheduledList[i].quarterName.split('-')[0]) > Integer.valueOf(prevQuarter.split('-')[0]) 
                           || (Integer.valueOf(fcDisplayWrap.scheduledList[i].quarterName.split('-')[0]) == Integer.valueOf(prevQuarter.split('-')[0]) 
                               && (Integer.valueOf(fcDisplayWrap.scheduledList[i].quarterName.split('-Q')[1]) == Integer.valueOf(prevQuarter.split('-Q')[1]) ||
                                   Integer.valueOf(fcDisplayWrap.scheduledList[i].quarterName.split('-Q')[1]) > Integer.valueOf(prevQuarter.split('-Q')[1])))){
                                       flag = true;
                                   }else{
                                       
                                       fcRec = new Core_Opp_FC_Prod_Schedule__c();
                                       fcRec.Id = fcDisplayWrap.scheduledList[i].fcRecord.Id;
                                       fcRec.Core_Opp_FC_Approval_Status__c = 'Invalid';
                                       fcList.add(fcRec);
                                   }
                    }else{
                        flag = true;
                    }
                    if(flag){
                        if(quarterName == ''){
                            quarterName = fcDisplayWrap.scheduledList[i].quarterName;
                        }
                        fcRec = new Core_Opp_FC_Prod_Schedule__c();
                        fcRec.Id = fcDisplayWrap.scheduledList[i].fcRecord.Id;
                        fcRec.Core_Opp_FC_Approval_Status__c = nextStatus;
                        if(nextStatus.equalsIgnoreCase('Approved')){
                            fcRec.Core_Opp_FC_Approved_Date__c = system.now();
                        }
                        fcList.add(fcRec);
                        i = fcDisplayWrap.scheduledList.size();
                    }
                }
            }
        }
        if(nextStatus.equalsIgnoreCase('Submitted') || nextStatus.equalsIgnoreCase('Approved')){
            update fcList;
            Approval.lock(fcList,false);
        }else{
            Approval.unlock(fcList,false);
            update fcList;
        }
        return quarterName;
    }
    
    /*************************************************************************************************************
* Method name  : sendEmail
* Description  : This method is used to send email once a quarter is submitted for approval
* Return Type  : void
* Parameter    : List<String> toAddList, List<String> ccAddList, Opportunity opptyObj, String qtrSubmitted
**************************************************************************************************************/
    public static void sendEmail(List<String> toAddList, List<String> ccAddList, Opportunity opptyObj, String qtrSubmitted){
        String[] toAdd = new String[]{};
            String[] ccAdd = new String[]{};
                for(String str : toAddList){
                    toAdd.add(str);
                }
        for(String str1 : ccAddList){
            ccAdd.add(str1);
        }
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        if(toAdd !=null && !toAdd.isEmpty())
            email.setToAddresses(toAdd);
        if(ccAdd !=null && !ccAdd.isEmpty())
            email.setCcAddresses(ccAdd);         
        email.setSubject('6QPS approval request for '+qtrSubmitted+': '+String.valueOf(opptyObj.Name));
        
        Core_Sales_Opp_Internal_URL__mdt urlValue = [SELECT developerName, masterlabel, Core_Opp_URLValue__c FROM Core_Sales_Opp_Internal_URL__mdt WHERE developerName = 'Core_Url' LIMIT 1];
        String globalUrl = String.valueOf(urlValue.Core_Opp_URLValue__c);
        //TWC3123-5959 - If PCC Deal oppty, include Technical Owner name instead of Oppty Owner name
        if(opptyObj.Core_Opportunity_Coverage_Nm__c == 'Partner-Led Opportunity' && opptyObj.Core_Coverage_Type_Nm__c == 'Deal Registration')
        {
            email.setHtmlBody('Hello, <br/><br/>' + opptyObj.Core_Technical_Owner__r.Name + ', has requested for 6QPS approval for the below Opportunity.<br/><br/>' + 'Please look out for a task that has been created, you may go to the Activity Tab on the Opportunity page to view the details.<br/><br/>' + 'Account Name: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' + opptyObj.Account.name + '<br/>' + 'Opportunity Name: &nbsp;' + 
                              opptyObj.Name + '<br/><br/>' + 
                              globalUrl + '/' + opptyObj.Id + '<br/><br/>');
            
            email.setOrgWideEmailAddressId(ORGWIDE_EMAIL);
        }
        else{
            email.setHtmlBody('Hello, <br/><br/>'+opptyObj.Owner.Name+', has requested for 6QPS approval for the below Opportunity. <br/><br/> Account Name: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'+opptyObj.Account.name+'<br/> Opportunity Name: &nbsp;'+opptyObj.Name+'<br/><br/> '+globalUrl+'/'+opptyObj.Id+'<br/><br/>');  
        }
        
        try{
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        }catch(exception e){
            
            throw e;
        }
    }
    
    /*************************************************************************************************************
* Method name  : recallApproval
* Description  : This method is used to recall an approved quarter
* Return Type  : void
* Parameter    : Opportunity opp, String fcDisplayWrapString, String quarterStatusString
**************************************************************************************************************/
    @auraEnabled
    public static void recallApproval(Opportunity opp, String fcDisplayWrapString, String quarterStatusString){
        List<FCDisplayWrapper> fcDisplayWrapList = (List<FCDisplayWrapper>)System.JSON.deserialize(fcDisplayWrapString, List<FCDisplayWrapper>.class);
        Set<QuarterStatusWrapper> quarterStatusSet = (Set<QuarterStatusWrapper>)System.JSON.deserialize(quarterStatusString, Set<QuarterStatusWrapper>.class);
        List<Core_Opp_FC_Prod_Schedule__c> fcList = new List<Core_Opp_FC_Prod_Schedule__c>();
        Core_Opp_FC_Prod_Schedule__c fcRec;
        Map<String,String> quarterStatusMap = new Map<String,String>();
        for(QuarterStatusWrapper qtStatus : quarterStatusSet){
            quarterStatusMap.put(qtStatus.quarterName, qtStatus.quarterStatus);
        }
        for(FCDisplayWrapper fcDisplayWrap : fcDisplayWrapList){
            for(Integer i=fcDisplayWrap.scheduledList.size()-1; i>=0; i--){
                if(quarterStatusMap.get(fcDisplayWrap.scheduledList[i].quarterName).equalsIgnoreCase('Approved')){
                    fcRec = new Core_Opp_FC_Prod_Schedule__c();
                    fcRec.Id = fcDisplayWrap.scheduledList[i].fcRecord.Id;
                    fcRec.Core_Opp_FC_Approval_Status__c = '';
                    fcRec.Core_Forecast_Old_Claim_Date__c = fcDisplayWrap.scheduledList[i].fcRecord.Core_Opp_FC_Claim_Date__c;
                    fcRec.Core_Opp_FC_Claim_Date__c = null;
                    fcRec.Core_Opp_FC_Approved_Date__c = null;
                    fcRec.Core_Core_FC_Appvd_SalesPrice__c = null;
                    fcList.add(fcRec);
                    i = 0;
                }
            }
        }
        try{
            Approval.unlock(fcList,false);
            update fcList;
            Opportunity obj = new Opportunity();
            obj.Id = opp.Id;
            if(opp.Core_FC_Recall_Count__c == null){
                obj.Core_FC_Recall_Count__c = 1;
            }else{
                obj.Core_FC_Recall_Count__c = opp.Core_FC_Recall_Count__c + 1;
            }
            update obj;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @auraEnabled
    public static void deletePostWinProducts(List<String> listfcRec){
        try{
            
            List<Core_Opp_FC_Prod_Schedule__c> listFcProd = new List<Core_Opp_FC_Prod_Schedule__c>();
            for(Core_Opp_FC_Prod_Schedule__c fcRec:  [select id,Core_Opp_FC_isdeleted__c from Core_Opp_FC_Prod_Schedule__c where Core_Opp_Line_Item_RecordID__c in:listfcRec and Core_Opp_FC_isdeleted__c = false]){
                fcRec.Core_Opp_FC_isdeleted__c = true;
                listFcProd.add(fcRec);
            }
            
            update listFcProd;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @auraEnabled
    public static Boolean quarterAlignmentCheck(Id oppId){
        
        return Core_InactiveAccountonOpp.get6QPSData(oppId);
    }
    /*************************************************************************************************************
* Method name  : getQuarterEndDate
* Description  : This method is used to get Quarter End Date based on start date (TWC3123-5756)
* Return Type  : Boolean
* Parameter    : Id oppId
**************************************************************************************************************/ 
    public static Date getQuarterEndDate(Date quarterStartDate){
        Date quarterEndDate;
        if(quarterStartDate.month() == 1 || quarterStartDate.month() == 4 || quarterStartDate.month() == 7 || quarterStartDate.month() == 10){
            quarterEndDate = quarterStartDate.addmonths(3).toStartOfMonth().addDays(-1);
        }
        else if(quarterStartDate.month() == 2 || quarterStartDate.month() == 5 || quarterStartDate.month() == 8 || quarterStartDate.month() == 11){
            quarterEndDate = quarterStartDate.addmonths(2).toStartOfMonth().addDays(-1);
        }
        else if(quarterStartDate.month() == 3 || quarterStartDate.month() == 6 || quarterStartDate.month() == 9 || quarterStartDate.month() == 12){
            quarterEndDate = quarterStartDate.addmonths(1).toStartOfMonth().addDays(-1);
        }
        return quarterEndDate;
    }
    /*************************************************************************************************************
* Method name  : checkFCQuarterDate
* Description  : This method is used to check whether the quarter is in the price start and end dates (TWC3123-5756)
* Return Type  : Boolean
* Parameter    : Id oppId
**************************************************************************************************************/    
    //commented this method as part of TWC3123-6013
    /*
public static Boolean checkFCQuarterDate(Id oppId){
Boolean QuartersNotAligned = false;
Date quoteLineStart;
Date quoteLineEnd;
String qtr;
Date myStartDate;
List<Id> oliIdNotAlligned = new List<Id>();

Map<Id, List<Core_Opp_FC_Prod_Schedule__c>> allForecastSorted = getProdSortForecastMapMethod(oppId);

Map<Id,List<String>> qliQuarterMap = new Map<Id,List<String>>();

Map<Id,List<String>> fcQuarterMap = new Map<Id,List<String>>();

Map<Id,OpportunityLineItem> oppLineItemMap1 = new Map<Id,OpportunityLineItem>([select Id, Product2.Name, Core_QL_Start_Dt__c, Core_QL_End_Dt__c, Core_Vendor__r.Name, Core_Vendor__c, Core_Status__c,Quantity from OpportunityLineItem where OpportunityId =: oppId]);

for(Id oliId : oppLineItemMap1.keyset()){

List<String> tempList = new List<String>();

List<Core_Opp_FC_Prod_Schedule__c> fcRec = allForecastSorted.get(oliId);

for(Core_Opp_FC_Prod_Schedule__c fc : fcRec){

if(fcQuarterMap.get(fc.Core_Opp_Line_Item_RecordID__c) != null){

tempList = fcQuarterMap.get(fc.Core_Opp_Line_Item_RecordID__c);

tempList.add(fc.Core_Opp_FC_Quarter__c); 

fcQuarterMap.put(fc.Core_Opp_Line_Item_RecordID__c, tempList);

}else{

tempList.add(fc.Core_Opp_FC_Quarter__c);
fcQuarterMap.put(fc.Core_Opp_Line_Item_RecordID__c, tempList);
} 
}
}            

for(Id oliId : oppLineItemMap1.keyset()){

List<String> qliQtrList = new List<String>();
List<String> tempList1 = new List<String>();
quoteLineStart = oppLineItemMap1.get(oliId).Core_QL_Start_Dt__c;

if(quoteLineStart!=null){
quoteLineEnd = oppLineItemMap1.get(oliId).Core_QL_End_Dt__c;
myStartDate = quoteLineStart;       
while(myStartDate <= quoteLineEnd){
qtr = getQuarter(myStartDate);
qliQtrList.add(qtr);
myStartDate = getQuarterEndDate(myStartDate).addDays(1);
}

if(qliQuarterMap.containskey(oliId)){
tempList1 = qliQuarterMap.get(oliId);
tempList1.addAll(qliQtrList); 
qliQuarterMap.put(oliId, tempList1);   
}
else{
tempList1.addAll(qliQtrList);
qliQuarterMap.put(oliId, tempList1);      
} 

}  
}

for(Id oli : oppLineItemMap1.keyset()){
List<String> list1 = new List<String>();
List<String> list2 = new List<String>();
if(qliQuarterMap.containskey(oli)){                    
list1 = qliQuarterMap.get(oli);                    
list2 = fcQuarterMap.get(oli);                    
if(list1.size() == list2.size()){
list1.sort();
list2.sort();
if(!(list1.equals(list2))){
oliIdNotAlligned.add(oli);
}
}
else{
oliIdNotAlligned.add(oli);
}  
}
}

if(oliIdNotAlligned.size()>0){
QuartersNotAligned = true;
}

return QuartersNotAligned;

} 
*/
    
    
    // TWC3123-6080 - Devashish
    @auraEnabled
    public static List <Integer> checkQLDates(String fcDisplayWrapStr, String dummyFcDisplayWrapStr, Opportunity opp, String actionType, String comingFrom)
    {
        Date QLStartDate;
        Date QLEndDate;
        Date myStartDate;
        String Qtr;
        Boolean displayError = false;
        Integer i = 1;
        List <Integer> ProdNumberList = new List <Integer>();
        List <String> QLQtrList = new List <String> ();
        Map <Id, List <String>> OLIQtrMap = new Map <Id, List <String>> ();
        
        List<FCDisplayWrapper> fcDisplayWrapList = (List<FCDisplayWrapper>)System.JSON.deserialize(fcDisplayWrapStr, List<FCDisplayWrapper>.class);
        List<FCDisplayWrapper> dummyFcDisplayWrapList = (List<FCDisplayWrapper>)System.JSON.deserialize(dummyFcDisplayWrapStr, List<FCDisplayWrapper>.class);
        List<FCDisplayWrapper> finalWrapList;
        
        if(actionType.equalsIgnoreCase('addQuarter'))
        {
            finalWrapList = dummyFcDisplayWrapList;
        }
        else
        {
            finalWrapList = fcDisplayWrapList;
        }
        
        
        Map <Id, Core_Opp_FC_Prod_Schedule__c> allForecastMap = new Map <Id, Core_Opp_FC_Prod_Schedule__c> (getAllForecast(opp.Id));
        List <OpportunityLineItem> oliList = new List <OpportunityLineItem>([select Id, SBQQ__QuoteLine__c, SBQQ__QuoteLine__r.Pricing_Approved_End_Date_Dt__c, SBQQ__QuoteLine__r.Pricing_Approved_Start_Date_Dt__c, SBQQ__QuoteLine__r.Pricing_Status_Nm__c, Core_IsPCCOpportunity_cb__c, Product2.Name, Core_QL_Start_Dt__c, Core_QL_End_Dt__c, Core_Vendor__r.Name, Core_Vendor__c, Core_Status__c, Quantity from OpportunityLineItem where SBQQ__QuoteLine__c <> null AND SBQQ__QuoteLine__r.Pricing_Approved_Start_Date_Dt__c <> null AND SBQQ__QuoteLine__r.Pricing_Approved_End_Date_Dt__c <> null AND SBQQ__QuoteLine__r.Pricing_Status_Nm__c NOT IN('Rejected', 'Lost', 'Cancelled') AND OpportunityId =: opp.Id]);
        Set<Id> oliIds = (new Map<Id,SObject>(oliList)).keySet();
        
        for (OpportunityLineItem oli: oliList) {
            QLStartDate = oli.SBQQ__QuoteLine__r.Pricing_Approved_Start_Date_Dt__c;
            QLEndDate = oli.SBQQ__QuoteLine__r.Pricing_Approved_End_Date_Dt__c;
            myStartDate = QLStartDate;
            while (myStartDate <= QLEndDate) {
                Qtr = getQuarter(myStartDate);
                myStartDate = getQuarterEndDate(myStartDate).addDays(1);
                if (OLIQtrMap.containsKey(oli.Id)) {
                    OLIQtrMap.get(oli.id).add(Qtr);
                } else {
                    OLIQtrMap.put(oli.Id, new List <String> {Qtr});
                }
            }
        }
        
        for (FCDisplayWrapper fcDisplayWrap: finalWrapList) {
            for (ScheduledWrapper schdWrap: fcDisplayWrap.scheduledList) {
                List <String> QrtrList = OLIQtrMap.get(schdWrap.fcRecord.Core_Opp_Line_Item_RecordID__c);
                if (schdWrap.fcRecord <> null && allForecastMap.containskey(schdWrap.fcRecord.Id)) 
                {
                    if(allForecastMap.get(schdWrap.fcRecord.Id).Core_Opp_FC_Quantity__c != 0 && comingFrom == 'Submit'){
                        if (QrtrList != null) {
                            if (!QrtrList.contains(allForecastMap.get(schdWrap.fcRecord.Id).Core_Opp_FC_Quarter__c)) {
                                displayError = true;
                                if(!ProdNumberList.contains(i)){
                                    ProdNumberList.add(i);
                                }
                            }
                        }
                    }
                    else if(schdWrap.scheduledQuantity !=0 && comingFrom == 'Aura'){
                        if (QrtrList != null) {
                            if (!QrtrList.contains(allForecastMap.get(schdWrap.fcRecord.Id).Core_Opp_FC_Quarter__c)) {
                                displayError = true;
                                if(!ProdNumberList.contains(i)){
                                    ProdNumberList.add(i);
                                }
                            }
                        }
                    }
                }
                
                
                if (!(schdWrap.fcRecord <> null && allForecastMap.containskey(schdWrap.fcRecord.Id))) 
                {
                    if(schdWrap.oppProduct <> null){
                        if(OLIQtrMap.containsKey(schdWrap.oppProduct.Id)){
                            List<String> QrtrList2 = OLIQtrMap.get(schdWrap.oppProduct.Id);
                            if(oliIds != null && schdWrap.oppProduct != null && (!QrtrList2.contains(schdWrap.quarterName))){
                                if(oliIds.contains(schdWrap.oppProduct.Id))
                                {
                                    if(schdWrap.scheduledQuantity !=0 && comingFrom == 'Aura' && actionType=='addQuarter')
                                    {
                                        if(!ProdNumberList.contains(i))
                                        {
                                            ProdNumberList.add(i);
                                        }  
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            i = i + 1;
            displayError = false;
        }
        return ProdNumberList;
    }
    
    /*************************************************************************************************************
* Method name  : checkTotalQuantity
* Description  : This method is used to check whether the schedule Total quantity is greater than Product Quantity (TWC3123-5772)
* Return Type  : String
* Parameter    : Id oppId
**************************************************************************************************************/    
    
    public static String checkTotalQuantity(Id oppId){ 
        String strList = '';
        Integer count = 1;
        List<Core_Opp_FC_Prod_Schedule__c> tempList = new List<Core_Opp_FC_Prod_Schedule__c>();
        Map<Id,OpportunityLineItem> oppLineItemMap = new Map<Id,OpportunityLineItem>([select Id,Quantity,Core_IsPCCOpportunity_cb__c from OpportunityLineItem where OpportunityId =: oppId order by Id]);        
        Map<Id, List<Core_Opp_FC_Prod_Schedule__c>> allForecastSorted = getProdSortForecastMapMethod(oppId); 
        for(Id oliId : oppLineItemMap.keyset()){           
            Decimal total = 0;
            if(allForecastSorted.containsKey(oliId)){
                tempList = allForecastSorted.get(oliId);  
                for(Core_Opp_FC_Prod_Schedule__c fc : tempList){
                    total =total + fc.Core_Opp_FC_Quantity__c;
                }
            }
            if(total > oppLineItemMap.get(oliId).Quantity){
                if(strList ==''){
                    strList = 'Item#'+String.valueOf(count);                  
                }
                else{
                    strList = strList+'/Item#'+String.valueOf(count);                                      
                }
            }
            count++;
        } 
        return strList;
    }
    
    public static FCWrapper getFCWrapdata(String oppId){
        FCWrapper fcWrap = new FCWrapper();
        
        Map<Id,OpportunityLineItem> oppLineItemMap = new Map<Id,OpportunityLineItem>([select Id, Product2.Name, Core_Vendor__r.Name, Core_Vendor__c, Core_Status__c,Quantity, SBQQ__QuoteLine__c, SBQQ__QuoteLine__r.Pricing_Status_Nm__c,Core_IsPCCOpportunity_cb__c from OpportunityLineItem where OpportunityId =: oppId]);
        
        fcWrap = prepareFCDisplayWrapper(getProdSortForecastMapMethod(oppId), oppLineItemMap, fcWrap);
        
        return fcwrap ;
        
    }
    
    public class FCWrapper{
        
        @auraEnabled
        public Core_FC_Product_Schedule_Permission__c fcCustomSetting{get;set;}
        @auraEnabled
        public Opportunity oppRecord{get;set;}
        @auraEnabled
        public Integer oppProductCount{get;set;}
        @auraEnabled
        public Integer invalidProductCount{get;set;}
        @auraEnabled
        public User delegatedApprover{get;set;}
        @auraEnabled
        public Map<String, Double> quarterTotalMap{get;set;}
        @auraEnabled
        public List<FCDisplayWrapper> fcDisplayWrapList{get;set;}
        @auraEnabled
        public List<FCDisplayWrapper> dummyFcDisplayWrapList{get;set;}
        @auraEnabled
        public Set<QuarterStatusWrapper> quarterStatusSet{get;set;}
        @auraEnabled
        public Set<QuarterStatusWrapper> dummyQuarterStatusSet{get;set;}
        @auraEnabled
        public Boolean canSchedQuarter{get;set;}
        @auraEnabled
        public Boolean canAddQuarter{get;set;}
        @auraEnabled
        public Boolean canEditQuarter{get;set;}
        @auraEnabled
        public Boolean canSubmitQuarter{get;set;}
        @auraEnabled
        public Boolean canAppRejQuarter{get;set;}
        @auraEnabled
        public Boolean canRecallApproval{get;set;}
        @auraEnabled
        public Boolean isOwner{get;set;}
        @auraEnabled
        public Boolean noManager{get;set;}
        @auraEnabled
        public Boolean isManager{get;set;}
        @auraEnabled
        public Boolean isFirstCustmerShipDateEmpty{get;set;}
        @auraEnabled
        public Boolean isPartnerUser{get;set;}
        @auraEnabled
        public Boolean isOppLocked{get;set;}
        @auraEnabled
        public String totalQuantityError{get;set;}
        @auraEnabled
        public Boolean isTechnicalOwner{get;set;}
        @auraEnabled
        public Boolean isDelegateManagerPCC{get;set;}
        @auraEnabled
        public Boolean isOwnerPCC{get;set;}
        
        public FCWrapper(){
            this.fcCustomSetting = null;
            this.oppRecord = null;
            this.oppProductCount = 0;
            this.invalidProductCount = 0;
            this.delegatedApprover = null;
            this.quarterTotalMap = null;
            this.fcDisplayWrapList = null;
            this.dummyFcDisplayWrapList = null;
            this.quarterStatusSet = null;
            this.dummyQuarterStatusSet = null;
            this.canSchedQuarter = true;
            this.canAddQuarter = false;
            this.canEditQuarter = false;
            this.canSubmitQuarter = true;
            this.canAppRejQuarter = false;
            this.canRecallApproval = false;
            this.isOwner = false;
            this.noManager = false;
            this.isManager = false;
            this.isPartnerUser = false;
            this.isOppLocked = false;
            this.totalQuantityError = null;
            this.isTechnicalOwner = false;
            this.isDelegateManagerPCC = false;
            this.isOwnerPCC = false;
        }
    }
    
    public class FCDisplayWrapper{
        @auraEnabled
        public string productName{get;set;}
        @auraEnabled
        public Decimal productQuantity{get;set;}
        @auraEnabled
        public string productId{get;set;}
        @auraEnabled
        public boolean validProduct{get;set;}
        @auraEnabled
        public string vendorName{get;set;}
        @auraEnabled
        public string vendorId{get;set;}
        @auraEnabled
        public boolean isDeleteSelected{get;set;}
        @auraEnabled
        public boolean isPostWin{get;set;}
        @auraEnabled
        public boolean canDelete{get;set;}
        @auraEnabled
        public List<ScheduledWrapper> scheduledList{get;set;}
        @auraEnabled
        public Double totalQuantity{get;set;}
        @auraEnabled
        public Double totalRevenue{get;set;}
        @auraEnabled
        public Date lastModifiedDate{get;set;}
    }
    
    public class QuarterStatusWrapper{
        @auraEnabled
        public String quarterName{get;set;}
        @auraEnabled
        public String quarterStatus{get;set;}
        public QuarterStatusWrapper(String quarterName, String quarterStatus){
            this.quarterName = quarterName;
            this.quarterStatus = quarterStatus;
        }
    }
    
    public class ScheduledWrapper{
        @auraEnabled
        public Decimal scheduledQuantity{get;set;}
        @auraEnabled
        public Decimal scheduledRevenue{get;set;}
        @auraEnabled
        public String quarterName{get;set;}
        @auraEnabled
        public String access{get;set;}
        @auraEnabled
        public Core_Opp_FC_Prod_Schedule__c fcRecord{get;set;}
        @auraEnabled
        public opportunityLineItem oppProduct{get;set;}
        public ScheduledWrapper(Decimal scheduledQuantity, Decimal scheduledRevenue, String quarterName, Core_Opp_FC_Prod_Schedule__c fcRecord, opportunityLineItem oppProduct){
            if(scheduledQuantity <> null){
                this.scheduledQuantity = scheduledQuantity;
            }else{
                this.scheduledQuantity = 0;
            }
            if(scheduledRevenue <> null){
                this.scheduledRevenue = scheduledRevenue;
            }else{
                this.scheduledRevenue = 0;
            }
            this.quarterName = quarterName;
            this.fcRecord = fcRecord;
            this.oppProduct = oppProduct;
            if(fcRecord <> null && fcRecord.Core_Opp_FC_Approval_Status__c <> null && (fcRecord.Core_Opp_FC_Approval_Status__c.equalsIgnoreCase('Approved') || fcRecord.Core_Opp_FC_Approval_Status__c.equalsIgnoreCase('Submitted') || (fcRecord.Core_Opp_FC_Approval_Status__c.equalsIgnoreCase('Invalid') && fcRecord.Core_FC_Opportunity_Product__r.Core_IsPCCOpportunity_cb__c==false) || fcRecord.Core_Opp_FC_Approval_Status__c.equalsIgnoreCase('Pending'))){ //added Core_IsPCCOpportunity_cb__c -TWC3123-7036
                this.access = 'Read';
            }else{
                if((oppProduct == null && fcRecord!= null && !fcRecord.Core_Is_Post_Win__c)||(oppProduct <> null && lostCancelStatus.contains(oppProduct.Core_Status__c))){
                    this.access = 'Read';
                }else{
                    this.access = 'Edit';
                }
            }
        }
    }
}