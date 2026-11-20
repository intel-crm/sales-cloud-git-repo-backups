@isTest
public class Core_AccountLayoutController_test{
  @IsTest
  public static void displayAccountPreviewSectionTest(){
    Test.startTest();
    Core_AccountLayoutController.displayAccountPreviewSection();
    Core_AccountLayoutController.getFieldPermissions('Account');
    Test.stopTest();
  }
}