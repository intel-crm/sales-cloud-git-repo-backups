/**
 * @description       : Creating IQR class for maping from SObject type to Selector class
 * @author            : Rakshitha BR
 * @group             : Gravity
 * @last modified on  : 03-28-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class Pricing_IQR_Application {
	public static final fflib_Application.SelectorFactory selector = new fflib_Application.SelectorFactory(
		new Map<SObjectType, Type> {
            	Document.SObjectType							=> Pricing_DocumentSelector.class,
                Pricing_Comments__c.SObjectType					=> Pricing_Comments_Selector.class,
                Pricing_Document__c.SObjectType					=> Pricing_Document_Selector.class, 
                Pricing_Dynamic_Data_Table__mdt.SObjectType		=> Pricing_Dynamic_Data_Table_Selector.class, 
                Pricing_IQR_Email_Preferences__c.SObjectType	=> Pricing_IQR_Email_Preferences_Selector.class,
                Pricing_Performance_Metric__c.SObjectType		=> Pricing_Performance_Metric_Selector.class,
                PermissionSetAssignment.SObjectType 			=> Pricing_PermissionSetAssignment_Selector.class, //SEL_PermissionSetAssignments
                ProcessInstanceWorkitem.SObjectType     		=> Pricing_ProcessInstanceWorkitem_Selector.class,
                Product2.SObjectType     						=> Pricing_Product_Selector.class,
                Pricing_Quote_Line_Status_Age__c.SObjectType	=> Pricing_Quote_Line_Status_Age_Selector.class,
                Pricing_Quote_Team__c.SObjectType				=> Pricing_Quote_Team_Selector.class,
                Pricing_QuoteLine_WonLoss_Restriction__mdt.SObjectType => Pricing_QLIWonLossRestriction_Selector.class,
                SBQQ__QuoteLine__c.SObjectType 					=> Pricing_QuoteLines_Selector.class, //SEL_QuoteLines
                ContentDocumentLink.SObjectType         		=> Pricing_ContentDocumentLink_Selector.class,
                SBQQ__Quote__c.SObjectType              		=> Pricing_Quote_Selector.class,
                User.SObjectType                        		=> Pricing_User_Selector.class
		}
	);

    public static final fflib_Application.ServiceFactory service = new fflib_Application.ServiceFactory(
        new Map<Type, Type> {
			/*SRV_ActionFailureHandler.IService.class		=>	SRV_ActionFailureHandler.class*/
        }
    );
    
    public static final fflib_Application.DomainFactory Domain = new fflib_Application.DomainFactory(
        Pricing_IQR_Application.Selector, new Map<SObjectType, Type> {
            	Pricing_Comments__c.SObjectType => Pricing_Comments_Const.Constructor.class,
                Pricing_Document__c.SObjectType => Pricing_Document_Const.Constructor.class,
                Pricing_Performance_Metric__c.SObjectType => Pricing_Performance_Metric_Const.Constructor.class,
                SBQQ__Quote__c.SObjectType => Pricing_Quote_Const.Constructor.class,
                Pricing_Quote_Line_Status_Age__c.SObjectType => Pricing_Quote_Line_Status_Age_Const.Constructor.class,
                SBQQ__QuoteLine__c.SObjectType => Pricing_QuoteLines_Const.Constructor.class,
                Pricing_Quote_Team__c.SObjectType => Pricing_Quote_Team_Const.Constructor.class
        }
    );

	public static final List<SObjectType> unitOfWorkRegisteredTypes = new List<SObjectType> {
        Account.SObjectType,
        Contact.SObjectType,
        Pricing_IQR_Email_Preferences__c.SObjectType,    
        SBQQ__Quote__c.SObjectType,
        Pricing_Document__c.SObjectType,
        Pricing_Quote_Team__c.SObjectType,    
		SBQQ__QuoteLine__c.SObjectType,
        Pricing_Quote_Line_Status_Age__c.SObjectType,
        Pricing_Performance_Metric__c.SObjectType,    
        Pricing_Comments__c.SObjectType
	};
        
    public static final fflib_Application.UnitOfWorkFactory unitOfWork = new fflib_Application.UnitOfWorkFactory(
		unitOfWorkRegisteredTypes
    );
}