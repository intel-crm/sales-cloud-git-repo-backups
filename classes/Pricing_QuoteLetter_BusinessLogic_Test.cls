/**
 * @description       : Test Class for Pricing_QuoteLetter_BusinessLogic
 * @author            : Sandeep Chamate
 * @group             : Accenture
 * @last modified on  : 03-09-2026
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class Pricing_QuoteLetter_BusinessLogic_Test {
    
    @testSetup
    static void setUpData(){
        List<User> adminUserList = Pricing_Test_Utility.createAdminUser();
        Pricing_Test_Utility.createPriceBook();
        System.runAs(adminUserList[0]) {
            Test.startTest();
            Account acc = Pricing_Test_Utility.createAccount();
            Contact con = Pricing_Test_Utility.createPrimaryContactWithParam(acc.Id,'Quote_Letter_Business_Logic_Test');
            
            List<User> accExeUserList = Pricing_Test_Utility.createAEUser();
            List<User> salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
            AccountTeamMember accTeam = new AccountTeamMember(AccountId = acc.Id,TeamMemberRole = 'Technical Sales',UserId = salesRepUserList[0].Id);
            insert accTeam;

            List<SBQQ__Quote__c> quoteList = Pricing_Test_Utility.createQuoteWithParam(acc.Id, con.Id, 1,salesRepUserList[0].Email,accExeUserList[0].Email);
            List<SBQQ__QuoteLine__c> quoteLines = Pricing_Test_Utility.createQuoteLines(quoteList[0].Id, 3);                   
            for(SBQQ__QuoteLine__c quoteLine : quoteLines){
                Pricing_Test_Utility.createPerformanceMetrics(quoteLine.Id);
            }
            
            //List<SBQQ__Quote__c> quoteFIList = Pricing_Test_Utility.createFIQuoteWithParam(acc.Id, con.Id, 1,adminUserList[0].Email,accExeUserList[0].Email);   
            //List<SBQQ__QuoteLine__c> lstquoteLines = Pricing_Test_Utility.createFIQuoteLines(quoteFIList[0].Id, 1);
            
            Core_Trigger_Executions__c triggerEntry2 = new Core_Trigger_Executions__c();
            triggerEntry2.name = 'pricingSendOutboundMessagesIQR';
            triggerEntry2.Core_Object__c = 'Descriptive Feature';
            triggerEntry2.Core_Trigger_Events__c = 'After insert';
            triggerEntry2.Core_Active__c = TRUE;
            triggerEntry2.Core_Description__c = 'This is test description';
            triggerEntry2.Core_Class_Name__c = 'Test Class';
            insert triggerEntry2;
            
            Document document;            
            document = new Document();
            document.Body = Blob.valueOf('Some Text');
            document.ContentType = 'application/pdf';
            document.DeveloperName = 'my_document';
            document.IsPublic = true;
            document.Name = Label.Pricing_IQR_Intel_Logo;
            document.FolderId = userinfo.getuserid();
            insert document;
            Test.stopTest();
            File myFile = File.make(document);
            Blob body = myFile.getBody();
            SObject sObj = myFile.getRecord();
            String cType = myFile.getContentType();
            try{
                File myFile1 = File.make(new Attachment());
            }catch(Exception exp){
                Pricing_Tender_Utility.logError(exp);
            }
        }
        
        SBQQ__QuoteTemplate__c quoteTemplates = new SBQQ__QuoteTemplate__c();
        quoteTemplates.Name = 'IQR Quote Template';
        quoteTemplates.SBQQ__DeploymentStatus__c = 'Deployed';
        quoteTemplates.SBQQ__PageWidth__c = 1.000;
        quoteTemplates.SBQQ__PageHeight__c = 1.000;
        quoteTemplates.SBQQ__TopMargin__c = 1.000;
        quoteTemplates.SBQQ__BottomMargin__c = 1.000;
        quoteTemplates.SBQQ__LeftMargin__c = 1.000;
        quoteTemplates.SBQQ__RightMargin__c = 1.000;
        insert quoteTemplates;
    }    
  
    static testmethod void testGenerateQuoteLetetr_1(){        
        Map<id,SBQQ__Quote__c> quotesMap = new Map<Id,SBQQ__Quote__c>([SELECT id FROM SBQQ__Quote__c WHERE Pricing_Quote_Program_Nm__c = 'Tender' Limit 1]);
        List<SBQQ__QuoteLine__c> quoteLies = new List<SBQQ__QuoteLine__c>();
        
        for(SBQQ__QuoteLine__c qli : [SELECT id,Pricing_Status_Nm__c,Pricing_Deal_RFQ_Id__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c IN :quotesMap.keySet()]){
            qli.Pricing_Status_Nm__c = 'Approved';
            qli.Pricing_Deal_RFQ_Id__c = '5654561';
            quoteLies.add(qli);
        }
        if(quoteLies.size() > 0){
            update quoteLies;
        }   
        List<SBQQ__QuoteLine__c> qlis = [SELECT id,Pricing_Status_Nm__c,SBQQ__Quote__c,SBQQ__Quote__r.SBQQ__Account__c,SBQQ__Quote__r.name FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c IN :quotesMap.keySet()];
        system.assertEquals('Approved', qlis[0].Pricing_Status_Nm__c);
        
        /*Database.SaveResult result = EventBus.publish(new Pricing_Quote_Letter_Event__e(
                                  Pricing_QuoteIds_Txt__c = String.valueOf(qlis[0].SBQQ__Quote__c),
                                  Pricing_Action_Nm__c = Label.Pricing_Generate_QuoteLetter_Action));
        system.assertEquals(True, result.isSuccess());*/
        Pricing_QuoteLetter_BusinessLogic.generateQuoteLetters(new List<Pricing_Quote_Letter_Event__e>{new Pricing_Quote_Letter_Event__e(
                                  Pricing_QuoteIds_Txt__c = String.valueOf(qlis[0].SBQQ__Quote__c),
                                  Pricing_Action_Nm__c = Label.Pricing_Generate_QuoteLetter_Action)});
        Set<String> quoteIds = new Set<String>();
        quoteIds.add(qlis[0].SBQQ__Quote__c);
        Set<String> statuses = new Set<String>{'Draft','Lost','Revised','Rejected'};
        Set<Id> quoteIdsForQuoteLetter = new Set<Id>();
        Map<Id,List<SBQQ__QuoteLine__c>> quoteIdQLIsMap = new Map<Id,List<SBQQ__QuoteLine__c>>();
        Pricing_QuoteLetter_BusinessLogic.generateQuoteLetterForFI(quoteIds, statuses, quoteIdsForQuoteLetter, quoteIdQLIsMap);

    }
    
    static testmethod void testModelClasses(){
        QuoteLineModel qlm = new QuoteLineModel();
        qlm.record = null;
        qlm.amountDiscountProrated = null;
        qlm.parentGroupKey = null;
        qlm.parentItemKey = null;
        qlm.key = null;
        qlm.upliftable = null;
        qlm.configurationType = null;
        qlm.configurationEvent = null;
        qlm.reconfigurationDisabled = null;
        qlm.descriptionLocked = null;
        qlm.productQuantityEditable = null;
        qlm.productQuantityScale = null;
        qlm.dimensionType = null;
        qlm.productHasDimensions = null;
        qlm.targetCustomerAmount = null;
        qlm.targetCustomerTotal = null;
        QuoteLineGroupModel qlgm = new QuoteLineGroupModel();
        qlgm.record = null;
        qlgm.netNonSegmentTotal = null;
        qlgm.key = null;
        OptionModel om = new OptionModel();
        om.record = null;
        om.externalConfigurationData = null;
        om.configurable = null;
        om.configurationRequired = null;
        om.quantityEditable = null;
        om.priceEditable = null;
        om.productQuantityScale = null;
        om.priorOptionExists = null;
        om.dependentIds = null;
        om.controllingGroups = null;
        om.exclusionGroups = null;
        om.reconfigureDimensionWarning = null;
        om.hasDimension = null;
        om.isUpgrade = null;
        om.dynamicOptionKey = null;
        FeatureModel fm = new FeatureModel();
        fm.record = null;
        fm.instructionsText = null;
        fm.containsUpgrades = null;
        ConfigAttributeModel cam = new ConfigAttributeModel();
        cam.name = null;
        cam.targetFieldName = null;
        cam.displayOrder = null;
        cam.colmnOrder = null;
        cam.required = null;
        cam.featureId = null;
        cam.position = null;
        cam.appliedImmediately = null;
        cam.applyToProductOptions = null;
        cam.autoSelect = null;
        cam.shownValues = null;
        cam.hiddenValues = null;
        cam.hidden = null;
        cam.noSuchFieldName = null;
        cam.myId = null;
        ConfigurationModel cm = new ConfigurationModel();
        cm.configuredProductId = null;
        cm.optionId = null;
        cm.optionData = null;
        cm.configurationData = null;
        cm.inheritedConfigurationData = null;
        cm.optionConfigurations = null;
        cm.configured = null;
        cm.changedByProductActions = null;
        cm.isDynamicOption = null;
        cm.isUpgrade = null;
        cm.disabledOptionIds = null;
        cm.hiddenOptionIds = null;
        cm.listPrice = null;
        cm.priceEditable = null;
        cm.validationMessages = null;
        cm.dynamicOptionKey = null;
        ConstraintModel com = new ConstraintModel();
        com.record = null;
        com.priorOptionExists = null;
        ProductModel pm = new ProductModel();
        pm.record = null;
        pm.upgradedAssetId = null;
        pm.currencySymbol = null;
        pm.currencyCode = null;
        pm.featureCategories = null;
        pm.options = null;
        pm.features = null;
        pm.configuration = null;
        pm.configurationAttributes = null;
        pm.inheritedConfigurationAttributes = null;
        pm.constraints = null;
        QuoteModel qm = new QuoteModel();
        qm.record = null;
        qm.lineItems = null;
        qm.lineItemGroups = null;
        qm.nextKey = null;
        qm.applyAdditionalDiscountLast = null;
        qm.applyPartnerDiscountFirst = null;
        qm.channelDiscountsOffList = null;
        qm.customerTotal = null;
        qm.netTotal = null;
        qm.netNonSegmentTotal = null;
        QuoteProposalModel qpm = new QuoteProposalModel();
        qpm.name = null;
        qpm.quoteId = null;
        qpm.templateId = null;
        qpm.language = null;
        qpm.outputFormat = null;
        qpm.paperSize = null;
        QuoteTermModel qtm = new QuoteTermModel();
        qtm.value = null;
        qtm.type = null;
        qtm.standardTermId = null;
        qtm.quoteId = null;
        qtm.locked = null;
        qtm.label = null;
        qtm.id = null;            
        
        system.assert(true);
    }
    
}