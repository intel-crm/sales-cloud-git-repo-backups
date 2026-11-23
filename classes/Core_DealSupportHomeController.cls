/**************************************************************************************
Apex Class Name:  Core_DealSupportHomeController
Version     : 1.0 
Created Date: 06 NOV 2014
Function    : Seeds Page to View Seeds based on Opportunity Id OR Account Id
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Srikant Joshi             11/07/2014              Original Version
*************************************************************************************/
public with sharing class Core_DealSupportHomeController {

    // Boolean to hold the reference to the user access 
    public Boolean bUserHasAccess { get; set; }
    
    // String to hold the reference to the search text 
    public String sSearchText{get;set;}
    public String sSearchText1{get;set;}
    public String sSearchText2{get;set;}
    public String sSearchText3{get;set;}
    public String sSearchText4{get;set;}
    public String sSearchText5{get;set;}
    public String sSearchText6{get;set;}
    public String sSearchText7{get;set;}
    public String sSearchText8{get;set;}
    public String sSearchText9{get;set;}
    public String sSearchText10{get;set;}       
    public String sSearchText11{get;set;}
    public String sSearchText12{get;set;}
      
    // String to hold the reference to the search text 
    public String orderSeedsAccount { get; set;}
    
    // String to hold the reference to the url for orderSeedsOpportunity   
    public String orderSeedsOpportunity { get; set; }
    
    // String to hold the reference to the url for orderSeedsTab
    public String orderSeedsTab { get; set; }
    
    // String to hold the reference to the url for demoDepotURL
    public String demoDepotURL { get; set; }
    
    // sObject to hold the reference to the opportunity records
    public Opportunity sobjOppt {
        get;
        set;
    }
    
    // sObject to hold the reference to the Account records
    public Account sobjAcct {
        get;
        set;
    }
    
    // sObject to hold the reference to the Apex Object to deserialize JSON response
    public seedWebserviceWrapper seedWebserviceWrapperInstance {
        get;
        set;
    }
    
    // sObject List to hold the reference to the Apex Object to deserialize JSON response
    public list < seedWebserviceWrapper > lstSeedWebserviceWrapperInstance {
        get;
        set;
    }
    // sObject result to hold the reference to the opportunity records 
    public list < seedWebserviceWrapper > lstResSeedWebserviceWrapperInstance {
         get;
        set;
    }
    
    // Id to hold the ID of the Opportunity or the account passed through the URL
    public String recordId {
        get;
        set;
    }
    
    // Id to hold the ID of the Opportunity or the account passed through the URL
    public Id sAccntId {
        get;
        set;
    }
    
    // String to hold the Name of the Opportunity or the account passed through the URL
    public String sAcctRecName  {
        get;
        set;
    }
    
    // sAccntId to hold the ID of the Opportunity or the account passed through the URL
    public String sOppRecName{
        get;
        set;
    }
    
    // Boolean value to conditionally render the sub section
    public Boolean bRender {
        get;
        set;
    }
    
    // String value to conditionally WWID
    public String sWWID {
        get;
        set;
    }
    
    // String to hold the reference to the CimId field 
    public String sCimId { get; set; }
    
    // boolean to hold the reference to the opportunity records 
    public Boolean bRenderFlag { get; set; }
    
    // boolean to hold the reference to the opportunity records 
    public Boolean bErrorFlag { get; set; }
    
    // Map to hold the reference to the system url name to system credentials 
    public map<String,Core_System_Credentials__c> mapStringToCS{get;set;}
    
    // Constructor to get the recordID to be shown on the sectionheader using the parameter supplied
    public Core_DealSupportHomeController() {
        
        // Instatiate the variables 
        seedWebserviceWrapperInstance = new seedWebserviceWrapper();
        mapStringToCS = new map<String,Core_System_Credentials__c>{};
        
        // Set the boolean values to default values 
        bUserHasAccess = true;   
        bRenderFlag = true;
        bErrorFlag = false;
        
        try{
            // Set the reference to the system url name to system credentials 
            for(Core_System_Credentials__c sobjCS : Core_System_Credentials__c.getAll().Values())
                mapStringToCS.put(sobjCS.Name,sobjCS);
            
            //Get the OpportunityID using the parameter passed through the URL
            if (String.isNotBlank(ApexPages.currentPage().getParameters().get(system.label.Core_OpportunityID))) {
                sCimId = ApexPages.currentPage().getParameters().get(system.label.Core_CIMID);
                recordId = ApexPages.currentPage().getParameters().get(system.label.Core_OpportunityID);
                sOppRecName=ApexPages.currentPage().getParameters().get(system.label.Core_OpportunityName);
                if(!String.isEmpty(sOppRecName))
                    sOppRecName = sOppRecName.replace('+',' ');
                
                List<UserRecordAccess> lstUserRecordAccess = new List<UserRecordAccess>();
                lstUserRecordAccess = [SELECT RecordId, HasReadAccess,HasEditAccess FROM UserRecordAccess
                                                              WHERE UserId =: UserInfo.getUserId() AND RecordId = :recordId LIMIT 1];
                
                //If the user is present in the Opportunity Team                                             
                if(lstUserRecordAccess.isEmpty() || (!lstUserRecordAccess.isEmpty() && !lstUserRecordAccess.get(0).HasReadAccess)){ 
                    bUserHasAccess = false; 
                    bRenderFlag = false;
                    bErrorFlag = false;
                }
                               
            } 
            
            //Get the CIMID using the parameter passed through the URL
            else if (String.isNotBlank(ApexPages.currentPage().getParameters().get(system.label.Core_AccountName))) 
            {
                sCimId = ApexPages.currentPage().getParameters().get(system.label.Core_CIMID);
                sAcctRecName=ApexPages.currentPage().getParameters().get(system.label.Core_AccountName);
                sAcctRecName = sAcctRecName.replace('+',' ');   
                sAccntId = ApexPages.currentPage().getParameters().get(system.label.Core_AccountID);
                
                List<UserRecordAccess> lstUserRecordAccess = new List<UserRecordAccess>();
                lstUserRecordAccess = [SELECT RecordId, HasReadAccess,HasEditAccess FROM UserRecordAccess
                                                              WHERE UserId =: UserInfo.getUserId() AND RecordId = :sAccntId LIMIT 1];
                System.debug(lstUserRecordAccess);
                
                //If the user is present in the Account Team 
                if(lstUserRecordAccess.isEmpty() || (!lstUserRecordAccess.isEmpty() && !lstUserRecordAccess.get(0).HasEditAccess))
                {       
                        List<AccountTeamMember> lstAccountTeamMembers = new List<AccountTeamMember>();
                        lstAccountTeamMembers = [SELECT Id,accountId,UserId FROM AccountTeamMember Where AccountId =:sAccntId and UserId =: userInfo.getUserId()];
                        
                        System.debug(lstAccountTeamMembers );
                        
                        if(lstAccountTeamMembers.isEmpty())
                        {
                            bUserHasAccess = false; 
                            bRenderFlag = false;
                            bErrorFlag = false;
                        } 
                }
                
            }  
            
            else {
                List<User> lstUser = [select id,Core_WWID__c from User where id = :UserInfo.getUserID()];
                sWWID = lstUser[0].Core_WWID__c;
                
                System.debug(Limits.getDMLStatements());
                if(sWWID == NULL){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING, System.Label.Core_WWID_Not_Found + System.Label.Core_Exception);
                    ApexPages.addMessage(myMsg);
                    bRenderFlag = true;
                    bErrorFlag = true;
                }
            }
            
            //Get the variables to be used to launch the button
            if(mapStringToCS.containsKey(system.label.Core_DemoDepotOrder)){

                orderSeedsAccount = mapStringToCS.get(system.label.Core_DemoDepotOrder).Core_End_Point_URL__c+system.label.Core_CIMID+'='+sCimId;               
                
                orderSeedsOpportunity = mapStringToCS.get(system.label.Core_DemoDepotOrder).Core_End_Point_URL__c+system.label.Core_aceOppID+'='+recordId+'&'+system.label.Core_CIMID+'='+sCimId;
   
                orderSeedsTab = mapStringToCS.get(system.label.Core_DemoDepotOrder).Core_End_Point_URL__c;  
                
                demoDepotURL =   mapStringToCS.get(system.label.Core_DemoDepotOrderManagement).Core_End_Point_URL__c;      
            }  
        }
        catch(Exception e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Core_Exception + e.getmessage());
            ApexPages.addMessage(myMsg);
            bRenderFlag = false;
            bErrorFlag = true;
        }

    }
    
    /*
    * Method name  : searchSeed
    * Description  : This is used to make calls to the rest webservice and get the list of apex object from the JSON response
    * Return Type  : List < seedWebserviceWrapper >
    * Parameter    : NONE
    */ 
    public void init() {
    
        //Call the method to fetch the APex Object record if the parameters are set
        if((String.isNotBlank(recordId) || String.isNotBlank(sWWID) || (String.isNotBlank(sAccntId) && String.isNotEmpty(sCimId))) && bUserHasAccess){
            coreGetSeeds(); 
        }
        else  if(bUserHasAccess){
            if(String.isNotBlank(recordId) || String.isNotBlank(sAcctRecName)){
                //Throw the error saying no records are present
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO, System.Label.Core_NoRecordsError);
                ApexPages.addMessage(myMsg);
            }
            bRenderFlag = false;
            bErrorFlag = true;
        }       
    }
    
    /*
    * Method name  : searchSeed
    * Description  : This is used to make calls to the rest webservice and get the list of apex object from the JSON response
    * Return Type  : List < seedWebserviceWrapper >
    * Parameter    : NONE
    */ 
    public void searchSeed() {
        // Boolean to set the INfO message to enter atleast one search text for retreiving results.
        Boolean bEmpty = False;
        
        //Initialisize the result set of the apex object
        lstResSeedWebserviceWrapperInstance = new list < seedWebserviceWrapper > {};
        Set < seedWebserviceWrapper >  setResSeedWebserviceWrapperInstance = new Set < seedWebserviceWrapper > {};
        
        try{
            // RUN the set of records to restrieve only the result set pertaining to the serach text
              for(seedWebserviceWrapper sObjSeedWrapper : lstSeedWebserviceWrapperInstance){
                
                //Search if the result set contains the search text
                if((String.isEmpty(sSearchText) || (String.isNotEmpty(sSearchText) && sObjSeedWrapper.Ordernumber != NULL && String.ValueOf(sObjSeedWrapper.Ordernumber).containsIgnoreCase(sSearchText)))
               
                    && (String.isEmpty(sSearchText1) || (String.isNotEmpty(sSearchText1) && sObjSeedWrapper.productname != NULL &&  String.ValueOf(sObjSeedWrapper.productname).containsIgnoreCase(sSearchText1)))    
               
                    && (String.isEmpty(sSearchText2) || (String.isNotEmpty(sSearchText2) && sObjSeedWrapper.EstimatedShipDate != NULL && String.ValueOf(sObjSeedWrapper.EstimatedShipDate).containsIgnoreCase(sSearchText2)))      
                       
                    && (String.isEmpty(sSearchText3) || (String.isNotEmpty(sSearchText3) && sObjSeedWrapper.RequestedDeliveryDate != NULL && String.ValueOf(sObjSeedWrapper.RequestedDeliveryDate).containsIgnoreCase(sSearchText3)))
    
                    && (String.isEmpty(sSearchText4) || (String.isNotEmpty(sSearchText4) && sObjSeedWrapper.lineItemStatus != NULL && String.ValueOf(sObjSeedWrapper.lineItemStatus).containsIgnoreCase(sSearchText4)))       
                    
                    && (String.isEmpty(sSearchText5) || (String.isNotEmpty(sSearchText5) && sObjSeedWrapper.returnPickupDate != NULL && String.ValueOf(sObjSeedWrapper.returnPickupDate).containsIgnoreCase(sSearchText5)))
     
                    && (String.isEmpty(sSearchText6) || (String.isNotEmpty(sSearchText6) && sObjSeedWrapper.Requestor != NULL && String.ValueOf(sObjSeedWrapper.Requestor).containsIgnoreCase(sSearchText6)))
                       
                    && (String.isEmpty(sSearchText7) || (String.isNotEmpty(sSearchText7) && sObjSeedWrapper.requestedQty != NULL && String.ValueOf(sObjSeedWrapper.requestedQty).containsIgnoreCase(sSearchText7)))
    
                    && (String.isEmpty(sSearchText8) || (String.isNotEmpty(sSearchText8) && sObjSeedWrapper.AccountName != NULL && sObjSeedWrapper.AccountName.containsIgnoreCase(sSearchText8)))
                              
                    && (String.isEmpty(sSearchText9) || (String.isNotEmpty(sSearchText9) && sObjSeedWrapper.OpportunityName != NULL && sObjSeedWrapper.OpportunityName.containsIgnoreCase(sSearchText9)))){

                    lstResSeedWebserviceWrapperInstance.add(sObjSeedWrapper);         
                }
                
                // To check if atleast one search text is NULL 
                if (String.isEmpty(sSearchText) && String.isEmpty(sSearchText1) && String.isEmpty(sSearchText2) && String.isEmpty(sSearchText3) 
                    && String.isEmpty(sSearchText4) && String.isEmpty(sSearchText5) && String.isEmpty(sSearchText6) && String.isEmpty(sSearchText7) 
                    && String.isEmpty(sSearchText8) && String.isEmpty(sSearchText9) && String.isEmpty(sSearchText10) && String.isEmpty(sSearchText11) && String.isEmpty(sSearchText12)) {
                    bEmpty = True;
                }
            }
            // To check if atleast one search text is NULL
            if(bEmpty == True){
                lstResSeedWebserviceWrapperInstance = lstSeedWebserviceWrapperInstance;
            }
            else{
                lstResSeedWebserviceWrapperInstance.addALL(setResSeedWebserviceWrapperInstance);
            }
        }
        catch(Exception e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Core_Exception + e.getmessage());
            ApexPages.addMessage(myMsg);
            bRenderFlag = false;
            bErrorFlag = true;
        }
    }          

    /*
    * Method name  : coreGetSeeds
    * Description  : This is used to make calls to the rest webservice and get the list of apex object from the JSON response
    * Return Type  : List < seedWebserviceWrapper >
    * Parameter    : NONE
    */  
    public List < seedWebserviceWrapper > coreGetSeeds() {
    
        // Intialize the declared variables
        lstSeedWebserviceWrapperInstance = new list < seedWebserviceWrapper > {};
        lstResSeedWebserviceWrapperInstance = new list < seedWebserviceWrapper > {};
        list<String> lstOppID = new list<String>{};
        list<String> lstAccntID = new list<String>{};
        map<String,String> mapOppNametoID = new map<String,String>{};
        map<String,String> mapAccntNametoID = new map<String,String>{};
        map<String,seedWebserviceWrapper> mapOrderNoToseedWebserviceWrapper = new map<String,seedWebserviceWrapper>{};
        list<String> lstOrderNo =new list<String>{};
        
        try{
            //Make the callout to the service
            HTTPResponse httpResp = new HTTPResponse();
            
            //If the page is navigated from the tab
            if(String.isNotEmpty(sWWID))
               // httpResp = Core_WebServiceUtility.restServiceCallout('',mapStringToCS.get(System.Label.Core_SeedsWebservice).Core_End_Point_URL__c+System.Label.Core_SeedsURL+sWWID+'/ALL','Get',System.Label.Core_TimeOut,System.Label.Core_SeedsWebservice);
                httpResp = Core_WebServiceUtility.restServiceCallout('','callout:SalesCRM_Apigee'+System.Label.Core_SeedsURL+sWWID+'/ALL','Get',System.Label.Core_TimeOut,System.Label.Core_SeedsWebservice);
            else if(String.isNotEmpty(sAcctRecName))//If the page is NOT navigated from the tab
               // httpResp = Core_WebServiceUtility.restServiceCallout('',mapStringToCS.get(System.Label.Core_SeedsWebservice).Core_End_Point_URL__c+System.Label.Core_SeedsURLAccount+sCimId+'/ALL','Get',System.Label.Core_TimeOut,System.Label.Core_SeedsWebservice);
                httpResp = Core_WebServiceUtility.restServiceCallout('','callout:SalesCRM_Apigee'+System.Label.Core_SeedsURLAccount+sCimId+'/ALL','Get',System.Label.Core_TimeOut,System.Label.Core_SeedsWebservice);
            else //If the page is NOT navigated from the tab
               // httpResp = Core_WebServiceUtility.restServiceCallout('',mapStringToCS.get(System.Label.Core_SeedsWebservice).Core_End_Point_URL__c+System.Label.Core_SeedsURLOpp+recordID+'/ALL','Get',System.Label.Core_TimeOut,System.Label.Core_SeedsWebservice);                   
                httpResp = Core_WebServiceUtility.restServiceCallout('','callout:SalesCRM_Apigee'+System.Label.Core_SeedsURLOpp+recordID+'/ALL','Get',System.Label.Core_TimeOut,System.Label.Core_SeedsWebservice);                   
            system.debug('------**'+httpResp);
            
            //Until the actual service is up & running. This piece of code is to ensure testing purpose
            if(httpResp.getStatus() != System.Label.Core_OK){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Core_Exception);
                ApexPages.addMessage(myMsg);
                bRenderFlag = false;  
                bErrorFlag = true;
                return lstseedWebserviceWrapperInstance;            
            }
            
            //Use the parser to get the response as JSONParser type
            System.JSONParser parser = JSON.createParser(httpResp.getbody());
            
            while (parser.nextToken() != NULL) {
                // Start at the array of Records.
                if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                    while (parser.nextToken() != NULL) {
                        // Advance to the start object marker to
                        // find next invoice statement object.
                        if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                            // Read entire invoice object, including its array of line items.
                            seedWebserviceWrapper apexObjseedWrapperRecord  = (seedWebserviceWrapper) parser.readValueAs(seedWebserviceWrapper.class);
                            // Add the record to the list of Apex Objects
                            lstseedWebserviceWrapperInstance.add(apexObjseedWrapperRecord);
                            parser.skipChildren();
                        }
                    }
                }
            }
            boolean ucdSwitch = Core_CRM_Utility.isUCDSwitchOn(); //TWC4767-3431 - implementation of UCD and CIM logic switch
            // If the list of the Apex Object records to be rendered is empty, throw up an error on the screen
            if (!lstseedWebserviceWrapperInstance.isEmpty()){
                for(seedWebserviceWrapper seedWrap : lstseedWebserviceWrapperInstance){
                    lstOppID.add(seedWrap.OpportunityID);
                    lstAccntID.add(seedWrap.AccountID);
                }
                
                if(!lstOppID.isEmpty()){
                    for(Opportunity sObjOpp : [select id,name from Opportunity where ID in :lstOppID]){
                        mapOppNametoID.put(sObjOpp.ID,sObjOpp.Name);
                    }
                }
                if(!lstAccntID.isEmpty()){
                    if(ucdSwitch == true){ //TWC4767-3431
                        for(Account sObjAccnt : [select Core_Business_Party_Id__c,name from Account where Core_Business_Party_Id__c in :lstAccntID])
                            mapAccntNametoID.put(sObjAccnt.Core_Business_Party_Id__c,sObjAccnt.Name);
                    }
                    else { //TWC4767-3431
                       for(Account sObjAccnt : [select Core_CIM_ID__c,name from Account where Core_CIM_ID__c in :lstAccntID])
                            mapAccntNametoID.put(sObjAccnt.Core_CIM_ID__c,sObjAccnt.Name); 
                    }
                }   
            }
            
            //Convert the format of the Date from exter source format to the salesforce format
            for (seedWebserviceWrapper mk: lstseedWebserviceWrapperInstance) {
                Date dateDt;
                if(mk.RequestedDeliveryDate != NULL){
                    dateDt = Date.Valueof(mk.RequestedDeliveryDate);
                    mk.RequestedDeliveryDate = dateDt.format();
                }
                if(mk.EstimatedShipDate != NULL){
                    dateDt = Date.Valueof(mk.EstimatedShipDate);
                    mk.EstimatedShipDate = dateDt.format();
                }
                if(mk.ReturnPickupDate != NULL){
                    dateDt= Date.Valueof(mk.ReturnPickupDate);
                    mk.ReturnPickupDate = dateDt.format();
                }
                
                if(mapOppNametoID.containsKey(mk.OpportunityID))
                    mk.OpportunityName = mapOppNametoID.get(mk.OpportunityID);
                if(mapAccntNametoID.containsKey(mk.AccountID))
                    mk.AccountName = mapAccntNametoID.get(mk.AccountID);
                    
                lstOrderNo.add(mk.OrderNumber+mk.productname);
                mapOrderNoToseedWebserviceWrapper.put(mk.OrderNumber+mk.productname,mk);
            }
            
            // Sort the list by the descending order
            lstseedWebserviceWrapperInstance = new list < seedWebserviceWrapper > {};
            for(Integer iRow = lstOrderNo.Size()-1;iRow>=0;iRow-- ){
                lstseedWebserviceWrapperInstance.add(mapOrderNoToseedWebserviceWrapper.get(lstOrderNo[iRow]));
            }
            
            // If the list of the Apex Object records to be rendered is empty, throw up an error on the screen
            if (lstseedWebserviceWrapperInstance.isEmpty()) {
                bRenderFlag = false;
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO, System.Label.Core_NoRecordsError);
                ApexPages.addMessage(myMsg);
                bErrorFlag = true;
            }
        }
        catch(Exception e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Core_Exception + e.getmessage());
            System.debug(e.getmessage());
            ApexPages.addMessage(myMsg);
            //bRenderFlag = false;
            //bErrorFlag = true;
        }
        // return the List of records to be shown on the VF page
        lstResSeedWebserviceWrapperInstance = lstseedWebserviceWrapperInstance;
        return lstResSeedWebserviceWrapperInstance;
    }

    // Wrapper Class/Apex Object to hold the JSON response
    public class seedWebserviceWrapper {
        
        // String to hold the account external ID
        public String AccountID {
            get;
            set;
        }
        // String to hold the opportunity external ID
        public String OpportunityID {
            get;
            set;
        }
        // String to hold the account external ID
        public String AccountName {
            get;
            set;
        }
        // String to hold the opportunity external ID
        public String OpportunityName {
            get;
            set;
        }
        // String to hold the Order Number 
        public Integer OrderNumber {
            get;
            set;
        }
        // String to hold the Order Status
        public String OrderStatus {
            get;
            set;
        }
        // String to hold the Requested Delivery Date
        public String RequestedDeliveryDate {
            get;
            set;
        }
        // String to hold the Return Pickup Date
        public String ReturnPickupDate {
            get;
            set;
        }
        // String to hold the Requestor
        public String Requestor {
            get;
            set;
        }
        // String to hold the Submitter
        public String Submitter {
            get;
            set;
        }
        // String to hold the ProductCode
        public String ProductCode {
            get;
            set;
        }
        // String to hold the LineItemStatus
        public String LineItemStatus {
            get;
            set;
        }
        // String to hold the Product Name
        public String ProductName {
            get;
            set;
        }
        // String to hold the Estimated Ship Date
        public String EstimatedShipDate {
            get;
            set;
        }
        // String to hold the Actual ShipDate
        public String ActualShipDate {
            get;
            set;
        }
        // String to hold the RequestedQty
        public Integer RequestedQty {
            get;
            set;
        }
        // String to hold the ShippedQty
        public Integer ShippedQty {
            get;
            set;
        }
        // String to hold the ProductDesc
        public String ProductDesc {
            get;
            set;
        }
        // String to hold the ProductListDesc
        public String ProductListDesc {
            get;
            set;
        }
        // String to hold the Company Name
        public String CompanyName {
            get;
            set;
        }
        // String to hold the Street Address1
        public String StreetAddress1 {
            get;
            set;
        }
        // String to hold the Street Address2
        public String StreetAddress2 {
            get;
            set;
        }
        // String to hold the MailStop
        public String MailStop {
            get;
            set;
        }
        // String to hold the City
        public String City {
            get;
            set;
        }
        // String to hold the State
        public String State {
            get;
            set;
        }
        // String to hold the ZipCode
        public String ZipCode {
            get;
            set;
        }
        // String to hold the Country
        public String Country {
            get;
            set;
        }
        // String to hold the Attention Name
        public String AttentionName {
            get;
            set;
        }
        // String to hold the Attention Number
        public String AttentionNumber {
            get;
            set;
        }
        // String to hold the Notes
        public String Notes {
            get;
            set;
        }
        // String to hold the status
        public String status {
            get;
            set;
        }
        // String to hold the message
        public String message {
            get;
            set;
        }
        // String to hold the bRenderCSection
        public Boolean bRenderCSection {
            get;
            set;
        }

        public seedWebserviceWrapper parse(String json) {
            //Deserialize the specified JSON string into an Apex object of the specified type.
            return (seedWebserviceWrapper) System.JSON.deserialize(json, seedWebserviceWrapper.class);
        }
    }
}