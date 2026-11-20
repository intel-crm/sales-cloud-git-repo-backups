/**************************************************************************************
Trigger  Name:  Core_AccountTeamMember
Version     : 1.0 
Created Date: 28 FEB 2020
Function    : Trigger for the object AccountTeamMember
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Gopala Krishna            02/28/2020              Original version 
*************************************************************************************/

trigger Core_AccountTeamMember on AccountTeamMember (After insert,After Update,After delete) {

 
        new Core_AccountTeamMemberHandler().run();
   
}