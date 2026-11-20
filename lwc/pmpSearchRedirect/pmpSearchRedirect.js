/**
 * This component will be embeded in the MP 1.0 community search page
 * and will be used to redirect the users to the right 2.0 pages as the 1.0 search page is EOLd.
 * Contextual filters are not considered for redirection, as the logic for selection of filters has changed in 2.0.
 * 
*/

import { LightningElement } from 'lwc';
import { dispatch, getState, subscribe } from 'c/ipaRedux';
import { NavigationMixin } from 'lightning/navigation';

export default class PmpSearchRedirect extends NavigationMixin(LightningElement) {
    renderedCallback() {
        //fetch url parameter
        var match = window.location.href.split('?')[1], params = {}, searchParams = {}; 
       // console.log('url--' ,decodeURIComponent(match)); // to do: remove this log
        try {
            if(match.indexOf('&')!=-1 || match.indexOf('=')!=-1){
                match = match.split('&');
                var urlParams = {};
                //console.log('afterSpliturl--' ,searchParams);            
                    match.forEach(function(m) {
                    m = m.replace(/\+/g, " ");	
                    urlParams[m.split('=')[0]] = decodeURIComponent(m.split('=')[1] || '');
                    
                });
                
                if (urlParams.search) {	
                    searchParams = JSON.parse(urlParams.search);
                    var selfilters = {};
                    selfilters = searchParams.selectedFilters;

                   /* Scenario 1 : Search URL contains the category id and search type is product.
                    redirect the user to the 2.0 category detail page. */
                    if(searchParams.cat && searchParams.type == 'product'){
                        this.redirectToRecordPage('PMP_Category__c', searchParams.cat);
                    }
                    /* Scenario 2 : Search URL contains the partner id and search type is partner.
                    redirect the user to the 2.0 partner detail page. */
                    else if(searchParams.cat && searchParams.type == 'partner'){
                        this.redirectToRecordPage('PMP_Company__c', searchParams.cat);
                    }

                    /* Scenario 3 : CategoryId/PartnerId is null--> this means that user has landed on 
                    the search page by clicking on View all Offerings or View all Partners etc.
                    In this sceanrio, redirection happens to the Partner Specialty detail page 
                    Only if the URL is having "Specialty_Partner" key and only one value is present for the key.
                    If key is having more than one value, Redirect partners by specialty page. */
                    else if(!searchParams.cat && searchParams.type == 'partner'
                        && searchParams.selectedFilters && searchParams.selectedFilters.Specialty_Partner){
                            if(searchParams.selectedFilters.Specialty_Partner.length == 1){
                                this.redirectToRecordPage('PMP_Partner_Specialty__c', searchParams.selectedFilters.Specialty_Partner[0]);
                            }
                            else{
                                this.redirectToCommunityPage('Partners_by_Specialty__c');
                            }
                    }
                    /* Scenario 4 : CategoryId/PartnerId is null--> this means that user has landed on 
                    search page by clicking on "Learn More" button in events section of the Home Page.
                    In this sceanrio, redirection happens to the Event detail page 
                    Only if the URL is having "Marketplace_Event" key and only one value is present for the key.
                    If key is having more than one value, Redirect partners by specialty page. */
                    else if(!searchParams.cat && searchParams.selectedFilters
                         && searchParams.selectedFilters.Marketplace_Event){
                            if(searchParams.selectedFilters.Marketplace_Event.length == 1){
                                this.redirectToRecordPage('PMP_Marketplace_Event__c', searchParams.selectedFilters.Marketplace_Event[0]);

                            }
                            else{
                                this.redirectToCommunityPage('Home');
                            }
                    
                    }
                    /*
                    If none of the scenarios are matching, redirect to default Home page.                    
                    */
                    else{
                        this.redirectToCommunityPage('Home');
                    }
                                        
                }
                /*
                If no parameters redirect to Home Page(Anonymous User).                    
                */
                else{
                    this.redirectToCommunityPage('Home');
                } 
            } 
                /*
                If no parameters redirect to Home Page.                    
                */
               else{
                    this.redirectToCommunityPage('Home');
                }
            
        } 
        catch(e) {
            console.error('Search Params incorrect JSON format.', e);
        }
    }
    redirectToRecordPage(objectApi, redcorId){
        this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
                recordId: redcorId,
                objectApiName: objectApi,
                actionName: "view"
            }
        });
    }
    redirectToCommunityPage(pageName){
        this[NavigationMixin.Navigate]({
            type: "comm__namedPage",
            attributes: {
                name: pageName
            }
        });
    }
}