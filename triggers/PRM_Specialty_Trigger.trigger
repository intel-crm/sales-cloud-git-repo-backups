/****************************************************************************************************************************
Apex Class Name     : PRM_Specialty_Trigger 
Version             : 1.0
Created Date        : 09 Jan 2020

Modification Log    :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------------
* Teja Munagala      09-Jan-2020                   Added to restrict Name change and Inative Specialty check

****************************************************************************************************************************/
trigger PRM_Specialty_Trigger on PRM_Specialty__c (before update) {
	new PRM_Specialty_Handler().run();
}