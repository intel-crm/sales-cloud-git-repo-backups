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
public without sharing class Application {

    public static final fflib_Application.SelectorFactory selector = new fflib_Application.SelectorFactory(
        new Map<SObjectType, Type> {
                Account.SObjectType                     => SEL_Account.class,
                core_cpq_dpa_aln_line__c.SObjectType    => DPALine_selector.class, //SEL_DPALines
                OrderItem.SObjectType                   => Sales_Selectors.class //SEL_OrderItems
                //PermissionSetAssignment.SObjectType     => SEL_PermissionSetAssignment.class, //SEL_PermissionSetAssignments
                //SBQQ__QuoteLine__c.SObjectType          => SEL_QuoteLines.class //SEL_QuoteLines
        }
    );


    public static final fflib_Application.ServiceFactory service = new fflib_Application.ServiceFactory(
        new Map<Type, Type> {
            /*SRV_ActionFailureHandler.IService.class       =>  SRV_ActionFailureHandler.class*/
        }
    );
    
    public static final fflib_Application.DomainFactory Domain = new fflib_Application.DomainFactory(
        Application.Selector, new Map<SObjectType, Type> {
            Account.SObjectType => Accounts.Constructor.class,
            Contact.SObjectType => Contacts.Constructor.class
            //Opportunity.SObjectType => DMN_Opportunities.Constructor.class,
        }
    );

    public static final List<SObjectType> unitOfWorkRegisteredTypes = new List<SObjectType> {
        Account.SObjectType,
        Contact.SObjectType,
        SBQQ__Quote__c.SObjectType,
        SBQQ__QuoteLine__c.SObjectType
    };
        
    public static final fflib_Application.UnitOfWorkFactory unitOfWork = new fflib_Application.UnitOfWorkFactory(
        unitOfWorkRegisteredTypes
    );

}