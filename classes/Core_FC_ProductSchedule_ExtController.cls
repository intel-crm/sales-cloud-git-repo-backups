public with sharing class Core_FC_ProductSchedule_ExtController {
    //Variables/collections Declaration
    public Opportunity opptyObj{get;set;}
    public List<displayWrapper> forecastTable{get;set;}
    public Map<Id, List<Core_Opp_FC_Prod_Schedule__c>> productSortedForecastMap{get;set;}
    public List<String> qtrNameList{get;set;}
    public boolean editAll{get;set;}
    public boolean showMoreRecords{get;set;}
    public List<Core_Opp_FC_Prod_Schedule__c> updateForeCastList{get;set;}
    public List<Core_Opp_FC_Prod_Schedule__c> insertForeCastList{get;set;}
    public boolean flag{get;set;}
    public boolean oliPresentFlag{get;set;}
    public static final Set<String> Core_Status = new Set<String>{'Lost','Cancelled','Deleted','On Hold','Production Lost','Production Cancelled'};
    public boolean clearFlag{get;set;}
    
    //Constructor
    public Core_FC_ProductSchedule_ExtController(ApexPages.StandardController cont) {
        this.opptyObj = (Opportunity)cont.getRecord();
        productSortedForecastMap = new Map<Id, List<Core_Opp_FC_Prod_Schedule__c>>();
        forecastTable = new List<displayWrapper>();
        oliPresentFlag = false;
        qtrNameList = new List<String>();
        editAll = false; 
        flag = false;
        List<OpportunityLineItem> oliPresentList;
        showMoreRecords = false;  //Add logic to show a link to more records - future enhancement
        productSortedForecastMap = getProdSortForecastMapMethod();  //Populating ProductSortedForecastMap. 
        if(!productSortedForecastMap.isEmpty()){
            forecastTable = getDispWrapperTableMethod(productSortedForecastMap, qtrNameList);
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,System.Label.Core_FC_No_6QPS_Message));
            if(OpportunityLineItem.SObjectType.getDescribe().isAccessible()){
                 oliPresentList = [SELECT id, Quantity, OpportunityId FROM OpportunityLineItem WHERE OpportunityId = :opptyObj.Id];
            }
                if(!oliPresentList.isEmpty()){
                oliPresentFlag = true;
            }
        }       
    }
    
    //Cleanup Task to be performed before loading any opportunity Page
    public void deleteAllBlankQuantity(){
        Id oppObjId = ApexPages.currentPage().getParameters().get('Id');
        List<Core_Opp_FC_Prod_Schedule__c> updateIsDeleted;
        if(oppObjId != null){
            if(Core_Opp_FC_Prod_Schedule__c.SObjectType.getDescribe().isAccessible()){
             updateIsDeleted = [SELECT id, Name, Core_Opp_FC_isdeleted__c, lastModifiedDate FROM Core_Opp_FC_Prod_Schedule__c WHERE Core_Opp_FC_Opportunity__c = :oppObjId AND Core_Opp_FC_isdeleted__c = true ORDER BY lastModifiedDate DESC];
            }
            List<Core_Opp_FC_Prod_Schedule__c> deleteBlankQty = [SELECT id, Name, Core_Opp_FC_isdeleted__c, Core_Opp_FC_Quantity__c, lastModifiedDate FROM Core_Opp_FC_Prod_Schedule__c WHERE Core_Opp_FC_Opportunity__c = :oppObjId AND Core_Opp_FC_isdeleted__c = false AND Core_Opp_FC_Quantity__c = null ORDER BY lastModifiedDate DESC];
            Integer size = deleteBlankQty.size();
            if(size != null && size > 0){
                System.debug('$$$ delete -'+deleteBlankQty);
                for(Integer i=0; i<size; i++){
                    updateIsDeleted[i].Core_Opp_FC_isdeleted__c = false;
                }           
                if (Schema.sObjectType.Core_Opp_FC_Prod_Schedule__c.isDeletable()) {
                delete deleteBlankQty;
                }
                update updateIsDeleted;         
                qtrNameList = new List<String>();
                productSortedForecastMap = getProdSortForecastMapMethod();  //Populating ProductSortedForecastMap. 
                if(!productSortedForecastMap.isEmpty()){
                    forecastTable = getDispWrapperTableMethod(productSortedForecastMap, qtrNameList);
                }
            }
        }
    }
    
    public void editAllMethod(){
        editAll = true;
    }
    public PageReference cancelMethod(){
        editAll = false;
        if(flag){
            System.debug('### Deleted List - '+insertForeCastList);
            if(!insertForeCastList.isEmpty()){
                try{
                    if (Schema.sObjectType.Core_Opp_FC_Prod_Schedule__c.isDeletable()) {
                    delete insertForeCastList;
                    }
                }catch(exception e){
                    
                }
            }
            for(Core_Opp_FC_Prod_Schedule__c fc : updateForeCastList){
                fc.Core_Opp_FC_isdeleted__c = false;
            }
            update updateForeCastList;
            qtrNameList = new List<String>();
            Map<Id, List<Core_Opp_FC_Prod_Schedule__c>> psFCMap =  getProdSortForecastMapMethod(); 
            forecastTable = getDispWrapperTableMethod(psFCMap, qtrNameList);    
        }
        flag = false;
        String globalUrl = String.valueOf(System.URL.getSalesforceBaseUrl().toExternalForm());
        PageReference pgRef = new PageReference(globalUrl+'/apex/Core_FC_Product_Schedule?id='+opptyObj.Id);
        System.debug('***Pg - '+pgRef);
        pgRef.setRedirect(true);
        return pgRef;
    }
    
    //Populating the productSortedForecastMap with OpportunityLineItem Id in the Key and list of ForecastWrapper in the value which are inturn sorted with quarter dates
    //ForecastWrapper will contain the object of Core_Opp_FC_Prod_Schedule__c 
    public Map<Id, List<Core_Opp_FC_Prod_Schedule__c>> getProdSortForecastMapMethod(){     
        List<Core_Opp_FC_Prod_Schedule__c> tempList;
        Map<Id, List<Core_Opp_FC_Prod_Schedule__c>> prodSortForecastMap = new Map<Id, List<Core_Opp_FC_Prod_Schedule__c>>();
        for(Core_Opp_FC_Prod_Schedule__c fc : [SELECT id, Core_Opp_FC_Opportunity__c, Core_Opp_Line_Item_RecordID__c, Core_Opp_FC_Product__c, Core_Opp_FC_Product__r.Name, Core_Opp_FC_Quarter_Date__c, Core_Opp_FC_Quarter__c, Core_Opp_FC_Quantity__c, Core_Opp_FC_isdeleted__c, lastModifiedDate, createdDate, Core_FC_4Q_Shed_Quantity__c, Core_FC_Last_Modified_Date__c, Core_FC_Vendor__c FROM Core_Opp_FC_Prod_Schedule__c WHERE Core_Opp_FC_Opportunity__c = :opptyObj.Id AND Core_Opp_FC_isdeleted__c = false ORDER BY Core_Opp_FC_Product__r.Name,Core_Opp_FC_Quarter_Date__c]){
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
        displayWrapper dw;
        //Populating the displayWrapper class for displaying the table in the vfpage 
        if(!prodSortForecastMap.isEmpty()){
            for(Id item : prodSortForecastMap.keyset()){           
                List<String> quarterNameList1 = new List<String>();               
                List<Core_Opp_FC_Prod_Schedule__c> fcList = new List<Core_Opp_FC_Prod_Schedule__c>();
                for(Core_Opp_FC_Prod_Schedule__c fc : prodSortForecastMap.get(item)){
                    quarterNameList1.add(fc.Core_Opp_FC_Quarter__c);
                    fcList.add(fc);
                }
                dw = new displayWrapper(fcList);
                fcTable.add(dw);
                quarterNameSet.addAll(quarterNameList1);
            }
        }
        qNameList.addAll(quarterNameSet);
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
                if((dw.fcObjList[i].Core_Opp_FC_Quantity__c == null && dw.viewQuantityList[i] == '' ) || (dw.viewQuantityList[i]).trim() == '' || !isNumeric(dw.viewQuantityList[i]) || Decimal.valueOf(dw.viewQuantityList[i]).precision() > 10){
                    System.debug('**Value of Quantity to edit - '+dw.viewQuantityList[i]+' trimmed - '+dw.viewQuantityList[i].trim()+' IsNumeric- '+isNumeric(dw.viewQuantityList[i]));
                    count++;
                    continue;
                }
                //if((productSortedForecastMap1.get(dw.fcObjList[i].Core_Opp_Line_Item_RecordID__c))[i].fcObj.Core_Opp_FC_Quantity__c != dw.fcObjList[i].Core_Opp_FC_Quantity__c){
                if((String.valueOf(dw.fcObjList[i].Core_Opp_FC_Quantity__c) != dw.viewQuantityList[i]) || flag){
                    dw.fcObjList[i].Core_Opp_FC_Quantity__c = (Decimal.valueOf(dw.viewQuantityList[i].trim())).round(System.RoundingMode.HALF_UP);
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
                if(oliFCMap.get(fc.Core_Opp_Line_Item_RecordID__c) != null && !Core_Status.contains(oliFCMap.get(fc.Core_Opp_Line_Item_RecordID__c).Core_Status__c)){
                    updateFCList1.add(fc);
                }else{
                    fc.Core_Opp_FC_Quantity__c = 0;
                    updateFCList1.add(fc);
                }
            }
            update updateFCList1;
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
        return pgRef;
    }
    
    public void addQuarterMethod(){
        editAll = true;
        flag = true;
        updateForeCastList = new List<Core_Opp_FC_Prod_Schedule__c>();
        insertForeCastList = new List<Core_Opp_FC_Prod_Schedule__c>();
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
            fcObject1.Core_Opp_FC_isdeleted__c = productSortedForecastMap.get(item)[num].Core_Opp_FC_isdeleted__c;
            fcObject1.Core_FC_4Q_Shed_Quantity__c = productSortedForecastMap.get(item)[num].Core_FC_4Q_Shed_Quantity__c;
            fcObject1.Core_FC_Last_Modified_Date__c = null;
            fcObject1.Core_FC_Vendor__c = productSortedForecastMap.get(item)[num].Core_FC_Vendor__c;
            insertForeCastList.add(fcObject1);
        }
        if(!updateForeCastList.isEmpty())
            update updateForeCastList;
        if(!insertForeCastList.isEmpty())
            insert insertForeCastList;
        qtrNameList = new List<String>();
        Map<Id, List<Core_Opp_FC_Prod_Schedule__c>> psFCMap =  getProdSortForecastMapMethod(); 
        forecastTable = getDispWrapperTableMethod(psFCMap, qtrNameList);        
        System.debug('$$$ New Table Values - '+forecastTable);
    }
    
    public Boolean isNumeric(String s){
        Boolean ReturnValue;
        try{
            Decimal.valueOf(s);
            ReturnValue = TRUE; 
        } catch (Exception e) {
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
        return pgRef;
    }
    
    public PageReference clearQuantities(){
        qtrNameList = new List<String>();
        Map<Id, List<Core_Opp_FC_Prod_Schedule__c>> psFCMap =  getProdSortForecastMapMethod(); 
        forecastTable = getDispWrapperTableMethod(psFCMap, qtrNameList); 
        List<displayWrapper> tempForecastTable =  new List<displayWrapper>();
        for(displayWrapper dw : forecastTable){
            for(Integer i=0; i<6; i++){
                dw.viewQuantityList[i] = '0';
            }
            tempForecastTable.add(dw);
        }   
        forecastTable.clear();
        forecastTable.addAll(tempForecastTable);
        return null;
    }
    
    public class displayWrapper{
        public Decimal forecastedQuantity{get;set;}
        public List<Core_Opp_FC_Prod_Schedule__c> fcObjList{get;set;}
        public List<String> viewQuantityList{get;set;}
        
        public displayWrapper(List<Core_Opp_FC_Prod_Schedule__c> fcObjList){
            this.forecastedQuantity = countTotalQuantity(fcObjList);
            this.fcObjList = fcObjList;
            this.viewQuantityList = new List<String>();
            for(Core_Opp_FC_Prod_Schedule__c fcq : fcObjList){  
                if(fcq.Core_Opp_FC_Quantity__c == null){
                    this.viewQuantityList.add('');
                }else{
                    this.viewQuantityList.add(String.valueOf(fcq.Core_Opp_FC_Quantity__c));
                }
            }
        }
        
        public Decimal countTotalQuantity(List<Core_Opp_FC_Prod_Schedule__c> fcQty){
            Decimal sum = 0;
            for(Integer i = 0; i<6; i++){ //changed to 0 from 2 so that it will calculate all 6 quarters value
                if(fcQty[i].Core_Opp_FC_Quantity__c != null && String.valueOf(fcQty[i].Core_Opp_FC_Quantity__c) != ''){
                    sum = sum+(Decimal)fcQty[i].Core_Opp_FC_Quantity__c;
                }
            }
            for(Core_Opp_FC_Prod_Schedule__c fc : fcQty){
                fc.Core_FC_4Q_Shed_Quantity__c = sum;
            }
            return sum;
        }
    }
}