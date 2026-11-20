public without sharing class PSS_listViewController {

    @AuraEnabled
    public static Map<String, Object> listValues(String objectInfo) {
        Boolean isAdmin = PMP_Utility.isLoggedInUserAdmin();
        List<String> listViewSet = getListViewSet(objectInfo, isAdmin);
        List<ListView> listviewforobj = fetchListViews(objectInfo, listViewSet);

        List<ListViewWrapper> oListViewWrapper = createListViewWrappers(listviewforobj);

        return buildResponseMap(oListViewWrapper, isAdmin);
    }

    private static List<String> getListViewSet(String objectInfo, Boolean isAdmin) {
        List<String> listViewSet = new List<String>();

        switch on objectInfo {
            /*when 'ArdiraSurvey__Survey_Result__c' {//IPA2.0: US-TWC729-7976
                if (isAdmin) {
                    listViewSet.addAll(PSS_StaticConstants.ADMIN_REVIEW_LISTVIEW);
                } else {
                    listViewSet.add(PSS_StaticConstants.ALL_LISTVIEW);
                }
            }*/
            /*when 'PMP_Partner_offering__c' {//IPA 2.0 OFFERING EOL
                listViewSet.addAll(isAdmin ? PSS_StaticConstants.ADMIN_REVIEW_LISTVIEW_OFFERING : PSS_StaticConstants.PARTNER_OFFERING_LISTVIEW);
            }*/
            when 'PMP_Company__c' {
                if (isAdmin) {
                    listViewSet.addAll(PSS_StaticConstants.PARTNER_LISTVIEW);
                }
            }
        }
        return listViewSet;
    }

    private static List<ListView> fetchListViews(String objectInfo, List<String> listViewSet) {
        List<ListView> listviewforobj = new List<ListView>();
        
        if (listViewSet != null && !listViewSet.isEmpty()) {
            listviewforobj = [SELECT Id, Name, DeveloperName FROM ListView WHERE sObjectType = :objectInfo AND DeveloperName IN :listViewSet];
            List<ListView> newlistviewforobj = new List<ListView>(listviewforobj);
            for (Integer i = 0; i < listviewforobj.size(); i++) {
                Integer index = listViewSet.indexOf(listviewforobj[i].DeveloperName);
                newlistviewforobj[index] = listviewforobj[i];
            }
            listviewforobj = newlistviewforobj;
        } else {
            listviewforobj = [SELECT Id, Name, DeveloperName FROM ListView WHERE sObjectType = :objectInfo];
        }

        return listviewforobj;
    }

    private static List<ListViewWrapper> createListViewWrappers(List<ListView> listviewforobj) {
        List<ListViewWrapper> oListViewWrapper = new List<ListViewWrapper>();
        for (ListView lv : listviewforobj) {
            ListViewWrapper oWrapper = new ListViewWrapper();
            oWrapper.label = lv.Name;
            oWrapper.developerName = lv.DeveloperName;
            oListViewWrapper.add(oWrapper);
        }
        return oListViewWrapper;
    }

    private static Map<String, Object> buildResponseMap(List<ListViewWrapper> oListViewWrapper, Boolean isAdmin) {
        Map<String, Object> responseMap = new Map<String, Object>();
        responseMap.put('listViewWrapper', oListViewWrapper);
        responseMap.put('isAdmin', isAdmin);
        return responseMap;
    }

    public class ListViewWrapper {
        @AuraEnabled public String label {get; set;}
        @AuraEnabled public String developerName {get; set;}
    }
}