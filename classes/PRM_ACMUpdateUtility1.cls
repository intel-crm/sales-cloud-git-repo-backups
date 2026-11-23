/*********************************************************************************************************************
Class Name    : PRM_ACMUpdateUtility
Version       : 1.0
Created Date  : July, 2021
Function      : Update Account channel membership at OPID OR Account wihout OPID based on IPA Membership

Modification Log :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------
* Dinesh Mengade            July, 2021              This class will update ACM and assign benefits based on new Partner role and tier
-----------------------------
NOTE - This class will work for Account which has only one ACM(Account Channel Membership)      
SOQL Consumed - 6 -PRM_IPA_Membership__c, ChannelProgramLevel, PRM_AccountChannelMembership__c, PRM_Account_Contact_Relationship__c, PRM_VXBnftMatrix__c, PRM_AccountBenefitAssociation__c
-----------------------------
*********************************************************************************************************************/

public with sharing class PRM_ACMUpdateUtility1{//implements Database.Batchable<SObject>,Database.Stateful
    
}