/********************************************************************************************************************
Apex Class Name:  Core_FC_ProductSchedule_ExtController
Version      : 1.0 
Created Date : 11/21/14
Function     : Utility methods to handle OpportunityLineItem functions
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------
* Ashwin Dash               10/01/2017              Original Version
* Ashwin Dash               01/16/2018              US91359 : 6 Qtr Product Scheduler Enhancement -- adding Approval and Revenue.
* Ashwin Dash               02/07/2018              DE35729 : Corrected the email link and enabled Technical Owner to be able to Submit
* Ashwin Dash               02/12/2018              DE35986 : 6QPS accept Quantity with Comma and ensured negative values should not be added in quantity
* Ashwin Dash               04/03/2018              US102131 : 6QPS: Ensure Delegate Manager Can Approve 6QPS
* Ashwin Dash               11/27/2018              US229893 : LEx Enhancements
* Sougata Sarkar     		02/11/2019              US227105 : Clickjack : Vulnerable IPS securit,y Clickjack and Security Score Card
* Sougata Sarkar			02/18/2019              US231051 : 6QPS: Ability to recall 6QPS
*************************************************************************************/

public with sharing class Core_FC_ProductSchedule_ExtController {
    //Variables/collections Declaration
    public Opportunity opptyObj{get;set;}
    public Opportunity opptyObj1{get;set;}
    public User delegatedApp{get;set;}
    public List<displayWrapper> forecastTable{get;set;}
    public Map<Id, List<Core_Opp_FC_Prod_Schedule__c>> productSortedForecastMap{get;set;}
    public List<String> qtrNameList{get;set;}
    public List<String> colorList{get;set;}
    public boolean editAll{get;set;}
    public boolean showMoreRecords{get;set;}
    public List<Core_Opp_FC_Prod_Schedule__c> updateForeCastList{get;set;}
    public List<Core_Opp_FC_Prod_Schedule__c> insertForeCastList{get;set;}
    public boolean flag{get;set;}
    public boolean oliPresentFlag{get;set;}
    public static final Set<String> Core_Status = new Set<String>{'Lost','Cancelled','Deleted','On Hold','Production Lost','Production Cancelled'};
    public boolean clearFlag{get;set;}
    public boolean isOwner{get;set;}
    public boolean isManager{get;set;}
    public boolean isSubmitChk{get;set;}
    public boolean noManager{get;set;}
    public boolean isAllZero{get;set;}
    public boolean addQtrCheck{get;set;}
    public String qtrTobeSubmitted{get;set;}
    public List<String> qtrSubmitMsg{get;set;}
    public boolean isAddQuarter{get;set;}
    public boolean isAdmin{get;set;}
    public boolean isRecall{get;set;}
    public List<Core_Opp_FC_Prod_Schedule__c> lastApprovedProdList{get;set;}
    public boolean isClassic{get;set;}
    public boolean isNewPage{get;set;}
    
    //Constructor
    public Core_FC_ProductSchedule_ExtController(ApexPages.StandardController cont) {
        this.opptyObj = (Opportunity)cont.getRecord();
        //US102131 : 6QPS: Ensure Delegate Manager Can Approve 6QPS - Added Owner's manager's delegated approver -- Ashwin
        this.opptyObj1 = [SELECT id, Name, Core_FC_Recall_Count__c, OwnerId, Owner.Name, Account.Name, Owner.ManagerId, Owner.email, Owner.Manager.email, Owner.Manager.DelegatedApproverId, Owner.DelegatedApproverId, Core_Technical_Owner__c, Core_Technical_Owner__r.ManagerId, Core_Technical_Owner__r.Manager.email FROM Opportunity WHERE id = :opptyObj.Id LIMIT 1];
        this.qtrSubmitMsg = Label.Core_FC_SubmitMessage.split(';');
        if(opptyObj1.Owner.Manager.DelegatedApproverId != null && String.valueOf(opptyObj1.Owner.Manager.DelegatedApproverId) != '')
            delegatedApp = [SELECT id, name, email FROM User WHERE id = :opptyObj1.Owner.Manager.DelegatedApproverId LIMIT 1];
        else    
            delegatedApp = null;
        productSortedForecastMap = new Map<Id, List<Core_Opp_FC_Prod_Schedule__c>>();
        forecastTable = new List<displayWrapper>();
        oliPresentFlag = false;
        qtrNameList = new List<String>();
        colorList = new List<String>();
        editAll = false; 
        flag = false;
        isAddQuarter = false;
        showMoreRecords = false;  //Add logic to show a link to more records - future enhancement
        productSortedForecastMap = getProdSortForecastMapMethod();  //Populating ProductSortedForecastMap.
        if(UserInfo.getUserId() == opptyObj1.OwnerId || UserInfo.getUserId() == opptyObj1.Core_Technical_Owner__c){
            isOwner = true;
        }else{
            isOwner = false;
        }
        if(opptyObj1.Owner.ManagerId == null || String.valueOf(opptyObj1.Owner.ManagerId) == ''){
            noManager = true;
        }else{
            noManager = false;
        }
        if((UserInfo.getUserId() == opptyObj1.Owner.ManagerId || (delegatedApp != null && UserInfo.getUserId() == delegatedApp.Id)) && !noManager){
            isManager = true;
        }else{
            isManager = false;
        }
        if(!productSortedForecastMap.isEmpty()){
            forecastTable = getDispWrapperTableMethod(productSortedForecastMap, qtrNameList);
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,System.Label.Core_FC_No_6QPS_Message));
            List<OpportunityLineItem> oliPresentList = [SELECT id, Quantity, OpportunityId FROM OpportunityLineItem WHERE OpportunityId = :opptyObj.Id];
            if(!oliPresentList.isEmpty()){
                oliPresentFlag = true;
            }
        }       
        Map<String, List<Core_Opp_FC_Prod_Schedule__c>> qtrFCMap = getQtrSortedForecastRec(qtrNameList, productSortedForecastMap);
        if(isSubmittedQuarter(qtrFCMap)){
            isSubmitChk = true;
        }else{
            isSubmitChk = false;
        }
        
        //US231051 : Recall button visibility check start
        isAdmin = false;
        List<String> profileNames = Label.Core_Profiles_Recall_2nd_last_approved_FC.split(',');
        List<Profile> profileList = [select Id, Name from Profile where Name IN: profileNames];
        for(Profile prof : profileList){
            if(prof.id == UserInfo.getProfileId()){
                isAdmin = true;
            }
        }
        boolean isApprovedFC = getIsApprovedFC(productSortedForecastMap);
        if(isApprovedFC){
            if(isAdmin && (opptyObj1.Core_FC_Recall_Count__c == null || opptyObj1.Core_FC_Recall_Count__c < 2)){
                isRecall = true;
            }else if(!isAdmin && (opptyObj1.Core_FC_Recall_Count__c == null || opptyObj1.Core_FC_Recall_Count__c == 0)){
                isRecall = true;
            }else{
                isRecall = false;
            }
        }else{
            isRecall = false;
        }
        //US231051 : Recall button visibility check end
        
        if(isAllZeroQuantity(qtrFCMap)){
            isAllZero = true;
        }else{
            isAllZero = false;
        }
        if(checkAddQuarter(qtrFCMap)){
            addQtrCheck = true;
        }else{
            addQtrCheck = false;
        }
        qtrTobeSubmitted = '';
        //START : Changes for US229893 : LEx Enhancements - Ashwin
        String editMode = ApexPages.currentPage().getParameters().get('edit');
        if(editMode == 'true'){
            editAll = true;
        }
		//END : Changes for US229893 : LEx Enhancements - Ashwin
		
        //US227105 : Clickjack : Vulnerable IPS securit,y Clickjack and Security Score Card - Start
        String isQuarter = 'false';
        isQuarter = ApexPages.currentPage().getParameters().get('isAddQuarter');
        if(isQuarter == 'true'){
            isAddQuarter = true;
        }
        
        isClassic = false;
        if(UserInfo.getUiThemeDisplayed() == 'Theme3'){
            isClassic = true;
        }
        
        isNewPage = false;
        String isNew = ApexPages.currentPage().getParameters().get('isNew');
        if(isNew == 'TRUE'){
            isNewPage = true;
        }
        //US227105 : Clickjack : Vulnerable IPS securit,y Clickjack and Security Score Card - End
    }
    
    //Redirect to Opportunity record page
    public PageReference redirectToOppRec(){
        PageReference pgRef = new PageReference('/'+opptyObj1.Id);
        pgRef.setRedirect(true);
        return pgRef;
    }
    
    //US231051 : 6QPS: Ability to recall 6QPS - Start
    //Check if any approved Quarter is available
    public boolean getIsApprovedFC(Map<Id,List<Core_Opp_FC_Prod_Schedule__c>> fcProdMap){
        boolean isApproved = false;
        Core_Opp_FC_Prod_Schedule__c lastAppProd = new Core_Opp_FC_Prod_Schedule__c();
        lastApprovedProdList = new List<Core_Opp_FC_Prod_Schedule__c>();
        for(Integer i=0; i<fcProdMap.keyset().size(); i++){
            lastAppProd = new Core_Opp_FC_Prod_Schedule__c();
            for(Core_Opp_FC_Prod_Schedule__c fcProd : fcProdMap.values()[i]){
                if(fcProd.Core_Opp_FC_Approval_Status__c <> null && fcProd.Core_Opp_FC_Approval_Status__c.equalsIgnoreCase('approved')){
                    isApproved = true;
                    lastAppProd = fcProd;
                }else if(fcProd.Core_Opp_FC_Approval_Status__c <> null && fcProd.Core_Opp_FC_Approval_Status__c.equalsIgnoreCase('submitted')){
                    isApproved = false;
                    i = fcProdMap.values().size();
                    break;
                }
            }
            lastApprovedProdList.add(lastAppProd);
            system.debug('lastAppProdList '+lastApprovedProdList);
        }
        return isApproved;
    }
    
    //Recall last approved quarter
    public pageReference recallLastApprovedFC(){
        updateAppRejClass appRejObj = new updateAppRejClass();
                
        List<Core_Opp_FC_Prod_Schedule__c> fcProdList = new List<Core_Opp_FC_Prod_Schedule__c>();
        for(Core_Opp_FC_Prod_Schedule__c fcProd : lastApprovedProdList){
            Core_Opp_FC_Prod_Schedule__c fcProduct = new Core_Opp_FC_Prod_Schedule__c();
            fcProduct.Id = fcProd.Id;
            fcProduct.Core_Opp_FC_Approval_Status__c = '';
            fcProduct.Core_Forecast_Old_Claim_Date__c = fcProd.Core_Opp_FC_Claim_Date__c;
            fcProduct.Core_Opp_FC_Claim_Date__c = null;
            fcProduct.Core_Opp_FC_Approved_Date__c = null;
            fcProduct.Core_Core_FC_Appvd_SalesPrice__c = null;
            fcProdList.add(fcProduct);
        }
        appRejObj.reject(fcProdList);
        Opportunity obj = new Opportunity();
        obj.Id = opptyObj1.Id;
        if(opptyObj1.Core_FC_Recall_Count__c == null){
            obj.Core_FC_Recall_Count__c = 1;
        }else{
            obj.Core_FC_Recall_Count__c = opptyObj1.Core_FC_Recall_Count__c + 1;
        }
        update obj;
        String globalUrl = String.valueOf(System.URL.getSalesforceBaseUrl().toExternalForm());
        PageReference pgRef;
        pgRef = new PageReference(globalUrl+'/apex/Core_FC_Product_Schedule?id='+obj.Id);
        pgRef.setRedirect(true);
        if(isClassic){
            return null;
        }else{
            return pgRef;
        }
    }
    //US231051 : 6QPS: Ability to recall 6QPS - End
    
    public boolean isSubmittedQuarter(Map<String, List<Core_Opp_FC_Prod_Schedule__c>> qtrFCMap){
        for(String str : qtrFCMap.keySet()){
            for(Core_Opp_FC_Prod_Schedule__c fc1 : qtrFCMap.get(str)){
                if(fc1.Core_Opp_FC_Approval_Status__c == 'Submitted'){
                    return true;
                }
            }
        }
        return false;
    }   
    
    public boolean checkAddQuarter(Map<String, List<Core_Opp_FC_Prod_Schedule__c>> qtrFCMap){
        Map<String, Set<boolean>> quarterApproveMap = new Map<String, Set<boolean>>();
        for(String str : qtrFCMap.keySet()){
            Set<boolean> tempSet = new Set<boolean>();
            for(Core_Opp_FC_Prod_Schedule__c fc1 : qtrFCMap.get(str)){
                if(fc1.Core_Opp_FC_Approval_Status__c != 'Approved'){
                    if(quarterApproveMap.get(str) != null){
                        tempSet = quarterApproveMap.get(str);
                        tempSet.add(true);
                        quarterApproveMap.put(str, tempSet);
                    }else{
                        tempSet.add(true);
                        quarterApproveMap.put(str, tempSet);
                    }
                }else{
                    if(quarterApproveMap.get(str) != null){
                        tempSet = quarterApproveMap.get(str);
                        tempSet.add(false);
                        quarterApproveMap.put(str, tempSet);
                    }else{
                        tempSet.add(false);
                        quarterApproveMap.put(str, tempSet);
                    }
                }
            }
        }
        for(String str : quarterApproveMap.keySet()){
            if(quarterApproveMap.get(str).contains(false)){
                return false;
            }
        }
        return true;
    }
    
    public boolean isAllZeroQuantity(Map<String, List<Core_Opp_FC_Prod_Schedule__c>> qtrFCMap){
        Map<String, Set<boolean>> quarterZeroMap = new Map<String, Set<boolean>>();
        for(String str : qtrFCMap.keySet()){
            Set<boolean> tempSet = new Set<boolean>();
            for(Core_Opp_FC_Prod_Schedule__c fc1 : qtrFCMap.get(str)){
                if(fc1.Core_Opp_FC_Quantity__c == 0){
                    if(quarterZeroMap.get(str) != null){
                        tempSet = quarterZeroMap.get(str);
                        tempSet.add(true);
                        quarterZeroMap.put(str, tempSet);
                    }else{
                        tempSet.add(true);
                        quarterZeroMap.put(str, tempSet);
                    }
                }else{
                    if(quarterZeroMap.get(str) != null){
                        tempSet = quarterZeroMap.get(str);
                        tempSet.add(false);
                        quarterZeroMap.put(str, tempSet);
                    }else{
                        tempSet.add(false);
                        quarterZeroMap.put(str, tempSet);
                    }
                }
            }
        }
        for(String str : quarterZeroMap.keySet()){
            if(quarterZeroMap.get(str).contains(false)){
                return false;
            }
        }
        return true;
    }
    //Cleanup Task to be performed before loading any opportunity Page
    public void deleteAllBlankQuantity(){
        Id oppObjId = ApexPages.currentPage().getParameters().get('Id');
        if(oppObjId != null){
            List<Core_Opp_FC_Prod_Schedule__c> updateIsDeleted = [SELECT id, Name, Core_Opp_FC_isdeleted__c, lastModifiedDate FROM Core_Opp_FC_Prod_Schedule__c WHERE Core_Opp_FC_Opportunity__c = :oppObjId AND Core_Opp_FC_isdeleted__c = true ORDER BY lastModifiedDate DESC];
            List<Core_Opp_FC_Prod_Schedule__c> deleteBlankQty = [SELECT id, Name, Core_Opp_FC_isdeleted__c, Core_Opp_FC_Quantity__c, lastModifiedDate FROM Core_Opp_FC_Prod_Schedule__c WHERE Core_Opp_FC_Opportunity__c = :oppObjId AND Core_Opp_FC_isdeleted__c = false AND Core_Opp_FC_Quantity__c = null ORDER BY lastModifiedDate DESC];
            Integer size = deleteBlankQty.size();
            if(size != null && size > 0){
                System.debug('$$$ delete -'+deleteBlankQty);
                for(Integer i=0; i<size; i++){
                    updateIsDeleted[i].Core_Opp_FC_isdeleted__c = false;
                }           
                delete deleteBlankQty;
                update updateIsDeleted;         
                qtrNameList = new List<String>();
                productSortedForecastMap = getProdSortForecastMapMethod();  //Populating ProductSortedForecastMap. 
                if(!productSortedForecastMap.isEmpty()){
                    forecastTable = getDispWrapperTableMethod(productSortedForecastMap, qtrNameList);
                }
            }
        }
        addQuarterMethod();
    }
    
    public pageReference editAllMethod(){
        //editAll = true;
	//START : Changes for US229893 : LEx Enhancements open Edit in fresh page - Ashwin
        String globalUrl = String.valueOf(System.URL.getSalesforceBaseUrl().toExternalForm());
        PageReference pgRef = new PageReference(globalUrl+'/apex/Core_FC_Product_Schedule?id='+opptyObj.Id+'&edit=true');
        pgRef.setRedirect(true);
        if(isClassic){
            return null;
        }else{
            return pgRef;
        }
	//END : Changes for US229893 : LEx Enhancements open Edit in fresh page - Ashwin
    }
    public PageReference cancelMethod(){
        editAll = false;
        updateAppRejClass appRejObj = new updateAppRejClass();
        if(flag){
            System.debug('### Deleted List - '+insertForeCastList);
            if(!insertForeCastList.isEmpty()){
                try{
                    delete insertForeCastList;
                }catch(exception e){
                    
                }
            }
            for(Core_Opp_FC_Prod_Schedule__c fc : updateForeCastList){
                fc.Core_Opp_FC_isdeleted__c = false;
            }
            appRejObj.approve(updateForeCastList);
            //update updateForeCastList;
            qtrNameList = new List<String>();
            Map<Id, List<Core_Opp_FC_Prod_Schedule__c>> psFCMap =  getProdSortForecastMapMethod(); 
            forecastTable = getDispWrapperTableMethod(psFCMap, qtrNameList);    
        }
        flag = false;
        String globalUrl = String.valueOf(System.URL.getSalesforceBaseUrl().toExternalForm());
        PageReference pgRef = new PageReference(globalUrl+'/apex/Core_FC_Product_Schedule?id='+opptyObj.Id+'&isNew=true');
        System.debug('***Pg - '+pgRef);
        pgRef.setRedirect(true);
        return pgRef;
    }
    
    //Populating the productSortedForecastMap with OpportunityLineItem Id in the Key and list of ForecastWrapper in the value which are inturn sorted with quarter dates
    //ForecastWrapper will contain the object of Core_Opp_FC_Prod_Schedule__c 
    public Map<Id, List<Core_Opp_FC_Prod_Schedule__c>> getProdSortForecastMapMethod(){     
        List<Core_Opp_FC_Prod_Schedule__c> tempList;
        Map<Id, List<Core_Opp_FC_Prod_Schedule__c>> prodSortForecastMap = new Map<Id, List<Core_Opp_FC_Prod_Schedule__c>>();
        for(Core_Opp_FC_Prod_Schedule__c fc : [SELECT id, Core_Opp_FC_Claim_Date__c, Core_Forecast_Old_Claim_Date__c, Core_Opp_FC_Opportunity__c, Core_Opp_Line_Item_RecordID__c, Core_Opp_FC_Product__c, Core_Opp_FC_Product__r.Name, Core_Opp_FC_Quarter_Date__c, Core_Opp_FC_Quarter__c, Core_Opp_FC_Quantity__c, Core_Opp_FC_isdeleted__c, lastModifiedDate, createdDate, Core_FC_4Q_Shed_Quantity__c, Core_FC_Last_Modified_Date__c, Core_FC_BU_Short_Name__c, Core_FC_Vendor__c, Core_Opp_FC_Approval_Status__c, Core_Opp_FC_Approved_Date__c, Core_Core_FC_Appvd_SalesPrice__c, Core_Opp_FC_Prod_Sales_Price__c, Core_Opp_FC_Sched_Revenue__c FROM Core_Opp_FC_Prod_Schedule__c WHERE Core_Opp_FC_Opportunity__c = :opptyObj.Id AND Core_Opp_FC_isdeleted__c = false ORDER BY Core_Opp_FC_Product__r.Name,Core_Opp_FC_Quarter_Date__c]){
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
        System.debug('*** ProdMap - '+prodSortForecastMap);
        return prodSortForecastMap;
    }
    
    //Populate the displayWrapper List to contain the list of forecastWrapper to be displayed in table in the page.
    public List<displayWrapper> getDispWrapperTableMethod(Map<Id, List<Core_Opp_FC_Prod_Schedule__c>> prodSortForecastMap,List<String>qNameList){
        List<displayWrapper> fcTable = new List<displayWrapper>();
        Integer count = 0;
        Set<String> quarterNameSet = new Set<String>();
        Set<String> colorNameSet = new Set<String>();
        displayWrapper dw;
        //Populating the displayWrapper class for displaying the table in the vfpage 
        if(!prodSortForecastMap.isEmpty()){
            for(Id item : prodSortForecastMap.keyset()){           
                List<String> quarterNameList1 = new List<String>();   
                List<String> colorNameList = new List<String>();  
                Set<String> tempSet = new Set<String>();
                Integer ccount = 1;
                List<Core_Opp_FC_Prod_Schedule__c> fcList = new List<Core_Opp_FC_Prod_Schedule__c>();
                Integer iCol = 1;
                for(Core_Opp_FC_Prod_Schedule__c fc : prodSortForecastMap.get(item)){
                    quarterNameList1.add(fc.Core_Opp_FC_Quarter__c);
                    if(fc.Core_Opp_FC_Approval_Status__c == 'Approved'){
                        colorNameList.add('green'+icol);
                    }else if(fc.Core_Opp_FC_Approval_Status__c == 'Submitted'){
                        colorNameList.add('submitted'+icol);
                    }else if(fc.Core_Opp_FC_Approval_Status__c == 'Pending'){
                        colorNameList.add('pending'+icol);
                    }else{
                        colorNameList.add('none'+icol);
                    }
                    fcList.add(fc);
                    iCol++;
                }
                dw = new displayWrapper(fcList);
                fcTable.add(dw);
                quarterNameSet.addAll(quarterNameList1);
                if(colorNameSet != null && !colorNameSet.isEmpty()){
                    for(Integer i=0; i<colorNameList.size(); i++){
                        if(colorNameSet.contains(colorNameList[i])){
                            tempSet.add(colorNameList[i]);
                        }else if(colorNameList[i].containsIgnoreCase('pending')){
                            if(colorNameSet.contains('submitted'+ccount) && !tempSet.contains('submitted'+ccount)){
                                //tempSet.add(colorNameList[i]);
                                tempSet.add('submitted'+ccount);
                            }else{
                                tempSet.add('none'+ccount);
                            }
                        }else if(colorNameList[i].containsIgnoreCase('submitted')){
                            tempSet.add(colorNameList[i]);
                        }else if(colorNameList[i].containsIgnoreCase('green')){
                            tempSet.add('green'+ccount);
                        }else{
                            tempSet.add('none'+ccount);
                        }
                        ccount++;
                    }
                    colorNameSet = tempSet;
                }else{
                    colorNameSet.addAll(colorNameList);
                }
            }
        }
        qNameList.addAll(quarterNameSet);
        colorList.addAll(colorNameSet);
        System.debug('***--- Color '+colorList);
        return fcTable;     
    }
    
    public PageReference saveAllMethod(){    
        editAll = false;
        Integer count = 0;
        List<Core_Opp_FC_Prod_Schedule__c> updateFCList = new List<Core_Opp_FC_Prod_Schedule__c>();
        List<Core_Opp_FC_Prod_Schedule__c> updateFCList1 = new List<Core_Opp_FC_Prod_Schedule__c>();
        Set<Id> oliIdSet = new Set<Id>();
        Map<Id, Core_Opp_FC_Prod_Schedule__c> updateFCMap = new Map<Id, Core_Opp_FC_Prod_Schedule__c>();
        Set<String> oliSet = new Set<String>();
        for(displayWrapper dw : forecastTable){
            for(Integer i=0; i<dw.fcObjList.size(); i++){
                String modValue = dw.viewQuantityList[i].remove(',');
                if((dw.fcObjList[i].Core_Opp_FC_Quantity__c == null && dw.viewQuantityList[i] == '' ) || (modValue).trim() == '' || !isNumeric(modValue) || Decimal.valueOf(modValue).precision() > 10){
                    count++;
                    continue;
                }
                //if((productSortedForecastMap1.get(dw.fcObjList[i].Core_Opp_Line_Item_RecordID__c))[i].fcObj.Core_Opp_FC_Quantity__c != dw.fcObjList[i].Core_Opp_FC_Quantity__c){
                
                if((String.valueOf(dw.fcObjList[i].Core_Opp_FC_Quantity__c) != modValue) || flag){
                    dw.fcObjList[i].Core_Opp_FC_Quantity__c = (Decimal.valueOf(modValue.trim())).round(System.RoundingMode.HALF_UP);
                    dw.fcObjList[i].Core_FC_Last_Modified_Date__c = System.Today();
                    updateFCList.add(dw.fcObjList[i]);
                    oliSet.add(dw.fcObjList[i].Core_Opp_Line_Item_RecordID__c);
                    updateFCMap.put(dw.fcObjList[i].Id, dw.fcObjList[i]);
                }                   
            }
        }
        if(count>0){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please fill in correct values for the empty Product schedule quantities.'));
            editAll = true;
            return null;
        }
        if(!updateFCList.isEmpty()){
            for(displayWrapper dw1 : forecastTable){
                for(Core_Opp_FC_Prod_Schedule__c fc1 : dw1.fcObjList){
                    if(updateFCMap.get(fc1.Id) == null &&  oliSet.contains(fc1.Core_Opp_Line_Item_RecordID__c)){
                        fc1.Core_FC_Last_Modified_Date__c = System.Today();
                        updateFCList.add(fc1);
                    }
                }
            }
            for(Core_Opp_FC_Prod_Schedule__c fc : updateFCList){
                oliIdSet.add(fc.Core_Opp_Line_Item_RecordID__c);
            }
            Map<Id, OpportunityLineItem> oliFCMap = new Map<Id, OpportunityLineItem>([SELECT id, quantity, Core_Status__c FROM OpportunityLineItem WHERE id IN :oliIdSet]);
            for(Core_Opp_FC_Prod_Schedule__c fc : updateFCList){
                if(oliFCMap.get(fc.Core_Opp_Line_Item_RecordID__c) != null && !Core_Status.contains(oliFCMap.get(fc.Core_Opp_Line_Item_RecordID__c).Core_Status__c) && !Approval.isLocked(fc)){
                    updateFCList1.add(fc);
                }else if(oliFCMap.get(fc.Core_Opp_Line_Item_RecordID__c) != null && Core_Status.contains(oliFCMap.get(fc.Core_Opp_Line_Item_RecordID__c).Core_Status__c) && !Approval.isLocked(fc)){
                    fc.Core_Opp_FC_Quantity__c = 0;
                    updateFCList1.add(fc);
                }
            }
            try{
                update updateFCList1;
            }catch(Exception e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
                return null;
            }
        }
        qtrNameList = new List<String>();
        forecastTable = new List<displayWrapper>();
        Map<Id, List<Core_Opp_FC_Prod_Schedule__c>> psFCMap =  getProdSortForecastMapMethod(); 
        forecastTable = getDispWrapperTableMethod(psFCMap, qtrNameList);
        System.debug('### New Table Values - '+forecastTable);  
        //PageReference pgRef = ApexPages.CurrentPage();
        String globalUrl = String.valueOf(System.URL.getSalesforceBaseUrl().toExternalForm());
        PageReference pgRef = new PageReference(globalUrl+'/apex/Core_FC_Product_Schedule?id='+opptyObj.Id);
        pgRef.setRedirect(true);
        if(isClassic){
            return null;
        }else{
            return pgRef;
        }
    }
    
    public void addQuarterMethod(){
        if(isAddQuarter){
            if(isSubmitChk || addQtrCheck){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,qtrSubmitMsg[1]));
                return;
            }
            editAll = true;
            flag = true;
            updateAppRejClass appRejObj = new updateAppRejClass();
            updateForeCastList = new List<Core_Opp_FC_Prod_Schedule__c>();
            insertForeCastList = new List<Core_Opp_FC_Prod_Schedule__c>();
            Set<Id> fcIdSet = new Set<Id>();
            List<Core_Opp_FC_Prod_Schedule__c> toLockRecords = new List<Core_Opp_FC_Prod_Schedule__c>();
            Integer num = Integer.valueOf(System.Label.Core_FC_NumberOfQuarter) - 1;
            for(Id item : productSortedForecastMap.keyset()){
                Core_Opp_FC_Prod_Schedule__c fcObject = productSortedForecastMap.get(item)[0];
                fcObject.Core_Opp_FC_isdeleted__c = true;
                updateForeCastList.add(fcObject);
                Core_Opp_FC_Prod_Schedule__c fcObject1 = new Core_Opp_FC_Prod_Schedule__c();
                fcObject1.Core_Opp_FC_Opportunity__c = productSortedForecastMap.get(item)[num].Core_Opp_FC_Opportunity__c;
                fcObject1.Core_Opp_Line_Item_RecordID__c = productSortedForecastMap.get(item)[num].Core_Opp_Line_Item_RecordID__c;
                fcObject1.Core_Opp_FC_Product__c = productSortedForecastMap.get(item)[num].Core_Opp_FC_Product__c;
                fcObject1.Core_Opp_FC_Quarter_Date__c = productSortedForecastMap.get(item)[num].Core_Opp_FC_Quarter_Date__c.addMonths(3);
                fcObject1.Core_Opp_FC_Quantity__c = null;
                //Added for deletion of product
                if(productSortedForecastMap.get(item)[num].Core_Opp_FC_Approval_Status__c == 'Pending'){
                    fcObject1.Core_Opp_FC_Quantity__c = 0;
                    fcObject1.Core_Opp_FC_Approval_Status__c = 'Pending';
                }
                fcObject1.Core_Opp_FC_isdeleted__c = productSortedForecastMap.get(item)[num].Core_Opp_FC_isdeleted__c;
                fcObject1.Core_FC_4Q_Shed_Quantity__c = productSortedForecastMap.get(item)[num].Core_FC_4Q_Shed_Quantity__c;
                fcObject1.Core_FC_Last_Modified_Date__c = null;
                fcObject1.Core_FC_Vendor__c = productSortedForecastMap.get(item)[num].Core_FC_Vendor__c;
                fcObject1.Core_Opp_FC_Prod_Sales_Price__c = productSortedForecastMap.get(item)[num].Core_Opp_FC_Prod_Sales_Price__c;
                insertForeCastList.add(fcObject1);
            }       
            Integer count1 = 0;
            String excpt = '';
            if(!insertForeCastList.isEmpty()){
                try{
                    Database.SaveResult[] srList = Database.insert(insertForeCastList);  //insert insertForeCastList;
                    for (Database.SaveResult sr : srList){
                        fcIdSet.add(sr.getId());
                    }
                    if(!fcIdSet.isEmpty()){
                        for(Core_Opp_FC_Prod_Schedule__c fc1 : [SELECT id, Name, Core_Opp_FC_Approval_Status__c FROM Core_Opp_FC_Prod_Schedule__c WHERE Id IN : fcIdSet]){
                            if(fc1.Core_Opp_FC_Approval_Status__c == 'Pending'){
                                toLockRecords.add(fc1);
                            }
                        }
                        Approval.LockResult[] lrList = Approval.lock(toLockRecords,false);
                    }
                }Catch(Exception e){
                    System.debug('Insert Exception - '+e.getMessage());
                    excpt = e.getMessage();
                    count1++;
                }
            }
            if(count1 > 0){
                editAll = false;
                flag = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,excpt));
                return;
            }
            if(!updateForeCastList.isEmpty()){
                //update updateForeCastList;
                appRejObj.approve(updateForeCastList);
            }
            System.debug('*** return not working');
            qtrNameList = new List<String>();
            Map<Id, List<Core_Opp_FC_Prod_Schedule__c>> psFCMap =  getProdSortForecastMapMethod(); 
            forecastTable = getDispWrapperTableMethod(psFCMap, qtrNameList);        
            System.debug('$$$ New Table Values - '+forecastTable);
        }
    }
    
    public Boolean isNumeric(String s){
        Boolean ReturnValue;
        try{
            if(s.containsIgnoreCase(',')){
                s = s.remove(',');
            }
            Decimal.valueOf(s);
            if(s.charAt(0) == 45){
                ReturnValue = FALSE;
            }else{
                ReturnValue = TRUE; 
            }
        }catch(Exception e){
            ReturnValue = FALSE;
        }
        return ReturnValue;
    }
    
    public PageReference migrate6QPSMethod(){
        List<OpportunityLineItem> oliPresentMap = [SELECT id, Quantity, OpportunityId, Core_Vendor__c, Core_Status__c, Product2Id FROM OpportunityLineItem WHERE OpportunityId = :opptyObj.Id];
        Core_OpportunityLineItemHandler.insertForecastRecords(oliPresentMap, true);
        String globalUrl = String.valueOf(System.URL.getSalesforceBaseUrl().toExternalForm());
        PageReference pgRef = new PageReference(globalUrl+'/apex/Core_FC_Product_Schedule?id='+opptyObj.Id);
        pgRef.setRedirect(true);
        if(isClassic){
            return null;
        }else{
            return pgRef;
        }
    }
    
    public PageReference clearQuantities(){
        qtrNameList = new List<String>();
        Map<Id, List<Core_Opp_FC_Prod_Schedule__c>> psFCMap =  getProdSortForecastMapMethod(); 
        forecastTable = getDispWrapperTableMethod(psFCMap, qtrNameList); 
        List<displayWrapper> tempForecastTable =  new List<displayWrapper>();
        for(displayWrapper dw : forecastTable){
            for(Integer i=0; i<6; i++){
                if(!Approval.isLocked(dw.fcObjList[i])){
                    dw.viewQuantityList[i] = '0';
                }
            }
            tempForecastTable.add(dw);
        }   
        forecastTable.clear();
        forecastTable.addAll(tempForecastTable);
        return null;
    }
    
    public Map<String, List<Core_Opp_FC_Prod_Schedule__c>> getQtrSortedForecastRec(List<String> qtrList, Map<Id, List<Core_Opp_FC_Prod_Schedule__c>> psfMap){       
        Map<String, List<Core_Opp_FC_Prod_Schedule__c>> qFCMap = new Map<String, List<Core_Opp_FC_Prod_Schedule__c>>();
        for(String qtr : qtrList){  
            for(Id oliId : psfMap.keySet()){
                for(Core_Opp_FC_Prod_Schedule__c fc : psfMap.get(oliId)){
                    List<Core_Opp_FC_Prod_Schedule__c> tempFcList = new List<Core_Opp_FC_Prod_Schedule__c>();
                    if(fc.Core_Opp_FC_Quarter__c == qtr){
                        if(qFCMap.get(qtr) != null){
                            tempFcList = qFCMap.get(qtr);
                            tempFcList.add(fc);
                            qFCMap.put(qtr,tempFcList);
                        }else{
                            tempFcList.add(fc);
                            qFCMap.put(qtr,tempFcList);
                        }
                    }
                }
            }
        }
        return qFCMap;
    }
    
    public PageReference submitForApproval(){
        Integer numOfForecast = Integer.valueOf(Label.Core_FC_NumberOfQuarter);
        Set<String> quarterSet = new Set<String>();
        List<Core_Opp_FC_Prod_Schedule__c> lockRecord = new List<Core_Opp_FC_Prod_Schedule__c>();       
        List<String> toList = new List<String>();
        List<String> ccList = new List<String>();
        Map<String, List<Core_Opp_FC_Prod_Schedule__c>> qtrVsForecastMap = getQtrSortedForecastRec(qtrNameList, productSortedForecastMap);
        List<OpportunityShare> opptyShareList = new List<OpportunityShare>();
        List<OpportunityShare> delegateUserShareList = new List<OpportunityShare>();
        updateAppRejClass appRejObj = new updateAppRejClass();
        
        if(delegatedApp != null){
            delegateUserShareList = [SELECT Id, OpportunityId, UserOrGroupId, OpportunityAccessLevel, RowCause FROM OpportunityShare WHERE UserOrGroupId = :delegatedApp.Id AND OpportunityId = :opptyObj1.Id];
        }       
        
        if((delegateUserShareList == null || delegateUserShareList.isEmpty()) && opptyObj1 != null && delegatedApp != null){
            opptyShareList.add(new OpportunityShare(OpportunityId=opptyObj1.Id, UserOrGroupId=delegatedApp.Id, OpportunityAccessLevel='Edit'));
            appRejObj.insertOpptyShare(opptyShareList);         
        }
        
        if(noManager){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'The submitter has No Manager.'));
            return null;
        }       
        if(!qtrVsForecastMap.isEmpty()){
            for(String qtr : qtrVsForecastMap.keySet()){
                Integer check = 0;
                Integer nxtQtrCheck = 0;
                //if(checkNoFalseRecords(qtrVsForecastMap.get(qtr)[0].Core_Opp_Line_Item_RecordID__c)){
                List<Core_Opp_FC_Prod_Schedule__c> tempList1 = new List<Core_Opp_FC_Prod_Schedule__c>();    
                List<Core_Opp_FC_Prod_Schedule__c> tempList2 = new List<Core_Opp_FC_Prod_Schedule__c>();                    
                for(Core_Opp_FC_Prod_Schedule__c fcQtr : qtrVsForecastMap.get(qtr)){
                    if((fcQtr.Core_Opp_FC_Quantity__c == 0 && fcQtr.Core_Opp_FC_Approval_Status__c != 'Approved' )){ //(checkLessThanThisQuarter(fcQtr.Core_Opp_FC_Quarter_Date__c) && fcQtr.Core_Opp_FC_Quantity__c == 0 && !Approval.isLocked(fcQtr.Id)) || !Approval.isLocked(fcQtr.Id) &&
                        check++;
                        if(fcQtr.Core_Opp_FC_Approval_Status__c != 'Pending'){
                            fcQtr.Core_Opp_FC_Approval_Status__c = 'Submitted';
                        }
                        tempList1.add(fcQtr);
                        tempList2.add(fcQtr);
                    }else if(fcQtr.Core_Opp_FC_Approval_Status__c != 'Submitted' && !Approval.isLocked(fcQtr.Id) && fcQtr.Core_Opp_FC_Approval_Status__c != 'Approved'){
                        fcQtr.Core_Opp_FC_Approval_Status__c = 'Submitted';
                        tempList2.add(fcQtr);
                    }
                }
                if(check >= qtrVsForecastMap.get(qtr).size()){
                    Integer tcount = 0;
                    for(Core_Opp_FC_Prod_Schedule__c fc2 : tempList1){
                        if(!Approval.isLocked(fc2.Id)){
                            fc2.Core_Opp_FC_Approval_Status__c = 'Approved';                            
                        }
                        for(Core_Opp_FC_Prod_Schedule__c fc3 : tempList2){                          
                            if(fc3.Id == fc2.Id){
                                break;
                            }
                            tcount++;
                        }
                        //tcount = tempList2.indexOf(fc2);
                        tempList2.remove(tcount);
                    }
                    lockRecord.addAll(tempList1);
                    
                }           
                if(!tempList2.isEmpty()){                   
                    //lockRecord.addAll(tempList2);             
                    for(Core_Opp_FC_Prod_Schedule__c fc3 : tempList2){
                        if(fc3.Core_Opp_FC_Approval_Status__c != 'Pending'){
                            qtrTobeSubmitted = fc3.Core_Opp_FC_Quarter__c;
                            lockRecord.add(fc3);
                            nxtQtrCheck++;
                        }                   
                    }
                }
                if(nxtQtrCheck >0){
                    break;
                }
                //}
            }
            toList.add(opptyObj1.owner.Manager.email);
            if(delegatedApp != null){
                toList.add(delegatedApp.email);
            }
            System.debug('***toList- '+toList);
            ccList.add(opptyObj1.owner.email);
            System.debug('****ccList- '+ccList);
            System.debug('****LockRecord- '+lockRecord);
            Savepoint sp = Database.setSavepoint();
            try{
                if(!lockRecord.isEmpty()){                  
                    appRejObj.submitApprove(lockRecord);
                    //update lockRecord;
                    sendEmail(toList, ccList, opptyObj1, qtrTobeSubmitted);                 
                }               
            }catch(Exception ex){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
                Database.rollback(sp);
                Approval.UnLockResult[] lrList = Approval.unlock(lockRecord,false);
                return null;
            }
        }
        String globalUrl = String.valueOf(System.URL.getSalesforceBaseUrl().toExternalForm());
        PageReference pgRef = new PageReference(globalUrl+'/apex/Core_FC_Product_Schedule?id='+opptyObj.Id);
        pgRef.setRedirect(true);
        if(isClassic){
            return null;
        }else{
            return pgRef;
        }
    }
    
    
    public void sendEmail(List<String> toAddList, List<String> ccAddList, Opportunity opptyObj, String qtrSubmitted){
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
        //String globalUrl = String.valueOf(System.URL.getSalesforceBaseUrl().toExternalForm());
        Core_Sales_Opp_Internal_URL__mdt urlValue = [SELECT developerName, masterlabel, Core_Opp_URLValue__c FROM Core_Sales_Opp_Internal_URL__mdt WHERE developerName = 'Core_Url' LIMIT 1];
        String globalUrl = String.valueOf(urlValue.Core_Opp_URLValue__c);
        email.setHtmlBody('Hello, <br/><br/>'+opptyObj.Owner.Name+', has requested for 6QPS approval for the below Opportunity. <br/><br/> Account Name: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'+opptyObj.Account.name+'<br/> Opportunity Name: &nbsp;'+opptyObj.Name+'<br/><br/> '+globalUrl+'/'+opptyObj.Id+'<br/><br/>');
        try{
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        }catch(exception e){
            System.debug('***Exception caught - '+e.getMessage());
            throw e;
        }
    }
    
    public PageReference approvalMethod(){
        Map<String, List<Core_Opp_FC_Prod_Schedule__c>> qtrFCMap1 = getQtrSortedForecastRec(qtrNameList, productSortedForecastMap);
        List<Core_Opp_FC_Prod_Schedule__c> tobeApprovedList = new List<Core_Opp_FC_Prod_Schedule__c>();
        updateAppRejClass appRejObj = new updateAppRejClass();
        
        for(String qtr : qtrFCMap1.keySet()){
            for(Core_Opp_FC_Prod_Schedule__c fc : qtrFCMap1.get(qtr)){
                if(Approval.isLocked(fc.Id) && fc.Core_Opp_FC_Approval_Status__c == 'Submitted'){
                    fc.Core_Opp_FC_Approval_Status__c = 'Approved';
                    fc.Core_Opp_FC_Approved_Date__c = System.Now();
                    fc.Core_Core_FC_Appvd_SalesPrice__c = fc.Core_Opp_FC_Prod_Sales_Price__c;
                    tobeApprovedList.add(fc);
                }
            }
        }
        if(!tobeApprovedList.isEmpty()){
            //update tobeApprovedList;
            appRejObj.approve(tobeApprovedList);
            //Decreased the FC Recall Count in opportunity
            Opportunity obj = new Opportunity();
            obj.Id = opptyObj1.Id;
            obj.Core_FC_Recall_Count__c = 0;
            update obj;
        }
        String globalUrl = String.valueOf(System.URL.getSalesforceBaseUrl().toExternalForm());
        PageReference pgRef = new PageReference(globalUrl+'/apex/Core_FC_Product_Schedule?id='+opptyObj.Id);
        pgRef.setRedirect(true);
        if(isClassic){
            return null;
        }else{
            return pgRef;
        }
    }
    
    public PageReference rejectionMethod(){
        Map<String, List<Core_Opp_FC_Prod_Schedule__c>> qtrFCMap1 = getQtrSortedForecastRec(qtrNameList, productSortedForecastMap);
        List<Core_Opp_FC_Prod_Schedule__c> tobeRejectedList = new List<Core_Opp_FC_Prod_Schedule__c>();
        updateAppRejClass appRejObj = new updateAppRejClass();
        
        for(String qtr : qtrFCMap1.keySet()){
            for(Core_Opp_FC_Prod_Schedule__c fc : qtrFCMap1.get(qtr)){
                if(Approval.isLocked(fc.Id) && fc.Core_Opp_FC_Approval_Status__c == 'Submitted'){
                    //Approval.unlock(fc,false);
                    fc.Core_Opp_FC_Approval_Status__c = '';
                    tobeRejectedList.add(fc);
                }
            }
        }
        if(!tobeRejectedList.isEmpty()){
            //update tobeRejectedList;
            appRejObj.reject(tobeRejectedList);
        }
        String globalUrl = String.valueOf(System.URL.getSalesforceBaseUrl().toExternalForm());
        PageReference pgRef = new PageReference(globalUrl+'/apex/Core_FC_Product_Schedule?id='+opptyObj.Id);
        pgRef.setRedirect(true);
        if(isClassic){
            return null;
        }else{
            return pgRef;
        }
    }
    
    /*public boolean checkNoFalseRecords(Id oliId){
        List<Core_Opp_FC_Prod_Schedule__c> checkList = [SELECT id, Core_Opp_FC_isdeleted__c FROM Core_Opp_FC_Prod_Schedule__c WHERE Core_Opp_Line_Item_RecordID__c = :oliId AND Core_Opp_FC_isdeleted__c = true];
        if(checkList == null || checkList.isEmpty()){
            return true;
        }else{
            return false;
        }
        return false;
    }*/
    
    public class displayWrapper{
        //public Decimal forecastedQuantity{get;set;}
        public List<Core_Opp_FC_Prod_Schedule__c> fcObjList{get;set;}
        public List<String> viewQuantityList{get;set;}
        ////US91359 : 6 Qtr Product Scheduler Enhancement -added 2 List & Object below to store Revenue, Quantity & totalRevenue info -- Ashwin.
        public List<String> schedQRList{get;set;}
        public List<revenueQuantityWrapper> schedQtyRevList{get;set;}
        public revenueQuantityWrapper totalQtyRev{get;set;}

        
        public displayWrapper(List<Core_Opp_FC_Prod_Schedule__c> fcObjList){
            //this.forecastedQuantity = countTotalQuantity(fcObjList);
            this.totalQtyRev = countTotalQuantity(fcObjList);
            this.fcObjList = fcObjList;
            this.viewQuantityList = new List<String>();
            this.schedQRList = new List<String>();
            this.schedQtyRevList = new List<revenueQuantityWrapper>();
            this.schedQRList.add(Label.Core_FC_ForecastQuantity);
            this.schedQRList.add(Label.Core_FC_ForecastRevenue);
            for(Core_Opp_FC_Prod_Schedule__c fcq : fcObjList){  
                if(fcq.Core_Opp_FC_Quantity__c == null){
                    this.viewQuantityList.add('');
                    if(fcq.Core_Opp_FC_Sched_Revenue__c == null){
                        this.schedQtyRevList.add(new revenueQuantityWrapper(0, 0));
                    }else{
                        this.schedQtyRevList.add(new revenueQuantityWrapper(0, fcq.Core_Opp_FC_Sched_Revenue__c));
                    }
                }else{
                    this.viewQuantityList.add(String.valueOf(fcq.Core_Opp_FC_Quantity__c));
                    if(fcq.Core_Opp_FC_Sched_Revenue__c == null){
                        this.schedQtyRevList.add(new revenueQuantityWrapper(fcq.Core_Opp_FC_Quantity__c, 0));
                    }else{
                        this.schedQtyRevList.add(new revenueQuantityWrapper(fcq.Core_Opp_FC_Quantity__c, fcq.Core_Opp_FC_Sched_Revenue__c));
                    }
                }
            }
        }
        
        //US91359 : 6 Qtr Product Scheduler Enhancement - adding Approval and Revenue -- Ashwin.
        //public Decimal countTotalQuantity(List<Core_Opp_FC_Prod_Schedule__c> fcQty){
        public revenueQuantityWrapper countTotalQuantity(List<Core_Opp_FC_Prod_Schedule__c> fcQty){
            Decimal sum = 0;
            Decimal revSum = 0;
            for(Integer i = 0; i<6; i++){ //changed to 0 from 2 so that it will calculate all 6 quarters value
                if(fcQty[i].Core_Opp_FC_Quantity__c != null && String.valueOf(fcQty[i].Core_Opp_FC_Quantity__c) != ''){
                    sum = sum+(Decimal)fcQty[i].Core_Opp_FC_Quantity__c;
                }
                if(fcQty[i].Core_Opp_FC_Sched_Revenue__c != null){
                    revSum = revSum+(decimal)fcQty[i].Core_Opp_FC_Sched_Revenue__c;
                }               
            }
            revenueQuantityWrapper tqrObj = new revenueQuantityWrapper(sum, revSum);
            for(Core_Opp_FC_Prod_Schedule__c fc : fcQty){
                fc.Core_FC_4Q_Shed_Quantity__c = sum;
                fc.Core_FC_4Q_Shed_Revenue__c = revsum;
            }
            //return sum;
            return tqrObj;
        }
    }
    
    //US91359 : 6 Qtr Product Scheduler Enhancement - adding Approval and Revenue -- Ashwin.
    //Wrapper class for storing Revenue and Quantity
    public class revenueQuantityWrapper{
        public List<qtyOrRevWrapper> revenueQtyList{get;set;}
        
        public revenueQuantityWrapper(Decimal qty, Decimal rev){
            this.revenueQtyList = new List<qtyOrRevWrapper>();
            qtyOrRevWrapper q1 = new qtyOrRevWrapper(qty, true);
            this.revenueQtyList.add(q1);
            qtyOrRevWrapper q2 = new qtyOrRevWrapper(rev, false);
            this.revenueQtyList.add(q2);
        }
    }
    
    public class qtyOrRevWrapper{
        public Decimal value{get;set;}
        public boolean isQuantity{get;set;}
        
        public qtyOrRevWrapper(Decimal qtyRev, boolean isQty){
            this.value=qtyRev;
            this.isQuantity = isQty;
        }
    }
    
    public without Sharing class updateAppRejClass{
        public void approve(List<Core_Opp_FC_Prod_Schedule__c> appList){
            update appList;
        }       
        public void submitApprove(List<Core_Opp_FC_Prod_Schedule__c> subList){
            try{
                update subList;
                Approval.lock(subList,false);
            }catch(Exception e){
                throw e;
            }
        }
        public void reject(List<Core_Opp_FC_Prod_Schedule__c> appList){
            Approval.unlock(appList,false);
            update appList;
        }
        public void insertOpptyShare(List<OpportunityShare> shareList){
            insert shareList;
        }
    }   
}