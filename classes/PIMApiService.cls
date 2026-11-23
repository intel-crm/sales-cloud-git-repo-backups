/***************************************************************************************************************************
 * Apex Class Name: PIMApiService
 * Author And Date: Rohit Podder, 25 MAY 2026
 * Function: Handles all PIM API HTTP callouts
 *          (Single Responsibility: Only responsible for making HTTP calls to PIM API)
 ****************************************************************************************************************************/
public class PIMApiService {

    public HttpResponse getHierarchyCategories(Integer offset, Integer limitValue) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:PIM_Api/pim/v1/services/hierarchies?localeGeoId=en-US&hierarchyName=VPH_Hierarchy&offset=' + offset + '&limit=' + limitValue);
        req.setMethod('GET');
        req.setTimeout(120000);
        Http http = new Http();
        return http.send(req);
    }

    public HttpResponse getHierarchyLevels(String l1Product, Integer recordLimit, Integer offset, String productType) {
        String todayDate = Label.PIM_Api_EndDate != 'Null'? Label.PIM_Api_EndDate : String.valueOf(Date.today());
        String yesterdayDate = Label.PIM_Api_StartDate != 'Null'? Label.PIM_Api_StartDate : String.valueOf(Date.today().addDays(-1));
        System.debug(todayDate+' '+yesterdayDate);
        //System.debug('today'+todayDate+' '+'yesterday'+yesterdayDate);
        HttpRequest req = new HttpRequest();
        if (productType == 'VPH') {
            req.setEndpoint('callout:PIM_Api/pim/v1/services/hierarchyLevels?hierarchyName=VPH_Hierarchy&offset=' + offset + '&limit=' + recordLimit + '&l1id=' + l1Product + '&modifiedDateFrom=' + yesterdayDate + '&modifiedDateTo=' + todayDate + '&includeInactive=true');
        } else if (productType == 'VPLCH') {
            req.setEndpoint('callout:PIM_Api/pim/v1/services/hierarchyLevels?limit=' + recordLimit + '&offset=' + offset + '+&hierarchyName=VPLCH_Hierarchy&modifiedDateFrom=' + yesterdayDate + '&modifiedDateTo=' + todayDate + '&includeInactive=true');
        }
        req.setMethod('GET');
        req.setTimeout(120000);
        Http http = new Http();
        return http.send(req);
    }
}