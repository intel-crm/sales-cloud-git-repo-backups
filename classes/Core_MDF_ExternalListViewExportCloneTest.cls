@isTest (SeeAllData= true)
public class Core_MDF_ExternalListViewExportCloneTest {
@isTest
    public static void testListView(){
        User usr = [SELECT Id from user Where id='0052i0000033sO3'];
        System.runAs(usr){
            Core_MDF_ExternalListViewExportClone.listViewFilter('00BD3000001r4yDMAQ','Account');
        }
    }
}