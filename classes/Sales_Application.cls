/**
 * Main application factory class which is responsible for returning the correct business implementation for the unit
 * of work, service, selector and domain layers within the application.
 *
 * NOTE: Please add values to selector and service in ALPHABETICAL order, to prevent duplicates
 * Values for unitOfWork have to to be in execution order
 *
 * @author      
 * @date        July 2021
 */
public without sharing class Sales_Application {

    public static final fflib_Application.SelectorFactory selector = new fflib_Application.SelectorFactory(
        new Map<SObjectType, Type> {
                Account.SObjectType                             => SEL_Account.class,
                Contract.SObjectType                            => SEL_Contract.class,
                core_cpq_list_price__c.SObjectType              => SEL_core_cpq_list_price.class,
                Core_Account_SoldTo_ShipTo_Rel__c.SObjectType   => SEL_Core_Account_SoldTo_ShipTo_Rel.class,
                Order.SObjectType                               => SEL_Order.class,
                OrderItem.SObjectType                           => SEL_OrderItem.class,
                Pricebook2.SObjectType                          => SEL_Pricebook2.class,
                PricebookEntry.SObjectType                      => SEL_PricebookEntry.class,
                //SBQQ__Quote__c.SObjectType                      => SEL_Quote.class,
                //SBQQ__QuoteLine__c.SObjectType                  => SEL_QuoteLines.class,
                Sales_License__c.SObjectType                    => SEL_Sales_License.class,
                Sales_License_Control__c.SObjectType            => SEL_Sales_License_Control.class,
                Sales_License_Order_Product__c.SObjectType      => SEL_Sales_License_Order_Product.class
                //User.SObjectType                                => SEL_User.class
        }
    );


    public static final fflib_Application.ServiceFactory service = new fflib_Application.ServiceFactory(
        new Map<Type, Type> {
            /*SRV_ActionFailureHandler.IService.class       =>  SRV_ActionFailureHandler.class*/
        }
    );
    
    public static final fflib_Application.DomainFactory Domain = new fflib_Application.DomainFactory(
        Sales_Application.Selector, new Map<SObjectType, Type> {
            Account.SObjectType => Accounts.Constructor.class,
            Contact.SObjectType => Contacts.Constructor.class
            //Opportunity.SObjectType => DMN_Opportunities.Constructor.class,
        }
    );

    public static final List<SObjectType> unitOfWorkRegisteredTypes = new List<SObjectType> {
        Order.sObjectType
    };
        
    public static final fflib_Application.UnitOfWorkFactory unitOfWork = new fflib_Application.UnitOfWorkFactory(
        unitOfWorkRegisteredTypes
    );

}