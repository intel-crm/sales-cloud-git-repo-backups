/******************************************************************************************************************************************
Class Name  : Core_IntegrationInboundMessageParsing
Version     : 1.0
Created Date: 17 NOV 2016
Function    : Logic for parsing inbound message XML/JSON into objects

TO DO: see if we can use XPath syntax and the unmanaged codebase here to make the XML parsing easier, less brittle, and
more extensible: https://github.com/JenniferSimonds/apex-xpath

Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------
* Dave Hood                 11/17/2016              Original version
*****************************************************************************************************************************************/
public  without sharing class Core_IntegrationInboundMessageParsing {
    
    public static Core_IntegrationUtility.ERPM_Person parsePerson(String messageXml) {
        
        Core_IntegrationUtility.ERPM_Person p = new Core_IntegrationUtility.ERPM_Person(); // Person to return
        
        Dom.Document doc = new Dom.Document();
        //Kushal - Please remove below line
        system.debug('@@@xml::'+messageXml);
        doc.load(messageXml);
        Dom.XmlNode personXml = doc.getRootElement();
        
        p.inactIndicator = personXml.getAttributeValue('inact-indicator', null);
        p.isDeleteIndicator = personXml.getAttributeValue('is-delete-indicator', null);
        
        System.debug('$$$$$ ' + getValue(personXml, 'publish-timestamp'));
        p.publishTimestamp = null;
        if (getValue(personXml, 'publish-timestamp') != '') {
            try {
                p.publishTimestamp = Core_IntegrationUtility.convertERPMDatetimeStringToDatetime(getValue(personXml, 'publish-timestamp'));
            }
            catch (Exception ex) {
            }
        }
        
        // <person-information>
        Dom.XmlNode personInfoXml = personXml.getChildElement('person-information', null);
        parsePersonPersonInfo(p, personInfoXml);
        
        // <person-accounts>
        Dom.XmlNode personAccountsXml = personXml.getChildElement('person-accounts', null);
        
        if (personAccountsXml != null) {
            for (Dom.XmlNode childNode : personAccountsXml.getChildElements()) {
                if (childNode.getName() == 'person-account') {
                    // We only care about active account relationships
                    if (childNode.getAttributeValue('inact-indicator', null) == 'N')
                        p.personAccounts.add(parsePersonAccount(childNode));
                }
            }
        }
        
        // <person-electronic-addresses>
        Dom.XmlNode personElectronicAddrsXml = personXml.getChildElement('person-electronic-addresses', null);
        parsePersonElectronicAddresses(p, personElectronicAddrsXml);
        
        // <person-engagements>
        Dom.XmlNode personEngagementsXml = personXml.getChildElement('person-engagements', null);
        
        if (personEngagementsXml != null) {
            for (Dom.XmlNode childNode : personEngagementsXml.getChildElements()) {
                if (childNode.getName() == 'engagement')
                    p.personEngagements.add(parsePersonEngagement(childNode));
            }
        }
        // Person attributes
        Dom.XmlNode personAttributesXml = personXml.getChildElement('person-attributes', null);
        if (personAttributesXml != null) {
            for (Dom.XmlNode childNode : personAttributesXml.getChildElements()) {
                system.debug('###Mahesh'+childNode.getName());
                system.debug('###Mahesh1'+childNode.getChildElements());
                if (childNode.getName() == 'attribute'){
                    
                    for(Dom.XmlNode Node :childNode.getChildElements()){
                        
                        if(Node.getAttributeValue('profession-code', '')<>null){
                            String ProfessionVal=Node.getAttributeValue('profession-code', '');
                            p.Profession.Professioncode = String.ValueOf(ProfessionVal);
                            system.debug('###Profession'+p.Profession.Professioncode);
                        }
                    }
                    
                    
                }
            }
        }
        
        // <person-physical-addresses>
        Dom.XmlNode personPhysicalAddrsXml = personXml.getChildElement('person-physical-addresses', null);
        parsePersonPhysicalAddresses(p, personPhysicalAddrsXml);
        
        // ----------- #REGION :: eRPM Code Changes :: START ------------- //
        // <Get the eRPM Person Subscription>  
        p.eRPM_Subscriptions = Get_eRPMSubscriptions(personXml.getChildElement('person-subscription', null));
        p.changeAgentId = getValue(personXml, 'change-agt-id');
        // ----------- #REGION :: eRPM Code Changes :: END   ------------- //
        system.debug('######Person'+p);
        system.debug('######Person'+p.Profession);
        return p;
    }
    
    private static void parsePersonPersonInfo(Core_IntegrationUtility.ERPM_Person p, Dom.XmlNode personInfoXml) {
        
        p.erpmPersonId     = getValue(personInfoXml, 'person-id');
        p.enterpriseId     = getValue(personInfoXml, 'enterprise-id');
        p.identityStatus   = getValue(personInfoXml, 'identity-status');
        p.loginId          = getValue(personInfoXml, 'external-login-id');
        p.title            = getValue(personInfoXml, 'person-title');
        p.firstName        = getValue(personInfoXml, 'person-given-name');
        p.lastName         = getValue(personInfoXml, 'person-family-name');
        p.erpmLanguageCode = getValue(personInfoXml, 'language-code');
        p.jobFunctionCode  = getValue(personInfoXml, 'occupation-title-code');
        p.email            = getValue(personInfoXml, 'primary-email-address').toLowerCase(); // Zay 3-27-2017 Added to address ERPM Duplicate problems ;
        p.doNotContact     = getValue(personInfoXml, 'all-intel-no-contact-dtm');
        p.englishFirstName = getValue(personInfoXml, 'person-english-given-name');
        p.englishLastName  = getValue(personInfoXml, 'person-english-family-name');
        if (getValue(personInfoXml, 'sales-do-not-contact-dtm') != '') {
            try {
                p.salesDoNotContactDate = Core_IntegrationUtility.convertERPMDatetimeStringToDatetime(getValue(personInfoXml, 'sales-do-not-contact-dtm'));//Gireesh:US942207
            }
            catch (Exception ex) {
            }
        }
        
        // ----------- #REGION :: eRPM Code Changes :: START ------------- //
        //eRPM - Store EV date and Intel Last Login date
        p.emailVerificationDate = getValue(personInfoXml, 'email-valid-status-dtm');
        p.lastLoginDate	   = getValue(personInfoXml, 'last-login-dtm');
        // ----------- #REGION :: eRPM Code Changes :: END ------------- //
    }
    
    private static void parsePersonElectronicAddresses(Core_IntegrationUtility.ERPM_Person p, Dom.XmlNode personElectronicAddrsXml) {
        
        // Look for specific electronic addresses we need, and store them
        if (personElectronicAddrsXml != null) {
            for (Dom.XmlNode childNode : personElectronicAddrsXml.getChildElements()) {
                if ((childNode.getName() == 'person-electronic-address') &&
                    (childNode.getAttributeValue('isnull-indicator', null) != 'Y')) {
                        
                        // This is the code that needs to be updated to pull from the child element instead
                        if (childNode.getAttributeValue('electronic-addr-type-code', null) == 'PHONE')
                            p.phone = childNode.getChildElement('electronic-address', null).getText();
                        else if (childNode.getAttributeValue('electronic-addr-type-code', null) == 'MOB')
                            p.mobilePhone = childNode.getChildElement('electronic-address', null).getText();
                        else if (childNode.getAttributeValue('electronic-addr-type-code', null) == 'FAX')
                            p.fax = childNode.getChildElement('electronic-address', null).getText();
                    }
            }
        }
    }
    
    private static void parsePersonPhysicalAddresses(Core_IntegrationUtility.ERPM_Person p, Dom.XmlNode personPhysicalAddrsXml) {
        
        // Look for specific physical addresses we need, and store them
        if (personPhysicalAddrsXml != null) {
            for (Dom.XmlNode childNode : personPhysicalAddrsXml.getChildElements()) {
                if ((childNode.getName() == 'physical-address') &&
                    (childNode.getAttributeValue('address-usg-type-code', null) == 'MAIL') &&
                    (childNode.getAttributeValue('isnull-indicator', null) != 'Y')) {
                        
                        for (Dom.XmlNode addrElement : childNode.getChildElements()) {
                            
                            String currentValue = (addrElement.getText() != null) ? addrElement.getText() : '';
                            
                            if (addrElement.getName() == 'address-line1-text')
                                //System.debug('##### at address-line1-text');
                                //System.debug('##### addrElement.getText(): ' + addrElement.getText());
                                p.mailingStreet1 = currentValue;
                            else if (addrElement.getName() == 'address-line2-text')
                                p.mailingStreet2 = currentValue;
                            else if (addrElement.getName() == 'address-line3-text')
                                p.mailingStreet3 = currentValue;
                            else if (addrElement.getName() == 'address-line4-text')
                                p.mailingStreet4 = currentValue;
                            
                            else if (addrElement.getName() == 'city-name')
                                p.mailingCity = currentValue;
                            else if (addrElement.getName() == 'state-code')
                                p.mailingState = currentValue;
                            else if (addrElement.getName() == 'postal-code')
                                p.mailingPostalCode = currentValue;
                            else if (addrElement.getName() == 'iso-country-code')
                                p.mailingCountry = currentValue;
                        }
                        // Now that we got a mailing address, break out of the method, since we just want the first one
                        return;
                    }
            }
        }
    }
    
    private static Core_IntegrationUtility.ERPM_Person_Account parsePersonAccount(Dom.XmlNode personAccountXml) {
        
        Core_IntegrationUtility.ERPM_Person_Account pa = new Core_IntegrationUtility.ERPM_Person_Account();
        
        pa.erpmAccountNumber = getValue(personAccountXml, 'account-number');
        pa.cimId = getValue(personAccountXml, 'cim-id');
        pa.acctSalesCloudID = getValue(personAccountXml, 'salescloud-id');
        pa.accountName = getValue(personAccountXml, 'account-name');
        pa.erpmDedupGroupCode = getValue(personAccountXml, 'engg_dedup_grp_cd');
        /*
Dom.XmlNode personAccountRelationXml = personAccountXml.getChildElement('person-account-relation', null);
if (personAccountRelationXml != null) {
pa.personAccountRelation.engagementCode = personAccountRelationXml.getAttributeValue('engagement-code', null);
pa.personAccountRelation.relationCode = getValue(personAccountRelationXml, 'relation-code');
pa.personAccountRelation.relationName = getValue(personAccountRelationXml, 'relation-name');
}
*/
        List<Dom.XmlNode> personAccountChildrenXml = personAccountXml.getChildElements();
        if (personAccountChildrenXml != null) {
            for (Dom.XmlNode childNode : personAccountChildrenXml) {
                if (childNode.getName() == 'person-account-relation') {
                    //if (childNode.getAttributeValue('inact-indicator', null) == 'N') {
                    Core_IntegrationUtility.ERPM_Person_Account_Relation relation = new Core_IntegrationUtility.ERPM_Person_Account_Relation();
                    relation.engagementCode = childNode.getAttributeValue('engagement-code', null);
                    relation.relationCode = getValue(childNode, 'relation-code');
                    relation.relationName = getValue(childNode, 'relation-name');
                    //Harshit added : below line to parse value for inactive-indicator : as part of US270245
                    //relation.inactiveIndicator = getValue(childNode, 'inact-indicator');
                    relation.inactiveIndicator = childNode.getAttributeValue('inact-indicator', null) =='N' ? false : true;
                    pa.personAccountRelations.add(relation);
                    // }
                }
            }
        }
        
        Dom.XmlNode accountEngagementsXml = personAccountXml.getChildElement('account-engagements', null);
        
        Map<String,Core_IntegrationUtility.ERPM_Engagement> enggCodeMap = new Map<String,Core_IntegrationUtility.ERPM_Engagement>();
        if(accountEngagementsXml != null) {
            for (Dom.XmlNode childNode : accountEngagementsXml.getChildren()) {
                if (childNode.getName() == 'engagement') {
                    Core_IntegrationUtility.ERPM_Engagement engg = parsePersonAccountEngagement(childNode);
                    pa.personAccountEngagements.add(engg);
                    enggCodeMap.put(engg.engagementCode, engg);
                }
            }
        }
        
        // Now loop through the Person Account Engagements and populate additional fields on Person Account Relation
        // when we see the matching one
        /*if (personAccountRelationXml != null) {
for (Core_IntegrationUtility.ERPM_Engagement engg : pa.personAccountEngagements) {
if (engg.engagementCode == pa.personAccountRelation.engagementCode) {
pa.personAccountRelation.engagementName = engg.engagementName;
pa.personAccountRelation.engagementStatusCode = engg.engagementStatusCode;
pa.personAccountRelation.effectiveTierCode = engg.effectiveTierCode;
}
}
}*/
        
        // Now loop through the Person Account Engagements and populate additional fields on Person Account Relations
        // when we see the matching one
        for (Core_IntegrationUtility.ERPM_Person_Account_Relation relation : pa.personAccountRelations) {
            Core_IntegrationUtility.ERPM_Engagement engg = enggCodeMap.get(relation.engagementCode);
            if (engg != null) {
                relation.engagementName = engg.engagementName;
                relation.engagementStatusCode = engg.engagementStatusCode;
                relation.effectiveTierCode = engg.effectiveTierCode;
            }
            else {
                relation.engagementName = relation.engagementCode;
                relation.engagementStatusCode = null;
                relation.effectiveTierCode = null;
            }
        }
        
        return pa;
    }
    
    private static Core_IntegrationUtility.ERPM_Engagement parsePersonAccountEngagement(Dom.XmlNode personAccountEnggXml) {
        
        Core_IntegrationUtility.ERPM_Engagement pae = new Core_IntegrationUtility.ERPM_Engagement();
        
        pae.engagementCode = getValue(personAccountEnggXml, 'engg-code');
        pae.engagementName = getValue(personAccountEnggXml, 'engg-name');
        pae.engagementStatusCode = getValue(personAccountEnggXml, 'engg-status-code');
        pae.effectiveTierCode = getValue(personAccountEnggXml, 'eff-tier-cd');
        
        return pae;
    }
    
    private static Core_IntegrationUtility.ERPM_Engagement parsePersonEngagement(Dom.XmlNode personEnggXml) {
        
        Core_IntegrationUtility.ERPM_Engagement pe = new Core_IntegrationUtility.ERPM_Engagement();
        
        pe.engagementCode = getValue(personEnggXml, 'engg-code');
        pe.engagementName = getValue(personEnggXml, 'engg-name');
        pe.engagementStatusCode = getValue(personEnggXml, 'engg-status-code');
        pe.effectiveTierCode = getValue(personEnggXml, 'effective-tier-code');
        pe.effEndEngagmentDate=getValue(personEnggXml, 'effective-end-dtm');
        return pe;
    }
    
    private static Core_IntegrationUtility.ERPM_Person_Attribute parsePersonAttribute(Dom.XmlNode personEnggXml) {
        
        Core_IntegrationUtility.ERPM_Person_Attribute pe = new Core_IntegrationUtility.ERPM_Person_Attribute();
        
        pe.Professioncode  = getValue(personEnggXml, 'person-profession');
        
        
        return pe;
    }
    
    // Take an XML Node (with a bunch of child nodes) and a "child string." Based on the string passed in,
    // selects that child node and returns its text value. Takes into account nulls and the isnull indicator.
    private static String getValue(Dom.XmlNode node, String child) {
        
        if ((node != null) && (node.getChildElement(child, null) != null)) {
            Dom.XmlNode childNode = node.getChildElement(child, null);
            
            if ((childNode.getAttributeValue('isnull-indicator', null) == null) ||
                (childNode.getAttributeValue('isnull-indicator', null) == 'N'))
                return childNode.getText();
        }
        return '';
    }
    
    public static Core_IntegrationUtility.ERPM_Account parseAccount(String messageXml) {
        
        Core_IntegrationUtility.ERPM_Account a = new Core_IntegrationUtility.ERPM_Account(); // Account to return
        
        Dom.Document doc = new Dom.Document();
        //Kushal - Please remove below line
        system.debug('@@@xml::'+messageXml);
        doc.load(messageXml);
        Dom.XmlNode accountXml = doc.getRootElement();
        
        // <account-information>
        Dom.XmlNode accountInfoXml = accountXml.getChildElement('account-information', null);
        parseAccountAccountInfo(a, accountInfoXml);
        
        // <external-systems>
        Dom.XmlNode externalSystemsXml = accountXml.getChildElement('account-external-systems', null);
        parseAccountExternalSystems(a, externalSystemsXml);
        
        // <electronic-addresses>
        Dom.XmlNode electronicAddrsXml = accountXml.getChildElement('electronic-addresses', null);
        parseAccountElectronicAddresses(a, electronicAddrsXml);
        
        // <physical-addresses>
        Dom.XmlNode physicalAddrsXml = accountXml.getChildElement('physical-addresses', null);
        parseAccountPhysicalAddresses(a, physicalAddrsXml);
        
        // <engagements>
        Dom.XmlNode engagementsXml = accountXml.getChildElement('engagements', null);
        if (engagementsXml != null) {
            system.debug('engagementsXml '+engagementsXml);
            for (Dom.XmlNode childNode : engagementsXml.getChildElements()) {
                if (childNode.getName() == 'engagement')
                    a.accountEngagements.add(parseAccountEngagement(childNode));
            }
        }
        
        // ----------- #REGION :: eRPM Code Changes :: START   ------------- //        
        // <Get the List of eRPM Account Profile Responses> 
        //system.debug( 'responses :-'+ accountXml.getChildElement('account-responses', null));
        a.eRPM_Profile_Responses = Get_eRPMProfileResponses(accountXml.getChildElement('account-responses', null));
        a.eRPM_Benefits=Get_eRPMBenefits(a, accountXml.getChildElement('account-benefits', null));
        a.secondaryAddress=parseERPMAccountPhysicalAddresses(a,accountXml.getChildElement('physical-addresses', null));
        
        // ----------- #REGION :: eRPM Code Changes :: END   ------------- //
        return a;
    }
    
    private static void parseAccountAccountInfo(Core_IntegrationUtility.ERPM_Account a, Dom.XmlNode accountInfoXml) {
        
        a.erpmAccountNumber = getValue(accountInfoXml, 'account-number');
        a.name = getValue(accountInfoXml, 'account-name');
        a.enggDedupGroupCode = getValue(accountInfoXml, 'engg-dedup-group-code');
        // eRPM - Store Number Of employees 
        a.employees = getValue(accountInfoXml, 'employee-size-code');
        a.employeeGrp = getValue(accountInfoXml, 'employee-size-grp-code');
        if(a.employeeGrp != null && a.employeeGrp.Contains(Label.Employee_Size_Code_1_9))
            a.employeeGrp = '1-9';
        a.PrimaryAddrType = getValue(accountInfoXml, 'primary-addr-type-code'); // Added to figure out the type of address for IPA engg(ITP,ISA,CSPx2) and B2B enggs.
        
        Dom.XmlNode accountNamesXml = accountInfoXml.getChildElement('account-names', null);
        
        if (accountNamesXml != null) {
            for (Dom.XmlNode childNode : accountNamesXml.getChildElements()) {
                if ((childNode.getAttributeValue('type', null) == 'Legal Name') &&
                    (childNode.getAttributeValue('isnull-indicator', null) == 'N'))
                    a.legalName = childNode.getText();
            }
        }
    }
    
    private static void parseAccountExternalSystems(Core_IntegrationUtility.ERPM_Account a, Dom.XmlNode externalSystemsXml) {
        
        if (externalSystemsXml != null) {
            for (Dom.XmlNode childNode : externalSystemsXml.getChildElements()) {
                if (childNode.getName() == 'account-external-system') {
                    if (childNode.getAttributeValue('system-name', null) == 'SLSCLDID' &&
                        childNode.getAttributeValue('inact-indicator', null) == 'N' ) {
                            a.sfdcId = childNode.getText();
                        }
                    else if (childNode.getAttributeValue('system-name', null) == 'CIM') {
                        a.cimId = childNode.getText();
                    }
                }
            }
        }
    }
    
    private static void parseAccountElectronicAddresses(Core_IntegrationUtility.ERPM_Account a, Dom.XmlNode electronicAddrsXml) {
        
        if (electronicAddrsXml != null) {
            for (Dom.XmlNode childNode : electronicAddrsXml.getChildElements()) {
                if ((childNode.getName() == 'electronic-address') &&
                    (childNode.getAttributeValue('isnull-indicator', null) != 'Y') && (childNode.getAttributeValue('inact-indicator', null) != 'Y')) {
                        
                        if (childNode.getAttributeValue('electronic-type-code', null) == 'PHONE' && childNode.getAttributeValue('location-type-code', null) == 'BUS')
                            a.phone = childNode.getText();
                        else if (childNode.getAttributeValue('electronic-type-code', null) == 'FAX' && childNode.getAttributeValue('location-type-code', null) == 'BUS')
                            a.fax = childNode.getText();
                        //eRPM - Get URL field value and assign it to Account object
                        else if (childNode.getAttributeValue('electronic-type-code', null) == 'URL' && childNode.getAttributeValue('location-type-code', null) == 'BUS')
                            a.website = childNode.getText();
                    }
            }
        }
    }
    
    private static void parseAccountPhysicalAddresses(Core_IntegrationUtility.ERPM_Account a, Dom.XmlNode physicalAddrsXml) {
        System.debug('Inside Parse Physical Addr');
        if (physicalAddrsXml != null) {
            System.debug('Inside Parse Physical Addr - inside if');
            for (Dom.XmlNode childNode : physicalAddrsXml.getChildElements()) {
                System.debug('Inside Parse Physical Addr - inside for');
                
                // a.PrimaryAddrType => Added to figure out the type of address for IPA engg(ITP,ISA,CSPx2) and B2B enggs.
                
                if ((childNode.getName() == 'physical-address') &&
                    (childNode.getAttributeValue('address-usg-type-code', null) == a.PrimaryAddrType) &&
                    (childNode.getAttributeValue('isnull-indicator', null) != 'Y')) {
                        System.debug('Inside Parse Physical Addr - inside for -inside if');
                        
                        for (Dom.XmlNode addrElement : childNode.getChildElements()) {
                            
                            String currentValue = (addrElement.getText() != null) ? addrElement.getText() : '';
                            
                            if (addrElement.getName() == 'address-line1-text')
                                a.primaryStreet1 = currentValue;
                            else if (addrElement.getName() == 'address-line2-text')
                                a.primaryStreet2 = currentValue;
                            else if (addrElement.getName() == 'address-line3-text')
                                a.primaryStreet3 = currentValue;
                            else if (addrElement.getName() == 'address-line4-text')
                                a.primaryStreet4 = currentValue;
                            
                            else if (addrElement.getName() == 'city-name')
                                a.primaryCity = currentValue;
                            else if (addrElement.getName() == 'state-code')
                                a.primaryState = currentValue;
                            else if (addrElement.getName() == 'postal-code')
                                a.primaryPostalCode = currentValue;
                            else if (addrElement.getName() == 'iso-country-code')
                                a.primaryCountry = currentValue;
                        }
                        System.debug('a.primaryStreet1'+a.primaryStreet1);
                        // Now that we got a mailing address, break out of the method, since we just want the first one
                        return;
                    }
            }
        }
    }
    
    
    
    private static Core_IntegrationUtility.ERPM_Engagement parseAccountEngagement(Dom.XmlNode accountEnggXml) {
        
        Core_IntegrationUtility.ERPM_Engagement engg = new Core_IntegrationUtility.ERPM_Engagement();
        
        engg.engagementCode = getValue(accountEnggXml, 'engg-code');
        engg.engagementName = getValue(accountEnggXml, 'engg-name');
        engg.engagementStatusCode = getValue(accountEnggXml, 'engg-status-code');
        engg.effectiveTierCode = getValue(accountEnggXml, 'effective-tier-code');
        //Harshit added : below code to parse value for tier code : as part of US270161
        engg.tierCode = getValue(accountEnggXml, 'tier-code');
        engg.engagementStatusReasonCode = getValue(accountEnggXml,'engg-status-reason-code');
        //engg.statusCode=getValue(accountEnggXml, 'engg-status-code');
        return engg;
    }
    
    public static Core_IntegrationUtility.ERPM_Blackbox_Response parseBlackboxResponse(String jsonMessage) {
        
        Core_IntegrationUtility.ERPM_Blackbox_Response bbResponse = (Core_IntegrationUtility.ERPM_Blackbox_Response)
            JSON.deserialize(jsonMessage, Core_IntegrationUtility.ERPM_Blackbox_Response.class);
        
        return bbResponse;
    }
    
    public static Core_IntegrationUtility.AGS_Response parseAGSResponse(String jsonMessage) {
        
        Core_IntegrationUtility.AGS_Response agsResponse = (Core_IntegrationUtility.AGS_Response)
            JSON.deserialize(jsonMessage, Core_IntegrationUtility.AGS_Response.class);
        
        return agsResponse;
    }    
    
    // ----------- #REGION :: eRPM Code Changes :: START ------------- //
    
    //Get the List of erpm person subscrition from the eRPM Out Bound Message
    //Just Read the message from the published XML and parse thru the person XML 
    //return the list of subscription
    private static List<Core_IntegrationUtility.eRPM_Subscription> Get_eRPMSubscriptions(Dom.XmlNode eRPM_PersonSubscriptions_XML)
    {
        if(eRPM_PersonSubscriptions_XML == null)
            return null;
        
        List<Core_IntegrationUtility.eRPM_Subscription> eRPM_Subscriptions = new List<Core_IntegrationUtility.eRPM_Subscription>();
        
        for (Dom.XmlNode childNode : eRPM_PersonSubscriptions_XML.getChildElements()) {
            if (childNode.getName() == 'subscription')
            {  
                Core_IntegrationUtility.eRPM_Subscription subscription = new Core_IntegrationUtility.eRPM_Subscription();
                subscription.eRPM_EngagementCode = childNode.getAttributeValue('engg-code', null);       
                subscription.eRPM_SubscriptionCode = getValue(childNode, 'subscription-code');                       
                subscription.eRPM_SubscriptionStatusCode = getValue(childNode, 'subscription-statuscode') == 'USER-SUB' ?
                    'Active' : 'Inactive';
                eRPM_Subscriptions.add(subscription);
            }
        }        
        return eRPM_Subscriptions;
    }
    
    //Read the message from the published XML and parse thru the Account XML , Get the erpm extended attributes for the given account
    //return the list of profile responses/ extended attributes
    private static List<Core_IntegrationUtility.eRPM_Profile_Response> Get_eRPMProfileResponses(Dom.XmlNode eRPM_ProfileResponses_XML)
    {
        if(eRPM_ProfileResponses_XML == null)
            return null;
        
        List<Core_IntegrationUtility.eRPM_Profile_Response> eRPM_Profile_Responses = new List<Core_IntegrationUtility.eRPM_Profile_Response>();
        
        for (Dom.XmlNode childNode : eRPM_ProfileResponses_XML.getChildElements()) {
            if (childNode.getName() == 'response')
            {
                Core_IntegrationUtility.eRPM_Profile_Response profResp = new Core_IntegrationUtility.eRPM_Profile_Response();                
                profResp.eRPM_ResponseCode = getValue(childNode, 'answer-code');                        
                profResp.eRPM_QuestionCode = getValue(childNode, 'question-code');
                profResp.eRPM_ResponseText = getValue(childNode, 'response-value-text');
                eRPM_Profile_Responses.add(profResp);
            }
        }        
        return eRPM_Profile_Responses;
    }
    
    //Read the message from the published XML and parse thru the Account XML , Get the erpm Benefit details for the given account
    //Method will check for allowed benefits for given engagements.
    //// Added by Manju on 07/09/2019
    private static List<Core_IntegrationUtility.eRPM_Benefit> Get_eRPMBenefits(Core_IntegrationUtility.ERPM_Account acct,Dom.XmlNode eRPM_Benefits_XML)
    {
        
        List<Core_IntegrationUtility.eRPM_Benefit> eRPMBenefits = new List<Core_IntegrationUtility.eRPM_Benefit>();
        if(eRPM_Benefits_XML!=null){
            //Get the allowed Benefits from metadata for mapping type benefit
            List<ERPM_SF_MAPPING_SETTING__mdt> erpmSFBenenfitMapSetting=[SELECT SF_KeyValue__c,eRPM_EngagementCodes__c FROM ERPM_SF_MAPPING_SETTING__mdt 
                                                                         WHERE Mappting_Type__c =:Label.PRM_Benefit];
            
            Map<string,List<string>> benMap=new Map<string,List<string>>();
            for(ERPM_SF_MAPPING_SETTING__mdt benSet : erpmSFBenenfitMapSetting)
            {
                benMap.put(benSet.eRPM_EngagementCodes__c, benSet.SF_KeyValue__c.split(',')); 
            }
            for (Dom.XmlNode childNode : eRPM_Benefits_XML.getChildElements()) {
                System.Debug('##Get childNode.getName() '+childNode.getName());
                if (childNode.getName() == 'benefit')
                {
                    Core_IntegrationUtility.eRPM_Benefit benefit= new Core_IntegrationUtility.eRPM_Benefit();
                    benefit.eRPM_BenefitCode = getValue(childNode, 'benefit-code');                       
                    benefit.eRPM_Benefit_InactiveReason = getValue(childNode, 'benefit-note-txt');
                    benefit.eRPM_Benefit_InactiveReasonCode = getValue(childNode, 'benefit-inact-reason-code');
                    benefit.eRPM_BenefitEngagementCode = getValue(childNode, 'engagement-code');
                    benefit.eRPM_BenefitInactiveIndicator = getValue(childNode, 'inact-ind');
                    if(benefit.eRPM_BenefitInactiveIndicator != 'Y')
                        eRPMBenefits.add(benefit);                
                    if(benMap.Get(benefit.eRPM_BenefitEngagementCode)!=null && !acct.eRPM_isITPBenefitCheck && (benefit.eRPM_BenefitInactiveIndicator.equals('N')) && (benMap.Get(benefit.eRPM_BenefitEngagementCode).contains(benefit.eRPM_BenefitCode))) {
                        //check for all allowed benefits                        
                        acct.eRPM_isITPBenefitCheck = true;                        
                    }
                }        
            }            
            
        }
        System.debug('acct.eRPM_isITPBenefitCheck = true; '+acct.eRPM_isITPBenefitCheck);
        return eRPMBenefits;
    }
    
    private static Core_IntegrationUtility.SecondaryAddress parseERPMAccountPhysicalAddresses(Core_IntegrationUtility.ERPM_Account a, Dom.XmlNode physicalAddrsXml) {
        
        Core_IntegrationUtility.SecondaryAddress secondaryAddress= new Core_IntegrationUtility.SecondaryAddress();
        if (physicalAddrsXml != null) {           
            List<string> enggCodes= new List<string>();   
            //Get account engagements
            for(Core_IntegrationUtility.ERPM_Engagement engg :a.accountEngagements)
            {
                enggCodes.Add(engg.engagementCode);
            }
            //Get Metadata only for respective engagements.         
            Set<string> eRPMAddressusagetype=new Set<string>();            
            for(ERPM_SF_MAPPING_SETTING__mdt addSetting :[SELECT eRPM_KeyValue__c FROM ERPM_SF_MAPPING_SETTING__mdt 
                                                          WHERE Mappting_Type__c =: Label.ERPM_Address_Mapping_Type and eRPM_EngagementCodes__c IN :enggCodes]){                
                                                              eRPMAddressUsageType.add(addSetting.eRPM_KeyValue__c);
                                                          }
            
            for (Dom.XmlNode childNode : physicalAddrsXml.getChildElements()) {  
                if ((childNode.getName() == 'physical-address') && (eRPMAddressUsageType.Contains(childNode.getAttributeValue('address-usg-type-code', null))) &&
                    (childNode.getAttributeValue('isnull-indicator', null) == 'N')) {                     
                        secondaryAddress.secondaryStreet1 = getValue(childNode, 'address-line1-text');
                        secondaryAddress.secondaryStreet2 = getValue(childNode, 'address-line2-text');
                        secondaryAddress.secondaryStreet3 = getValue(childNode, 'address-line3-text');
                        secondaryAddress.secondaryStreet4 = getValue(childNode, 'address-line4-text');
                        secondaryAddress.secondaryCity = getValue(childNode, 'city-name');
                        secondaryAddress.secondaryState = getValue(childNode, 'state-code');
                        secondaryAddress.secondaryPostalCode = getValue(childNode, 'postal-code');
                        secondaryAddress.secondaryCountry = getValue(childNode, 'iso-country-code');
                        return secondaryAddress;
                    }
                
            }
        }
        return secondaryAddress;
    }
    
    // ----------- #REGION :: eRPM Code Changes :: END   ------------- //
}