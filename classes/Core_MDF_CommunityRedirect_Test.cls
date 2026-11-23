/****************************************************************************************************************************************
* Class Name  : Core_MDF_CommunityRedirect_Test
* Version     : 1.0 
* Created Date: 30-Jul-2020
* Modification Log :
* Developer                        Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture-Ameya          30/Jul/2020                    Created to test community redirection functionality
*****************************************************************************************************************************************/
@isTest
public class Core_MDF_CommunityRedirect_Test {
    /* Method to test current session */
    @isTest
    public static void testCurrentSession(){
        try {
            test.startTest();            
            System.runAs(new user(ID = UserInfo.getUserID())){
                String sessionTypeValue = Core_MDF_CommunityRedirectController.getCurrentSession();
                System.assertEquals(null,sessionTypeValue);
            }
            
            test.stopTest();
        }catch (Exception e){
            String errorMessage = e.getMessage(); //in prod file 
            System.debug(e.getMessage());  
        }
    }
}