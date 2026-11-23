public class Contact_IPA_Integration_StatusHandler implements Queueable {
    List<sObject> sObjectList = null;
    SObjectType objType = null;
    static List<String> configPartnerRoles = null;
    public Contact_IPA_Integration_StatusHandler(List<sObject> sObjects, SObjectType sObjectType){
        configPartnerRoles = Label.PRM_AGSIdentityCreation_PartnerRoles.split(',');
        system.debug('configPartnerRoles : '+configPartnerRoles);
        sObjectList  = (List<sObject>)Type.forName('List<' + sObjectType + '>').newInstance();
        sObjectList.addAll(sObjects);
        //TODO:: REVISIT ::
        objType = sObjectType;
        system.debug('sObjectList : '+sObjectList);
    }
    
    public void execute(QueueableContext context) { 
        System.debug('Inside execute : '+context);
         if( sObjectList instanceof List<PRM_AccountBenefitAssociation__c>) {
            system.debug('PRM_AccountBenefitAssociation__c inside execute : '+sObjectList);         
          PRM_SalesCloudAccountIntStatus_Handler.setAccountIPAIntegrationStatusToPending((List<PRM_AccountBenefitAssociation__c>)sObjectList);
        } 
    }
    
}