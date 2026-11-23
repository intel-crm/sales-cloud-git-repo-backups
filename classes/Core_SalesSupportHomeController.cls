/**************************************************************************************
Apex Class Name:  Core_SalesSupportHomeController
Version     : 1.0 
Created Date: 11 JUL 2014
Function    : 
Modification Log :
* Developer           Date               Description
* ----------------------------------------------------------------------------    
* Srikant Joshi       Jul 11, 2014       Original Version
* Dave Hood           Jun 08, 2015       Copied from original code, refactored, updated for R2
* Accenture           Dec 06, 2016       Copied from original code, added functionality for Intel Altera Phase1
* Ashwin Dash         May 09, 2017       Providing user access on the related opportunity for updating the status on creation of Quote and removing it after updation - US63649
* Rangesh Kona        Aug 22nd, 2017     SMG-DRD - Sales Support Request Integration
*************************************************************************************/
public with sharing class Core_SalesSupportHomeController {

    // Booleans to control rendering, error messages, etc.
    public Boolean bUserHasAccess { get; set; }      // Does the user have access to the Sales Support tab for this oppty/acct?
    public Boolean bAccountWithNoCIMID { get; set; } // Are we on an account with no CIM ID?
    public Boolean bSeedsRenderFlag { get; set; }    // Conditionally render the subsection
    public Boolean bSeedsErrorFlag { get; set; }     // Display error messages
    public Boolean bSamplesRenderFlag { get; set; }  // Conditionally render the subsection
    public Boolean bSamplesErrorFlag { get; set; }   // Display error messages
  
	public Boolean isPartner {get;set;} //Is user a partner
    public String selectedISR {get;set;} //Selected ISR by partner
    
    public String sCurrentTab { get; set; }      // "tabSeeds" or "tabSamples"   
    // Seed search text
    public String[] sSeedSearch {
        get {
            if (sSeedSearch == null) {
                sSeedSearch = new String[]{'','','','','','','','','',''};
            }
            return sSeedSearch;
        }
        set;
    }
    
    // Samples search text
    public String[] sSampleSearch {
        get {
            if (sSampleSearch == null) {
                sSampleSearch = new String[]{'','','','','','','','','','','',''};
            }
            return sSampleSearch;
        }
        set;
    }
    
    // URLs for ordering seeds
    public String orderSeedsURL { get; set; }
    public String viewSeedURL { get; set; }
    
    // URLs for requesting samples
    public String requestSamplesURL { get; set; }
    public String viewSampleURL { get; set; }
    
    //US116483-to auto populate User Region starts
    public String UserRegion { get; set; }
    public String UIthemedisplayed { get; set; }
     //US116483-to auto populate User Region end
    
    // List to deserialize seeds JSON response, and the (potentially) filtered results for the user
    public list <SeedWebserviceWrapper> lstSeeds { get; set; }
    public list <SeedWebserviceWrapper> lstFilteredSeeds { get; set; }
    
    // List to deserialize samples JSON response, and the (potentially) filtered results for the user
    public list <SampleWebserviceWrapper> lstSamples { get; set; }
    public list <SampleWebserviceWrapper> lstFilteredSamples { get; set; }
    
    // sObject to hold the reference to the opportunity records
    public Opportunity sobjOppt { get; set; }
    
    // sObject to hold the reference to the Account records
    public Account sobjAcct { get; set; }
    
    // Values passed through URL parameters
    public String sOppId { get; set; }        // Opportunity ID
    public String sOppRecName { get; set; }   // Opportunity Name
    public Id sAcctId { get; set; }           // Account ID
    public String sAcctRecName { get; set; }  // Account Name
    public String sCimId { get; set; }        // Account CIM ID
    
    public String sWWID { get; set; }         // WWID of the current user
    
    
    // Map to hold the reference to the system url name to system credentials 
    public map<String,Core_System_Credentials__c> mapStringToCS{get;set;}
    

    // Intel Altera Phase1:
    //Below getter setter fields are added for Phas1 implementation
    
    public Boolean bPSGQuoteHistoryExist {get;set;} // This field is used for indicating the PSGQuoteHistory exist or not 
    public Boolean bSalesSupportHomePageAccessible {get;set;} // Field used for indicating Sales Support Home is accessible 
    public Boolean bOpportunityValidForQuoteCreation {get;set;} // To indicate opportunity valid for Quote Creation 
    public Boolean bPSGQuoteTabVisible {get;set;}
    public List<Core_PSG_Quote_Generation_History__c> lstPSGQuoteGenarationHistory {get;set;} // Displays the PSG Quote History related to a opportunity
    public boolean bPSGQuoteProcessingInfoDisp {get;set;} //This bit decides which error message to be displayed on the PSG Quote History Tab. 
    
    
    // SMG-DRD Support Request Integration *** Start
    public Boolean bUserOptyWriteAccess {get;set;}
    public Boolean showNoAccessMessage {get;set;}
    public Id userId {get;set;}  
    public Boolean showNavigationErrorMessage{get;set;}
    // SMG-DRD Support Request Integration *** End
    
    // Constructor - instantiates & initializes all of our variables based on how the user came to the page
    public Core_SalesSupportHomeController() {
            
        bPSGQuoteTabVisible = false; // Bit to indicate whether the PSG Quote tab has to be show or not .
        mapStringToCS = new map<String,Core_System_Credentials__c>{};
        lstPSGQuoteGenarationHistory = new List<Core_PSG_Quote_Generation_History__c>();
        userId = UserInfo.getUserId();
        // Set the boolean values to default values 
        bUserHasAccess = true;
        bAccountWithNoCIMID = false;
        bSeedsRenderFlag = false;
        bSeedsErrorFlag = false;
        bSamplesRenderFlag = false;
        bSamplesErrorFlag = false;
        
         // SMG-DRD Support Request Integration *** Start
        showNoAccessMessage = false;            // To check Read/Write Access
        showNavigationErrorMessage = false;     // display Error if user navigates from Account/Sales Support tab directly
        bUserOptyWriteAccess = false;           // To check Read/Write Access
        // SMG-DRD Support Request Integration *** End
        
        //Intel Altera Phase1:
        //Below field will be initialized to default value.
        bOpportunityValidForQuoteCreation  = true;
        bPSGQuoteProcessingInfoDisp = false;
        bPSGQuoteHistoryExist = false;
        
        // These are used to identify Custom Settings for Samples system credentials and will likely be replaced with Custom Labels
        final String mySamplesRequestPlacement = 'My Samples Request Placement';
        final String mySamplesRequestManagement = 'My Samples Request Management';
        final String mySamplesHome = 'My Samples Home';
        
         //US116483-to auto populate User Region starts
        User userObj = [select Id, Core_WWID__c, Core_User_Geo__c, Profile.Name from User where Id = :UserInfo.getUserID()];
        
        UserRegion=userObj.Core_User_Geo__c; 
        UIthemedisplayed=UserInfo.getUiThemeDisplayed();
        //US116483-to auto populate User Region end
       
        if(userObj.Profile.Name == System.Label.Core_Partner_Profile_Name){
            isPartner = true;
        }else{
            isPartner = false;
        }
        try {
                                                  
            // Set the reference to the system url name to system credentials 
            for(Core_System_Credentials__c sobjCS : Core_System_Credentials__c.getAll().Values())
                mapStringToCS.put(sobjCS.Name, sobjCS);
               
            //Intel Altera Phase1: 
            //Calling isSalesSupportHomePageAccessible function to check for accessibility of page for the logged in user.
            bSalesSupportHomePageAccessible = Core_SalesSupportPSGQuoteSFDCToSiebel.isSalesSupportHomePageAccessible();
            
            // If the user came in through an Opportunity, get the OpportunityID using the URL parameter,
            // and set up all of our variables & URLs based on that
            if (String.isNotBlank(ApexPages.currentPage().getParameters().get(System.Label.Core_OpportunityID))) {
                bPSGQuoteTabVisible = true; // PSG Quote Tab is visible 
                sCimId = ApexPages.currentPage().getParameters().get(System.Label.Core_CIMID);
                sOppId = ApexPages.currentPage().getParameters().get(System.Label.Core_OpportunityID);
                sOppRecName = ApexPages.currentPage().getParameters().get(System.Label.Core_OpportunityName);     
                //Called pullPSGQuoteHistory method for getting the PSG Quote history associated with Opportunity.
                pullPSGQuoteHistory();
                
                if(!String.isEmpty(sOppRecName))
                    sOppRecName = sOppRecName.replace('+',' ');
                orderSeedsURL = mapStringToCS.get(System.Label.Core_DemoDepotOrder).Core_End_Point_URL__c + System.Label.Core_aceOppID +
                    '=' + sOppId + '&' + System.Label.Core_CIMID + '=' + sCimId;
                requestSamplesURL = mapStringToCS.get(mySamplesRequestPlacement).Core_End_Point_URL__c + 'CIMId=' + sCimId +
                    '&OpportunityId=' + sOppId;
                
                List<UserRecordAccess> lstUserRecordAccess = new List<UserRecordAccess>();
                lstUserRecordAccess = [select RecordId, HasReadAccess, HasEditAccess from UserRecordAccess
                                       where UserId =: UserInfo.getUserId() and RecordId = :sOppId limit 1];
                
                //Intel Altera Phase1:
                //Below block of code used  for checking the PSG Quote Processing and existence of PSG Quote History of an Opportunity.
                sobjOppt = [Select id,name,Core_PSG_Quote_Last_Processed_Status__c from Opportunity where Id=:sOppId];
                
                if(sobjOppt.Core_PSG_Quote_Last_Processed_Status__c =='Processing') {
                      if(lstPSGQuoteGenarationHistory.isEmpty()) {
                          bPSGQuoteHistoryExist = true;
                          bPSGQuoteProcessingInfoDisp = true;
                      }
                      else {
                           bPSGQuoteHistoryExist = false;
                           bPSGQuoteProcessingInfoDisp = true;
                      }
                }
                if(lstPSGQuoteGenarationHistory.isEmpty() && (!(sobjOppt.Core_PSG_Quote_Last_Processed_Status__c =='Processing'))) {
                    bPSGQuoteHistoryExist = true;
                    bPSGQuoteProcessingInfoDisp = false;
                }
                
                
                // If the user doesn't have read access to the Opportunity
                if (lstUserRecordAccess.isEmpty() || (!lstUserRecordAccess.isEmpty() && !lstUserRecordAccess.get(0).HasReadAccess)) { 
                    bUserHasAccess = false; 
                    bSeedsRenderFlag = false;
                    bSeedsErrorFlag = false;
                    bSamplesRenderFlag = false;
                    bSamplesErrorFlag = false;
                }
                
                 // SMG-DRD Support Request Integration *** Start
                if (lstUserRecordAccess.get(0).HasEditAccess) {
                        bUserOptyWriteAccess = true;
                }    
                 // SMG-DRD Support Request Integration *** End
            } 
            
            // If the user came in through an Account, get the CIM ID using the URL parameter,
            // and set up all of our variables & URLs based on that
            else if (String.isNotBlank(ApexPages.currentPage().getParameters().get(System.Label.Core_AccountName))) {
               
                sCimId = ApexPages.currentPage().getParameters().get(System.Label.Core_CIMID);
                sAcctRecName = ApexPages.currentPage().getParameters().get(System.Label.Core_AccountName);
                sAcctRecName = sAcctRecName.replace('+',' ');   
                sAcctId = ApexPages.currentPage().getParameters().get(System.Label.Core_AccountID);
                               
                if (String.isBlank(sCimId)) {
                    bAccountWithNoCIMID = true;
                    bSeedsRenderFlag = false;
                    bSeedsErrorFlag = false;
                    bSamplesRenderFlag = false;
                    bSamplesErrorFlag = false;
                }
                else {                    
                    orderSeedsURL = mapStringToCS.get(System.Label.Core_DemoDepotOrder).Core_End_Point_URL__c + System.Label.Core_CIMID + '=' + sCimId;
                    requestSamplesURL = mapStringToCS.get(mySamplesRequestPlacement).Core_End_Point_URL__c + 'CIMId=' + sCimId;
                    
                    List<UserRecordAccess> lstUserRecordAccess = new List<UserRecordAccess>();
                    lstUserRecordAccess = [select RecordId, HasReadAccess, HasEditAccess from UserRecordAccess
                                           where UserId =: UserInfo.getUserId() and RecordId = :sAcctId limit 1];
                    
                    // If the user doesn't have edit access to the Account
                    if (lstUserRecordAccess.isEmpty() || ((lstUserRecordAccess.size() > 0) && (lstUserRecordAccess[0].HasEditAccess == false))) {
                        
                        List<AccountTeamMember> lstAccountTeamMembers = new List<AccountTeamMember>();
                        lstAccountTeamMembers = [select Id, AccountId, UserId from AccountTeamMember
                                                 where AccountId = :sAcctId and UserId =: userInfo.getUserId()];
                                                
                        // If the user isn't on the Account team
                        if(lstAccountTeamMembers.isEmpty()) {
                            bUserHasAccess = false; 
                            bSeedsRenderFlag = false;
                            bSeedsErrorFlag = false;
                            bSamplesRenderFlag = false;
                            bSamplesErrorFlag = false;
                        }
                    }
                }
            }
            
            // If the user came straight to the tab, get their WWID using the URL parameter,
            // and set up all of our variables & URLs based on that
            else {
                List<User> lstUser = [select Id, Core_WWID__c,Core_User_Geo__c from User where Id = :UserInfo.getUserID()];
                sWWID = lstUser[0].Core_WWID__c;
                //UserRegion=lstUser[0].Core_User_Geo__c;
               // UIthemedisplayed=UserInfo.getUiThemeDisplayed();
                system.debug('Region'+UserRegion);
                system.debug('UIthemedisplayed'+UIthemedisplayed);
                
                
                sCimId = ApexPages.currentPage().getParameters().get(System.Label.Core_CIMID);
                
                orderSeedsURL = mapStringToCS.get(System.Label.Core_DemoDepotOrder).Core_End_Point_URL__c;
                requestSamplesURL = mapStringToCS.get(mySamplesHome).Core_End_Point_URL__c;
                
                if(sWWID == NULL){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING, System.Label.Core_WWID_Not_Found + System.Label.Core_Exception);
                    ApexPages.addMessage(myMsg);
                    bSeedsRenderFlag = true;
                    bSeedsErrorFlag = true;
                    bSamplesRenderFlag = true;
                    bSamplesErrorFlag = true;
                }
            }
            
            // Main URLs to get to the Demo Depot and My Samples systems
            viewSeedURL = mapStringToCS.get(System.Label.Core_DemoDepotOrderManagement).Core_End_Point_URL__c;
            viewSampleURL = mapStringToCS.get(mySamplesRequestManagement).Core_End_Point_URL__c;
            
            // See which tab the user was last on; if none, default to Seeds
            Cookie lastSalesSupportTab = ApexPages.currentPage().getCookies().get('lastSalesSupportTab');
            if (lastSalesSupportTab == null)
                sCurrentTab = 'tabSeeds';
            else {
                sCurrentTab = lastSalesSupportTab.getValue();
                //Intel Altera Phase1:
                //Calling pullPSGQuoteHistory  function to get the PSG Quote History if current tab selected is PSG Quote.
                //if( sCurrentTab == 'tabPSGQuote')
                     //pullPSGQuoteHistory();
                     
                //Intel Altera Phase1: 
                //Default the Tab to Seed if the page is loaded  from Account or from click of SalesSupport Tab  
                if( sCurrentTab == 'tabPSGQuote' &&  (!String.isEmpty(sAcctId) || (String.isEmpty(sAcctId) && String.isEmpty(sOppId))))  {
                    sCurrentTab = 'tabSeeds';
                }
                
            }
            
            lastSalesSupportTab = new Cookie('lastSalesSupportTab', sCurrentTab, '/apex', 365*24*60*60, false);
            ApexPages.currentPage().setCookies(new Cookie[]{lastSalesSupportTab});
        }
        catch (Exception e) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Core_Exception + e.getmessage());
            ApexPages.addMessage(myMsg);
            bSeedsRenderFlag = false;
            bSeedsErrorFlag = true;
            bSamplesRenderFlag = false;
            bSamplesErrorFlag = true;
        }
    }
    
    //Fetch the ISR List for partner
    public List<SelectOption> getISRList(){
        Core_SalesSupportHomeControllerHelper helper = new Core_SalesSupportHomeControllerHelper();
        return helper.fetchISRList();
    }
    
    public void init() {
    }

    // SSG Sales Support Request Changes
    /* Created On: Aug 17th, 2017
     * Created By: Rangesh Kona
     * Sales Support Home Redirects to SSG Support Request Page
     * only if User has navigated correctly from Opportunity Page
     * and if User has Read/Edit access to opportunity 
    */
    public PageReference processSSGRequest() {
        
        if (sOppId == null ) {
            showNavigationErrorMessage = true;
            return null;
        }
        if (bUserOptyWriteAccess == false) {
            showNoAccessMessage = true;
            return null;
        }
        PageReference pageRef = new PageReference(System.Label.Core_SSR_Support_Request_URL +'?Id='+ sOppId );
        return pageRef;
        
    }
    
   
    /**********************************
    * Method Name : pullPSGQuoteHistory 
    * Created On  : Dec-08-2016
    * Created By  : Accenture 
    * Description : Intel Altera Phase1: 
    *               Below method is used for getting the PSG Quote History associated with Opportunity.
    *        
    ***********************************/
    public void pullPSGQuoteHistory() {
          lstPSGQuoteGenarationHistory = new List<Core_PSG_Quote_Generation_History__c>();
          lstPSGQuoteGenarationHistory = [SELECT Id, Name, Core_RFQ_ID__c, Core_Opportunity__c, Core_Quote_URL__c, Core_Message_Status__c,CreatedDate, LastModifiedDate FROM Core_PSG_Quote_Generation_History__c where Core_Opportunity__c=:sOppId   order by LastModifiedDate desc  limit 10];

    }
    
    /**********************************
    * Method Name : createPSGQuoteonSiebel 
    * Created On  : Dec-05-2016
    * Created By  : Accenture 
    * Description : Intel Altera Phase1: 
    *               Below method is used for validating the opportunity and 
    *               for creating the Payload before sending the data to Siebel.
    ***********************************/

  
    
    public void createPSGQuoteonSiebel() {
        //Added for getting the record ID of the opportunity object
        String opptyId = ApexPages.currentPage().getParameters().get(System.Label.Core_OpportunityID);
        try
        {           
            //US63649: Add record level access through Apex Sharing - Ashwin 9th-May-2017
            UserRecordAccess recordAccessObj = [SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :soppId];
            if (recordAccessObj == null || recordAccessObj.HasEditAccess != true){                          
                SharingInnerClass innerClass = new SharingInnerClass();
                innerClass.insertSharing(opptyId);
            }
            
            //Below code validates the opportunity before quote creation and creates the payload for Quote creation 
            if(Core_SalesSupportPSGQuoteSFDCToSiebel.validateOpportuntyBeforeQuoteCreation()) {

                //Below method is used for creating the payload for valid Opportunity
                if(isPartner == true && selectedISR <> null){
                    Core_SalesSupportPSGQuoteSFDCToSiebel.selectedISR = selectedISR;
                } 
                String payload = Core_SalesSupportPSGQuoteSFDCToSiebel.createPayloadForOpportuntiyQuote();

                if(!String.isEmpty(payload)) {
                    
                    //Inserts the new record to Outbound message.
                    Core_Integration_Outbound_Message__c objOutboundMessage = new Core_Integration_Outbound_Message__c();
                    objOutboundMessage.Core_MessageType__c = 'PSG_Quote';
                    objOutboundMessage.Core_Payload__c =  payload;
                    insert objOutboundMessage;
                    
                    //Updates the Last Process Status of Opportunity to Processing.
                    Opportunity oppObjUpdate =[select Id,Core_PSG_Quote_Last_Processed_Status__c from Opportunity where Id=:ApexPages.currentPage().getParameters().get(System.Label.Core_OpportunityID)];
                    oppObjUpdate.Core_PSG_Quote_Last_Processed_Status__c='Processing';
                    update oppObjUpdate;
                    
                    //below code used for displaying the status message based on the existence of 
                    //PSGQuoteHistory and opportunity status.
                    if(lstPSGQuoteGenarationHistory.isEmpty()) {
                         bPSGQuoteHistoryExist = true;
                         bPSGQuoteProcessingInfoDisp = false;
                    }
                    else {
                         bPSGQuoteProcessingInfoDisp = false;
                         bPSGQuoteHistoryExist = false;
                    }
                    bOpportunityValidForQuoteCreation = false;
                    
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Confirm,System.Label.Core_PSG_Quote_Sent_Message);
                    ApexPages.addMessage(myMsg);
                }
            }
            else {
               //setting this boolean variable able display the error message.
               //Bit decides apex:Pagemessage has to be rendered or not
               bOpportunityValidForQuoteCreation = false;
               bSeedsErrorFlag = false;
            }
        }
        catch(Exception e) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, e.getMessage());
            ApexPages.addMessage(myMsg);
            bOpportunityValidForQuoteCreation = false;
        }
        //US63649: Adding finally block where we are removing R/W access from the user - Ashwin 9th-May-2017
        finally{
            SharingInnerClass innClass = new SharingInnerClass();
            innClass.deleteSharing(opptyId, UserInfo.getUserID());
        }
    }
    
    public void loadFirstTab() {
    
        System.debug('##### loadFirstTab');
    
        // Pull data if the parameters are set, either seeds or samples depending on which tab they're on
        if ((String.isNotBlank(sOppId) || String.isNotBlank(sWWID) || (String.isNotBlank(sAcctId) && String.isNotEmpty(sCimId))) && bUserHasAccess) {
            if (sCurrentTab == 'tabSeeds')
                pullSeeds();
            else if (sCurrentTab == 'tabSamples')
                pullSamples();
        }
        else if (bUserHasAccess) {
            if(String.isNotBlank(sOppId) || String.isNotBlank(sAcctRecName)) {
                // Throw the error saying no records are present
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO, System.Label.Core_NoRecordsError);
                ApexPages.addMessage(myMsg);
            }
            bSeedsRenderFlag = false;
            bSeedsErrorFlag = true;
            bSamplesRenderFlag = false;
            bSamplesErrorFlag = true;
        }
    }
    
    

    /*
    * Method name  : pullSeeds
    * Description  : This is used to make calls to the rest webservice and get the list of apex object from the JSON response
    * Return Type  : NONE
    * Parameter    : NONE
    */  
    public void pullSeeds() {
        
        sCurrentTab = 'tabSeeds';
        System.debug('##### entered pullSeeds');
        
        // Only pull seeds if we haven't yet pulled them (a full page refresh is needed to call the web service again)
        if ((lstFilteredSeeds == null) && (bSeedsErrorFlag == false)) {
            System.debug('##### trying to pull seeds');
    
            // Intialize the declared variables
            lstSeeds = new List<seedWebserviceWrapper> {};
            lstFilteredSeeds = new List<seedWebserviceWrapper> {};
            List<String> lstOppID = new List<String>{};
            List<String> lstAcctID = new List<String>{};
            Map<String,String> mapOppNametoID = new Map<String,String>{};
            Map<String,String> mapAcctNametoID = new Map<String,String>{};
            Map<String,seedWebserviceWrapper> mapOrderNoToSeed = new Map<String,seedWebserviceWrapper>{};
            List<String> lstOrderNo =new List<String>{};
        
            try {
                // Make the callout to the service
                HTTPResponse httpResp = new HTTPResponse();
                
                // If the user came via the tab
                if (String.isNotEmpty(sWWID)) {
                    httpResp = Core_WebServiceUtility.restServiceCallout('', mapStringToCS.get(System.Label.Core_SeedsWebservice).Core_End_Point_URL__c +
                                                                         System.Label.Core_SeedsURL+sWWID+'/ALL', 'Get', System.Label.Core_TimeOut,
                                                                         System.Label.Core_SeedsWebservice);
                }
                // If the user came via the account
                else if (String.isNotEmpty(sAcctRecName)) {
                    httpResp = Core_WebServiceUtility.restServiceCallout('', mapStringToCS.get(System.Label.Core_SeedsWebservice).Core_End_Point_URL__c +
                                                                         System.Label.Core_SeedsURLAccount+sCimId+'/ALL', 'Get', System.Label.Core_TimeOut,
                                                                         System.Label.Core_SeedsWebservice);
                }
                // If the user came via the opportunity
                else {
                    httpResp = Core_WebServiceUtility.restServiceCallout('', mapStringToCS.get(System.Label.Core_SeedsWebservice).Core_End_Point_URL__c +
                                                                         System.Label.Core_SeedsURLOpp + sOppId+'/ALL', 'Get', System.Label.Core_TimeOut,
                                                                         System.Label.Core_SeedsWebservice);                   
                }
                
                // Display an error message if we're not getting an OK response
                if (httpResp.getStatusCode() != 200) {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Core_Exception);
                    ApexPages.addMessage(myMsg);
                    bSeedsRenderFlag = false;  
                    bSeedsErrorFlag = true;
                    return;
                }
                
                // Use the parser to get the response as JSONParser type
                JSONParser parser = JSON.createParser(httpResp.getbody());
                
                while (parser.nextToken() != NULL) {
                    // Start at the array of Records.
                    if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                        while (parser.nextToken() != NULL) {
                            // Advance to the start object marker to find the next seed object
                            if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                                // Read entire seed object, including its array of line items
                                seedWebserviceWrapper seed  = (seedWebserviceWrapper) parser.readValueAs(seedWebserviceWrapper.class);
                                // Add the record to the list of Apex Objects
                                lstSeeds.add(seed);
                                parser.skipChildren();
                            }
                        }
                    }
                }
                
                // If the list of the Apex Object records to be rendered isn't empty, pull the opportunity & account IDs in them
                if (!lstSeeds.isEmpty()) {
                    for (seedWebserviceWrapper seed : lstSeeds) {
                        lstOppID.add(seed.OpportunityID);
                        lstAcctID.add(seed.AccountID);
                    }                
                    if (!lstOppID.isEmpty()) {
                        for(Opportunity sObjOpp : [select Id, Name from Opportunity where Id in :lstOppID]) {
                            mapOppNametoID.put(sObjOpp.ID, sObjOpp.Name);
                        }
                    }
                    if (!lstAcctID.isEmpty()) {
                        for(Account sObjAcct : [select Core_CIM_ID__c, Name from Account where Core_CIM_ID__c in :lstAcctID])
                            mapAcctNametoID.put(sObjAcct.Core_CIM_ID__c, sObjAcct.Name);
                    }   
                }
                
                // Convert the format of the Date from external source format to the salesforce format,
                // fetch opportunity & account names, map order numbers, and ensure the rendering flag is set
                for (seedWebserviceWrapper seed: lstSeeds) {
                    Date dt;
                    if (seed.RequestedDeliveryDate != NULL) {
                        dt = Date.Valueof(seed.RequestedDeliveryDate);
                        seed.RequestedDeliveryDate = dt.format();
                    }
                    if (seed.EstimatedShipDate != NULL) {
                        dt = Date.Valueof(seed.EstimatedShipDate);
                        seed.EstimatedShipDate = dt.format();
                    }
                    if (seed.ReturnPickupDate != NULL) {
                        dt = Date.Valueof(seed.ReturnPickupDate);
                        seed.ReturnPickupDate = dt.format();
                    }
                    
                    if(mapOppNametoID.containsKey(seed.OpportunityID))
                        seed.OpportunityName = mapOppNametoID.get(seed.OpportunityID);
                    if(mapAcctNametoID.containsKey(seed.AccountID))
                        seed.AccountName = mapAcctNametoID.get(seed.AccountID);
                    
                    lstOrderNo.add(seed.OrderNumber + seed.productname);
                    mapOrderNoToSeed.put(seed.OrderNumber + seed.productname, seed);
                    
                    if (seed.bRenderCSection == null)
                        seed.bRenderCSection = false;
                }
                
                // Sort the list by the descending order
                lstSeeds = new list < seedWebserviceWrapper > {};
                    for(Integer iRow = lstOrderNo.Size()-1; iRow>=0; iRow--) {
                        lstSeeds.add(mapOrderNoToSeed.get(lstOrderNo[iRow]));
                    }
                
                // If the list of the seeds to be rendered is empty, display an error message
                if (lstSeeds.isEmpty()) {
                    bSeedsRenderFlag = false;
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO, System.Label.Core_NoRecordsError);
                    ApexPages.addMessage(myMsg);
                    bSeedsErrorFlag = true;
                }
                else
                    bSeedsRenderFlag = true;
            }
            catch(Exception e){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Core_Exception + e.getmessage());
                System.debug(e.getmessage());
                ApexPages.addMessage(myMsg);
                //bRenderFlag = false;
                //bErrorFlag = true;
            }
            
            lstFilteredSeeds.addAll(lstSeeds);
        }
    }
    
    @TestVisible
    private Boolean seedMatchesFilters(seedWebserviceWrapper seed) {
        if ((String.isEmpty(sSeedSearch[0])  || (String.isNotEmpty(sSeedSearch[0])  && seed.OrderNumber != NULL && String.ValueOf(seed.OrderNumber).containsIgnoreCase(sSeedSearch[0]))) &&
            (String.isEmpty(sSeedSearch[1]) || (String.isNotEmpty(sSeedSearch[1]) && seed.ProductName != NULL &&  String.ValueOf(seed.ProductName).containsIgnoreCase(sSeedSearch[1]))) &&
            (String.isEmpty(sSeedSearch[2]) || (String.isNotEmpty(sSeedSearch[2]) && seed.EstimatedShipDate != NULL && String.ValueOf(seed.EstimatedShipDate).containsIgnoreCase(sSeedSearch[2]))) &&
            (String.isEmpty(sSeedSearch[3]) || (String.isNotEmpty(sSeedSearch[3]) && seed.RequestedDeliveryDate != NULL && String.ValueOf(seed.RequestedDeliveryDate).containsIgnoreCase(sSeedSearch[3]))) &&
            (String.isEmpty(sSeedSearch[4]) || (String.isNotEmpty(sSeedSearch[4]) && seed.LineItemStatus != NULL && String.ValueOf(seed.LineItemStatus).containsIgnoreCase(sSeedSearch[4]))) &&
            (String.isEmpty(sSeedSearch[5]) || (String.isNotEmpty(sSeedSearch[5]) && seed.ReturnPickupDate != NULL && String.ValueOf(seed.ReturnPickupDate).containsIgnoreCase(sSeedSearch[5]))) &&
            (String.isEmpty(sSeedSearch[6]) || (String.isNotEmpty(sSeedSearch[6]) && seed.Requestor != NULL && String.ValueOf(seed.Requestor).containsIgnoreCase(sSeedSearch[6]))) &&
            (String.isEmpty(sSeedSearch[7]) || (String.isNotEmpty(sSeedSearch[7]) && seed.RequestedQty != NULL && String.ValueOf(seed.RequestedQty).containsIgnoreCase(sSeedSearch[7]))) &&
            (String.isEmpty(sSeedSearch[8]) || (String.isNotEmpty(sSeedSearch[8]) && seed.AccountName != NULL && seed.AccountName.containsIgnoreCase(sSeedSearch[8]))) &&
            (String.isEmpty(sSeedSearch[9]) || (String.isNotEmpty(sSeedSearch[9]) && seed.OpportunityName != NULL && seed.OpportunityName.containsIgnoreCase(sSeedSearch[9]))))
            return true;
        else
            return false;
    }
    
    public void filterSeeds() {
        if(lstFilteredSeeds!=null){
        lstFilteredSeeds.clear();
        }        
        // If no search text has been entered, return the full original result set
        if (String.isEmpty(sSeedSearch[0]) && String.isEmpty(sSeedSearch[1]) && String.isEmpty(sSeedSearch[2]) && String.isEmpty(sSeedSearch[3]) 
            && String.isEmpty(sSeedSearch[4]) && String.isEmpty(sSeedSearch[5]) && String.isEmpty(sSeedSearch[6]) && String.isEmpty(sSeedSearch[7]) 
            && String.isEmpty(sSeedSearch[8]) && String.isEmpty(sSeedSearch[9])) {
                if(lstSeeds!=null){
                lstFilteredSeeds.addAll(lstSeeds);
                }
            }
        else {
            // Otherwise iterate through the list and return only the samples containing the search text
            if(lstSeeds!=null){
            for (seedWebserviceWrapper seed : lstSeeds) {
                if(seedMatchesFilters(seed)) {
                    lstFilteredSeeds.add(seed);
                }
            }
            }
        }
    }

    // Wrapper Class/Apex Object to hold seeds JSON response
    public class SeedWebserviceWrapper {
        
        public String AccountID { get; set; }
        public String AccountName { get; set; }
        
        public String OpportunityID { get; set; }
        public String OpportunityName { get; set; }
        
        public Integer OrderNumber { get; set; }
        public String OrderStatus { get; set; }
        
        public String RequestedDeliveryDate { get; set; }
        public String ReturnPickupDate { get; set; }
        
        public String Requestor { get; set; }
        public String Submitter { get; set; }
        
        public String ProductCode { get; set; }
        public String LineItemStatus { get; set; }
        public String ProductName { get; set; }
        
        public String EstimatedShipDate { get; set; }
        public String ActualShipDate { get; set; }
        
        public Integer RequestedQty { get; set; }
        public Integer ShippedQty { get; set; }
        
        public String ProductDesc { get; set; }
        public String ProductListDesc { get; set; }
        
        public String CompanyName { get; set; }
        
        public String StreetAddress1 { get; set; }
        public String StreetAddress2 { get; set; }
        public String MailStop { get; set; }
        public String City { get; set; }
        public String State { get; set; }
        public String ZipCode { get; set; }
        public String Country { get; set; }
        
        public String AttentionName { get; set; }
        public String AttentionNumber { get; set; }
        
        public String Notes { get; set; }
        
        public String Status { get; set; }
        
        public String Message { get; set; }
        
        public Boolean bRenderCSection { get; set; }

        public SeedWebserviceWrapper parse(String json) {
            //Deserialize the specified JSON string into an Apex object of the specified type.
            return (SeedWebserviceWrapper) System.JSON.deserialize(json, SeedWebserviceWrapper.class);
        }
    }

    /*
    * Method name  : pullSamples
    * Description  : Calls the REST web service to get a list of samples wrapper objects from the JSON response
    * Return Type  : NONE
    * Parameter    : NONE
    */  
    public void pullSamples() {
        
        sCurrentTab = 'tabSamples';
        System.debug('##### entered pullSamples');
        
        // Only pull samples if we haven't yet pulled them (a full page refresh is needed to call the web service again)
        if ((lstFilteredSamples == null) && (bSamplesErrorFlag == false)) {
            
            System.debug('##### trying to pull samples');
            lstSamples = new List<sampleWebserviceWrapper> {};
            lstFilteredSamples = new List<sampleWebserviceWrapper> {};
            Set<String> setOppID = new Set<String>{};
            Set<String> setAcctCIMID = new Set<String>{};
            Map<String,String> mapOppIDtoName = new Map<String,String>{};
            Map<String,String> mapOppIDtoStage = new Map<String,String>{};
            Map<String,String> mapAcctCIMIDtoID = new Map<String,String>{};
            Map<String,String> mapAcctCIMIDtoName = new Map<String,String>{};
            Map<String,Integer> mapRequestIDLineToApprovedQty = new Map<String,Integer>();
            
            try {
                // Make the callout to the service
                HTTPResponse httpResp = new HTTPResponse();
                
                // If the user came via the tab
                if (String.isNotEmpty(sWWID)) {
                    httpResp = Core_WebServiceUtility.restServiceCallout('', mapStringToCS.get('My Samples Service').Core_End_Point_URL__c +
                                                                         '/wwid/' + sWWID, 'Get', System.Label.Core_TimeOut, 'My Samples Service');
                }
                // If the user came via the account
                else if (String.isNotEmpty(sAcctRecName)) {
                    httpResp = Core_WebServiceUtility.restServiceCallout('', mapStringToCS.get('My Samples Service').Core_End_Point_URL__c +
                                                                         '/account/' + sCimId, 'Get', System.Label.Core_TimeOut, 'My Samples Service');
                }
                // If the user came via the opportunity
                else {
                    httpResp = Core_WebServiceUtility.restServiceCallout('', mapStringToCS.get('My Samples Service').Core_End_Point_URL__c +
                                                                         '/opportunity/' + sOppId, 'Get', System.Label.Core_TimeOut, 'My Samples Service');                   
                }
                
                // Display an error message if we're not getting an OK response
                if (httpResp.getStatusCode() != 200) {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Core_Exception);
                    ApexPages.addMessage(myMsg);
                    bSamplesRenderFlag = false;  
                    bSamplesErrorFlag = true;
                    return;
                }
                
                System.debug('##### httpResp = ' + httpResp);
                System.debug('##### httpResp.getBody = ' + httpResp.getbody());
                
                // Use the parser to get the response as JSONParser type
                JSONParser parser = JSON.createParser(httpResp.getbody());
                
                while (parser.nextToken() != NULL) {
                    // Start at the array of Records.
                    if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                        while (parser.nextToken() != NULL) {
                            // Advance to the start object marker to find the next sample object
                            if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                                // Read entire object
                            
                                SampleWebserviceWrapper sample  = (SampleWebserviceWrapper) parser.readValueAs(SampleWebserviceWrapper.class);
                                
                                // Add the record to the list of Apex Objects
                                lstSamples.add(sample);
                                parser.skipChildren();
                            }
                        }
                    }
                }
                
                // If the list of the samples records to be rendered isn't empty, pull the opportunity association data
                // (including account data) for each of them. Start by adding all oppty/acct IDs to sets, then pull names,
                // stages, etc. using those sets.
                if (!lstSamples.isEmpty()) {
                    
                    for (SampleWebserviceWrapper sample : lstSamples) {
                        for (SampleOpportunityAssociation oppAssoc : sample.Opportunity) {
                            if ((oppAssoc.OpportunityID != null) && (oppAssoc.OpportunityID != ''))
                                setOppID.add(oppAssoc.OpportunityID);
                            if ((oppAssoc.AccountCIMID != null) && (oppAssoc.AccountCIMID != ''))
                                setAcctCIMID.add(oppAssoc.AccountCIMID);
                        }
                        
                        if ((sample.CustomerCIMID != null) && (sample.CustomerCIMID != '')) setAcctCIMID.add(sample.CustomerCIMID);
                        if ((sample.DefaultCIM    != null) && (sample.DefaultCIM    != '')) setAcctCIMID.add(sample.DefaultCIM);    // Remove this line later, once attribute name is fixed
                        if ((sample.DefaultCIMID  != null) && (sample.DefaultCIMID  != '')) setAcctCIMID.add(sample.DefaultCIMID);
                        
                        // For any approved requests, keep a running total of how many for that Request ID & Line have
                        // been approved, so we can use that to adjust requested numbers for non-approved lines later
                        if (sample.ApproverName != '') {
                            String key = sample.RequestID + sample.Line;
                            Integer approvedVal = 0;
                            if (mapRequestIDLineToApprovedQty.containsKey(key))
                                approvedVal = mapRequestIDLineToApprovedQty.get(key);
                            approvedVal += Integer.valueOf(sample.ApprovedQty);
                            mapRequestIDLineToApprovedQty.put(key, approvedVal);
                        }
                    }
                    
                    if (!setOppID.isEmpty()) {
                        for(Opportunity opp : [select Id, Name, StageName from Opportunity where Id in :setOppID]) {
                            mapOppIDtoName.put(opp.ID, opp.Name);
                            mapOppIDtoStage.put(opp.ID, opp.StageName);
                        }
                    }
                    if (!setAcctCIMID.isEmpty()) {
                        // Get account info, regardless of covered/non-covered, but order it by: non-covered then covered, so we can just
                        // iterate through it and be assured that if there's multiple accounts with the same CIM ID, we overwrite non-covered
                        // account info with the covered account
                        List<Account> accounts = [select Id, Core_CIM_ID__c, Name, Core_Covered_Account__c from Account
                                                  where Core_CIM_ID__c in :setAcctCIMID order by Core_Covered_Account__c, Core_CIM_ID__c];
                        
                        for (Account a : accounts) {
                            mapAcctCIMIDtoID.put(a.Core_CIM_ID__c, a.Id);
                            mapAcctCIMIDtoName.put(a.Core_CIM_ID__c, a.Name);
                        }
                    }
                    
                    // Loop back through all of the samples to set everything the way we want it displayed
                    for (SampleWebserviceWrapper sample : lstSamples) {
                        
                        Set<String> acctNames = new Set<String>();
                        Set<String> oppNames = new Set<String>();
                        Set<String> oppStages = new Set<String>();
                        
                        // Account & opportunity data
                        for (SampleOpportunityAssociation oppAssoc : sample.Opportunity) {
                            oppAssoc.AccountId = mapAcctCIMIDtoID.get(oppAssoc.AccountCIMID);
                            oppAssoc.AccountName = mapAcctCIMIDtoName.get(oppAssoc.AccountCIMID);
                            oppAssoc.OpportunityName = mapOppIDtoName.get(oppAssoc.OpportunityID);
                            oppAssoc.OpportunityStage = mapOppIDtoStage.get(oppAssoc.OpportunityID);
                            
                            if (String.isNotBlank(oppAssoc.AccountName)) acctNames.add(oppAssoc.AccountName);
                            if (String.isNotBlank(oppAssoc.OpportunityName)) oppNames.add(oppAssoc.OpportunityName);
                            if (String.isNotBlank(oppAssoc.OpportunityStage)) oppStages.add(oppAssoc.OpportunityStage);
                        }
                        
                        // If we don't have account name via the opportunity association, see if we have it via one of the other fields
                        if (acctNames.size() == 0) {
                            if (sample.CustomerCIMID != '') acctNames.add(mapAcctCIMIDtoName.get(sample.CustomerCIMID));
                            else if (sample.DefaultCIM != '') acctNames.add(mapAcctCIMIDtoName.get(sample.DefaultCIM));  // Remove this line later, once attribute name is fixed
                            else if (sample.DefaultCIMID != '') acctNames.add(mapAcctCIMIDtoName.get(sample.DefaultCIMID));
                        }
                        
                        // Set the grid view display to one or "Multiple" depending on how many there are
                        if (acctNames.size() == 1)
                            sample.GridViewAccountName = new List<String>(acctNames)[0];
                        else if (acctNames.size() > 1)
                            sample.GridViewAccountName = 'Multiple';
                        
                        if (oppNames.size() == 1)
                            sample.GridViewOpportunityName = new List<String>(oppNames)[0];
                        else if (oppNames.size() > 1)
                            sample.GridViewOpportunityName = 'Multiple';
                        
                        if (oppStages.size() == 1)
                            sample.GridViewOpportunityStage = new List<String>(oppStages)[0];
                        else if (oppStages.size() > 1)
                            sample.GridViewOpportunityStage = 'Multiple';
                        
                        if (sample.Opportunity.size() >= 1) {
                            sample.DetailViewCIMIDs = '';
                            sample.DetailViewOppIDs = '';
                            for (SampleOpportunityAssociation oppAssoc : sample.Opportunity) {
                                if (String.isNotBlank(oppAssoc.AccountCIMID)) sample.DetailViewCIMIDs += oppAssoc.AccountCIMID + ', ';
                                if (String.isNotBlank(oppAssoc.OpportunityId)) sample.DetailViewOppIDs += oppAssoc.OpportunityId + ', ';
                            }
                            sample.DetailViewCIMIDs = sample.DetailViewCIMIDs.left(sample.DetailViewCIMIDs.length() - 2);
                            sample.DetailViewOppIDs = sample.DetailViewOppIDs.left(sample.DetailViewOppIDs.length() - 2);
                        }
                        else if (sample.CustomerCIMID != '') sample.DetailViewCIMIDs = sample.CustomerCIMID;
                        else if (sample.DefaultCIM != '') sample.DetailViewCIMIDs = sample.DefaultCIM;  // Remove this line later, once attribute name is fixed
                        else if (sample.DefaultCIMID != '') sample.DetailViewCIMIDs = sample.DefaultCIMID;
                        
                        // Adjust the numbers from the My Samples physical DB numbers to the user-friendly
                        // numbers that match the My Samples UI
                        if (sample.ApproverName == '') {
                            sample.ApprovedQty = '0';
                            String key = sample.RequestID + sample.Line;
                            if (mapRequestIDLineToApprovedQty.containsKey(key))
                                sample.RequestQty = (Integer.valueOf(sample.RequestQty) - mapRequestIDLineToApprovedQty.get(key)).format();
                        }
                        
                        // Convert the format of the Date from external source format to the salesforce format
                        if(sample.RDD != NULL) {
                            Date dt = Date.Valueof(sample.RDD);
                            sample.RDD = dt.format();
                        }
                    }
                }
                // Sort the samples based on our implementation of the Comparable interface, which essentially sorts
                // in descending order of Request ID + Line ID + the ordering of Status we want within the same ID
                lstSamples.sort();
                
                // If the list of the samples to be rendered is empty, display an error
                if (lstSamples.isEmpty()) {
                    bSamplesRenderFlag = false;
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO, System.Label.Core_NoRecordsError);
                    ApexPages.addMessage(myMsg);
                    bSamplesErrorFlag = true;
                }
                else
                    bSamplesRenderFlag = true;
            }
            catch (Exception e) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Core_Exception + e.getmessage());
                System.debug(e.getmessage());
                ApexPages.addMessage(myMsg);
                //bRenderFlag = false;
                //bErrorFlag = true;
            }
            System.debug('*******lstSamples******'+lstSamples);
            // Set the List of records to be shown on the VF page
            lstFilteredSamples.addAll(lstSamples);
        }
    }
    
    @TestVisible
    private Boolean sampleMatchesFilters(sampleWebserviceWrapper sample) {
        if ((String.isEmpty(sSampleSearch[0])  || (String.isNotEmpty(sSampleSearch[0])  && sample.RequestID != NULL                && String.ValueOf(sample.RequestID).containsIgnoreCase(sSampleSearch[0]))) &&
            (String.isEmpty(sSampleSearch[1])  || (String.isNotEmpty(sSampleSearch[1])  && sample.Line != NULL                     && String.ValueOf(sample.Line).containsIgnoreCase(sSampleSearch[1]))) &&
            (String.isEmpty(sSampleSearch[2])  || (String.isNotEmpty(sSampleSearch[2])  && sample.RequestedEPMName != NULL         && String.ValueOf(sample.RequestedEPMName).containsIgnoreCase(sSampleSearch[2]))) &&
            (String.isEmpty(sSampleSearch[3])  || (String.isNotEmpty(sSampleSearch[3])  && sample.RDD != NULL                      && String.ValueOf(sample.RDD).containsIgnoreCase(sSampleSearch[3]))) &&
            (String.isEmpty(sSampleSearch[4])  || (String.isNotEmpty(sSampleSearch[4])  && sample.Status != NULL                   && String.ValueOf(sample.Status).containsIgnoreCase(sSampleSearch[4]))) &&
            (String.isEmpty(sSampleSearch[5])  || (String.isNotEmpty(sSampleSearch[5])  && sample.Requester != NULL                && String.ValueOf(sample.Requester).containsIgnoreCase(sSampleSearch[5]))) &&
            (String.isEmpty(sSampleSearch[6])  || (String.isNotEmpty(sSampleSearch[6])  && sample.RequestQty != NULL               && String.ValueOf(sample.RequestQty).containsIgnoreCase(sSampleSearch[6]))) &&
            (String.isEmpty(sSampleSearch[7])  || (String.isNotEmpty(sSampleSearch[7])  && sample.ApprovedQty != NULL              && String.ValueOf(sample.ApprovedQty).containsIgnoreCase(sSampleSearch[7]))) &&
            (String.isEmpty(sSampleSearch[8])  || (String.isNotEmpty(sSampleSearch[8])  && sample.GridViewAccountName != NULL      && String.ValueOf(sample.GridViewAccountName).containsIgnoreCase(sSampleSearch[8]))) &&
            (String.isEmpty(sSampleSearch[9])  || (String.isNotEmpty(sSampleSearch[9])  && sample.GridViewOpportunityName != NULL  && String.ValueOf(sample.GridViewOpportunityName).containsIgnoreCase(sSampleSearch[9]))) &&
            (String.isEmpty(sSampleSearch[10]) || (String.isNotEmpty(sSampleSearch[10]) && sample.GridViewOpportunityStage != NULL && String.ValueOf(sample.GridViewOpportunityStage).containsIgnoreCase(sSampleSearch[10]))) &&
            (String.isEmpty(sSampleSearch[11]) || (String.isNotEmpty(sSampleSearch[11]) && sample.ApproverName != NULL             && String.ValueOf(sample.ApproverName).containsIgnoreCase(sSampleSearch[11]))))
            return true;
        else
            return false;
    }
    
    public void filterSamples() {
     
        if (lstFilteredSamples == NULL)
            lstFilteredSamples = new List<SampleWebserviceWrapper>();
            
        lstFilteredSamples.clear();
        
        // If no search text has been entered, return the full original result set
        if (String.isEmpty(sSampleSearch[0]) && String.isEmpty(sSampleSearch[1]) && String.isEmpty(sSampleSearch[2]) && String.isEmpty(sSampleSearch[3]) &&
            String.isEmpty(sSampleSearch[4]) && String.isEmpty(sSampleSearch[5]) && String.isEmpty(sSampleSearch[6]) && String.isEmpty(sSampleSearch[7]) &&
            String.isEmpty(sSampleSearch[8]) && String.isEmpty(sSampleSearch[9]) && String.isEmpty(sSampleSearch[10]) && String.isEmpty(sSampleSearch[11])) {
                
                lstFilteredSamples.addAll(lstSamples);
            }
        else {
            // Otherwise iterate through the list and return only the samples containing the search text
            for (sampleWebserviceWrapper sample : lstSamples) {
                if(sampleMatchesFilters(sample)) {
                    lstFilteredSamples.add(sample);
                }
            }
        }
    }
    
    public PageReference toggleRendering() {
        return null;
    }
    
    
    private class SampleOpportunityAssociation {
        private String AccountId;
        private String AccountName;
        private String AccountCIMID;
        
        private String OpportunityId;
        private String OpportunityName;
        private String OpportunityStage;
    }

    // Wrapper class to hold samples JSON response
    public class SampleWebserviceWrapper implements Comparable {
        
        public String RequestProductID { get; set; }
        public String RequestID { get; set; }
        public String RDD { get; set; }
        public String Line { get; set; }
        public String RequestedMM { get; set; }
        public String RequestedEPMName { get; set; }
        public String ApprovedMM { get; set; }
        public String ApprovedEPMName { get; set; }
        public String Requester { get; set; }
        public String RequestQty { get; set; }
        public String ApprovedQty { get; set; }
        public String OBO { get; set; }
        public String ApproverName { get; set; }
        public String ApproverEmail { get; set; }
        public String Status { get; set; }
        public String Socket { get; set; }
        public String Media { get; set; }
        public String Stepping { get; set; }
        public String QDF { get; set; }
        public String BoxQuantity { get; set; }
        public String Contact { get; set; }
        public String CustomerName { get; set; }
        public String CustomerCMFID { get; set; }
        public String ShiptoCustomerName { get; set; }
        public String ShipToCustomerCMFID { get; set; }
        public String StreetAddress1 { get; set; }
        public String StreetAddress2 { get; set; }
        public String City { get; set; }
        public String StateName { get; set; }
        public String ZipCode { get; set; }
        public String Country { get; set; }
        public String ActualShipDtm { get; set; }
        public String TrackingIdForCarrier1Txt { get; set; }
        public String TrackingIdForCarrier2Txt { get; set; }
        public String CustomerCIMID { get; set; }
        public String DefaultCIM { get; set; }
        public String DefaultCIMID { get; set; }
        
        public List<SampleOpportunityAssociation> Opportunity { get; set; }
        
        public String GridViewAccountName { get; set; }
        public String GridViewOpportunityName { get; set; }
        public String GridViewOpportunityStage { get; set; }
        
        public String DetailViewCIMIDs { get; set; }
        public String DetailViewOppIDs { get; set; }
        
        //public String Message { get; set; }
        
        public Boolean bRenderCSection { get; set; }

        public SampleWebserviceWrapper parse(String json) {
            //Deserialize the specified JSON string into an Apex object of the specified type.
            return (SampleWebserviceWrapper) System.JSON.deserialize(json, SampleWebserviceWrapper.class);
        }
        
        // When sorting, ensure they're sorted in descending order, by Request ID + Line + the ordering we want for Approval Status,
        // so when sorted in descending order, they would appear like: 438-100-Approved, 423-100-Approved, 423-100 Requested, 238-100 Approved.
        // Also, we need to zero-pad the numbers, so the sorting works regardless of number of digits.  And "Line" needs to be flipped, in
        // terms of sort order, so it goes 100, 200, 300 for a given Request ID, even though overall it's sorted in reverse order.
        public Integer compareTo(Object compareTo) {
            SampleWebserviceWrapper compareToSample = (SampleWebserviceWrapper) compareTo;
            
            String statusSortVal = '';
            if (Status == 'Requested') statusSortVal = 'A'; else if (Status == 'Approved') statusSortVal = 'ZZZZZZZZ';
            String sortString = pad(RequestID, 12, '0') + pad(String.valueOf(1000000-Integer.valueOf(Line)), 6, '0') + statusSortVal;
            
            if (compareToSample.Status == 'Requested') statusSortVal = 'A';
            else if (compareToSample.Status == 'Approved') statusSortVal = 'ZZZZZZZZ';
            String compareToSortString = pad(compareToSample.RequestID, 12, '0') +
                pad(String.valueOf(1000000-Integer.valueOf(compareToSample.Line)), 6, '0') + statusSortVal;
            
            Integer returnValue = 0;
            if (sortString < compareToSortString)
                returnValue = 1;
            else if (sortString > compareToSortString)
                returnValue = -1;
            return returnValue;
        }
        
        private String pad(String nonPaddedStr, Integer paddedLen, String padChar) {
            return padChar.repeat(paddedLen-nonPaddedStr.length()) + nonPaddedStr;
        }
    }
    
    //US63649: Inner class added for removing Apex Sharing Rule assigned to user - Ashwin 9th-May-2017
    public without sharing class SharingInnerClass{
        public void insertSharing(String opptyId){
            OpportunityShare oppShare = New OpportunityShare();
            oppShare.UserOrGroupID = UserInfo.getUserId();
            oppShare.OpportunityAccessLevel = 'Edit';
            oppShare.OpportunityId = opptyId;
            oppShare.rowCause = Schema.OpportunityShare.RowCause.Manual;
            insert oppShare;
        }
        public void deleteSharing(String optyId, String userId){
            List<OpportunityShare> oppShareDeleteList = [select id from OpportunityShare where OpportunityId = :optyId and RowCause = :Schema.OpportunityShare.RowCause.Manual and UserOrGroupID = :userId];
            if(!oppShareDeleteList.isEmpty()){
                delete oppShareDeleteList;
            }
        }
    }
    
    //US-0002513 : Inner class added to fetch the list ISR assigned to public group
    public without sharing class Core_SalesSupportHomeControllerHelper {
        
        //Fetch the ISR List for partner
        public List<SelectOption> fetchISRList(){
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('','--None--'));
            Group ISRGroup = [select id, DeveloperName from group where type='Regular' and DeveloperName =: 'Core_ISR_for_Partner'];
            List<GroupMember> memberList = [select UserOrGroupId FROM GroupMember WHERE GroupId =: ISRGroup.Id];
            if(memberList.size() > 0){
                List<String> idList = new List<String>();
                for(GroupMember u : memberList){
                    idList.add(u.UserOrGroupId);
                }
                List<User> userList = [select Id, Name, Core_Login_Id__c, Email, Profile.Name from User where Id IN: idList];
                for(User us : userList){
                    if(us.Core_Login_Id__c <> null){
                        options.add(new SelectOption(us.Core_Login_Id__c, us.Name));
                    }
                }
            }
            return options;
        }
    }
}