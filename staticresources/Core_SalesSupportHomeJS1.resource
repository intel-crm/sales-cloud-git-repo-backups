function setFocusOnLoad() {};

function newRequest(requestTypeElementId, sOpportunityId, sOpportunityName, sAccountId, sOrderSeedsURL, sRequestSamplesURL,UserRegion,UIthemedisplayed, sRegURL, sWarningError, sPremierSupportURL, sWebQuoteURL) {
    
    requestType = document.getElementById(requestTypeElementId).value;
    
    var popupUrl = '';
    if (requestType == 'Order Seed') {
        popupUrl = sOrderSeedsURL;
    }
    else if (requestType == 'Premier Support (IPS)') {
        var redirectUrl = sPremierSupportURL+sOpportunityId;
        window.location = redirectUrl;
        
    }
        else if (requestType == 'Request Sample') {
            popupUrl = sRequestSamplesURL;
        }
    // Rangesh - SMG-DRD Integration Changes - Start
            else if(requestType == 'CreateSSR') {
                processSSGRequest();
            }
    // Rangesh - SMG-DRD Integration Changes - End
                else if (requestType == 'IT@Intel') {
                    console.log('Region'+UserRegion);
                    var objectPrefix = 'a0s';
                    var recordTypeId = '012o0000000pEji';
                    var opportunityNameFieldId = '00No000000CnaeH';
                    
                    //US116483-to auto populate User Region 
                    console.log('UIthemedisplayed'+UIthemedisplayed);
                    if(UIthemedisplayed=='Theme3' && sOpportunityName != '' ){
                        
                        var redirectUrl1 = '/' + objectPrefix + '/e?retURL=%2F' + objectPrefix + '%2Fo&RecordType=' + recordTypeId;
                        
                        
                        redirectUrl = redirectUrl1 + '&CF' + opportunityNameFieldId + '=' + encodeURIComponent(sOpportunityName) + '&CF' + opportunityNameFieldId + '_lkid=' + sOpportunityId +'&' + '00No000000CnaeD=' + UserRegion;
                        
                        window.location = redirectUrl;
                    }
                    if(UIthemedisplayed=='Theme3' && sOpportunityName == '' ){
                        
                        var redirectUrl1 = '/' + objectPrefix + '/e?retURL=%2F' + objectPrefix + '%2Fo&RecordType=' + recordTypeId + '&' + '00No000000CnaeD=' + UserRegion;
                        
                        
                        window.location = redirectUrl1;
                    }
                    
                    if(UIthemedisplayed !='Theme3' && sOpportunityName == '' ){        
                        sforce.one.createRecord('Core_Sales_Support_Request__c',recordTypeId,{ 
                            Core_IT_Intel_Geo__c : UserRegion
                        });
                        
                    }
                    if(UIthemedisplayed !='Theme3' && sOpportunityName != '' ){
                        
                        sforce.one.createRecord('Core_Sales_Support_Request__c',recordTypeId,{ 
                            Core_IT_Intel_Geo__c : UserRegion,
                            Core_Opportunity__c : sOpportunityId
                        });
                        
                    }
                    
                    
                }
    //Intel Altera Phase1:
    //Code added on 12-5-2016.On click of Create PSG Quote as request type and click on Continue button will call the action function
                    else if(requestType == 'Create PSG Quote') { 
                        processOpportuntyQuote();
                    }
                        else if(requestType == 'Create WebQuote') { 
                            var redirectWebQuoteUrl = sWebQuoteURL+sOpportunityId;
                            popupUrl = redirectWebQuoteUrl;
                        }
    
    if (popupUrl != '') {
        openSalesSupportPopup(popupUrl);
    }
}

function openSalesSupportPopup(url) {
    var newWin=window.open(url, 'Popup');
    if (window.focus) {
        newWin.focus();
    }
}

function isIE() {
    var ua = window.navigator.userAgent;
    var msie = ua.indexOf("MSIE ");
    return (msie > -1 || !!navigator.userAgent.match(/Trident.*rv\:11\./));
}

function runOnEnter(ev, sSeedsSamples) 
{ 
    if (window.event && window.event.keyCode == 13 || ev.which == 13) { 
        if (sSeedsSamples == 'Seeds')
            applySeedsFilters();
        else if (sSeedsSamples == 'Samples')
            applySamplesFilters();
        return false; 
    } 
    else { 
        return true; 
    } 
}

function clickTab(tabName, tableId, messagesId) {
    
    setTabCookie(tabName);
    //Intel Altera Phase1:
    //Below code modified to perform the load data to PSG Quote too.
    // Rangesh - SMG-DRD Integration - added tabName condition to preserve user selection in cookie
    if ((tabName == 'tabSeeds') || (tabName == 'tabSamples') || (tabName == 'tabPSGQuote') || (tabName == 'tabDRDSSR') || (tabName == 'tabWebquotes') ) {
        if (document.getElementById(tableId) && document.getElementById(tableId).childNodes[2] &&
            (document.getElementById(tableId).childNodes[2].childNodes.length > 0)) {
            
            ; // If there's already a table on the page, don't re-pull the data
        }
        else if (document.getElementById(messagesId) && document.getElementById(messagesId).childNodes[0]) {
            ; // If there's already a page message being displayed, don't try to re-pull data
            
        }
            else {
                
                if (tabName == 'tabSeeds')
                    pullSeeds();
                else if (tabName == 'tabSamples')
                    pullSamples();
                    else if(tabName == 'tabPSGQuote') {
                        pullPSGQuote();
                    }
                        else if(tabName == 'tabWebquotes') {
                            pullWebQuotes();
                        }
                
            }
    }
}

function setTabCookie(tabName) {
    var d = new Date();
    d.setTime(d.getTime() + (365*24*60*60*1000));
    document.cookie = "apex__lastSalesSupportTab=" + tabName +
        "; expires=" + d.toGMTString() +
        "; path=/apex";
}