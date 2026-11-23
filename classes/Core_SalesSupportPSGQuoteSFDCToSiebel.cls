/**************************************************************************************
* Apex Class Name:  Core_SalesSupportPSGQuoteSFDCToSiebel 
* Version     : 1.0 
* Created Date: 5 DEC 2016
* Description : Intel Altera Phase1: 
                This class contains the functionality for verifying the opportunity 
                and creating the payload
* Modification Log :
* Developer           Date               Description
* ----------------------------------------------------------------------------    
* Accenture        5-DEC-2016       Original Version
* Venu Karumuru    3-MAR-2017       Updated validateOpportuntyBeforeQuoteCreation() to check if the user has R/W Access to Opportunity
* Venu Karumuru    15-JAN-2018		Validated the additional DDR fields sent, updated code to not send idsid for Partner Users
* Venu Karumuru    30-JAN-2018		Added Opportunity Description to Quote Message
*************************************************************************************/

public without sharing class  Core_SalesSupportPSGQuoteSFDCToSiebel {
    

    static final String STATUS_CANCELLED  = 'Cancelled';
    static final String STATUS_PROD_CANCELLED  = 'Production Cancelled';
   @AuraEnabled public static String errorMessage{get;set;}//Shivini
   @AuraEnabled public static Boolean isValid{get;set;}//Shivini
    
    public static String selectedISR = '';

    /**********************************
    * Method Name : isSalesSupportHomePageAccessible
    * Created On  : Dec-13-2016
    * Created By  : Accenture
    * Description : Intel Altera Phase1:
    *               This method is used for checking SalesSupportHome Accessible 
    *               for the logged in user.
    ***********************************/

     public static Boolean isSalesSupportHomePageAccessible() {
        List < SetupEntityAccess> SEA =[SELECT Id, Parent.Name, Parent.Profile.Name, Parent.Profile.Id FROM SetupEntityAccess WHERE Parent.Profile.Id = :UserInfo.getProfileId() AND SetupEntityId in (SELECT Id FROM ApexPage WHERE Name =: System.label.Core_PSG_Sales_Support_Page AND NamespacePrefix = null)];
        if(SEA.isEmpty()) {
        return false;
        }
        return true;
     }


    /**********************************
    * Method Name : writeErrorMessage
    * Created On  : Jan-3-2016
    * Created By  : Accenture
    * Description : Intel Altera Phase1:
    *               This method is used for writing the Error message during validation 
    *               before Quote creation.
    ***********************************/

    public static void writeErrorMessage(String errorMessage) {
          ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,errorMessage);
          ApexPages.addMessage(myMsg);
        
    }
//Shivini
    @AuraEnabled public static String errorMessages(String errorMessage) {
    return errorMessage;
}
    /**********************************
    * Method Name : validateOpportuntyBeforeQuoteCreation
    * Created On  : Dec-13-2016
    * Created By  : Accenture
    * Description : Intel Altera Phase1:
    *               This method is used for validating the Opportunity 
    *               Before Quote creation.
    ***********************************/

     public static Boolean validateOpportuntyBeforeQuoteCreation() {
        
        // Get the Opportunity Id
        String soppId = ApexPages.currentPage().getParameters().get(System.Label.Core_OpportunityID);
        
        // Check if Opportunity Id values exists
        if (String.isEmpty(soppId)) {
            writeErrorMessage(System.Label.Core_PSG_Validate_Quote_Opportunity);
            return false;
        }

        // Check if the user has Read/Write Access to the Opportunity
        UserRecordAccess recordAccessObj = [SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :soppId];
        if (recordAccessObj == null || recordAccessObj.HasEditAccess != true) {
            writeErrorMessage(System.Label.Core_PSG_Validate_Opportunity_Access);
            return false;
        }

        // Get the Opportunity Details
        Opportunity oppObj = [SELECT Id, Core_PSG_Quote_Last_Processed_Status__c, AccountId, Core_First_Customer_Ship_Date__c, Core_Volume__c FROM Opportunity WHERE Id = :soppId];

        // Check if there is a quote request is progress
        if (oppObj.Core_PSG_Quote_Last_Processed_Status__c == 'Processing') {
            writeErrorMessage(System.Label.Core_PSG_Opportunity_Quote_Creation_Status);
            return false;
        }

        // Check if the Account associated to the Opportunity is a PSG Account
        Account accObj = [SELECT Id,Core_Account_Type__c, Core_PSG_Account__c FROM Account WHERE Id = :oppObj.AccountId];
        if(!accObj.Core_PSG_Account__c) {
            writeErrorMessage(System.Label.Core_PSG_Validate_Quote_Account);
            return false; 
        }

        // Check if First Customer Ship Date and Volume have values
        
        if (oppObj.Core_First_Customer_Ship_Date__c == null || oppObj.Core_Volume__c == null ) {
          writeErrorMessage(System.Label.Core_PSG_Opportunity_Fields_Required);
          
            return false;
        }
         

        // Get the list of PSG Products associated to the Opportunity
        List<OpportunityLineItem> opportunityProducts = [SELECT Id, Product2.Name, Product2Id, Quantity FROM OpportunityLineItem WHERE Core_Product_Type__c = 'Intel® FPGAs' AND OpportunityId =: oppObj.Id AND Core_Status__c != :STATUS_CANCELLED AND Core_Status__c != :STATUS_PROD_CANCELLED];

        // Check if there are any PSG Products associated to the Opportunity
        if (opportunityProducts.isEmpty()) {
            writeErrorMessage(System.Label.Core_PSG_Product_Required);
            return false;
        }

        // No validation errors
        return true;
     }

    //Shivini
    @AuraEnabled
    public static Map<String, Object> validateOpportunityBeforeQuoteCreationNew(Id opportunityId) {
        Map<String, Object> result = new Map<String, Object>();
        List<String> errorMessages = new List<String>();
        Boolean isValid = true;
    
        // Check if Opportunity Id is provided
        if (opportunityId == null) {
            errorMessages.add(System.Label.Core_PSG_Validate_Quote_Opportunity);
            isValid = false;
        }
    
        // Check if the user has Read/Write Access to the Opportunity
        UserRecordAccess recordAccessObj = [
            SELECT RecordId, HasEditAccess
            FROM UserRecordAccess
            WHERE UserId = :UserInfo.getUserId()
                AND RecordId = :opportunityId
        ];
    
        if (recordAccessObj == null || !recordAccessObj.HasEditAccess) {
            errorMessages.add(System.Label.Core_PSG_Validate_Opportunity_Access);
            isValid = false;
        }
    
        // Get the Opportunity Details
        Opportunity oppObj = [
            SELECT Id, Core_PSG_Quote_Last_Processed_Status__c, AccountId, Core_First_Customer_Ship_Date__c, Core_Volume__c
            FROM Opportunity
            WHERE Id = :opportunityId
        ];
    
        // Check if there is a quote request in progress
        if (oppObj.Core_PSG_Quote_Last_Processed_Status__c == 'Processing') {
            errorMessages.add(System.Label.Core_PSG_Opportunity_Quote_Creation_Status);
            isValid = false;
        }
    
        // Check if the Account associated with the Opportunity is a PSG Account
        Account accObj = [
            SELECT Id, Core_Account_Type__c, Core_PSG_Account__c
            FROM Account
            WHERE Id = :oppObj.AccountId
        ];
    
        if (!accObj.Core_PSG_Account__c) {
            errorMessages.add(System.Label.Core_PSG_Validate_Quote_Account);
            isValid = false;
        }
    
       
    
        // Check if First Customer Ship Date and Volume have values
        if (oppObj.Core_First_Customer_Ship_Date__c == null || oppObj.Core_Volume__c == null) {
            errorMessages.add(System.Label.Core_PSG_Opportunity_Fields_Required);
            isValid = false;
        }
    
        // Get the list of PSG Products associated with the Opportunity
        List<OpportunityLineItem> opportunityProducts = [
            SELECT Id, Product2.Name, Product2Id, Quantity
            FROM OpportunityLineItem
            WHERE Core_Product_Type__c = 'Intel® FPGAs'
                AND OpportunityId = :oppObj.Id
                AND Core_Status__c != :STATUS_CANCELLED
                AND Core_Status__c != :STATUS_PROD_CANCELLED
        ];
    
        // Check if there are any PSG Products associated with the Opportunity
        if (opportunityProducts.isEmpty()) {
            errorMessages.add(System.Label.Core_PSG_Product_Required);
            isValid = false;
        }
    
        // Prepare the result map
        result.put('isValid', isValid);
        result.put('errorMessages', errorMessages);
    
        return result;
    }
    
    
    /**********************************
    * Method Name : processPSGQuoteMessage
    * Created On  : Dec-13-2016
    * Created By  : Accenture
    * Description : Intel Altera Phase1:
    *               This method is used for Parsing the
    *               Response obtained from Siebel
    ***********************************/

    public static void processPSGQuoteMessage(List<Core_Integration_Inbound_Message__c> newQuoteList) {
        String processingStatus='Pending';
        String exceptionMessage='';
        try {
            List<SiebelResponse> siebelResponseProcessedList = new List<SiebelResponse>();
            List<Core_PSG_Quote_Generation_History__c> quoteGenarationHistoryList = new List<Core_PSG_Quote_Generation_History__c>();
            Map<String,SiebelResponse> siebelResponseMap = new Map<String,SiebelResponse> ();
            for( Core_Integration_Inbound_Message__c obj : newQuoteList ) {
                if(!String.isBlank(obj.Core_Payload__c)) {
                    siebelResponseProcessedList.add(processpayLoad(obj.Core_Payload__c));
                }
            }

            if(!siebelResponseProcessedList.isEmpty()) {

                for(SiebelResponse objResponse :siebelResponseProcessedList) {
                    siebelResponseMap.put(objResponse.OpportunityId,objResponse);
                    Core_PSG_Quote_Generation_History__c objQuoteHistory = new Core_PSG_Quote_Generation_History__c();
                    objQuoteHistory.Core_RFQ_ID__c = objResponse.RFQId;
                    objQuoteHistory.Core_Quote_URL__c =objResponse.QuoteURL;
                    objQuoteHistory.Core_Message_Status__c =objResponse.Status;
                    objQuoteHistory.Core_Error_Code__c =objResponse.ErrorCode;
                    objQuoteHistory.Core_Error_Message__c =objResponse.ErrorMessage;
                    objQuoteHistory.Core_Opportunity__c = objResponse.OpportunityId;
                    quoteGenarationHistoryList.add(objQuoteHistory);
                }
            }
            if(!(quoteGenarationHistoryList.isEmpty())) {
                insert quoteGenarationHistoryList;
                List<Opportunity> oppList = [select Id,Core_PSG_Quote_Last_Processed_Date__c,Core_PSG_Quote_Last_Processed_Status__c from Opportunity where Id IN: siebelResponseMap.keySet()];
                for(Opportunity opp :oppList) {
                    SiebelResponse objResponse = siebelResponseMap.get(opp.Id);
                    opp.Core_PSG_Quote_Last_Processed_Status__c = 'Success';
                    opp.Core_PSG_Quote_Last_Processed_Date__c = DateTime.Now();
                }
                update oppList;
                processingStatus='Successful';
            }
        }
        catch(Exception e) {
             processingStatus='Failed';
             exceptionMessage = e.getMessage();
        }
        // Update Processing Status to "Successful" or "Failure" depending on above
        for (Core_Integration_Inbound_Message__c msg : (List<Core_Integration_Inbound_Message__c>) Trigger.new) {
           msg.Core_Processing_Status__c = processingStatus;
           if(!String.isEmpty(exceptionMessage))
                msg.Core_Exception_Message__c = exceptionMessage;
        }
    }

     /**********************************
    * Method Name : processpayLoad
    * Created On  : Dec-13-2016
    * Created By  : Accenture
    * Description : Intel Altera Phase1:
    *               This method is used for Processing the payload
    *
    ***********************************/

    public static  SiebelResponse processpayLoad(String payload) {

        Dom.Document docx = new Dom.Document();
        docx.load(Payload);
        dom.XmlNode xroot = docx.getrootelement() ; //points to the SOAP-ENV:Envelope root element 

        dom.XmlNode [] xrec = xroot.getchildelements() ; 
        SiebelResponse objResponse = new SiebelResponse();//Points to the SOAP-ENV:Body element 
        for(Dom.XMLNode innerNode : xrec){ //Loop Through Records
           dom.XmlNode [] xrecChild = innerNode.getchildelements() ; //Points to the ns:AlteraSfdcQuoteCreate_Output element 
            for(Dom.XMLNode innerNodeChild : xrecChild) {
                   for(Dom.XMLNode child : innerNodeChild.getChildElements()) { // reading the data from ns:AlteraSfdcQuoteCreate_Output element 
                       if(child.getName() == 'Error_spcCode')
                            objResponse.ErrorCode = child.getText();
                        if(child.getName() == 'Error_spcMessage')
                            objResponse.ErrorMessage = child.getText();
                        if(child.getName() == 'QuoteURL')
                            objResponse.QuoteURL = child.getText();
                        if(child.getName() == 'RFQ_ID')
                           objResponse.RFQId = child.getText();
                        if(child.getName() == 'Status')
                            objResponse.Status = child.getText();
                        if(child.getName() == 'Opportunity_ID')
                            objResponse.OpportunityId = child.getText();
                   }
            }
        }
        return objResponse;
    }

    /**********************************
    * Method Name : createPayloadForOpportuntiyQuote
    * Created On  : Dec-13-2016
    * Created By  : Accenture
    * Description : Intel Altera Phase1:
    *               This method is used for creating the 
    *               Payload for Opportunity Quote 
    ***********************************/

    public static String createPayloadForOpportuntiyQuote() {
        
        Opportunity opp=[SELECT Id, Name, CloseDate, createdById, AccountID, Core_Consumption_Market__c, Core_Product_Segment__c, Core_Product_Application__c, Core_First_Customer_Ship_Date__c, Core_Production_End_Date__c, Core_Volume__c, Core_Opportunity_Past_Due__c, Core_Technical_Owner_Idsid__c, Core_Technical_Owner_Email_Txt__c, Core_Design_Registration_Id__r.Name, Description FROM Opportunity WHERE id=:ApexPages.currentPage().getParameters().get(System.Label.Core_OpportunityID)]; //need to change opportunity id
        User userObj = [SELECT Id, Name, Core_Login_Id__c, Email, Profile.Name FROM User WHERE Id=:UserInfo.getUserId()];


        List<OpportunityLineItem> lstoppLineItem = [SELECT Id, Product2.Name, Product2Id, Core_Design_Registration_Product_Id__r.Name, Quantity, UnitPrice FROM OpportunityLineItem WHERE Core_Product_Type__c = 'Intel® FPGAs' AND OpportunityId =: opp.Id AND Core_Status__c != :STATUS_CANCELLED AND Core_Status__c != :STATUS_PROD_CANCELLED];
        List<Core_Opportunity_Partner__c> opportuntiyPartnerList = [SELECT Id, Name, Core_Partner_Notes__c FROM Core_Opportunity_Partner__c WHERE Core_Partner_Type__c ='Distributor' AND Core_Opportunity__c=:opp.Id ORDER BY lastmodifiedDate DESC Limit 1];
        Core_PSG_Integration_Settings__c psgIntegrationSetting = Core_PSG_Integration_Settings__c.getOrgDefaults();
         
        //Preparing xml data
        XmlStreamWriter PSGQuoteXmlStreamWriter = new XmlStreamWriter();
        
        PSGQuoteXmlStreamWriter.writeStartDocument('UTF-8','1.0');
        PSGQuoteXmlStreamWriter.writeStartElement('soapenv','Envelope', 'http://schemas.xmlsoap.org/soap/envelope/');
            PSGQuoteXmlStreamWriter.writeNamespace('soapenv', 'http://schemas.xmlsoap.org/soap/envelope/');
            PSGQuoteXmlStreamWriter.writeNamespace('cus', 'http://siebel.com/CustomUI');
            PSGQuoteXmlStreamWriter.writeNamespace('eai','http://www.siebel.com/xml/EAI%20Opty%20IO%20SFDC%20Altera'); 
        
                //Header Start element 
                PSGQuoteXmlStreamWriter.writeStartElement('soapenv','Header', '');

                if(psgIntegrationSetting != null) {
                    PSGQuoteXmlStreamWriter.writeStartElement('','UsernameToken', 'http://siebel.com/webservices'); //UsernameToken Start Element
                         PSGQuoteXmlStreamWriter.writeNamespace('xmlns', 'http://siebel.com/webservices');
                         PSGQuoteXmlStreamWriter.writeCharacters(String.valueOf(psgIntegrationSetting.get('Core_User_Name__c')));
                    PSGQuoteXmlStreamWriter.writeEndElement(); //UsernameToken End Element
                    PSGQuoteXmlStreamWriter.writeStartElement('','PasswordText', 'http://siebel.com/webservices'); //PasswordText Start Element
                         PSGQuoteXmlStreamWriter.writeNamespace('xmlns', 'http://siebel.com/webservices');
                         PSGQuoteXmlStreamWriter.writeCharacters(String.valueOf(psgIntegrationSetting.get('Core_Password__c')));

                    PSGQuoteXmlStreamWriter.writeEndElement(); //PasswordText End Element
                    PSGQuoteXmlStreamWriter.writeStartElement('','SessionType ', 'http://siebel.com/webservices'); //Session Type Start Element
                         PSGQuoteXmlStreamWriter.writeNamespace('xmlns', 'http://siebel.com/webservices');
                         PSGQuoteXmlStreamWriter.writeCharacters('None');
                    PSGQuoteXmlStreamWriter.writeEndElement(); //Session Type End Element
                }
                PSGQuoteXmlStreamWriter.writeEndElement(); //Header End element 
                // Body Start element  
                PSGQuoteXmlStreamWriter.writeStartElement('soapenv','Body', '');
 
                    //AlteraSfdcQuoteIntegration_Input
                    PSGQuoteXmlStreamWriter.writeStartElement('cus','AlteraSfdcQuoteCreate_Input', '');
                        // IDSID Start element 
                        PSGQuoteXmlStreamWriter.writeStartElement('cus','IDSID','');
                        if(userObj.Profile.Name != System.Label.Core_Partner_Profile_Name && userObj.Core_Login_Id__c != null) // Add idsid only for Internal Users, not Partner Users
                            PSGQuoteXmlStreamWriter.writeCharacters(userObj.Core_Login_Id__c); 
                        PSGQuoteXmlStreamWriter.writeEndElement(); // IDSID End element
                        PSGQuoteXmlStreamWriter.writeStartElement('cus','Email', ''); // Email Start element
                            PSGQuoteXmlStreamWriter.writeCharacters(userObj.Email); 
                        PSGQuoteXmlStreamWriter.writeEndElement(); // Email end element
        				        				
                        PSGQuoteXmlStreamWriter.writeStartElement('eai','ListOfEaiOptyIoSfdcAltera', '');

                        PSGQuoteXmlStreamWriter.writeStartElement('eai','Opportunity', ''); // Opportunity Start element

                            // ISR Start element
                            PSGQuoteXmlStreamWriter.writeStartElement('eai','Isr','');
                            if(userObj.Profile.Name == System.Label.Core_Partner_Profile_Name && selectedISR != '') // Add loginId for selected ISR by partner
                                PSGQuoteXmlStreamWriter.writeCharacters(selectedISR.abbreviate(50));
                            PSGQuoteXmlStreamWriter.writeEndElement(); // ISR End element
        
                            //Opportuntiy_Id Start Element
                            PSGQuoteXmlStreamWriter.writeStartElement('eai','Opportunity_ID', ''); 
                                PSGQuoteXmlStreamWriter.writeCharacters(opp.Id);  
                            PSGQuoteXmlStreamWriter.writeEndElement(); //Opportuntiy_Id End Element
                            //Account_ID Start Element
                            PSGQuoteXmlStreamWriter.writeStartElement('eai','Account_ID', ''); 
                                PSGQuoteXmlStreamWriter.writeCharacters(String.valueOf(opp.AccountID));
                            PSGQuoteXmlStreamWriter.writeEndElement(); //Account_ID End Element
                            //Volume Start Element
                            PSGQuoteXmlStreamWriter.writeStartElement('eai','Volume', ''); 
                                if(opp.Core_Volume__c != null)
                                    PSGQuoteXmlStreamWriter.writeCharacters(String.valueOf(opp.Core_Volume__c));
                            PSGQuoteXmlStreamWriter.writeEndElement(); //Volume End Element
                            //PartnerNotes Start Element
                            PSGQuoteXmlStreamWriter.writeStartElement('eai','PartnerNotes', '');
                                if(!opportuntiyPartnerList.isEmpty()) {
                                        if(!String.isEmpty(opportuntiyPartnerList[0].Core_Partner_Notes__c))
                                             PSGQuoteXmlStreamWriter.writeCharacters(opportuntiyPartnerList[0].Core_Partner_Notes__c); 
                                }
                            PSGQuoteXmlStreamWriter.writeEndElement(); //PartnerNotes end Element
                            //ProductionEndDate Start Element
                            PSGQuoteXmlStreamWriter.writeStartElement('eai','ProductionEndDate', '');
                                if(opp.Core_Production_End_Date__c != null) {
                                     PSGQuoteXmlStreamWriter.writeCharacters(String.valueOF((datetime.newInstance(opp.Core_Production_End_Date__c.year(), opp.Core_Production_End_Date__c.month(),opp.Core_Production_End_Date__c.day()).format('MM/dd/yyyy HH:mm:SS'))));
                                }
                            PSGQuoteXmlStreamWriter.writeEndElement(); //ProductionEndDate end Element
                            //ProductApplication Start Element
                            PSGQuoteXmlStreamWriter.writeStartElement('eai','ProductApplication', '');
                                if(opp.Core_Product_Application__c != null)
                                    PSGQuoteXmlStreamWriter.writeCharacters(opp.Core_Product_Application__c);
                            PSGQuoteXmlStreamWriter.writeEndElement(); //ProductApplication End Element
                            //ProductSegment Start Element
                            PSGQuoteXmlStreamWriter.writeStartElement('eai','ProductSegment', '');
                                if(opp.Core_Product_Segment__c != null)
                                    PSGQuoteXmlStreamWriter.writeCharacters(opp.Core_Product_Segment__c);
                            PSGQuoteXmlStreamWriter.writeEndElement(); //ProductSegment End Element                            
                            //Name Start Element
                            PSGQuoteXmlStreamWriter.writeStartElement('eai','Name', '');
                                    PSGQuoteXmlStreamWriter.writeCharacters(opp.Name);   
                            PSGQuoteXmlStreamWriter.writeEndElement(); //Name end Element
                            //FirstCustomerShipDate Start Element
                            PSGQuoteXmlStreamWriter.writeStartElement('eai','FirstCustomerShipDate', '');
                                if(opp.Core_First_Customer_Ship_Date__c != null) {
                                    PSGQuoteXmlStreamWriter.writeCharacters(String.valueOF((datetime.newInstance(opp.Core_First_Customer_Ship_Date__c.year(), opp.Core_First_Customer_Ship_Date__c.month(),opp.Core_First_Customer_Ship_Date__c.day()).format('MM/dd/yyyy HH:mm:SS'))));
                                }
                            PSGQuoteXmlStreamWriter.writeEndElement(); //FirstCustomerShipDate End Element
                            //DecisionDate Start Element
                            PSGQuoteXmlStreamWriter.writeStartElement('eai','DecisionDate', '');
                                    PSGQuoteXmlStreamWriter.writeCharacters(String.valueOF((datetime.newInstance(opp.closeDate.year(), opp.closeDate.month(),opp.closeDate.day()).format('MM/dd/yyyy HH:mm:SS')))); 
                            PSGQuoteXmlStreamWriter.writeEndElement(); //DecisionDate End Element
 
                            //TechnicalOwnerIdsid Start Element
                            PSGQuoteXmlStreamWriter.writeStartElement('eai','TechnicalOwnerIdsid', '');
                                if(opp.Core_Technical_Owner_Idsid__c != null)
                                    PSGQuoteXmlStreamWriter.writeCharacters(String.ValueOf(opp.Core_Technical_Owner_Idsid__c));
                            PSGQuoteXmlStreamWriter.writeEndElement(); //TechnicalOwnerIdsid End Element 
                            
                            //TechnicalOwnerEmail Start Element
                            PSGQuoteXmlStreamWriter.writeStartElement('eai','TechnicalOwnerEmail', '');
                                if(opp.Core_Technical_Owner_Email_Txt__c != null)
                                    PSGQuoteXmlStreamWriter.writeCharacters(opp.Core_Technical_Owner_Email_Txt__c);
                            PSGQuoteXmlStreamWriter.writeEndElement(); //TechnicalOwnerEmail End Element 
                            
                            //DesignRegistrationNumber Start Element
                            PSGQuoteXmlStreamWriter.writeStartElement('eai','DesignRegistrationNumber', '');
                                if(opp.Core_Design_Registration_Id__r.Name != null)
                                    PSGQuoteXmlStreamWriter.writeCharacters(String.ValueOf(opp.Core_Design_Registration_Id__r.Name));
                            PSGQuoteXmlStreamWriter.writeEndElement(); //DesignRegistrationNumber End Element 
        					
        					//PartnerComments Start Element. Send first 1024 characters of Description value for Channel Opportunities only
        					PSGQuoteXmlStreamWriter.writeStartElement('eai','PartnerComments', '');
        						if(opp.Core_Design_Registration_Id__r.Name != null)
                                    PSGQuoteXmlStreamWriter.writeCharacters(String.ValueOf(opp.Description).abbreviate(1024));   
                            PSGQuoteXmlStreamWriter.writeEndElement(); //PartnerComments End Element
                            
                            //ListOfOpportunityProduct Start Element
                            PSGQuoteXmlStreamWriter.writeStartElement('eai','ListOfOpportunityProduct', '');
                                if(lstoppLineItem.size() > 0 ) {
                                    for(OpportunityLineItem oppLineItem : lstoppLineItem ) {

                                        //OpportunityProduct Start Element
                                        PSGQuoteXmlStreamWriter.writeStartElement('eai','OpportunityProduct', '');
                                            //Product_ID Start Element
                                            PSGQuoteXmlStreamWriter.writeStartElement('eai','Product_ID', '');
                                                PSGQuoteXmlStreamWriter.writeCharacters(String.valueOf(oppLineItem.Product2Id));
                                            PSGQuoteXmlStreamWriter.writeEndElement(); //Product_ID End Element
                                            //Quantity Start Element
                                            PSGQuoteXmlStreamWriter.writeStartElement('eai','Quantity', '');
                                                if(oppLineItem.Quantity != null)
                                                    PSGQuoteXmlStreamWriter.writeCharacters(String.valueOf(oppLineItem.Quantity)); 
                                            PSGQuoteXmlStreamWriter.writeEndElement(); //Quantity End Element
                                            //Opportunity LineItem Name Start Element
                                            PSGQuoteXmlStreamWriter.writeStartElement('eai','Name', '');
                                                    PSGQuoteXmlStreamWriter.writeCharacters(oppLineItem.Product2.Name);
                                            PSGQuoteXmlStreamWriter.writeEndElement(); // Name End Element
                                            
                                            /* Added by Infosys - on October 23rd 2017 as per the US - 83100 */
                                            
                                            PSGQuoteXmlStreamWriter.writeStartElement('eai','DesignRegistrationProductNumber', '');
                                            If(oppLineItem.Core_Design_Registration_Product_Id__r.Name !=null)
                                                    PSGQuoteXmlStreamWriter.writeCharacters(String.valueOf(oppLineItem.Core_Design_Registration_Product_Id__r.Name));
                                            PSGQuoteXmlStreamWriter.writeEndElement(); // DesignRegistrationProductNumber End Element
                                        
                                        	/* Added by Infosys - on August 9th 2018 as per the US - 103446 */
                                        	//Opportunity LineItem Sales Price Start Element
                                            PSGQuoteXmlStreamWriter.writeStartElement('eai','RequestedResale', '');
                                                    PSGQuoteXmlStreamWriter.writeCharacters(String.valueOf(oppLineItem.UnitPrice).abbreviate(50));
                                            PSGQuoteXmlStreamWriter.writeEndElement(); // Sales Price End Element
                                            /* Added by Infosys - on October 23rd 2017 as per the US - 83100 */
                                        PSGQuoteXmlStreamWriter.writeEndElement(); //OpportunityProduct End Element 
                                    }
                                }

                        PSGQuoteXmlStreamWriter.writeEndElement(); // ListOfOpportunityProduct element ends here 
                    PSGQuoteXmlStreamWriter.writeEndElement(); // Opportunity element ends here 
                    PSGQuoteXmlStreamWriter.writeEndElement(); // ListOfEaiOptyIoSfdcAltera element ends here  
                PSGQuoteXmlStreamWriter.writeEndElement(); // AlteraSfdcQuoteIntegration_Input element ends here 
            PSGQuoteXmlStreamWriter.writeEndElement(); // Body element ends here 
            PSGQuoteXmlStreamWriter.writeEndElement(); // Root element ends here
            PSGQuoteXmlStreamWriter.writeEndDocument(); //Document element ends here 
            String xmlOutput = PSGQuoteXmlStreamWriter.getXmlString();

            PSGQuoteXmlStreamWriter = new XmlStreamWriter();
            PSGQuoteXmlStreamWriter.writeCData(xmlOutput);

            String payload = PSGQuoteXmlStreamWriter.getXmlString();

            PSGQuoteXmlStreamWriter.close();
            return  payload ;         
    }

    /**********************************
    * Class Name : SiebelResponse
    * Created On  : Dec-12-2016
    * Created By  : Accenture
    * Description : Intel Altera Phase1:
    *               Wrapper class is used for storing
    *               Siebel Response after parsing response obtained
    *
    ***********************************/
    public class SiebelResponse  {
          public String QuoteURL;
          public String ErrorCode;
        public String ErrorMessage;
          public String RFQId;
          public String Status;
          public String OpportunityId;
    }
}