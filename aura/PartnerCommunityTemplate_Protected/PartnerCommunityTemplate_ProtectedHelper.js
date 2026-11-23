({
    redirectUserToTnCPage: function (component) {
        debugger;
        var action = component.get("c.redirect");
        console.log('window.location.href--',window.location.href);
        action.setParams({
            "siteUrl": window.location.href
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if (response.getReturnValue() == 'true') {
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": "/customerdisclaimer"
                    });
                    // let result = urlEvent.fire();
                    // console.log('resulttt', result);
                    // window.location.reload();
                    // let promiseEvent = this.promisesForNavEvent(urlEvent);
                    // Promise.allSettled([promiseEvent]).then($A.getCallback(function () {
                    //         setTimeout(() => {
                    //             console.log('window.location.href', window.location.href);
                    //             if(window.location.href.includes('/customerdisclaimer')) {
                    //                 window.location.reload(true);
                    //             }
                    //         }, 0)
                    // }));
                    urlEvent.fire();
                    this.pageReload('/customerdisclaimer');
                }
                else if (response.getReturnValue() == '') {
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": "/errorpage"
                    });
                    urlEvent.fire();
                    this.pageReload('/errorpage');
                }
            }
            else {
                var errors = response.getError();
                console.log('line number 44');
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        var urlEvent = $A.get("e.force:navigateToURL");
                        urlEvent.setParams({
                            "url": "/errorpage"
                        });
                        urlEvent.fire();
                        this.pageReload('/errorpage');
                    }
                }

            }
        });
        $A.enqueueAction(action);
    },

    pageReload: function (url) {
        setTimeout(() => {
            console.log('window.location.href', window.location.href);
            if(window.location.href.includes(url)) {
                window.location.reload(true);
            }
        }, $A.get("$Label.c.Core_MDF_CommunityPageReload_Timer"))
    },

    promisesForNavEvent: function (urlEvent) {
        return new Promise($A.getCallback(function (resolve, reject) {
            resolve(urlEvent.fire());
        }));
    }
})